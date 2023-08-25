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

###########Estimando a Regressão Simples#########
result_lm <- f_lm(ceap_uf, valor ~ .)
summ(result_lm)
export_summs(result_lm, digits = 6)
ols_test_breusch_pagan(result_lm)

final <- data.frame(ceap_uf)
temp <- data.frame(predict(result_lm, new_data = ceap_uf$valor, interval = "prediction"))
final <- cbind(final, temp)


ggplot(data = final, aes(x = distancia, y = valor)) +
  geom_point() +
  geom_smooth(method = "lm", color = "green", se = TRUE, level = .95) +
  geom_line(data = final, aes(x = distancia, y = final$lwr), linetype = "dashed", color = "red") +
  geom_line(data = final, aes(x = distancia, y = final$upr), linetype = "dashed", color = "red") +
  xlab("Distância entre Capitais (Km)") +
  ylab("Porcentagem da Cota Gasta com Mobilidade") + theme_classic()


###########  BOX-COX  #####################
lambda <- powerTransform(ceap_uf$valor)
lambda
ceap_uf$valor_bc = y2ybc(ceap_uf$valor, lambda$lambda)
model_bc <- lm(formula = valor_bc ~ . - valor, data = ceap_uf)
export_summs(model_bc, digits=6)
ols_test_breusch_pagan(model_bc)


bptest(model_bc)

shapiro.test(model_bc$residuals)

sf.test(model_bc$residuals)

hist(model_bc$residuals)

f_grafico_residuos(ceap_uf, model_bc$residuals)

confint(model_bc, level = 0.95) # siginificância de 5%

source("y_boxcox.R")

temp  <- data.frame(predict(model_bc, new_data = ceap_uf$valor, interval = "prediction"))
#ceap_uf$pbc <- predict(model_bc, new_data = ceap_uf$valor_bc, interval = "prediction")

final$p_fit <- ybc2y(temp$fit, lambda$lambda)
final$p_lwr <- ybc2y(temp$lwr, lambda$lambda)
final$p_upr <- ybc2y(temp$upr, lambda$lambda)

temp  <- data.frame(predict(model_bc, new_data = ceap_uf$valor, interval = "confidence"))

final$c_fit <- ybc2y(temp$fit, lambda$lambda)
final$c_lwr <- ybc2y(temp$lwr, lambda$lambda)
final$c_upr <- ybc2y(temp$upr, lambda$lambda)

final$p_lwr[is.na(final$p_lwr)] <- 0
final$c_lwr[is.na(final$c_lwr)] <- 0

# load library ggplot2
library(ggplot2)

# create dataframe with actual and predicted values
plot_data <- data.frame(Predicted_value = final$p_fit,  
                        Observed_value = final$valor)

# plot predicted values and actual values
ggplot(plot_data, aes(x = Predicted_value, y = Observed_value)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1, color = "green")



ggplot(data = final, aes(x = distancia, y = valor)) +
  geom_point() +
  geom_line(data = final, aes(x = distancia, y = fit), color = "blue", linetype = 'dotted', alpha = 1, show.legend = TRUE) +
  geom_line(data = final, aes(x = distancia, y = p_fit), color = "green", size = 1.1, show.legend = TRUE) +
  geom_line(data = final, aes(x = distancia, y = p_lwr), linetype = "dashed", color = "red") +
  geom_line(data = final, aes(x = distancia, y = p_upr), linetype = "dashed", color = "red") +
  geom_ribbon(aes(ymin = c_lwr, ymax = c_upr), alpha = 0.15, fill = "grey50", colour = NA) + 
  xlab("Distância entre Capitais (Km)") +
  ylab("Valores ajustados") +
  theme(panel.background = element_rect("white"),
        panel.grid = element_line("grey95"),
        panel.border = element_rect(NA),
        legend.position = c(.75, .25))

final %>%
  ggplot() +
  geom_smooth(aes(x = distancia, y = fit, color = "OLS Linear"),
              method = "lm", se = F, formula = y ~ splines::bs(x, df = 5), size = 1.5) +
  geom_point(aes(x = distancia, y = valor),
             color = "#FDE725FF", alpha = 0.6, size = 2) +
  geom_smooth(aes(x = distancia, y = p_fit, color = "Box-Cox"),
              method = "lm", se = F, formula = y ~ confint(model_bc, 0.95), size = 1.5) +
  geom_point(aes(x = distancia, y = p_fit),
             color = "#440154FF", alpha = 0.6, size = 2) +
  geom_smooth(aes(x = distancia, y = valor), method = "lm", 
              color = "gray30", size = 1.05,
              linetype = "longdash") +
  scale_color_manual("Modelos:", 
                     values = c("#440154FF", "#FDE725FF")) +
  labs(x = "distancia", y = "Fitted Values") +
  theme(panel.background = element_rect("white"),
        panel.grid = element_line("grey95"),
        panel.border = element_rect(NA),
        legend.position = "bottom")
########### MASS  BOX-COX  #####################
lambda <- 0.5
hist(ceap_uf$valor)
result_box <- MASS::boxcox(lm(data = ceap_uf, formula = valor ~ .), lambda = seq(-10, 10, 0.5))
result_box$x[which.max(result_box$y)]

ceap_uf$valor_bc <- (((ceap_uf$valor ^ lambda) - 1) / 
                       lambda)

bc_model <- lm(formula = valor_bc ~ . -valor,
               data = ceap_uf)

plot(bc_model)
print(summary(bc_model))

bptest(bc_model)

ols_test_breusch_pagan(bc_model)

shapiro.test(bc_model$residuals)

sf.test(bc_model$residuals)

hist(bc_model$residuals)

f_grafico_residuos(ceap_uf, bc_model$residuals)


ceap_uf$valor_bc = y2ybc(ceap_uf$valor, lambda)

#ceap_uf$pbc <- predict(model_bc, new_data = ceap_uf$valor, interval = "prediction")
ceap_uf$pbc <- predict(bc_model, new_data = ceap_uf$valor_bc, interval = "prediction")

ceap_uf$p_fit <- ybc2y(ceap_uf$pbc[,'fit'], lambda)
ceap_uf$p_lwr <- ybc2y(ceap_uf$pbc[,'lwr'], lambda)
ceap_uf$p_upr <- ybc2y(ceap_uf$pbc[,'upr'], lambda)

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
  geom_smooth(method = "lm", color = "green", se = TRUE, level = .95) +
  geom_line(data = ceap_uf, aes(x = distancia, y = p_lwr), linetype = "dashed", color = "red") +
  geom_line(data = ceap_uf, aes(x = distancia, y = p_upr), linetype = "dashed", color = "red") +
  xlab("Distância entre Capitais (Km)") +
  ylab("Porcentagem da Cota Gasta com Mobilidade") + theme_classic()

