/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  thiago
 * Created: 16 de mai. de 2022
 */
begin;

--INSIRO A REPRESENTATIVIDADE FALTANTE DA FUSÃO
DELETE FROM representatividade_stg WHERE partido = 'UNIÃO' AND legislatura = 56;
INSERT INTO representatividade_stg(partido, deputados, legislatura)VALUES('UNIÃO', 52, 56);

--ATUALIZO OS PARTIDOS QUE MUDARAM DE NOME
UPDATE representatividade_stg SET partido = 'SOLIDARIEDADE' WHERE trim(partido) = 'SD';
UPDATE representatividade_stg SET partido = 'CIDADANIA' WHERE trim(partido) = 'PPS';
UPDATE representatividade_stg SET partido = 'PATRIOTA' WHERE trim(partido) = 'PATRI';
UPDATE representatividade_stg SET partido = 'PATRIOTA' WHERE trim(partido) = 'PRP';
UPDATE representatividade_stg SET partido = 'REPUBLICANOS' WHERE trim(partido) = 'PRB';
UPDATE representatividade_stg SET partido = 'MDB' WHERE trim(partido) = 'PMDB';
UPDATE representatividade_stg SET partido = 'PODEMOS' WHERE trim(partido) = 'PHS';
UPDATE representatividade_stg SET partido = 'PCdoB' WHERE trim(partido) = 'PC do B';
UPDATE representatividade_stg SET partido = 'PCdoB' WHERE trim(partido) = 'PPL';
--UPDATE representatividade_stg SET partido = 'UNIÃO' WHERE trim(partido) = 'PSL';
--UPDATE representatividade_stg SET partido = 'UNIÃO' WHERE trim(partido) = 'DEM';
UPDATE representatividade_stg SET partido = 'REPUBLICANOS' WHERE trim(partido) = 'PRB';
UPDATE representatividade_stg SET partido = 'PODEMOS' WHERE trim(partido) = 'PODE';
UPDATE representatividade_stg SET partido = 'PODEMOS' WHERE trim(partido) = 'PTN';
UPDATE representatividade_stg SET partido = 'PATRIOTA' WHERE trim(partido) = 'PEN';
UPDATE representatividade_stg SET partido = 'DC' WHERE trim(partido) = 'PSDC';
UPDATE representatividade_stg SET partido = 'AVANTE' WHERE trim(partido) = 'PTdoB';
--UPDATE representatividade_stg SET partido = 'AVANTE' WHERE trim(partido) = 'PT do B';
UPDATE representatividade_stg SET partido = 'AGIR' WHERE trim(partido) = 'PTC';
UPDATE representatividade_stg SET partido = 'PL' WHERE trim(partido) = 'PR';
UPDATE representatividade_stg SET partido = trim(partido);

--REMOVO LEGISLATURA ANTERIOR E POSTERIOR
DELETE FROM ceap_stg WHERE codlegislatura IN('54', '57');

--ATUALIZO NÚMEROS COM VALORES VAZIOS
UPDATE ceap_stg SET vlrdocumento = 0 WHERE vlrdocumento = '';
UPDATE ceap_stg SET vlrglosa = 0 WHERE vlrglosa = '';
UPDATE ceap_stg SET vlrrestituicao = 0 WHERE vlrrestituicao = '';

--ATUALIZO PARTIDOS
UPDATE ceap_stg SET sgpartido = 'SOLIDARIEDADE' WHERE trim(sgpartido) = 'SDD';
UPDATE ceap_stg SET sgpartido = 'PATRIOTA' WHERE trim(sgpartido) = 'PATRI';
UPDATE ceap_stg SET sgpartido = 'MDB' WHERE trim(sgpartido) = 'PMDB';
UPDATE ceap_stg SET sgpartido = 'PODEMOS' WHERE trim(sgpartido) = 'PHS';
UPDATE ceap_stg SET sgpartido = 'PP' WHERE trim(sgpartido) = 'PP**';
UPDATE ceap_stg SET sgpartido = 'PCdoB' WHERE trim(sgpartido) = 'PPL';
UPDATE ceap_stg SET sgpartido = 'REPUBLICANOS' WHERE trim(sgpartido) = 'PRB';
UPDATE ceap_stg SET sgpartido = 'PODEMOS' WHERE trim(sgpartido) = 'PODE';
UPDATE ceap_stg SET sgpartido = 'CIDADANIA' WHERE trim(sgpartido) = 'PPS';
UPDATE ceap_stg SET sgpartido = 'AVANTE' WHERE trim(sgpartido) = 'PTdoB';
UPDATE ceap_stg SET sgpartido = 'PL' WHERE trim(sgpartido) = 'PR';

