FROM ubuntu:24.04

# Declarar el argumento para eliminar el warning de variable indefinida
ARG BUILD_VERSION=local

# Etiquetas obligatorias para el Add-on de Home Assistant
LABEL io.hass.version="${BUILD_VERSION}" \
      io.hass.type="addon" \
      io.hass.arch="aarch64|amd64"

# Forzar la instalación desatendida en el entorno
ENV DEBIAN_FRONTEND=noninteractive
ENV ACCEPT_EULA=Y

# PASO 1: Instalar dependencias base del sistema y PHP 8.3
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    curl \
    gnupg \
    ca-certificates \
    lsb-release \
    build-essential \
    make \
    unixodbc-dev \
    php8.3 \
    libapache2-mod-php8.3 \
    php8.3-dev \
    php8.3-xml \
    php8.3-odbc \
    php8.3-curl \
    php-pear \
    && rm -rf /var/lib/apt/lists/*

# PASO 2: Registrar las llaves y el repositorio oficial de Microsoft para Ubuntu 24.04
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/24.04/prod noble main" > /etc/apt/sources.list.d/mssql-release.list

# PASO 3: Pre-aceptar la licencia EULA en la base de datos interna de APT (Esto soluciona el Exit Code 100)
RUN apt-get update \
    && echo "msodbcsql18 msodbcsql/ACCEPT_EULA boolean true" | debconf-set-selections \
    && echo "mssql-tools18 mssql-tools/ACCEPT_EULA boolean true" | debconf-set-selections \
    && apt-get install -y --no-install-recommends msodbcsql18 mssql-tools18 \
    && rm -rf /var/lib/apt/lists/*

# PASO 4: Compilar extensiones de SQL Server mediante PECL
RUN pecl install sqlsrv pdo_sqlsrv \
    && printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.3/mods-available/sqlsrv.ini \
    && printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.3/mods-available/pdo_sqlsrv.ini \
    && phpenmod sqlsrv pdo_sqlsrv

# PASO 5: Limpieza profunda de paquetes de compilación para reducir espacio
RUN apt-get purge -y --auto-remove build-essential make php8.3-dev php-pear unixodbc-dev \
    && apt-get clean

# Configurar ruta de ejecución de las herramientas SQL de Microsoft
ENV PATH="$PATH:/opt/mssql-tools18/bin"

# Cambiar el puerto por defecto de Apache al 460
RUN sed -i 's/Listen 80/Listen 460/g' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:460>/g' /etc/apache2/sites-available/000-default.conf

# Copiar el script de inicio al contenedor
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 460

# Ejecutar el script al iniciar el contenedor
CMD [ "/run.sh" ]
