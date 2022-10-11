#!/bin/bash

dsn=$1

pasta_brutos=../dados_brutos

pasta_dados=../dados

psql -f ./pre.sql $dsn

psql -c "\copy capitais_stg FROM '$pasta_brutos/capitais.csv' WITH (FORMAT CSV, HEADER)" $dsn

psql -c "\copy vagas_stg FROM '$pasta_brutos/vagas.csv' WITH (FORMAT CSV, HEADER)" $dsn

psql -c "\copy representatividade_stg FROM '$pasta_brutos/representatividade.csv' WITH (FORMAT CSV, HEADER)" $dsn

for i in 10 14 18; do
    psql -c "\copy eleitor_stg FROM '$pasta_brutos/eleitores-uf_20$i.csv' WITH (FORMAT CSV, HEADER, ENCODING 'LATIN1', DELIMITER ',')" $dsn
done

for i in 54 55 56; do
    psql -c "\copy tempo_mandato_stg FROM '$pasta_brutos/tempo_mandato_$i.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',')" $dsn
done

php ./deputado.php

for i in 54 55 56; do
    psql -c "\copy deputado_stg FROM '$pasta_brutos/deputado_$i.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',')" $dsn
done

psql -c "\copy cota_uf_stg FROM '$pasta_brutos/cota_uf.csv' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn

for i in 13 14 15 16 17 18 19 20 21; do
    file=$pasta_brutos/Ano-20$i.csv
    wget -O $file.zip https://www.camara.leg.br/cotas/Ano-20$i.csv.zip
    unzip -o -d $pasta_brutos $file.zip 
    if [ -f "$file" ]; then
        rm $file.zip
        psql -c "\copy ceap_stg FROM '$file' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn
        rm $file
    fi
done

psql -f ./post.sql $dsn

psql -c "\copy dados TO '$dados/final.csv' WITH (FORMAT CSV, HEADER)" $dsn
psql -c "\copy dados_v2 TO '$dados/final_v2.csv' WITH (FORMAT CSV, HEADER)" $dsn
psql -c "\copy dados_v3 TO '$dados/final_v3.csv' WITH (FORMAT CSV, HEADER)" $dsn
psql -c "\copy contagem_v3 TO '$dados/contagem_v3.csv' WITH (FORMAT CSV, HEADER)" $dsn