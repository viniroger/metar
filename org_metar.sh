#!/bin/bash
# Script para reorganizar dados do METAR em CSV

icao='SBGL'

file_in='metares/metar_'$icao'.txt'
file_out='metares/metar_'$icao'.csv'
echo "icao,ano,mes,dia,hora_min,v_dir,v_int,v_raj,visibilidade,teto,t,td,pressao,feno" > $file_out

while read INPUT ; do
	# Se realmente tiver dados na linha
	teste=$(echo $INPUT | grep "Mensagem" | wc -l)
	if [ "$teste" == "0" ]; then
		tipo_informe='NA';icao='NA';dia='NA';hora='NA',min='NA';v_dir='NA';v_int='NA';v_raj='NA';visibilidade='9999';teto='9999';t='NA';td='NA';pressao='NA';feno='NA'
		# Tirar palavra AUTO e COR (quando tem correção, apagam o METAR errado antigo)
		linha=$(echo $INPUT | sed 's/AUTO //g' | sed 's/COR //g')
		IFS=' ' read -r -a array <<< "$linha"
		penultimo=${array[-2]}
		ultimo=${array[-1]}
		for index in "${!array[@]}"; do
		    #echo "$index ${array[index]}"
			elemento=${array[index]}
		    ndigitos=$(echo $elemento | awk -F '[0-9]' '{print NF-1}') #contar número de dígitos do elemento do array
		    #len=$(expr "x$elemento" : "x[0-9]*$")
		    nletras=$(echo $elemento | grep -o '[^0-9]' | wc -l) #contar número de letras do elemento do array
		    delete=($elemento)
		    length=${#elemento}
		    if [[ $index == 0 ]];then
				echo $elemento
				ano=$(echo $elemento | cut -b 1-4)
				mes=$(echo $elemento | cut -b 5-6)
				dia=$(echo $elemento | cut -b 7-8)
				hora=$(echo $elemento | cut -b 9-10)
				array=( "${array[@]/$delete}" )
		    fi
			if [[ $elemento == *'SB'* ]]; then
				# aeródromo
				icao=$elemento
				array=( "${array[@]/$delete}" )
			fi
			if [[ "${elemento: -1}" == "Z" && "$length" == "7" ]]; then
				# data
				#dia=$(echo $elemento | cut -b 1-2)
				#hora=$(echo $elemento | cut -b 3-4)
				min=$(echo $elemento | cut -b 5-6)
				array=( "${array[@]/$delete}" )
			fi
			if [[ $index == 4 && $elemento == *'K'* && $length -gt 5 || $elemento == *'KT'* && $length -gt 5 ]]; then
				# velocidade do vento
				v_dir=$(echo $elemento | cut -b 1-3)
				v_int=$(echo $elemento | cut -b 4-5)
				if [[ $elemento == *'G'* ]]; then
					v_raj=$(echo $elemento | cut -b 7-8)
				else
					v_raj=0
				fi
				array=( "${array[@]/$delete}" )
			fi
			if [[ $elemento == *'/'* || $elemento == $penultimo && $ultimo != *'R'* && $ultimo != '=' && $elemento != 'Q' ]]; then
				# T e Td
				arrIN=(${elemento//// })
				t=$(echo ${arrIN[0]} | rev | cut -c 1-2 | rev)
				erro_nuvem=$(echo ${arrIN[0]} | rev | cut -c 3- | rev)
				td=$(echo ${arrIN[1]} | cut -c 1-2)
				erro_pressao=$(echo ${arrIN[1]} | cut -c 4-)
				if [[ -z "$td" ]]; then
					t=$(echo $elemento | cut -c 1-2)
					td=$(echo $elemento | cut -c 3-4)
					array=( "${array[@]/$delete}" )
				fi
				if [[ -z "$erro_nuvem" && -z "$erro_pressao" ]]; then
					array=( "${array[@]/$delete}" )
				fi
			fi
			if [[ $elemento == *'Q'* || $elemento == *'='* && $elemento != *'R'* && $ndigitos == 4 ]]; then
				# pressao (extrair somente números)
				pressao=$(echo $elemento | tr -d -c 0-9)
				array=( "${array[@]/$delete}" )
			fi
			if [[ $ndigitos == 4 && $nletras == 0 && $elemento != $penultimo ]]; then
				# Visibilidade (só tem números)
				visibilidade=$elemento
				array=( "${array[@]/$delete}" )
			fi
			if [[ $elemento == *'FEW'* || $elemento == *'SCT'* || $elemento == *'BKN'* || $elemento == *'OVC'* ]]; then
				# nebulosidade
				quant_nuvens=$(echo $elemento | cut -b 1-3)
				if [[ $quant_nuvens == 'BKN' || $quant_nuvens == 'OVC' ]]; then
					teto_cpes=$(echo $elemento | cut -b 4-6) #em centenas de pés
					if [[ $teto_cpes == *'O'* ]]; then
						teto_cpes=$(echo $teto_cpes | sed 's/O/0/g')
					fi
					teto=$((10#$teto_cpes*100)) #em pés
					#teto=$(echo $teto_cpes*100*0.3084 | bc) #em metros
				fi
				array=( "${array[@]/$delete}" )
			fi
			if [[ $elemento == 'CAVOK' || $elemento == 'CAVPK' ]]; then
				quant_nuvens=0
				visibilidade=9999
				teto=5000
				array=( "${array[@]/$delete}" )
			fi
		done
		# Fenomenos diversos
		feno=`echo ${array[@]} | tr -d '-'`
		echo $icao,$ano,$mes,$dia,$hora:$min,$v_dir,$v_int,$v_raj,$visibilidade,$teto,$t,$td,$pressao,$feno >> $file_out
		#exit
	fi
done < $file_in ;
