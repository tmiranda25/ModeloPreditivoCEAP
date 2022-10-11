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
DROP TABLE IF EXISTS dados;
CREATE TABLE dados(
ano integer,
mes integer,
legislatura integer,
anolegislatura text,
uf text,
partido text,
tipo text,
eleitores integer,
representatividade integer,
distancia integer,
vagas integer,
valor numeric(20,2)
);

DROP TABLE IF EXISTS dados_v2;
CREATE TABLE dados_v2(
ano integer,
legislatura integer,
anolegislatura text,
uf text,
tipo text,
eleitores integer,
distancia integer,
vagas integer,
valor numeric(20,2)
);

DROP TABLE IF EXISTS dados_v3;
CREATE TABLE dados_v3(
iddeputado integer,
partido text,
ano integer,
mes integer,
legislatura integer,
meseslegislatura integer, 
cotalegislatura numeric(20,2),
anolegislatura integer,
uf text,
tipo text,
eleitores integer,
distancia integer,
vagas integer,
valor numeric(20,2),
cota numeric(20,2)
);

DROP TABLE IF EXISTS eleitor;
CREATE TABLE eleitor(
id serial primary key,
ano integer,
uf text,
total integer
);

DROP TABLE IF EXISTS ceap;
CREATE TABLE ceap(
id serial primary key,
iddeputado integer,
emissao date,
ano integer,
mes integer,
legislatura integer,
uf text,
partido text,
tipo text,
valor numeric(20,2)
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
ano integer
);

DROP TABLE IF EXISTS tempo_mandato;
CREATE TABLE tempo_mandato(
iddeputado integer,
legislatura integer
);

DROP TABLE IF EXISTS cota_uf;
CREATE TABLE cota_uf(
uf text,
cota numeric(20,2),
pos54 bool
);

DROP TABLE IF EXISTS deputado;
create table deputado(
    iddeputado integer not null,
    nome text not null,
    siglapartido text not null,
    siglauf text,
    legislatura integer,
    PRIMARY KEY(iddeputado, legislatura)
);

-- vlrtotal - vlrglosa - vlrrestituicao
INSERT INTO eleitor(uf, ano, total)
SELECT uf, ano::integer, eleitores::integer
FROM eleitor_stg;

UPDATE ceap_stg SET vlrdocumento = 0 WHERE vlrdocumento = '';
UPDATE ceap_stg SET vlrglosa = 0 WHERE vlrglosa = '';
UPDATE ceap_stg SET vlrrestituicao = 0 WHERE vlrrestituicao = '';

UPDATE ceap_stg SET sgpartido = 'SOLIDARIEDADE' WHERE trim(sgpartido) = 'SDD';
UPDATE ceap_stg SET sgpartido = 'PATRIOTA' WHERE trim(sgpartido) = 'PATRI';
UPDATE ceap_stg SET sgpartido = 'MDB' WHERE trim(sgpartido) = 'PMDB';
UPDATE ceap_stg SET sgpartido = 'PODEMOS' WHERE trim(sgpartido) = 'PHS' AND codlegislatura = '56';
UPDATE ceap_stg SET sgpartido = 'PP' WHERE trim(sgpartido) = 'PP**';
UPDATE ceap_stg SET sgpartido = 'PCdoB' WHERE trim(sgpartido) = 'PPL' AND codlegislatura = '56';
-- UPDATE ceap_stg SET sgpartido = 'UNIÃO' WHERE trim(sgpartido) = 'PSL';
-- UPDATE ceap_stg SET sgpartido = 'UNIÃO' WHERE trim(sgpartido) = 'DEM';
UPDATE ceap_stg SET sgpartido = 'REPUBLICANOS' WHERE trim(sgpartido) = 'PRB';
UPDATE ceap_stg SET sgpartido = 'PODEMOS' WHERE trim(sgpartido) = 'PODE';

DELETE FROM ceap_stg WHERE numano::integer < 2013 OR numano::integer > 2021;