--CONSIDRO AS PASSAGENS AÉREAS SOMENTE UM GRUPO
UPDATE ceap_stg SET txtdescricao = 'PASSAGEM AÉREA' WHERE trim(txtdescricao) = 'PASSAGEM AÉREA - REEMBOLSO';
UPDATE ceap_stg SET txtdescricao = 'PASSAGEM AÉREA' WHERE trim(txtdescricao) = 'PASSAGEM AÉREA - RPA';
UPDATE ceap_stg SET txtdescricao = 'PASSAGEM AÉREA' WHERE trim(txtdescricao) = 'PASSAGEM AÉREA - SIGEPA';

UPDATE ceap_stg SET txtdescricao = 'DIVULGAÇÃO MANDATO' WHERE trim(txtdescricao) = 'DIVULGAÇÃO DA ATIVIDADE PARLAMENTAR.';
UPDATE ceap_stg SET txtdescricao = 'MANUTENÇÃO DE ESCRITÓRIO' WHERE trim(txtdescricao) = 'MANUTENÇÃO DE ESCRITÓRIO DE APOIO À ATIVIDADE PARLAMENTAR';
UPDATE ceap_stg SET txtdescricao = 'ASSESSORIA TÉCNICA/JURÍDICA' WHERE trim(txtdescricao) = 'CONSULTORIAS, PESQUISAS E TRABALHOS TÉCNICOS.';
UPDATE ceap_stg SET txtdescricao = 'LOCAÇÃO DE AUTOMÓVEIS' WHERE trim(txtdescricao) = 'LOCAÇÃO OU FRETAMENTO DE VEÍCULOS AUTOMOTORES';
UPDATE ceap_stg SET txtdescricao = 'COMBUSTÍVEIS E LUBRIFICANTES' WHERE trim(txtdescricao) = 'COMBUSTÍVEIS E LUBRIFICANTES.';
--REMOVO O ÚNICO REGISTRO DO TIPO
DELETE FROM ceap_stg WHERE txtdescricao = 'AQUISIÇÃO DE TOKENS E CERTIFICADOS DIGITAIS';

DROP TABLE IF EXISTS ceap;
CREATE TABLE ceap(
id serial primary key,
ano integer,
anolegislatura integer,
legislatura integer,
uf text,
partido text,
tipo text,
valor numeric(20,2)
);

INSERT INTO ceap(uf, ano, legislatura, partido, tipo, valor, anolegislatura)
SELECT c.uf, c.ano, c.legislatura, c.partido, c.tipo, SUM(c.valor), 
    MAX(CASE 
        WHEN c.ano = 2015 THEN 1 
        WHEN c.ano = 2016 THEN 2 
        WHEN c.ano = 2017 THEN 3 
        WHEN c.ano = 2018 THEN 4 
        WHEN c.ano = 2019 AND c.legislatura = 55 THEN 5
        WHEN c.ano = 2019 THEN 1 
        WHEN c.ano = 2020 THEN 2 
        WHEN c.ano = 2021 THEN 3 
        WHEN c.ano = 2022 THEN 4
        WHEN c.ano = 2023 AND c.legislatura = 56 THEN 5  END)
FROM (
    SELECT sguf AS uf, numano::integer AS ano, nummes::integer AS mes, codlegislatura::integer AS legislatura, sgpartido AS partido, txtdescricao AS tipo, vlrliquido::numeric AS valor
    FROM ceap_stg
    WHERE nucarteiraparlamentar <> '' AND (vlrliquido::numeric > 0 OR txtdescricao <> 'PASSAGEM AÉREA')
) c
GROUP BY 1, 2, 3, 4, 5;

