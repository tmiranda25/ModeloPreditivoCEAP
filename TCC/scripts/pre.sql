/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 * Author:  thiago
 * Created: 13 de mai. de 2022
 */
begin;
--create user tcc with password 'tcc';
--create database tcc with owner tcc;
DROP TABLE IF EXISTS ceap_stg;
create table ceap_stg(
txNomeParlamentar text,
cpf text,
ideCadastro text,
nuCarteiraParlamentar text,
nuLegislatura text,
sgUF text,
sgPartido text,
codLegislatura text,
numSubCota text,
txtDescricao text,
numEspecificacaoSubCota text,
txtDescricaoEspecificacao text,
txtFornecedor text,
txtCNPJCPF text,
txtNumero text,
indTipoDocumento text,
datEmissao text,
vlrDocumento text,
vlrGlosa text,
vlrLiquido text,
numMes text,
numAno text,
numParcela text,
txtPassageiro text,
txtTrecho text,
numLote text,
numRessarcimento text,
vlrRestituicao text,
nuDeputadoId text,
ideDocumento text,
urlDocumento text
);

DROP TABLE IF EXISTS eleitor_stg;
create table if not exists eleitor_stg(
NR_ANO_ELEICAO text,
CD_PAIS text,
NM_PAIS text,
SG_REGIAO text,
NM_REGIAO text,
SG_UF text,
NM_UF text,
CD_MUNICIPIO text,
NM_MUNICIPIO text,
QTD_ELEITORES text,
QTD_ELEITORES_FEMININO text,
QTD_ELEITORES_MASCULINO text,
QTD_ELEITORES_NAOINFORMADO text,
QTD_ELEITORES_MENOR16 text,
QTD_ELEITORES_16 text,
QTD_ELEITORES_17 text,
QTD_ELEITORES_18 text,
QTD_ELEITORES_19 text,
QTD_ELEITORES_20 text,
QTD_ELEITORES_21A24 text,
QTD_ELEITORES_25A29 text,
QTD_ELEITORES_30A34 text,
QTD_ELEITORES_35A39 text,
QTD_ELEITORES_40A44 text,
QTD_ELEITORES_45A49 text,
QTD_ELEITORES_50A54 text,
QTD_ELEITORES_55A59 text,
QTD_ELEITORES_60A64 text,
QTD_ELEITORES_65A69 text,
QTD_ELEITORES_70A74 text,
QTD_ELEITORES_75A79 text,
QTD_ELEITORES_80A84 text,
QTD_ELEITORES_85A89 text,
QTD_ELEITORES_90A94 text,
QTD_ELEITORES_95A99 text,
QTD_ELEITORES_MAIORIGUAL100 text,
QTD_ELEITORES_IDADEINVALIDO text,
QTD_ELEITORES_IDADENAOSEAPLICA text,
QTD_ELEITORES_IDADENAOINFORMADA text,
QTD_ELEITORES_COMBIOMETRIA text,
QTD_ELEITORES_SEMBIOMETRIA text,
QTD_ELEITORES_DEFICIENTE text,
QUANTITATIVO_NOMESOCIAL text);

ALTER TABLE eleitor_stg ALTER COLUMN qtd_eleitores TYPE integer USING qtd_eleitores::integer;
ALTER TABLE eleitor_stg ALTER COLUMN qtd_eleitores_masculino TYPE integer USING qtd_eleitores_masculino::integer;
ALTER TABLE eleitor_stg ALTER COLUMN qtd_eleitores_feminino TYPE integer USING qtd_eleitores_feminino::integer;
ALTER TABLE eleitor_stg ALTER COLUMN qtd_eleitores_naoinformado TYPE integer USING qtd_eleitores_naoinformado::integer;

DROP TABLE IF EXISTS eleitor2010_stg;
create table if not exists eleitor2010_stg(
uf text,
eleitores integer);

DROP TABLE IF EXISTS capitais_stg;
create table capitais_stg(
capital text,
distancia text,
uf text
);

drop table if exists representatividade_stg;
create table representatividade_stg(
partido text,
deputados integer,
ano integer
);

DROP TABLE IF EXISTS vagas_stg;
create table vagas_stg(
uf text,
vagas text
);

DROP TABLE IF EXISTS tempo_mandato_stg;
create table tempo_mandato_stg(
legislatura text,
nome text,
carteira text,
dias text
);

DROP TABLE IF EXISTS cota_uf_stg;
create table cota_uf_stg(
uf text,
cota text,
pos54 bool
);

DROP TABLE IF EXISTS deputado_stg;
create table deputado_stg(
    iddeputado integer not null,
    nome text not null,
    siglapartido text not null,
    siglauf text,
    idlegislatura integer,
    carteira integer,
    PRIMARY KEY(iddeputado, idlegislatura)
);
commit;