INSERT INTO ceap(uf, ano, mes, legislatura, partido, tipo, valor, iddeputado)
SELECT sguf, numano::integer, nummes::integer, codlegislatura::integer, sgpartido, txtdescricao, vlrdocumento::numeric - vlrglosa::numeric - vlrrestituicao::numeric, idecadastro::integer
FROM ceap_stg;

INSERT INTO capitais(uf, distancia)SELECT uf, distancia::integer FROM capitais_stg;

INSERT INTO vagas(uf, vagas)SELECT uf, vagas::integer FROM vagas_stg;

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
UPDATE representatividade_stg SET partido = 'AVANTE' WHERE trim(partido) = 'PT do B';
UPDATE representatividade_stg SET partido = 'AGIR' WHERE trim(partido) = 'PTC';
--IMPORTANTE

INSERT INTO representatividade(partido, deputados, ano)SELECT trim(partido), SUM(deputados), ano FROM representatividade_stg GROUP BY 1, 3;
UPDATE tempo_mandato_stg SET nome = UPPER(nome);
UPDATE tempo_mandato_stg SET nome = 'MAJOR VITOR HUGO' WHERE trim(nome) = 'VITOR HUGO';
UPDATE tempo_mandato_stg SET nome = 'ALENCAR SANTANA' WHERE trim(nome) = 'ALENCAR SANTANA BRAGA';
UPDATE tempo_mandato_stg SET nome = 'DOUTOR LUIZINHO' WHERE trim(nome) = 'DR. LUIZ ANTONIO TEIXEIRA JR.';
UPDATE tempo_mandato_stg SET nome = 'CAPITÃO DERRITE' WHERE trim(nome) = 'GUILHERME DERRITE';
UPDATE tempo_mandato_stg SET nome = 'PAULINHO DA FORÇA' WHERE trim(nome) = 'PAULO PEREIRA DA SILVA';
UPDATE tempo_mandato_stg SET nome = 'MAJOR VITOR HUGO' WHERE trim(nome) = 'RENATO QUEIROZ';

INSERT INTO tempo_mandato(iddeputado, legislatura)
SELECT DISTINCT bar.iddeputado, foo.legislatura FROM (select legislatura::integer, trim(UPPER(nome)) AS nome, dias::integer from tempo_mandato_stg) foo JOIN (select idlegislatura::integer AS legislatura, trim(UPPER(nome)) AS nome, iddeputado from deputado_stg) bar USING(nome, legislatura) WHERE (legislatura IN(54,55) AND dias::integer = 1460) OR (legislatura = 56 AND dias = 1221);

INSERT INTO cota_uf(uf, cota, pos54)SELECT uf, replace(cota, ',', '.')::numeric, pos54 FROM cota_uf_stg;

UPDATE deputado_stg SET siglapartido = 'SOLIDARIEDADE' WHERE siglapartido = 'SD';
UPDATE deputado_stg SET siglapartido = 'CIDADANIA' WHERE siglapartido = 'PPS';
UPDATE deputado_stg SET siglapartido = 'PATRIOTA' WHERE siglapartido = 'PATRI';
UPDATE deputado_stg SET siglapartido = 'PATRIOTA' WHERE siglapartido = 'PRP';
UPDATE deputado_stg SET siglapartido = 'REPUBLICANOS' WHERE siglapartido = 'PRB';
UPDATE deputado_stg SET siglapartido = 'MDB' WHERE siglapartido = 'PMDB';
UPDATE deputado_stg SET siglapartido = 'PODEMOS' WHERE siglapartido = 'PHS';
UPDATE deputado_stg SET siglapartido = 'PCdoB' WHERE siglapartido = 'PC do B';
UPDATE deputado_stg SET siglapartido = 'PCdoB' WHERE siglapartido = 'PPL';
--UPDATE deputado_stg SET siglapartido = 'UNIÃO' WHERE siglapartido = 'PSL';
--UPDATE deputado_stg SET siglapartido = 'UNIÃO' WHERE siglapartido = 'DEM';
UPDATE deputado_stg SET siglapartido = 'REPUBLICANOS' WHERE siglapartido = 'PRB';
UPDATE deputado_stg SET siglapartido = 'PODEMOS' WHERE siglapartido = 'PODE';
UPDATE deputado_stg SET siglapartido = 'PODEMOS' WHERE siglapartido = 'PTN';
UPDATE deputado_stg SET siglapartido = 'PATRIOTA' WHERE siglapartido = 'PEN';
UPDATE deputado_stg SET siglapartido = 'DC' WHERE siglapartido = 'PSDC';
UPDATE deputado_stg SET siglapartido = 'AVANTE' WHERE siglapartido = 'PTdoB';
UPDATE deputado_stg SET siglapartido = 'AGIR' WHERE siglapartido = 'PTC';
UPDATE deputado_stg SET siglapartido = 'PP' WHERE siglapartido = 'PP**';
UPDATE deputado_stg SET siglapartido = 'MDB' WHERE siglapartido = 'PMDB';

