#!/bin/bash

echo "Iniciando configuración dinámica del Add-on..."

# 1. Leer las variables de Home Assistant (si vienen vacías, asigna un backup)
HTTP_PORT=${puerto:-460}
CERT_NAME=${SSL_CERT:-fullchain.pem}
KEY_NAME=${SSL_KEY:-privkey.pem}


VALOR_INTERFAZ=$(bashio::config 'puerto')

echo "El usuario configuró el valor: $VALOR_INTERFAZ"

echo "Configurando Apache para usar el puerto interno: 460 (Mapeado externamente al: $HTTP_PORT)"
echo "Buscando certificado: $CERT_NAME"
echo "Buscando llave privada: $KEY_NAME"

# 2. Vincular directorio de desarrollo PHP en /share
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
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/server.crt
    SSLCertificateKeyFile /etc/apache2/ssl/server.key

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# 6. Reemplazar las rutas de los certificados de forma segura dentro del archivo final
sed -i "s|/etc/apache2/ssl/server.crt|$CERT_FILE|g" /etc/apache2/sites-available/000-default.conf
sed -i "s|/etc/apache2/ssl/server.key|$KEY_FILE|g" /etc/apache2/sites-available/000-default.conf

echo "Iniciando Apache de forma segura..."
exec apachectl -D FOREGROUND
