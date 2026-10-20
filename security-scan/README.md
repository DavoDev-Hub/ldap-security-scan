# Análisis de seguridad con Nuclei — LDAP / ldap-api

## Cómo correrlo

1. Levanta el stack (si no está corriendo):
   ```sh
   docker compose up -d --build
   ```
2. Corre el escaneo contra el API (el servicio HTTP custom de este repo):
   ```sh
   ./security-scan/run-nuclei.sh
   ```
   (por defecto apunta al servicio `api`, puerto 8000 — FastAPI)

   Opcionalmente, también se puede escanear el resto de las interfaces HTTP
   de este repo (phpLDAPadmin y la consola de Keycloak), que corren software
   de terceros y pueden tener hallazgos propios:
   ```sh
   ./security-scan/run-nuclei.sh phpldapadmin 80
   ./security-scan/run-nuclei.sh keycloak 8080
   ```

El contenedor de Nuclei se conecta con `--network container:<id del contenedor>`,
compartiendo el namespace de red del contenedor objetivo directamente. Así no
depende de que el puerto esté publicado al host ni de adivinar el nombre de
la red de `docker-compose` — es el "bridge" entre Nuclei y lo que se está
analizando.

3. Los resultados quedan en `security-scan/results/nuclei-<servicio>.txt`.

Nota: LDAP/LDAPS (puertos 389/636) no son HTTP, así que Nuclei no los
escanea directamente — esos puertos ya están cubiertos por la protección de
`ldap-guard` (ver la raíz del repo), no por este análisis.

## Flujo de entrega

1. Correr el escaneo (al menos contra `api`) y guardar los resultados en
   esta carpeta.
2. `git add security-scan/ && git commit -m "Agrega resultados de análisis Nuclei" && git push`.
3. Revisar cada hallazgo:
   - Si es de complejidad alta y el profesor indica que no se debe
     implementar, se deja documentado aquí (con la razón) y no se toca.
   - El resto se corrige **uno por uno**, con un commit independiente por
     cada corrección.

## Notas

- Si el escaneo no encuentra nada, igual se documenta aquí como evidencia
  de que se corrió.