INSERT INTO deputado SELECT * FROM deputado_stg;
UPDATE deputado SET siglapartido = trim(siglapartido);

INSERT INTO dados(ano, mes, legislatura, anolegislatura, uf, partido, tipo, eleitores, distancia, vagas, representatividade, valor)
SELECT 
    c.ano, c.mes, c.legislatura, 
    CASE 
        WHEN c.ano = 2013 THEN 3
        WHEN c.ano = 2014 THEN 4 
        WHEN c.ano = 2015 AND legislatura = 54 THEN 5 
        WHEN c.ano = 2015 THEN '1' 
        WHEN c.ano = 2016 THEN '2' 
        WHEN c.ano = 2017 THEN '3' 
        WHEN c.ano = 2018 THEN '4' 
        WHEN c.ano = 2019 THEN '1' 
        WHEN c.ano = 2020 THEN '2' 
        WHEN c.ano = 2021 THEN '3' 
        WHEN c.ano = 2022 THEN '4' END, 
    c.uf, c.partido, c.tipo, e.total, ca.distancia, v.vagas, COALESCE(r.deputados, 0), c.valor AS valor
FROM eleitor e 
JOIN ceap c ON e.uf = c.uf AND ((e.ano = 2010 AND c.legislatura = 54) OR (e.ano = 2014 AND c.legislatura = 55) OR (e.ano = 2018 AND c.legislatura = 56))
JOIN capitais ca ON e.uf = ca.uf
JOIN vagas v ON e.uf = v.uf
LEFT JOIN representatividade r ON r.partido = c.partido AND ((r.ano = 2010 AND c.legislatura = 54) OR (r.ano = 2014 AND c.legislatura = 55) OR (r.ano = 2018 AND c.legislatura = 56))
WHERE valor > 0;

-- SELECT SUM(valor/vagas), SUM(valor/e.total), c.ano, c.uf, tipo 
-- FROM ceap c
-- JOIN vagas USING(uf) JOIN capitais ca USING(uf)
-- JOIN eleitor e ON e.uf = c.uf AND ((e.ano = 2014 AND c.legislatura = 55) OR (e.ano = 2018 AND c.legislatura = 56))
-- WHERE c.ano <> 2022
-- GROUP BY c.ano, c.uf, c.tipo;


INSERT INTO dados_v2(ano, legislatura, anolegislatura, uf, tipo, eleitores, distancia, vagas, valor)
SELECT 
    c.ano, c.legislatura, 
        CASE
        WHEN c.ano = 2013 THEN 3
        WHEN c.ano = 2014 THEN 4 
        WHEN c.ano = 2015 THEN 1 
        WHEN c.ano = 2016 THEN 2 
        WHEN c.ano = 2017 THEN 3 
        WHEN c.ano = 2018 THEN 4 
        WHEN c.ano = 2019 THEN 1 
        WHEN c.ano = 2020 THEN 2 END, 
    c.uf, c.tipo, e.total, ca.distancia, v.vagas, c.valor AS valor
