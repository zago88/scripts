#!/bin/bash

input_folder=$1
output_pdf=$2

# Verificar que se proporcionaron los argumentos
if [ -z "$input_folder" ] || [ -z "$output_pdf" ]; then
    echo "Uso: $0 <carpeta_entrada> <pdf_salida>"
    exit 1
fi

# Obtener la lista ordenada de imágenes en la carpeta de entrada
images=($(ls "$input_folder"*.jpg | sort -n))

# Crear un directorio temporal
temp_dir=$(mktemp -d)

#poniendo las marcar de agua a los archivos: 
for image_path in "${images[@]}"; do
    filename=$(basename "$image_path")
    convert "$image_path" -fill black -pointsize 30 -gravity SouthWest -annotate +10+10 "%f" "$temp_dir/$filename"
done

#define variable para images marcadas
images_marked=($(ls "$temp_dir"/*.jpg | sort -n))

# Procesar las imágenes y agregarlas al directorio temporal
for ((i=0; i<${#images_marked[@]}; i+=4)); do
    convert "${images_marked[@]:i:2}" +append "$temp_dir/horizontal_$((i/4)).jpg"
    convert "${images_marked[@]:i+2:2}" +append "$temp_dir/horizontal_$((i/4))_2.jpg"
    convert "$temp_dir/horizontal_$((i/4)).jpg" "$temp_dir/horizontal_$((i/4))_2.jpg" -append "$temp_dir/page_$((i/4)).jpg"
done

# Convertir las imágenes del directorio temporal a un solo archivo PDF
convert -page letter "$temp_dir"/page_*.jpg "$output_pdf"

# Limpiar el directorio temporal
rm -r "$temp_dir"

echo "PDF creado: $output_pdf"

