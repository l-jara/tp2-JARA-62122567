#!/bin/bash

# ==========================================================
# Script: pdf_version.sh
# Descripción: Busca PDFs y extrae su versión omitiendo filtros
# ==========================================================

# Iniciales del alumno para el filtro
INICIALES="LJ"

# Buscar archivos .pdf en el directorio actual y subdirectorios
find . -type f -name "*.pdf" | while read -r archivo; do
    nombre_archivo=$(basename "$archivo")

    # Filtrar si contiene 'excluir' o las iniciales (ignorando mayúsculas/minúsculas)
    nombre_min=$(echo "$nombre_archivo" | tr '[:upper:]' '[:lower:]')
    iniciales_min=$(echo "$INICIALES" | tr '[:upper:]' '[:lower:]')

    if [[ "$nombre_min" == *"excluir"* ]] || [[ "$nombre_min" == *"$iniciales_min"* ]]; then
        continue
    fi

    # Extraer la primera línea del archivo PDF
    primera_linea=$(head -n 1 "$archivo" 2>/dev/null)

    # Validar formato %PDF-1.X y extraer versión
    if [[ "$primera_linea" =~ %PDF-([0-9]+\.[0-9]+) ]]; then
        version="${BASH_REMATCH[1]}"
        echo "Archivo: [$nombre_archivo] - Versión PDF: [$version]"
    fi
done

exit 0