FROM eleitor e 
JOIN ceap c ON e.uf = c.uf AND ((e.ano = 2010 AND c.legislatura = 54) OR (e.ano = 2014 AND c.legislatura = 55) OR (e.ano = 2018 AND c.legislatura = 56))
JOIN capitais ca ON e.uf = ca.uf
JOIN vagas v ON e.uf = v.uf
WHERE valor > 0 AND c.ano <> 2022;
--GROUP BY 1, 2, 3, 4, 5, 6, 7;

INSERT INTO dados_v3(iddeputado, ano, mes, legislatura, meseslegislatura, anolegislatura, uf, tipo, eleitores, distancia, vagas, valor, cota)
SELECT 
    c.iddeputado, c.ano, c.mes, c.legislatura,
    CASE 
        WHEN c.ano = 2013 THEN 12 
        WHEN c.ano = 2014 THEN 12 
        WHEN c.ano = 2015 AND c.legislatura = 54 THEN 1
        WHEN c.ano = 2015 THEN 11 
        WHEN c.ano = 2016 THEN 12 
        WHEN c.ano = 2017 THEN 12
        WHEN c.ano = 2018 THEN 12 
        WHEN c.ano = 2019 AND c.legislatura = 55 THEN 1
        WHEN c.ano = 2019 THEN 11
        WHEN c.ano = 2020 THEN 12 
        WHEN c.ano = 2021 THEN 12 END,
    CASE 
        WHEN c.ano = 2014 THEN 4 
        WHEN c.ano = 2015 AND c.legislatura = 54 THEN 5
        WHEN c.ano = 2015 THEN 1 
        WHEN c.ano = 2016 THEN 2 
        WHEN c.ano = 2017 THEN 3 
        WHEN c.ano = 2018 THEN 4 
        WHEN c.ano = 2019 AND c.legislatura = 55 THEN 5 
        WHEN c.ano = 2019 THEN 1 
        WHEN c.ano = 2020 THEN 2 
        WHEN c.ano = 2021 THEN 3 END, 
    c.uf, c.tipo, e.total, ca.distancia, v.vagas, c.valor AS valor, cuf.cota
FROM  eleitor e
JOIN ceap c ON e.uf = c.uf AND ((e.ano = 2010 AND c.legislatura = 54) OR (e.ano = 2014 AND c.legislatura = 55) OR (e.ano = 2018 AND c.legislatura = 56))
JOIN capitais ca ON e.uf = ca.uf
JOIN vagas v ON e.uf = v.uf
JOIN tempo_mandato tm ON c.iddeputado = tm.iddeputado AND c.legislatura = tm.legislatura
JOIN cota_uf cuf ON cuf.uf = c.uf AND ((c.legislatura = 54 AND NOT cuf.pos54) OR (c.legislatura > 54 AND cuf.pos54))
WHERE c.ano <> 2022;

DELETE FROM dados_v3 WHERE legislatura = 56 AND anolegislatura = '1' AND iddeputado IN(
    SELECT iddeputado 
        FROM (
            SELECT sum(valor)AS valor, iddeputado
            FROM dados_v3 
            WHERE legislatura = 56 AND anolegislatura = '1'
            GROUP BY iddeputado, anolegislatura, legislatura 
     ) foo
     WHERE valor < 4000
);

DELETE FROM dados_v3 WHERE legislatura = 55 AND anolegislatura = '1' AND iddeputado IN(
    SELECT iddeputado 
        FROM (
            SELECT sum(valor)AS valor, iddeputado
            FROM dados_v3 
            WHERE legislatura = 55 AND anolegislatura = '1'
            GROUP BY iddeputado, anolegislatura, legislatura 
     ) foo
     WHERE valor < 2000
);


