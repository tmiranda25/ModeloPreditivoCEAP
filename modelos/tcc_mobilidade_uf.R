#ATENÇÃO O COMANDO ABAIXO LIMPA A MEMÓRIA
rm(list = ls())
source("init.R")

#################################################################################
#                 LENDO OS DADOS                                                #
#################################################################################
ceap_uf <- read.csv("../dados/mobilidade.csv")
rownames(ceap_uf) <- ceap_uf$uf
ceap_uf$uf <- NULL

#################################################################################
#                 OBSERVANDO OS DADOS CARREGADOS DO DATASET                     #
#################################################################################

#Plotando a relação entre as variáveis
ceap_uf %>% plot()

#Lista a tabela, limitado a 100 ou número de linhas
f_tabela(ceap_uf)

#Visualizando as observações e as especificações referentes às variáveis do dataset
glimpse(ceap_uf) 

#Estatísticas univariadas
summary(ceap_uf)

#Verificamos a existência de correlação entre as variáveis
#Requer instalação e carregamento dos pacotes see e ggraph para a plotagem
ceap_uf %>%
  correlation(method = "pearson") %>%
  plot()

#Estimando a Regressão Simples
f_lm(ceap_uf, valor ~ .)

###########  BOX-COX  #####################
result <- f_boxcox(ceap_uf)

ols_test_breusch_pagan(result$model)

bptest(result$model)

sf.test(result$model$residuals)

hist(result$model$residuals)

f_grafico_residuos(ceap_uf, result$model$residuals)

confint(result$model, level = 0.90) # siginificância de 5%

ceap_uf$pbc <- predict(result$model, new_data = ceap_uf$valor, interval = "prediction")

source("y_boxcox.R")

ceap_uf$p_fit <- ybc2y(ceap_uf$pbc[,'fit'], result$lambda)
ceap_uf$p_lwr <- ybc2y(ceap_uf$pbc[,'lwr'], result$lambda)
ceap_uf$p_upr <- ybc2y(ceap_uf$pbc[,'upr'], result$lambda)

# load library ggplot2
library(ggplot2)

# create dataframe with actual and predicted values
plot_data <- data.frame(Predicted_value = ceap_uf$p_fit,  
                        Observed_value = ceap_uf$valor)

# plot predicted values and actual values
ggplot(plot_data, aes(x = Predicted_value, y = Observed_value)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, color = "green")


ggplot(data = ceap_uf, aes(x = distancia, y = valor)) +
  geom_point() +
  geom_smooth(method = "lm", color = "green", se = TRUE) +
  geom_line(data = ceap_uf, aes(x = distancia, y = p_lwr), linetype = "dashed", color = "red") +
  geom_line(data = ceap_uf, aes(x = distancia, y = p_upr), linetype = "dashed", color = "red") +
  xlab("Distância entre Capitais (Km)") +
  ylab("Porcentagem da Cota Gasta com Mobilidade") + theme_classic()