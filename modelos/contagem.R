rm(list = ls())


REMOVER O TIPO DOS DADOS

source("/media/thiago/Arquivos/web/TCC/src/r/init.R")
source("proportional_stratified_sampling.R")

contagem <- read.csv("./contagem.csv")
df_contagem <- contagem %>% dplyr::select("ano", "mes", "anolegislatura", "siglauf", "iddeputado", "siglapartido", "valor", "contagem")

df_contagem$anolegislatura <- as.factor(df_contagem$anolegislatura)
df_contagem$ano <- as.factor(df_contagem$ano)
df_contagem$siglapartido <- as.factor(df_contagem$siglapartido)
df_contagem$mes <- as.factor(df_contagem$mes)
df_contagem$siglauf <- as.factor(df_contagem$siglauf)
df_contagem$iddeputado <- as.factor(df_contagem$iddeputado)

summary(df_contagem)

#amostragem
cols <- c("ano", "mes", "siglauf")
value_col = "contagem"
z = 0.95
b <- 0.5

pss <- create_pss(df_contagem, value_col, cols, b = b, z = z)

df_sample1 <- sample_pss(pss)
df_sample1


modelo_contagem <- glm(formula = contagem ~ siglauf + ano + mes + siglapartido,
                  data = df_sample1,
                  family = 'poisson')
summary(modelo_contagem)
export_summs(modelo_contagem, scale = F, digits = 4)
modelo_contagem
