# Domo WEB: imagen privada

Este repositorio es el catalogo publico del add-on. No contiene la aplicacion PHP
ni credenciales. Home Assistant descarga la imagen privada ya construida:
`ghcr.io/carferrer/domotica-php-cfm:2026.11.12`.

Se conserva el slug `domo-web-cfm`, la URL de este repositorio, el puerto interno
460, los montajes addon_config y ssl y las opciones existentes. Actualizar el
add-on instalado; no desinstalarlo ni añadir otro repositorio para la migracion.

## Antes de actualizar

1. Crear una copia de seguridad del add-on y conservar una instantanea o respaldo
   del sistema. Guardar la version instalada anterior.
2. En HA, Tienda de complementos > menu > Registros, configurar ghcr.io con el
   usuario autorizado y un token clasico de GitHub con read:packages. El token se
   introduce solo en HA; nunca en este repositorio. Docker login en un PC o en
   Portainer no configura las credenciales de Supervisor.
3. Comprobar que `/config/conf/configuracion_privada.php` contiene la configuracion
   real, `_ejemplo => false`, las claves de conexion y OTP existentes y las listas
   `ips_mssql_api`, `ips_unifi_api` e `ips_guzzle`. No regenerar la clave OTP.
   No publicar este archivo ni copiar valores privados a incidencias.
4. Revisar los .htaccess antiguos de esas tres carpetas: las reglas adicionales
   personalizadas deben incorporarse al generador privado antes de actualizar.
5. Mantener `conf`, `logs` y `html` en el almacenamiento del add-on. No borrar
   el PHP anterior: permite recuperar el funcionamiento previo con el respaldo.

La version 2026.11.12 figura en breaking_versions para exigir actualizacion manual.

## Actualizar y comprobar

1. Refrescar las actualizaciones de la tienda sin cambiar la URL del repositorio.
2. Comprobar que Domo WEB ofrece 2026.11.12 y actualizar el add-on existente.
3. Iniciar y revisar sus registros: la configuracion y las reglas deben prepararse
   antes de que Apache abra el puerto.
4. Probar login, OTP, cierre de sesion, una consulta web, MSSQL API, UniFi y un
   Atajo del iPhone habitual. Probar los comandos fisicos solo cuando sea seguro
   hacerlo. Esta version no incorpora Ingress.

El PHP se ejecuta desde `/opt/domo/html`, incluido en la imagen. El PHP de
`/config/html` se conserva, pero ya no se sirve. Las actualizaciones de codigo
se distribuyen mediante una nueva imagen, no copiando PHP al antiguo html.

## Configuracion y datos persistentes

- `/config/conf/configuracion_privada.php`: configuracion privada existente.
- `/config/conf/sesiones-web`: sesiones.
- `/config/conf/php.ini`: opcional; sustituye el predeterminado incluido en
  `/opt/domo/php/php.ini`. Editarlo y reiniciar no requiere reconstruir la imagen.
- `/config/logs`: registros.
- `/config/html/unifi_api/*.xml`: exportaciones UniFi persistentes.
- `/ssl`: certificados, con las mismas opciones que antes.

Cada arranque genera los .htaccess de mssql_api, unifi_api y GuzzleHttp desde las
listas privadas y los instala dentro de la imagen. Una lista vacia deniega todo;
una lista ausente o invalida impide arrancar. Los .htaccess antiguos de esas
carpetas se conservan como respaldo y no se usan. El .htaccess raiz opcional
sigue copiandose; la proteccion de OtpWeb sigue incluida en la imagen.

## Si falla la descarga o el arranque

- Unauthorized/denied: revisar el registro ghcr.io, el permiso read:packages y
  la caducidad del token en HA. No hacer publico el paquete.
- Configuracion o IP invalidas: corregir la configuracion privada y reiniciar.
- Si es necesario volver atras: detener el add-on y restaurar su backup anterior
  desde HA. Si ese backup no permite recuperar la imagen anterior, restaurar la
  instantanea completa conservada. No desinstalar ni borrar carpetas para probar.
  No actualizar otra vez a 2026.11.12 hasta resolver la causa.

## Mantenimiento del catalogo

Dockerfile, run.sh, rootfs y los flujos de construccion/publicacion estan en el
repositorio privado. Se retiraron de este catalogo; siguen en su historial Git.
Primero construir, probar y publicar una version privada. Despues cambiar
`version` en config.yaml y documentarla en CHANGELOG.md mediante un PR.
Supervisor usa `version` como etiqueta de la imagen; no utiliza `image_tag`.

La CI publica solo valida el catalogo: no descarga, construye ni publica PHP
y no necesita tokens de paquetes.

Referencias:
- [Configuracion del add-on](https://contributors.home-assistant.io/apps/reference/configuration/)
- [Registros de Supervisor](https://contributors.home-assistant.io/apps/supervisor-api/host/#post-dockerregistries)
