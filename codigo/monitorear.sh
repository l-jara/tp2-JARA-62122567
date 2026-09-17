#!/bin/bash

# ==========================================================
# Script: monitorear.sh
# Descripción: Panel interactivo de monitoreo de recursos
# ==========================================================

PS3="Seleccione una opción (1-4): "

opciones=(
    "Monitorear memoria RAM"
    "Buscar archivos grandes (>10MB en HOME)"
    "Espacio en particiones montadas"
    "Salir"
)

echo "=========================================================="
echo "         PANEL DE MONITOREO DE RECURSOS - CURZAS"
echo "=========================================================="

select opt in "${opciones[@]}"; do
    case $REPLY in
        1)
            echo ""
            echo "--- Estado de Memoria RAM (en MB) ---"
            free -m | awk 'NR==1 {print "Tipo\tTotal\tUsada\tLibre"} NR==2 {print "RAM\t" $2 "\t" $3 "\t" $4}'
            echo ""
            ;;
        2)
            echo ""
            echo "--- Top 5 archivos mayores a 10MB en $HOME ---"
            find "$HOME" -type f -size +10M -exec ls -lh {} + 2>/dev/null | awk '{print $5, $9}' | sort -hr | head -n 5
            echo ""
            ;;
        3)
            echo ""
            echo "--- Uso de particiones montadas ---"
            df -h -x tmpfs -x devtmpfs -x squashfs
            echo ""
            ;;
        4)
            echo ""
            echo "Sesión de monitoreo finalizada. Legajo: 6212"
            break
            ;;
        *)
            echo "Opción inválida. Por favor, seleccione un número entre 1 y 4."
            ;;
    esac
done

exit 0
