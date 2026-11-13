# Domo WEB: imagen privada

Este repositorio es el catalogo publico del add-on. No contiene la aplicacion PHP
ni credenciales. Home Assistant descarga la imagen privada ya construida:
`ghcr.io/carferrer/domotica-php-cfm:2026.11.13.1`.

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
2. Comprobar que Domo WEB ofrece 2026.11.13.1 y actualizar el add-on existente.
3. Iniciar y revisar sus registros: la configuracion y las reglas deben prepararse
   antes de que Apache abra el puerto.
4. Probar login, OTP, cierre de sesion, una consulta web, MSSQL API, UniFi y un
   Atajo del iPhone habitual. Probar los comandos fisicos solo cuando sea seguro
   hacerlo. Comprobar tambien el acceso Ingress descrito abajo.

El PHP se ejecuta desde `/opt/domo/html`, incluido en la imagen. El PHP de
`/config/html` se conserva, pero ya no se sirve. Las actualizaciones de codigo
se distribuyen mediante una nueva imagen, no copiando PHP al antiguo html.

## Acceso Ingress y HTTPS directo

La version 2026.11.13.1 corrige el regreso al inicio despues de enviar comandos
por Ingress. Los formularios conservan la pagina de origen y sus filtros, tambien
con varias pestanas abiertas. Despues de actualizar, recargar las paginas abiertas
para recibir los formularios nuevos. Probar un comando desde Luces (con filtro),
otra pantalla y el acceso HTTPS habitual.

La version 2026.11.13 corrige el rechazo de conexion al llegar a la pantalla OTP
por Ingress. Actualizar el complemento existente; no es necesario cambiar la
configuracion privada ni volver a configurar OTP. Las pantallas OTP permiten
el panel del mismo origen solo por Ingress; el acceso directo conserva el bloqueo
de incrustacion en otras paginas.

Desde la version 2026.11.12.1, **Abrir interfaz web** muestra la aplicacion dentro
de Home Assistant. Se puede activar **Mostrar en la barra lateral** en el
complemento; el panel Domotica se limita a administradores de Home Assistant.

Abrir Home Assistant por **HTTPS**: las cookies de la aplicacion siguen siendo
Secure y no funcionan si se abre HA por HTTP. Esta primera fase sigue solicitando
usuario, contrasena y OTP de la aplicacion; todavia no hay inicio automatico con
la identidad de Home Assistant.

La URL HTTPS habitual del add-on y el puerto externo configurado siguen
disponibles. Ingress usa el puerto interno 8099, accesible solamente desde el
Supervisor; no publicarlo en la red ni en el router. No hay que cambiar las
opciones, los certificados, la configuracion privada o la base de datos.

Las sesiones y el navegador recordado son independientes entre ambos accesos.
Cerrar sesion en Ingress no cierra la sesion HTTPS directa. Las API MSSQL, UniFi
y Atajos conservan su acceso directo; no se sirven a traves de Ingress.

Tras actualizar:

1. Abrir HA por HTTPS y pulsar Abrir interfaz web; comprobar login y OTP.
2. Navegar entre paginas y comprobar estilos, imagenes, botones y regreso al inicio.
3. Probar un formulario y un comando controlado; deben permanecer dentro del panel.
4. Probar desconectar, recordar navegador y el acceso por la URL HTTPS habitual.
5. Comprobar un Atajo del iPhone y las actualizaciones habituales de MSSQL/UniFi.

Si la sesion vuelve a pedir acceso inmediatamente, comprobar primero que la URL
de Home Assistant empieza por HTTPS. Si Ingress falla, el acceso HTTPS directo
sigue disponible para diagnosticar; revisar tambien los registros del complemento.
El registro de acceso Ingress esta en /config/logs/ingress_access_log y no incluye
URLs, cabeceras ni cookies.

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
  No repetir la actualizacion hasta resolver la causa.

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
