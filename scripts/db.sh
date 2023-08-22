#!/bin/bash

dsn=$1

pasta_brutos=./../dados_brutos

pasta_dados=./../dados

psql -f ./pre.sql $dsn

psql -c "\copy capitais_bruto FROM '$pasta_brutos/capitais.csv' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn

psql -c "\copy vagas_bruto FROM '$pasta_brutos/vagas.csv' WITH (FORMAT CSV, HEADER)" $dsn

psql -c "\copy representatividade_bruto FROM '$pasta_brutos/representatividade.csv' WITH (FORMAT CSV, HEADER)" $dsn

for i in 14 18; do
    psql -c "\copy eleitor_bruto FROM '$pasta_brutos/eleitores-uf_20$i.csv' WITH (FORMAT CSV, HEADER, ENCODING 'LATIN1', DELIMITER ',')" $dsn
done

psql -c "\copy cota_uf_bruto FROM '$pasta_brutos/cota_uf.csv' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn

for i in 15 16 17 18 19 20 21 22 23; do
    file=$pasta_brutos/Ano-20$i.csv
    if [ ! -f "$file" ]; then
        wget -O $file.zip https://www.camara.leg.br/cotas/Ano-20$i.csv.zip
        unzip -o -d $pasta_brutos $file.zip 
        if [ -f "$file" ]; then
            rm $file.zip
#            rm $file
        fi
    fi
    psql -c "\copy ceap_bruto FROM '$file' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn
done

psql -f ./post.sql $dsn

psql -c "\copy ceap TO '$dados/ceap.csv' WITH (FORMAT CSV, HEADER)" $dsn
psql -c "\copy assessoria_tecnica TO '$dados/assessoria_tecnica.csv' WITH (FORMAT CSV, HEADER)" $dsn

