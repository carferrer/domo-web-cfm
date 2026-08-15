#!/bin/bash

echo "Iniciando configuración dinámica del Add-on..."

# 1. Leer las variables de Home Assistant (si vienen vacías, asigna un backup)
#PUERTO hace referencia el puerto que mapea HA ya que el del docker dejo siempre 460
PUERTO=$(jq --raw-output '.puerto' $OPTIONS_FILE)
SSL_CERT=$(jq --raw-output '.ssl_cert' $OPTIONS_FILE)
SSL_KEY=$(jq --raw-output '.ssl_key' $OPTIONS_FILE)
URL=$(jq --raw-output '.url' $OPTIONS_FILE)


HTTP_PORT=${PUERTO:-460}
CERT_NAME=${SSL_CERT:-fullchain.pem}
KEY_NAME=${SSL_KEY:-privkey.pem}



echo "El usuario configuró el valor: $VALOR_INTERFAZ"

echo "Configurando Apache para usar el puerto interno: 460 (Mapeado externamente al: $HTTP_PORT)"
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

	CustomLog "|/usr/bin/rotatelogs -f /var/www/html/logs/access_log.%Y-%m-%d 86400 30 15" combined

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/server.crt
    SSLCertificateKeyFile /etc/apache2/ssl/server.key
    
</VirtualHost>
EOF

# 6. Reemplazar las rutas de los certificados de forma segura dentro del archivo final
sed -i "s|/etc/apache2/ssl/server.crt|$CERT_FILE|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|/etc/apache2/ssl/server.key|$KEY_FILE|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|server.server.com:460|$URL|g" /etc/apache2/sites-available/000-default.conf

echo "Iniciando Apache de forma segura..."
exec apachectl -D FOREGROUND
