#!/bin/bash

dsn=$1

psql -f ./pre.sql $dsn

psql -c "\copy capitais_stg FROM '../files/capitais.csv' WITH (FORMAT CSV, HEADER)" $dsn

psql -c "\copy vagas_stg FROM '../files/vagas.csv' WITH (FORMAT CSV, HEADER)" $dsn

psql -c "\copy representatividade_stg FROM '../files/representatividade.csv' WITH (FORMAT CSV, HEADER)" $dsn

psql -c "\copy eleitor_stg FROM '../files/eleitorado_municipio_2014.csv' WITH (FORMAT CSV, HEADER, ENCODING 'LATIN1', DELIMITER ';')" $dsn
psql -c "\copy eleitor_stg FROM '../files/eleitorado_municipio_2018.csv' WITH (FORMAT CSV, HEADER, ENCODING 'LATIN1', DELIMITER ';')" $dsn
psql -c "\copy eleitor2010_stg FROM '../files/eleitorado_uf_2010.csv' WITH (FORMAT CSV, HEADER, ENCODING 'LATIN1', DELIMITER ',')" $dsn

psql -c "\copy tempo_mandato_stg FROM '../files/tempo_mandato_54.csv' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn
psql -c "\copy tempo_mandato_stg FROM '../files/tempo_mandato_55.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',')" $dsn
psql -c "\copy tempo_mandato_stg FROM '../files/tempo_mandato_56.csv' WITH (FORMAT CSV, HEADER, DELIMITER ',')" $dsn

php ./deputado.php

psql -c "\copy cota_uf_stg FROM '../files/cota_uf.csv' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn

for i in 14 15 16 17 18 19 20 21; do
    file=../files/Ano-20$i.csv
    unzip -o -d ../files $file.zip 
    if [ -f "$file" ]; then
        psql -c "\copy ceap_stg FROM '$file' WITH (FORMAT CSV, HEADER, DELIMITER ';')" $dsn
        rm $file
    fi
done

psql -f ./post.sql $dsn

psql -c "\copy dados TO '../final.csv' WITH (FORMAT CSV, HEADER)" $dsn
psql -c "\copy dados_v2 TO '../final_v2.csv' WITH (FORMAT CSV, HEADER)" $dsn
psql -c "\copy dados_v3 TO '../final_v3.csv' WITH (FORMAT CSV, HEADER)" $dsn
psql -c "\copy contagem_v3 TO '../contagem_v3.csv' WITH (FORMAT CSV, HEADER)" $dsn