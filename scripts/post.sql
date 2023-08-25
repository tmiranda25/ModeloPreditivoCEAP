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

DROP TABLE IF EXISTS ceap_stg;
create table ceap_stg AS (select * from ceap_bruto);

ALTER TABLE ceap_stg ALTER numano TYPE integer USING numano::integer;
ALTER TABLE ceap_stg ALTER nummes TYPE integer USING nummes::integer;
ALTER TABLE ceap_stg ALTER codlegislatura TYPE integer USING codlegislatura::integer;

--ATUALIZO NÚMEROS COM VALORES VAZIOS
UPDATE ceap_stg SET vlrliquido = 0 WHERE vlrliquido = '';
ALTER TABLE ceap_stg ALTER vlrliquido TYPE numeric(20, 2) USING vlrliquido::numeric;

create index on ceap_stg(txtdescricao);
create index on ceap_stg(sgpartido);
create index on ceap_stg(numano);
create index on ceap_stg(codlegislatura);

ANALYZE ceap_stg;
ANALYZE ceap_stg;

DROP TABLE IF EXISTS eleitor_stg;
create table if not exists eleitor_stg AS (select * from eleitor_bruto);
ALTER TABLE eleitor_stg ALTER eleitores TYPE integer USING eleitores::integer;
ALTER TABLE eleitor_stg ALTER ano TYPE integer USING ano::integer;

DROP TABLE IF EXISTS capitais_stg;
create table capitais_stg AS (SELECT * FROM capitais_bruto);
ALTER TABLE capitais_stg ALTER distancia TYPE integer USING distancia::integer;

drop table if exists representatividade_stg;
create table representatividade_stg AS (SELECT * FROM representatividade_bruto);
ALTER TABLE representatividade_stg ALTER deputados TYPE integer USING deputados::integer;
ALTER TABLE representatividade_stg ALTER legislatura TYPE integer USING legislatura::integer;

DROP TABLE IF EXISTS vagas_stg;
create table vagas_stg AS (SELECT * FROM vagas_bruto);
ALTER TABLE vagas_stg ALTER vagas TYPE integer USING vagas::integer;

DROP TABLE IF EXISTS cota_uf_stg;
create table cota_uf_stg AS (SELECT * FROM cota_uf_bruto);
ALTER TABLE cota_uf_stg ALTER cota TYPE numeric(20, 2) USING cota::numeric;


--INSIRO A REPRESENTATIVIDADE FALTANTE DA FUSÃO
-- DELETE FROM representatividade_stg WHERE partido = 'UNIÃO' AND legislatura = 56;
-- INSERT INTO representatividade_stg(partido, deputados, legislatura)VALUES('UNIÃO', 52, 56);
-- 


--REMOVO LEGISLATURA ANTERIOR E POSTERIOR
DELETE FROM ceap_stg WHERE codlegislatura IN(54, 57);

--REMOVO LIDERANÇAS
DELETE FROM ceap_stg WHERE nucarteiraparlamentar = '';

--REMOVO MENOR QUE ZERO, MENOS PASSAGENS
DELETE FROM ceap_stg WHERE (vlrliquido < 0 AND txtdescricao NOT ILIKE 'PASSAGEM AÉREA%');

--REMOVO ZEROS
DELETE FROM ceap_stg WHERE vlrliquido = 0;

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

--CONSIDERO AS PASSAGENS AÉREAS SOMENTE UM GRUPO
UPDATE ceap_stg SET txtdescricao = 'AÉREA' WHERE trim(txtdescricao) = 'PASSAGEM AÉREA - REEMBOLSO';
UPDATE ceap_stg SET txtdescricao = 'AÉREA' WHERE trim(txtdescricao) = 'PASSAGEM AÉREA - RPA';
UPDATE ceap_stg SET txtdescricao = 'AÉREA' WHERE trim(txtdescricao) = 'PASSAGEM AÉREA - SIGEPA';

