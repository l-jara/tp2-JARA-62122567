#!/bin/bash

# ==========================================================
# Script: chequear_paginas.sh
# Descripción: Comprueba códigos HTTP con colores y genera log
# ==========================================================

LEGAJO="6212"
ARCHIVO_DEFAULT="../sitios_${LEGAJO}.txt"
LOG_FILE="../logs/chequeo_${LEGAJO}.log"

# Códigos de color ANSI para la terminal
VERDE="\e[32m"
AMARILLO="\e[33m"
ROJO="\e[31m"
RESET="\e[0m"

# Crear directorio de logs si no existe
mkdir -p "../logs"

# Limpiar o inicializar el log
echo "=== Reporte de Disponibilidad Web ($(date '+%Y-%m-%d %H:%M:%S')) ===" > "$LOG_FILE"

# Determinar lista de URLs: argumentos o archivo
urls=()
if [ $# -gt 0 ]; then
    urls=("$@")
else
    if [ ! -f "$ARCHIVO_DEFAULT" ]; then
        echo "Error: No se indicaron URLs y no existe el archivo $ARCHIVO_DEFAULT" >&2
        exit 1
    fi
    # Leer el archivo línea por línea omitiendo vacías
    while IFS= read -r linea || [ -n "$linea" ]; do
        [ -n "$linea" ] && urls+=("$linea")
    done < "$ARCHIVO_DEFAULT"
fi

# Procesar cada URL
for url in "${urls[@]}"; do
    # Obtener únicamente el código de estado HTTP con curl
    codigo=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url")

    # Si curl falla por red o DNS devuelve 000
    if [ "$codigo" = "000" ]; then
        color="$ROJO"
        estado="Error de Conexión"
    elif [ "$codigo" -eq 200 ]; then
        color="$VERDE"
        estado="OK"
    elif [ "$codigo" -ge 300 ] && [ "$codigo" -lt 400 ]; then
        color="$AMARILLO"
        estado="Redirección"
    elif [ "$codigo" -ge 400 ] && [ "$codigo" -lt 600 ]; then
        color="$ROJO"
        estado="Error"
    else
        color="$RESET"
        estado="Desconocido"
    fi

    # Mostrar con color en consola
    echo -e "${color}[$codigo] $url ($estado)${RESET}"

    # Guardar en el log en texto plano
    echo "[$codigo] $url ($estado)" >> "$LOG_FILE"
done

echo ""
echo "Reporte guardado en: $LOG_FILE"
exit 0
