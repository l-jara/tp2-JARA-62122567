#!/bin/bash

# ==========================================================
# Script: backup_manager.sh
# Descripción: Respaldo seguro con prevención de colisiones (lockfile)
# ==========================================================

LEGAJO="6212"
LOCK_DIR="/tmp/backup_${LEGAJO}.lock"
TMP_BACKUP="/tmp/backup_${LEGAJO}"
LOGS_DIR="../logs"
FECHA=$(date '+%Y%m%d_%H%M%S')
TARBALL_NAME="backup_${LEGAJO}_${FECHA}.tar.gz"

# 1. Mecanismo de bloqueo (creación atómica con mkdir)
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    echo "Error: El script de respaldo ya se encuentra en ejecución." >&2
    exit 9
fi

# 2. Asegurar la limpieza del bloqueo al salir
trap 'rm -rf "$TMP_BACKUP"; rmdir "$LOCK_DIR" 2>/dev/null' EXIT

echo "Iniciando proceso de respaldo..."

# 3. Preparar directorios de trabajo
mkdir -p "$TMP_BACKUP"
mkdir -p "$LOGS_DIR"

# 4. Buscar archivos modificados en las últimas 24 horas en el directorio actual
archivos_encontrados=0
while IFS= read -r archivo; do
    if [ -f "$archivo" ]; then
        cp "$archivo" "$TMP_BACKUP/"
        archivos_encontrados=$((archivos_encontrados + 1))
    fi
done < <(find . -maxdepth 1 -type f -mtime -1)

# Si ningún archivo coincidió por mtime, respaldamos los scripts existentes
if [ "$archivos_encontrados" -eq 0 ]; then
    cp ./*.sh "$TMP_BACKUP/" 2>/dev/null
fi

# 5. Empaquetar y comprimir en logs/
tar -czf "${LOGS_DIR}/${TARBALL_NAME}" -C "$TMP_BACKUP" .

echo "Respaldo completado exitosamente: ${LOGS_DIR}/${TARBALL_NAME}"
exit 0