--EDITO OS NOMES PARA FACILITAR
UPDATE ceap_stg SET txtdescricao = 'DIVULGAÇÃO' WHERE trim(txtdescricao) = 'DIVULGAÇÃO DA ATIVIDADE PARLAMENTAR.';
UPDATE ceap_stg SET txtdescricao = 'ESCRITÓRIO' WHERE trim(txtdescricao) = 'MANUTENÇÃO DE ESCRITÓRIO DE APOIO À ATIVIDADE PARLAMENTAR';
UPDATE ceap_stg SET txtdescricao = 'ASSESSORIA' WHERE trim(txtdescricao) = 'CONSULTORIAS, PESQUISAS E TRABALHOS TÉCNICOS.';
UPDATE ceap_stg SET txtdescricao = 'AUTOMÓVEIS' WHERE trim(txtdescricao) = 'LOCAÇÃO OU FRETAMENTO DE VEÍCULOS AUTOMOTORES';
UPDATE ceap_stg SET txtdescricao = 'COMBUSTÍVEIS' WHERE trim(txtdescricao) = 'COMBUSTÍVEIS E LUBRIFICANTES.';
UPDATE ceap_stg SET txtdescricao = 'HOSPEDAGEM' WHERE trim(txtdescricao) = 'HOSPEDAGEM ,EXCETO DO PARLAMENTAR NO DISTRITO FEDERAL.';
UPDATE ceap_stg SET txtdescricao = 'ALIMENTAÇÃO' WHERE trim(txtdescricao) = 'FORNECIMENTO DE ALIMENTAÇÃO DO PARLAMENTAR';
UPDATE ceap_stg SET txtdescricao = 'SEGURANÇA' WHERE trim(txtdescricao) = 'SERVIÇO DE SEGURANÇA PRESTADO POR EMPRESA ESPECIALIZADA.';
UPDATE ceap_stg SET txtdescricao = 'CURSOS' WHERE trim(txtdescricao) = 'PARTICIPAÇÃO EM CURSO, PALESTRA OU EVENTO SIMILAR';
UPDATE ceap_stg SET txtdescricao = 'AERONAVES' WHERE trim(txtdescricao) = 'LOCAÇÃO OU FRETAMENTO DE AERONAVES';
UPDATE ceap_stg SET txtdescricao = 'EMBARCAÇÕES' WHERE trim(txtdescricao) = 'LOCAÇÃO OU FRETAMENTO DE EMBARCAÇÕES';
UPDATE ceap_stg SET txtdescricao = 'TERRESTRE/MARÍTIMA/FLUVIAL' WHERE trim(txtdescricao) = 'PASSAGENS TERRESTRES, MARÍTIMAS OU FLUVIAIS';
UPDATE ceap_stg SET txtdescricao = 'TÁXI/PEDÁGIO/ESTACIONAMENTO' WHERE trim(txtdescricao) = 'SERVIÇO DE TÁXI, PEDÁGIO E ESTACIONAMENTO';

--REMOVO O ÚNICO REGISTRO DO TIPO
DELETE FROM ceap_stg WHERE txtdescricao = 'AQUISIÇÃO DE TOKENS E CERTIFICADOS DIGITAIS';

ALTER TABLE ceap_stg ADD COLUMN anolegislatura integer;

UPDATE ceap_stg SET anolegislatura = (CASE 
        WHEN numano = 2015 THEN 1 
        WHEN numano = 2016 THEN 2 
        WHEN numano = 2017 THEN 3
        WHEN numano = 2018 THEN 4 
        WHEN numano = 2019 AND codlegislatura = 55 THEN 5
        WHEN numano = 2019 THEN 1
        WHEN numano = 2020 THEN 2
        WHEN numano = 2021 THEN 3
        WHEN numano = 2022 THEN 4
        WHEN numano = 2023 AND codlegislatura = 56 THEN 5 END);

