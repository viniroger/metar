#!/bin/bash
# Script para ordenar dados de metar e retirar linhas duplicadas

# Listar todos os arquivos de uma pasta

for file in `ls metares`; do
	echo $file
	mv metares/$file metares/temp
	cat metares/temp | sort -u > metares/$file
done

rm -f metares/temp