DROP TABLE IF EXISTS eleitor;
CREATE TABLE eleitor(
id serial primary key,
legislatura integer,
uf text,
total integer
);

DROP TABLE IF EXISTS capitais;
CREATE TABLE capitais(
id serial primary key,
uf text,
distancia integer
);

DROP TABLE IF EXISTS vagas;
CREATE TABLE vagas(
id serial primary key,
uf text,
vagas integer
);

DROP TABLE IF EXISTS representatividade;
CREATE TABLE representatividade(
id serial primary key,
partido text,
deputados integer,
legislatura integer
);

DROP TABLE IF EXISTS cota_uf;
CREATE TABLE cota_uf(
uf text,
cota numeric(20,2)
);

INSERT INTO eleitor(uf, legislatura, total)
SELECT uf, CASE WHEN ano::integer = 2014 THEN 55 WHEN ano::integer = 2018 THEN 56 END, eleitores::integer
FROM eleitor_stg;

INSERT INTO capitais(uf, distancia)SELECT uf, distancia::integer FROM capitais_stg;

INSERT INTO vagas(uf, vagas)SELECT uf, vagas::integer FROM vagas_stg;

INSERT INTO cota_uf(uf, cota)SELECT uf, replace(cota, ',', '.')::numeric FROM cota_uf_stg;

INSERT INTO representatividade(partido, legislatura, deputados)SELECT trim(partido), legislatura, sum(deputados) AS deputados from representatividade_stg group by 1, 2 order by 1, 2;

DROP TABLE IF EXISTS agregado;
CREATE TABLE agregado(
ano integer,
legislatura integer,
anolegislatura integer,
uf text,
partido text,
tipo text,
representatividade integer,
distancia integer,
vagas integer, 
eleitores integer,
cota numeric(20,2),
valor numeric(20,2)
);

INSERT INTO agregado(uf, ano, legislatura, partido, tipo, representatividade, distancia, vagas, eleitores, cota, valor, anolegislatura)
SELECT c.uf, c.ano, c.legislatura, c.partido, c.tipo, r.deputados, ca.distancia, v.vagas, e.total, co.cota, c.valor, c.anolegislatura
FROM ceap c
JOIN capitais ca ON c.uf = ca.uf
JOIN vagas v ON c.uf = v.uf
JOIN eleitor e ON c.uf = e.uf AND e.legislatura = c.legislatura
JOIN cota_uf co ON c.uf = co.uf LEFT JOIN representatividade r ON c.legislatura = r.legislatura AND  c.partido = r.partido;
--GROUP BY 1, 2, 3, 4, 5;


DROP TABLE IF EXISTS agregado_uf;
CREATE TABLE agregado_uf(
uf text,
distancia integer,
cota numeric(20,2),
valor numeric(20,2)
);

INSERT INTO agregado_uf(uf, distancia, cota, valor)
SELECT c.uf, MAX(ca.distancia), MAX(co.cota), SUM(c.valor)/MAX(v.vagas)
FROM ceap c
JOIN capitais ca ON c.uf = ca.uf
JOIN vagas v ON c.uf = v.uf
--JOIN eleitor e ON c.uf = e.uf AND e.legislatura = c.legislatura
JOIN cota_uf co ON c.uf = co.uf 
--LEFT JOIN representatividade r ON c.legislatura = r.legislatura AND  c.partido = r.partido
GROUP BY c.uf;

DROP TABLE IF EXISTS agregado_partido;
CREATE TABLE agregado_partido(
partido text,
deputados integer,
valor numeric(20,2)
);

INSERT INTO agregado_partido(partido, deputados, valor)
select partido, deputados, valor AS valor from (select partido, sum(valor) AS valor FROM agregado WHERE partido NOT IN('DEM', 'PSL', 'UNIÃO') GROUP BY partido) p LEFT JOIN (select partido, sum(deputados) AS deputados from representatividade group by partido) r USING(partido);

commit;