-- select *, max-sum AS diff from (select sum(valor), iddeputado, anolegislatura, legislatura, MAX(cotalegislatura) from dados_v3 group by iddeputado, anolegislatura, legislatura) foo where iddeputado IN(193726, 73781) order by 2;

DROP TABLE IF EXISTS agregado_tipo;
CREATE TABLE IF NOT EXISTS agregado_tipo(
iddeputado integer, 
anolegislatura integer, 
legislatura integer, 
tipo text, 
siglapartido text, 
siglauf text, 
meses integer,
distancia integer, 
eleitores integer, 
vagas integer,
representatividade integer,
valor numeric(20,2),
contagem integer
);

DROP TABLE IF EXISTS agregado_ano;
CREATE TABLE IF NOT EXISTS agregado_ano(
iddeputado integer, 
anolegislatura integer, 
legislatura integer,
siglapartido text, 
siglauf text, 
meses integer,
cota numeric(20,2),
distancia integer, 
eleitores integer, 
vagas integer,
representatividade integer,
valor numeric(20,2),
contagem integer
);

DROP TABLE IF EXISTS contagem;
CREATE TABLE IF NOT EXISTS contagem(
anolegislatura integer, 
legislatura integer,
siglapartido text, 
siglauf text, 
tipo text,
iddeputado integer,
ano integer,
mes integer,
distancia integer, 
eleitores integer, 
vagas integer,
representatividade integer,
valor numeric(20,2),
contagem integer
);

--dados quebrados por ano-> tem a porcentagem da cota gasta

--dados quebrados por tipo
INSERT INTO agregado_tipo(iddeputado, anolegislatura, legislatura, tipo, siglapartido, siglauf, meses, distancia, eleitores, vagas, representatividade, valor, contagem)
select iddeputado, anolegislatura, legislatura, tipo, siglapartido, siglauf, meses, distancia, eleitores, vagas, deputados, valor, contagem from (select sum(valor) AS valor, count(*) AS contagem, iddeputado, anolegislatura, legislatura, tipo, MAX(meseslegislatura) AS meses, MAX(distancia) AS distancia, MAX(eleitores) AS eleitores, MAX(vagas) AS vagas from dados_v3 group by iddeputado, anolegislatura, legislatura, tipo) foo  JOIN deputado d USING(legislatura, iddeputado) left join representatividade r ON trim(r.partido) = trim(d.siglapartido) AND ((r.ano = 2014 AND foo.legislatura = 55) OR (r.ano = 2018 AND foo.legislatura = 56) OR (r.ano = 2010 AND foo.legislatura = 54));
;

--dados quebrados por ano-> tem a porcentagem da cota gasta
INSERT INTO agregado_ano(iddeputado, anolegislatura, legislatura, siglapartido, siglauf, cota, meses, distancia, eleitores, vagas, representatividade, valor, contagem)
select iddeputado, anolegislatura, legislatura, siglapartido, siglauf, cota, meses, distancia, eleitores, vagas, deputados, case when valor > cota*meses then cota*meses else valor end AS valor, contagem from (select sum(valor) AS valor, count(*) AS contagem, iddeputado, anolegislatura, legislatura, MAX(meseslegislatura) AS meses, MAX(cota) AS cota, MAX(distancia) AS distancia, MAX(eleitores) AS eleitores, MAX(vagas) AS vagas from dados_v3 group by iddeputado, anolegislatura, legislatura) foo join deputado d USING(iddeputado, legislatura)  left join representatividade r ON trim(r.partido) = trim(d.siglapartido) AND ((r.ano = 2014 AND foo.legislatura = 55) OR (r.ano = 2018 AND foo.legislatura = 56) OR (r.ano = 2010 AND foo.legislatura = 54));
;

