#!/bin/bash

echo "Iniciando configuración dinámica del Add-on..."

# 1. Leer las variables de Home Assistant (si vienen vacías, asigna un backup)
#PUERTO hace referencia el puerto que mapea HA ya que el del docker dejo siempre 460
#$OPTIONS_FILE se declara en el dockerfile
SSL_CERT=$(jq --raw-output '.ssl_cert' $OPTIONS_FILE)
SSL_KEY=$(jq --raw-output '.ssl_key' $OPTIONS_FILE)
URL=$(jq --raw-output '.url' $OPTIONS_FILE)

# --- NUEVO: Leer el nivel de log seleccionado en la interfaz de Home Assistant ---
HA_LOG_LEVEL=$(jq --raw-output '.log_level // "warning"' $OPTIONS_FILE)
echo "Nivel de log detectado desde la UI de Home Assistant: $HA_LOG_LEVEL"

# Mapear niveles de Home Assistant al formato estricto de Apache
APACHE_LOG_LEVEL="warn"
case "$HA_LOG_LEVEL" in
  "critical"|"fatal") APACHE_LOG_LEVEL="crit" ;;
  "error")            APACHE_LOG_LEVEL="error" ;;
  "warning")          APACHE_LOG_LEVEL="warn" ;;
  "notice")           APACHE_LOG_LEVEL="notice" ;;
  "info")             APACHE_LOG_LEVEL="info" ;;
  "debug"|"trace")    APACHE_LOG_LEVEL="debug" ;;
esac
# ---------------------------------------------------------------------------------

CERT_NAME=${SSL_CERT:-fullchain.pem}
KEY_NAME=${SSL_KEY:-privkey.pem}

echo "Configurando Apache para usar el puerto interno: 460. Si ha ha mapeado ver UI del addon el HA"
echo "Buscando certificado: $CERT_NAME"
echo "Buscando llave privada: $KEY_NAME"

# 2. Vincular directorio de desarrollo PHP en /config. Dentro de HA en app_config
SHARE_DIR="/config"
if [ ! -d "$SHARE_DIR" ]; then
    echo "Creando la carpeta del proyecto en /config..."
    mkdir -p "$SHARE_DIR"
    echo "<?php phpinfo(); ?>" > "$SHARE_DIR/index.php"
fi
rm -rf /var/www/html
ln -s "$SHARE_DIR" /var/www/html

# Asegurar que la carpeta de logs existe en /config para que rotatelogs no falle
mkdir -p /var/www/html/logs

# 3. Reescribir el archivo ports.conf desde cero para evitar duplicados 👇
echo "Listen 460" > /etc/apache2/ports.conf

# 4. Comprobar certificados SSL personalizados de Home Assistant
CERT_FILE="$CERT_NAME"
KEY_FILE="$KEY_NAME"

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

# 5. Generar VirtualHost apuntando estrictamente al puerto 460 interno
# MODIFICADO: Se añade LogLevel dinámico, CustomLog duplicado y ErrorLog duplicado rotativo
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

    # Configuración del nivel de Log dinámico
    LogLevel REPL_APACHE_LOG_LEVEL

    # Una sola línea para accesos: Guarda en disco (rotativo) y lo envía a la consola de HA sin duplicar en HA
    CustomLog "|/usr/bin/tee -a /dev/stdout | /usr/bin/rotatelogs -n 15 /var/www/html/logs/access_log 86400" combined
    

    # Una sola línea para errores: Guarda en disco (rotativo) y lo envía a la pantalla de fallos de HA sin duplicar en HA
    ErrorLog "|/usr/bin/tee -a /dev/stderr | /usr/bin/rotatelogs -n 15 /var/www/html/logs/error_log 86400"
    
    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/server.crt
    SSLCertificateKeyFile /etc/apache2/ssl/server.key
    
</VirtualHost>
EOF

# 6. Reemplazar las rutas, URL y el nivel de Log de forma segura dentro del archivo final
sed -i "s|/etc/apache2/ssl/server.crt|$CERT_FILE|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|/etc/apache2/ssl/server.key|$KEY_FILE|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|server.server.com:460|$URL|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|REPL_APACHE_LOG_LEVEL|$APACHE_LOG_LEVEL|g" /etc/apache2/sites-available/000-default.conf

# 7. Cargar variables de entorno obligatorias de Apache en Ubuntu antes de lanzar el binario
. /etc/apache2/envvars

echo "Iniciando Apache de forma segura..."
# Cambiado a 'apache2' directo para asegurar que las variables previas se hereden correctamente en primer plano
exec apache2 -DFOREGROUND
