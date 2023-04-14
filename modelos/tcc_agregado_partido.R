#ATENÇÃO O COMANDO ABAIXO LIMPA A MEMÓRIA
rm(list = ls())
source("init.R")

#################################################################################
#                 LENDO OS DADOS                                                #
#################################################################################
ceap_partido <- read.csv("../dados/partido.csv")
rownames(ceap_partido) <- ceap_partido$partido
ceap_partido$partido <- NULL
#################################################################################
#                 OBSERVANDO OS DADOS CARREGADOS DO DATASET                     #
#################################################################################

ceap_partido <- ceap_partido %>% drop_na()

#Plotando a relação entre as variáveis
ceap_partido %>% plot()

#Lista a tabela, limitado a 100 ou número de linhas
f_tabela(ceap_partido)

#Visualizando as observações e as especificações referentes às variáveis do dataset
glimpse(ceap_partido) 

#Estatísticas univariadas
summary(ceap_partido)

#Verificamos a existência de correlação entre as variáveis
#Requer instalação e carregamento dos pacotes see e ggraph para a plotagem
ceap_partido %>%
  correlation(method = "pearson") %>%
  plot()

#Estimando a Regressão Múltipla
f_lm(ceap_partido, valor ~ .)

###########  BOX-COX  #####################
bc <- f_boxcox(ceap_partido)
df <- data.frame(deputados = 100)
predict(object = bc$model,
        df,
        interval = "confidence", level = 0.95)

############  FIM  ########################