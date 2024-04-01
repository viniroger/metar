#!/bin/bash
# Script para separar os dados baixados de METAR em um arquivo para cada aeroporto

file_in='metar.txt'

aeroportos=( `cat estac_metar | awk '{print $3}'`)

for icao in "${aeroportos[@]}"; do
	file_out='metar_'$icao'.txt'
	echo $file_out
	cat $file_in | grep $icao > $file_out
done
