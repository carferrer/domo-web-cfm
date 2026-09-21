#!/usr/bin/with-contenv bashio
# CAMBIO: Bashio usa un shebang propio de Home Assistant que ShellCheck no reconoce.
# Se indica explícitamente que el script usa sintaxis Bash para que la validación CI sea correcta.
# shellcheck shell=bash

# CAMBIO: Mantener el arranque simple, pero documentar y validar mejor las opciones dinámicas.
echo "Iniciando configuración dinámica del Add-on..."

# CAMBIO: Obtener la zona horaria configurada en Home Assistant/Supervisor.
# /info es accesible para los add-ons con el rol por defecto y no requiere hassio_api: true.
TIMEZONE="$(bashio::api.supervisor 'GET' '/info' '' '.timezone' 2>/dev/null || true)"

if [ -n "$TIMEZONE" ] && [ -f "/usr/share/zoneinfo/$TIMEZONE" ]; then
    ln -snf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
    export TZ="$TIMEZONE"
    echo "Zona horaria configurada desde Home Assistant: $TIMEZONE"
else
    echo "AVISO: No se pudo obtener una zona horaria válida de Home Assistant. Se mantiene la zona horaria del contenedor."
fi

# CAMBIO: Garantizar una ruta por defecto al fichero de opciones de Home Assistant.
OPTIONS_FILE=${OPTIONS_FILE:-/data/options.json}

# CAMBIO: Convertir valores JSON null en cadena vacía para que funcionen los valores por defecto.
SSL_CERT=$(jq -r '.ssl_cert // empty' "$OPTIONS_FILE")
SSL_KEY=$(jq -r '.ssl_key // empty' "$OPTIONS_FILE")
URL=$(jq -r '.url // empty' "$OPTIONS_FILE")
HA_LOG_LEVEL=$(jq -r '.log_level // "warning"' "$OPTIONS_FILE")

echo "Nivel de log detectado desde la UI de Home Assistant: $HA_LOG_LEVEL"

# Mapear niveles de Home Assistant al formato estricto de Apache.
APACHE_LOG_LEVEL="warn"
case "$HA_LOG_LEVEL" in
  "critical"|"fatal") APACHE_LOG_LEVEL="crit" ;;
  "error")            APACHE_LOG_LEVEL="error" ;;
  "warning")          APACHE_LOG_LEVEL="warn" ;;
  "notice")           APACHE_LOG_LEVEL="notice" ;;
  "info")             APACHE_LOG_LEVEL="info" ;;
  "debug"|"trace")    APACHE_LOG_LEVEL="debug" ;;
esac

# CAMBIO: Aplicar nombres de certificado por defecto cuando no se hayan configurado en HA.
CERT_NAME=${SSL_CERT:-fullchain.pem}
KEY_NAME=${SSL_KEY:-privkey.pem}

# CAMBIO: Usar localhost si la opción URL está vacía para evitar un ServerName inválido.
SERVER_NAME=${URL:-localhost}

echo "Configurando Apache para usar el puerto interno: 460."
echo "Buscando certificado: $CERT_NAME"
echo "Buscando llave privada: $KEY_NAME"

# CAMBIO: Crear explícitamente la estructura persistente utilizada por Apache/PHP.
SHARE_DIR="/config"
mkdir -p \
    "$SHARE_DIR/html" \
    "$SHARE_DIR/html/unifi_api" \
    "$SHARE_DIR/logs" \
    "$SHARE_DIR/conf"

# CAMBIO: Mantener /var/www/html como enlace directo al almacenamiento persistente del add-on.
rm -rf /var/www/html
ln -s "$SHARE_DIR" /var/www/html

# CAMBIO: Hacer que todo el contenido web sea propiedad de www-data para que el add-on
# funcione con cualquier estructura PHP y no dependa de carpetas concretas como unifi_api.
# Los directorios usan 775 y los archivos 664 para permitir lectura/escritura a Apache/PHP
# sin volver a los permisos globales 777 utilizados anteriormente.
chown -R www-data:www-data /var/www/html/html
find /var/www/html/html -type d -exec chmod 775 {} \;
find /var/www/html/html -type f -exec chmod 664 {} \;

