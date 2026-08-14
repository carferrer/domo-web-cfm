FROM ubuntu:24.04

# 1. Declarar el argumento para eliminar el warning "UndefinedVar"
ARG BUILD_VERSION=local

# Etiquetas solicitadas para Home Assistant
LABEL io.hass.version="${BUILD_VERSION}" \
      io.hass.type="addon" \
      io.hass.arch="aarch64|amd64"

ENV DEBIAN_FRONTEND=noninteractive
ENV ACCEPT_EULA=Y

# 2. Instalación corregida y con URL de repositorio limpia
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    curl \
    gnupg \
    ca-certificates \
    lsb-release \
    unixodbc-dev \
    php8.3 \
    libapache2-mod-php8.3 \
    php8.3-dev \
    php8.3-xml \
    php8.3-odbc \
    php8.3-curl \
    php-pear \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && UBUNTU_VERSION=$(lsb_release -rs) \
    && echo "deb [signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://microsoft.com{UBUNTU_VERSION}/prod noble main" > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    msodbcsql18 \
    mssql-tools18 \
    && pecl install sqlsrv pdo_sqlsrv \
    && printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.3/mods-available/sqlsrv.ini \
    && printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.3/mods-available/pdo_sqlsrv.ini \
    && phpenmod sqlsrv pdo_sqlsrv \
    && apt-get purge -y --auto-remove php8.3-dev php-pear unixodbc-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV PATH="$PATH:/opt/mssql-tools18/bin"

EXPOSE 470

CMD ["apachectl", "-D", "FOREGROUND"]
