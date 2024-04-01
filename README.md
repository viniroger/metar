# METAR

Um METAR (Meteorological Aerodrome Report) é um relatório meteorológico padronizado emitido regularmente por estações terrestres em aeroportos e outras localidades de aviação, fornecendo informações sobre condições meteorológicas atuais, como temperatura, vento, visibilidade e condições de nuvens. Veja mais sobre o METAR no post [Códigos de Meteorologia Aeronáutica](https://www.monolitonimbus.com.br/codigos-de-meteorologia-aeronautica).

O banco de dados da REDEMET possui uma [API](https://ajuda.decea.mil.br/base-de-conhecimento/api-redemet-mensagem-metar/) destina à retornar mensagens METAR/SPECI das localidades disponíveis, com dados desde 2003. Os códigos a seguir foram desenvolvidos em 2017 com bash/shell script, sendo que a parte específica de obtenção dos dados via API provavelmente está desatualizada. No entanto, o script de organização dos dados inclui uma série de verificações criadas empiricamente com base no download dos dados nessa época, corrigindo prováveis erros de digitação encontrados.

- *estac_metar* - texto UTF-8 de informações das estações METAR contendo cinco colunas fixas: latitude, longitude, código ICAO, cidade e estado (sem acentuação e underline no lugar de espaço)

- *wget_aeroportos.sh* - baixar dados METAR usando wget e torsocks

- *org_metar.sh* - reorganizar dados do METAR em CSV

- *sep_aero.sh* - separar os dados baixados de METAR em um arquivo para cada aeroporto

- *sort_metar.sh* - ordenar dados de metar e retirar linhas duplicadas

