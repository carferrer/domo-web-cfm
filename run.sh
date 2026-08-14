#!/bin/bash

echo "Iniciando configuración del Add-on..."

# 1. Definir la ruta en /share donde pondrás tus archivos PHP
SHARE_DIR="/addon_config/mi_proyecto_php"

# 2. Si la carpeta no existe en /share, la creamos y añadimos un index.php de prueba
if [ ! -d "$SHARE_DIR" ]; then
    echo "Creando la carpeta del proyecto en /addon_config/mi_proyecto_php..."
    mkdir -p "$SHARE_DIR"
    echo "<?php phpinfo(); ?>" > "$SHARE_DIR/index.php"
fi

# 3. Limpiar el directorio por defecto de Apache
rm -rf /var/www/html

# 4. Crear un enlace simbólico para que Apache apunte directamente a /share
ln -s "$SHARE_DIR" /var/www/html

echo "Enlaces configurados. Iniciando Apache en el puerto 460..."

# 5. Ejecutar Apache en primer plano (reemplaza el CMD del Dockerfile)
exec apachectl -D FOREGROUND
