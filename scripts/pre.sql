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
ano text,
uf text,
eleitores text);

ALTER TABLE eleitor_stg ALTER COLUMN eleitores TYPE integer USING eleitores::integer;

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
iddeputado text,
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
    PRIMARY KEY(iddeputado, idlegislatura)
);
commit;
