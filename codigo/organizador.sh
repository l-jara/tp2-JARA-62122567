#!/bin/bash

# ==========================================================
# Script: organizador.sh
# Descripción: Clasifica archivos por extensión y renombra .old
# ==========================================================

# 1. Validar que se reciba un argumento y que sea un directorio existente
if [ $# -ne 1 ] || [ ! -d "$1" ]; then
    echo "Error: Debe indicar un directorio válido y existente." >&2
    echo "Uso: $0 <directorio_destino>" >&2
    exit 1
fi

DEST="$1"

# 2. Crear las carpetas de clasificación dentro del destino
mkdir -p "$DEST/imagenes" "$DEST/documentos" "$DEST/comprimidos" "$DEST/otros"

# 3. Recorrer los archivos que están en el directorio destino (sin entrar a las subcarpetas)
for archivo in "$DEST"/*; do
    # Evitar procesar directorios
    [ -f "$archivo" ] || continue

    nombre=$(basename "$archivo")

    # Renombrar archivos .old a .backup usando sustitución de variables
    if [[ "$archivo" == *.old ]]; then
        nuevo_nombre="${archivo%.old}.backup"
        mv "$archivo" "$nuevo_nombre"
        archivo="$nuevo_nombre"
        nombre=$(basename "$archivo")
    fi

    # Clasificar y mover según extensión
    case "$nombre" in
        *.jpg|*.png)
            mv "$archivo" "$DEST/imagenes/"
            ;;
        *.pdf|*.txt|*.docx)
            mv "$archivo" "$DEST/documentos/"
            ;;
        *.zip|*.tar.gz|*.rar)
            mv "$DEST/comprimidos/" 2>/dev/null || mv "$archivo" "$DEST/comprimidos/"
            ;;
        *)
            mv "$archivo" "$DEST/otros/"
            ;;
    esac
done

echo "Organización completada exitosamente en: $DEST"
exit 0