ALTER TABLE ceap_stg ADD COLUMN grupo text;

UPDATE ceap_stg SET grupo = 'OUTROS';
UPDATE ceap_stg SET grupo = 'DIVULGAÇÃO' WHERE trim(txtdescricao) = 'TELEFONIA';
UPDATE ceap_stg SET grupo = 'DIVULGAÇÃO' WHERE trim(txtdescricao) = 'DIVULGAÇÃO';
UPDATE ceap_stg SET grupo = 'ESCRITÓRIO' WHERE trim(txtdescricao) = 'ESCRITÓRIO';
UPDATE ceap_stg SET grupo = 'ASSESSORIA' WHERE trim(txtdescricao) = 'ASSESSORIA';
UPDATE ceap_stg SET grupo = 'MOBILIDADE' WHERE trim(txtdescricao) = 'AÉREA';
UPDATE ceap_stg SET grupo = 'MOBILIDADE' WHERE trim(txtdescricao) = 'AUTOMÓVEIS';
UPDATE ceap_stg SET grupo = 'MOBILIDADE' WHERE trim(txtdescricao) = 'COMBUSTÍVEIS';
UPDATE ceap_stg SET grupo = 'MOBILIDADE' WHERE trim(txtdescricao) = 'AERONAVES';
UPDATE ceap_stg SET grupo = 'MOBILIDADE' WHERE trim(txtdescricao) = 'EMBARCAÇÕES';
UPDATE ceap_stg SET grupo = 'MOBILIDADE' WHERE trim(txtdescricao) = 'TERRESTRE/MARÍTIMA/FLUVIAL';
UPDATE ceap_stg SET grupo = 'MOBILIDADE' WHERE trim(txtdescricao) = 'TÁXI/PEDÁGIO/ESTACIONAMENTO';


DROP TABLE IF EXISTS ceap;
CREATE TABLE ceap(
id serial primary key,
ano integer,
mes integer,
anolegislatura integer,
legislatura integer,
uf text,
tipo text,
grupo text,
partido text,
valor numeric(20,2),
vagas integer,
eleitores integer,
cota numeric(20, 2),
distancia integer
);

INSERT INTO ceap(uf, ano, mes, legislatura, tipo, grupo, partido, valor, anolegislatura, vagas, eleitores, cota, distancia)
SELECT sguf AS uf, numano AS ano, nummes, codlegislatura AS legislatura, txtdescricao, grupo, c.sgpartido AS partido, vlrliquido AS valor, anolegislatura, v.vagas, e.eleitores, co.cota, ca.distancia
FROM ceap_stg c
JOIN capitais_stg ca ON c.sguf = ca.uf
JOIN vagas_stg v ON c.sguf = v.uf
JOIN eleitor_stg e ON c.sguf = e.uf AND c.codlegislatura = (CASE WHEN e.ano = 2014 THEN 55 WHEN ano = 2018 THEN 56 END)
JOIN cota_uf_stg co ON c.sguf = co.uf;
--GROUP BY 1, 2, 3, 4, 6;


DROP TABLE IF EXISTS mobilidade;
CREATE TABLE mobilidade(
uf text,
distancia integer,
valor numeric(20,2)
);

INSERT INTO mobilidade(uf, distancia, valor)
SELECT sguf AS uf, MAX(ca.distancia), SUM(vlrliquido)/(MAX(co.cota)*MAX(v.vagas)*94)
FROM ceap_stg c
JOIN capitais_stg ca ON c.sguf = ca.uf
JOIN vagas_stg v ON c.sguf = v.uf
JOIN eleitor_stg e ON c.sguf = e.uf AND c.codlegislatura = (CASE WHEN e.ano = 2014 THEN 55 WHEN ano = 2018 THEN 56 END)
JOIN cota_uf_stg co ON c.sguf = co.uf
WHERE grupo = 'MOBILIDADE' AND anolegislatura <> 5
GROUP BY 1;

commit;

