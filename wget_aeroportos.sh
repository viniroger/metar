#!/bin/bash
# Script para baixar dados de METAR

#icao="sbsp,sbrb"
inicio=20150515
#inicio=20050918
fim=20161231
#fim=20050920

# Montar listas de aeroportos (80 + 78)
#aeroportos=( `cat ../nevoeiros/estac_metar | awk '{print tolower($3)}' | tr '\n' ' '` )
#for icao in "${aeroportos[@]}"; do
#	echo $icao
#done
parte1=( `cat estac_metar | awk '{print tolower($3)}' | tr '\n' ',' | rev | cut -c392- | rev`)
parte2=( `cat estac_metar | awk '{print tolower($3)}' | tr '\n' ',' | cut -c401- | rev | cut -c2- | rev`)
arq='metar_p1.txt'
icao=$parte1
rm -f $arq; touch $arq

ndias=$(( ($(date --date=$fim +%s) - $(date --date=$inicio +%s) )/(60*60*24) ))
n=0
while [ $n -le $ndias ]; do
	data=`date '+%Y%m%d' -d "$inicio+$n days"`
	echo $data
	dataini=$data'00'
	datafim=$data'23'
	torsocks wget -nv --post-data="&local=$icao&msg=metar&data_ini=$dataini&data_fim=$datafim" http://www.redemet.aer.mil.br/api/consulta_automatica/index.php -O- | tr '\r' ' ' | sed '/^\s*$/d' | sed '/ -  /d' > resultado2.tmp
	teste=$(cat resultado2.tmp | wc -l)
	while [ $teste -le 2 ]; do
		echo "baixando novamente"
		torsocks wget -nv --post-data="&local=$icao&msg=metar&data_ini=$dataini&data_fim=$datafim" http://www.redemet.aer.mil.br/api/consulta_automatica/index.php -O- | tr '\r' ' ' | sed '/^\s*$/d' | sed '/ -  /d' > resultado2.tmp
		teste=$(cat resultado2.tmp | wc -l)
	done
	cat resultado2.tmp >> $arq
	n=$((n+1))
done

exit
