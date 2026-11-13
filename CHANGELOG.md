# Versión 2026.11.13.7 (2026-11-13)

- Actualiza la imagen privada, publicada y validada para amd64 y aarch64.
- Revisar las notas funcionales antes de fusionar este PR.
- La fusion del catalogo y la actualizacion en Home Assistant siguen siendo manuales.

# Versión 2026.11.13.6 (2026-11-13)

- Actualiza la imagen privada, publicada y validada para amd64 y aarch64.
- Revisar las notas funcionales antes de fusionar este PR.
- La fusion del catalogo y la actualizacion en Home Assistant siguen siendo manuales.

# Versión 2026.11.13.5 (2026-11-13)

- Actualiza la imagen privada, publicada y validada para amd64 y aarch64.
- Revisar las notas funcionales antes de fusionar este PR.
- La fusion del catalogo y la actualizacion en Home Assistant siguen siendo manuales.

# Versión 2026.11.13.4 (2026-11-13)

- Actualiza la imagen privada, publicada y validada para amd64 y aarch64.
- Revisar las notas funcionales antes de fusionar este PR.
- La fusion del catalogo y la actualizacion en Home Assistant siguen siendo manuales.

# Versión 2026.11.13.3 (2026-11-13)

- Actualiza la imagen privada, publicada y validada para amd64 y aarch64.
- Revisar las notas funcionales antes de fusionar este PR.
- La fusion del catalogo y la actualizacion en Home Assistant siguen siendo manuales.

# Versión 2026.11.13.2 (2026-11-13)

- Acceso automatico opcional por Ingress mediante vinculacion explicita de usuario HA con usuario MSSQL.
- Desactivado por defecto: configurar ingress_usuarios solo en el fichero privado.
- Conserva permisos SQL, CSRF y autenticacion con contrasena/OTP por HTTPS directo.
- Explica el cierre de sesion por Ingress y reserva la gestion OTP al acceso HTTPS habitual.
- Imagen privada publicada y validada para amd64 y aarch64; sin cambios en las API.

# Versión 2026.11.13.1 (2026-11-13)

- Corrige el regreso a la pagina de origen tras enviar comandos por Ingress.
- Los formularios conservan sus filtros y su destino por pestana sin depender de Referer.
- Mantiene la validacion de destinos locales y la proteccion CSRF.
- Recargar las paginas abiertas despues de actualizar para usar los formularios nuevos.
- Imagen privada validada y publicada para amd64 y aarch64; sin cambios en las API.

# Versión 2026.11.13 (2026-11-13)

- Corrige el bloqueo de la pantalla OTP dentro del panel Ingress de Home Assistant.
- Aplica la correccion tambien a la configuracion OTP, conservando la proteccion del acceso HTTPS directo.
- Imagen privada validada y publicada para amd64 y aarch64.
- No requiere cambios en la configuracion privada ni en la base de datos.

# Versión 2026.11.12.1 (2026-11-12)

- Activa Ingress con panel Domotica para administradores de Home Assistant.
- Mantiene el acceso HTTPS directo y las API existentes.
- Conserva login, OTP y CSRF; sesiones y cookies separadas para cada entrada.
- Requiere abrir Home Assistant por HTTPS para conservar las cookies seguras.
- Imagen privada publicada y validada en amd64 y aarch64 antes de actualizar el catalogo.
- Consultar DOCS.md para actualizar y probar ambos accesos.

# Versión 2026.11.12 (2026-11-12)

- Migracion manual a la imagen privada con PHP integrado.
- Se conservan identificador, puertos, carpetas y opciones del add-on.
- Requiere credenciales GHCR de lectura y configuracion privada existente.
- Generacion automatica de reglas IP al arrancar; php.ini personalizado opcional.
- El repositorio publico pasa a ser solo catalogo; se retiran builds y arranque antiguos.
- Consultar DOCS.md antes de actualizar. Ingress queda pendiente.

# Versión 2026.10.01 (2026-10-21)

## What's Changed
* Seguridad: bloquear builds con PHP vulnerable (USN-8948-1) by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/21


**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.09.07...2026.10.01

# Versión 2026.09.07 (2026-09-21)

## What's Changed
* fix: compatibilizar envvars de Apache con Bashio by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/19


**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.09.06...2026.09.07

# Versión 2026.09.06 (2026-09-21)

## What's Changed
* chore: añadir Renovate by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/14
* ⬆️ Pin actions/checkout action to 3d3c42e by @renovate[bot] in https://github.com/carferrer/domo-web-cfm/pull/15
* fix: usar la zona horaria de Home Assistant by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/17

## New Contributors
* @renovate[bot] made their first contribution in https://github.com/carferrer/domo-web-cfm/pull/15

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.09.05...2026.09.06

# Versión 2026.09.05 (2026-09-19)

## What's Changed
* ci: evitar repetir CI tras merge en main by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/10
* refactor: ejecutar Apache bajo s6-overlay by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/11
* chore: preparar release 2026.09.04 by @github-actions[bot] in https://github.com/carferrer/domo-web-cfm/pull/12


**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.09.03...2026.09.05

# Versión 2026.09.04 (2026-09-19)

## What's Changed
* ci: evitar repetir CI tras merge en main by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/10
* refactor: ejecutar Apache bajo s6-overlay by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/11


**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.09.03...2026.09.04

# Versión 2026.09.03 (2026-09-19)

## What's Changed
* fix: desactivar init del Supervisor con s6-overlay by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/8


**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.09.02...2026.09.03

# Versión 2026.09.02 (2026-09-19)

## What's Changed
* fix: aplicar permisos genéricos al contenido web by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/6


**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.09.01...2026.09.02

# Versión 2026.09.01 (2026-09-19)

## What's Changed
* ci: añadir validación automática del add-on by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/1
* build: usar imagen base oficial de Home Assistant by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/2
* fix: robustecer run.sh y permisos de unifi_api by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/3
* ci: añadir flujo preparar/publicar release by @carferrer in https://github.com/carferrer/domo-web-cfm/pull/4

## New Contributors
* @carferrer made their first contribution in https://github.com/carferrer/domo-web-cfm/pull/1

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.35...2026.09.01

# Versión 2026.08.35 (2026-08-18)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.34...2026.08.35

# Versión 2026.08.34 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.33...2026.08.34

# Versión 2026.08.33 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.32...2026.08.33

# Versión 2026.08.32 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.31...2026.08.32

# Versión 2026.08.31 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.30...2026.08.31

# Versión 2026.08.30 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.29...2026.08.30

# Versión 2026.08.29 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.28...2026.08.29

# Versión 2026.08.28 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.27...2026.08.28

# Versión 2026.08.27 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.26...2026.08.27

# Versión 2026.08.26 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.25...2026.08.26

# Versión 2026.08.25 (2026-08-16)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.24...2026.08.25

# Versión 2026.08.24 (2026-08-15)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/compare/2026.08.23...2026.08.24

# Versión 2026.08.23 (2026-08-15)

**Full Changelog**: https://github.com/carferrer/domo-web-cfm/commits/2026.08.23

