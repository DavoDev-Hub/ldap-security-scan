#!/bin/bash
# Corre Nuclei contra un servicio del docker-compose de este repo.
#
# Truco del "bridge" que mencionó el profe: en vez de pegarle al puerto
# publicado al host (que puede no estar expuesto o chocar con otros stacks),
# el contenedor de Nuclei se conecta con --network container:<id>, es decir,
# comparte el namespace de red del contenedor objetivo. Así Nuclei ve el
# servicio como "localhost:<puerto interno>" sin necesitar saber el nombre
# de la red de docker-compose ni que el puerto esté publicado.
#
# Uso:
#   ./security-scan/run-nuclei.sh [servicio] [puerto_interno]
#
# Por defecto escanea el servicio "api" (ldap-api / FastAPI) en el puerto
# 8000. También puedes escanear los otros servicios HTTP de este repo:
#   ./run-nuclei.sh phpldapadmin 80
#   ./run-nuclei.sh keycloak 8080
set -e
cd "$(dirname "$0")/.."

SERVICE="${1:-api}"
PORT="${2:-8000}"
OUT_DIR="security-scan/results"
OUT_FILE="${OUT_DIR}/nuclei-${SERVICE}.txt"

mkdir -p "$OUT_DIR"

CID=$(docker compose ps -q "$SERVICE")
if [ -z "$CID" ]; then
  echo "ERROR: el servicio '$SERVICE' no está corriendo."
  echo "Levanta el stack primero con: docker compose up -d --build"
  exit 1
fi

echo ">>> Escaneando servicio '$SERVICE' (puerto interno $PORT) con Nuclei..."
docker run --rm \
  --network "container:${CID}" \
  -v "$(pwd)/${OUT_DIR}:/results" \
  projectdiscovery/nuclei:latest \
  -target "http://localhost:${PORT}" \
  -o "/results/nuclei-${SERVICE}.txt"

echo ">>> Resultado guardado en ${OUT_FILE}"