--dados contagem
INSERT INTO contagem(anolegislatura, legislatura, siglapartido, siglauf, tipo, iddeputado, ano, mes, distancia, eleitores, vagas, representatividade, valor, contagem)
select anolegislatura, legislatura, c.partido, c.uf, c.tipo, c.iddeputado, c.ano, c.mes, ca.distancia AS distancia, e.total AS eleitores, vagas, r.deputados, valor, contagem 
from (
	select count(*) AS contagem, sum(valor) AS valor, anolegislatura, legislatura, partido, uf, tipo, iddeputado, ano, mes
	FROM (
		select CASE 
                WHEN ano = 2014 THEN 4 
                WHEN ano = 2015 AND legislatura = 54 THEN 5
                WHEN ano = 2015 THEN 1 
                WHEN ano = 2016 THEN 2 
                WHEN ano = 2017 THEN 3 
                WHEN ano = 2018 THEN 4 
                WHEN ano = 2019 AND legislatura = 55 THEN 5 
                WHEN ano = 2019 THEN 1 
                WHEN ano = 2020 THEN 2 
                WHEN ano = 2021 THEN 3 END AS anolegislatura, legislatura, partido, uf, tipo, iddeputado, ano, mes, valor
		from ceap
		WHERE ano <> 2022
		) foo
    group by anolegislatura, legislatura, partido, uf, tipo, iddeputado, ano, mes
) c
JOIN eleitor e ON e.uf = c.uf AND ((e.ano = 2010 AND c.legislatura = 54) OR (e.ano = 2014 AND c.legislatura = 55) OR (e.ano = 2018 AND c.legislatura = 56))
JOIN capitais ca ON e.uf = ca.uf
JOIN vagas v ON e.uf = v.uf
JOIN cota_uf cuf ON cuf.uf = c.uf AND ((c.legislatura = 54 AND NOT cuf.pos54) OR (c.legislatura > 54 AND cuf.pos54))
LEFT JOIN representatividade r ON trim(r.partido) = trim(c.partido) AND ((r.ano = 2014 AND c.legislatura = 55) OR (r.ano = 2018 AND c.legislatura = 56) OR (r.ano = 2010 AND c.legislatura = 54));
--where NOT (iddeputado = 74043 and mes = 2 and ano = 2015);

DROP TABLE IF EXISTS contagem_v3;
CREATE TABLE IF NOT EXISTS contagem_v3(
anolegislatura integer, 
legislatura integer,
partido text, 
uf text, 
tipo text,
iddeputado integer,
ano integer,
mes integer,
distancia integer, 
eleitores integer, 
vagas integer,
representatividade integer,
valor numeric(20,2),
contagem integer
);

INSERT INTO contagem_v3(anolegislatura, legislatura, partido, uf, tipo, iddeputado, ano, mes, distancia, eleitores, vagas, representatividade, valor, contagem)
select anolegislatura, legislatura, c.partido, uf, tipo, iddeputado, c.ano, c.mes, distancia, eleitores, vagas, r.deputados, valor, contagem 
from (
	select count(*) AS contagem, sum(valor) AS valor, anolegislatura, legislatura, partido, uf, tipo, iddeputado, ano, mes, MAX(distancia) AS distancia, MAX(eleitores) AS eleitores, MAX(vagas) AS vagas, MAX(cota) AS cota
	FROM dados_v3
        group by anolegislatura, legislatura, partido, uf, tipo, iddeputado, ano, mes
) c
LEFT JOIN representatividade r ON trim(r.partido) = trim(c.partido) AND ((r.ano = 2014 AND c.legislatura = 55) OR (r.ano = 2018 AND c.legislatura = 56) OR (r.ano = 2010 AND c.legislatura = 54));

--validação de dados
--select * from ceap c WHERE NOT EXISTS(SELECT FROM dados d WHERE d.id_ceap = c.id);

-- ALTER TABLE dados DROP COLUMN id;
-- ALTER TABLE dados DROP COLUMN id_ceap;
-- ALTER TABLE dados DROP COLUMN id_eleitor;
-- ALTER TABLE dados DROP COLUMN id_capital;

commit;
