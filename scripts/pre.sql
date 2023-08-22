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
DROP TABLE IF EXISTS ceap_bruto;
create table ceap_bruto(
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
datPagamentoRestituicao text,
vlrRestituicao text,
nuDeputadoId text,
ideDocumento text,
urlDocumento text
);

DROP TABLE IF EXISTS eleitor_bruto;
create table if not exists eleitor_bruto(
ano text,
uf text,
eleitores text);

ALTER TABLE eleitor_bruto ALTER COLUMN eleitores TYPE integer USING eleitores::integer;

DROP TABLE IF EXISTS capitais_bruto;
create table capitais_bruto(
capital text,
distancia text,
uf text
);

drop table if exists representatividade_bruto;
create table representatividade_bruto(
partido text,
deputados text,
legislatura text
);

DROP TABLE IF EXISTS vagas_bruto;
create table vagas_bruto(
uf text,
vagas text
);

-- DROP TABLE IF EXISTS tempo_mandato_bruto;
-- create table tempo_mandato_bruto(
-- legislatura text,
-- iddeputado text,
-- dias text
-- );

DROP TABLE IF EXISTS cota_uf_bruto;
create table cota_uf_bruto(
uf text,
cota text
);

-- DROP TABLE IF EXISTS deputado_bruto;
-- create table deputado_bruto(
--     iddeputado integer not null,
--     nome text not null,
--     siglapartido text not null,
--     siglauf text,
--     idlegislatura integer,
--     PRIMARY KEY(iddeputado, idlegislatura)
-- );

commit;