# Asegurar que la carpeta de logs existe para que rotatelogs no falle.
mkdir -p /var/www/html/logs

# Reescribir ports.conf desde cero para evitar directivas Listen duplicadas.
echo "Listen 460" > /etc/apache2/ports.conf

# CAMBIO: Los certificados configurados por Home Assistant están montados en /ssl.
CERT_FILE="/ssl/$CERT_NAME"
KEY_FILE="/ssl/$KEY_NAME"

if [ -f "$CERT_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo "Certificados personalizados encontrados y validados."
else
    echo "No se encontraron los certificados especificados. Creando certificados de prueba..."
    mkdir -p /etc/apache2/ssl
    CERT_FILE="/etc/apache2/ssl/server.crt"
    KEY_FILE="/etc/apache2/ssl/server.key"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY_FILE" -out "$CERT_FILE" \
        -subj "/C=ES/ST=Local/L=HomeAssistant/O=ApacheAddon/CN=localhost"
fi

# Redirigir el directorio de logs global de Apache a la carpeta persistente del add-on.
echo "Redirigiendo el directorio de logs global de Apache..."
mkdir -p /var/www/html/logs
sed -i 's|export APACHE_LOG_DIR=.*|export APACHE_LOG_DIR=/var/www/html/logs|g' /etc/apache2/envvars

# Generar VirtualHost apuntando estrictamente al puerto interno 460.
cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:460>
    DocumentRoot /var/www/html/html
    ServerName server.server.com:460
    PHPINIDir /var/www/html/conf

    <Directory "/var/www/html/html">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Configuración del nivel de Log dinámico.
    LogLevel REPL_APACHE_LOG_LEVEL

    # El acceso sólo va al archivo de disco.
    CustomLog "|/usr/bin/rotatelogs -n 15 /var/www/html/logs/access_log 86400" combined

    # Se mantiene temporalmente el sistema de ErrorLog actual; se revisará en un PR independiente.
    ErrorLog "|/usr/bin/rotatelogs -n 15 /var/www/html/logs/error_log 86400"
    ErrorLog "|/usr/bin/tee -a /dev/stderr"

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/server.crt
    SSLCertificateKeyFile /etc/apache2/ssl/server.key

</VirtualHost>
EOF

# CAMBIO: Sustituir certificados, ServerName y nivel de log con los valores ya validados anteriormente.
sed -i "s|/etc/apache2/ssl/server.crt|$CERT_FILE|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|/etc/apache2/ssl/server.key|$KEY_FILE|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|server.server.com:460|$SERVER_NAME|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|REPL_APACHE_LOG_LEVEL|$APACHE_LOG_LEVEL|g" /etc/apache2/sites-available/000-default.conf

# CAMBIO: Bashio activa el control estricto de variables no definidas (nounset), mientras que
# /etc/apache2/envvars de Ubuntu/Debian espera que APACHE_CONFDIR haya sido inicializada por apache2ctl.
# Como este script carga envvars directamente, definimos explícitamente la ruta estándar de Apache.
export APACHE_CONFDIR="${APACHE_CONFDIR:-/etc/apache2}"

# CAMBIO: El fichero envvars pertenece al paquete de Apache y no está diseñado para ejecutarse
# con nounset activo. Se desactiva únicamente durante su carga y se reactiva inmediatamente después.
# Esto evita errores "unbound variable" sin reducir el control estricto en el resto de run.sh.
set +u
. /etc/apache2/envvars
set -u

# CAMBIO: Validar la configuración generada antes de iniciar Apache para fallar con un error claro.
echo "Validando configuración de Apache..."
if ! apache2ctl configtest; then
    echo "ERROR: La configuración de Apache no es válida."
    exit 1
fi

echo "Configuración de Apache correcta."
echo "Iniciando Apache de forma segura..."

# Ejecutar Apache en primer plano para que Home Assistant supervise correctamente el proceso principal.
exec apache2 -DFOREGROUND
