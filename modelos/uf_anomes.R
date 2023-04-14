rm(list = ls())
source("init.R")

#################################################################################
#                 LENDO OS DADOS                                                #
#################################################################################

ceap_uf <- read.csv("../dados/ufanomes.csv")

#################################################################################
#                 OBSERVANDO OS DADOS CARREGADOS DO DATASET                     #
#################################################################################

ceap_uf$valor <- ceap_uf$valor/ceap_uf$vagas
ceap_uf <- ceap_uf %>% dplyr::select(-one_of(c("vagas", "cota", "eleitores")))

#Plotando a relação entre as variáveis
ceap_uf %>% plot()

ceap_uf[1:100,] %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped",
                full_width = F,
                font_size = 12)

#Visualizando as observações e as especificações referentes às variáveis do dataset
glimpse(ceap_uf) 

#Estatísticas univariadas
summary(ceap_uf)

#Verificamos a existência de correlação entre as variáveis
#Requer instalação e carregamento dos pacotes see e ggraph para a plotagem
ceap_uf %>%
  correlation(method = "pearson") %>%
  plot()

#Estimando a Regressão Múltipla
modelo_ceap_uf <- lm(formula = valor ~ .,
                  data = ceap_uf)

anova(modelo_ceap_uf)
#Parâmetros do modelo
summary(modelo_ceap_uf)

confint(modelo_ceap_uf, level = 0.95) # significância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap_uf, confint = T, digits = 3, ci.width = .99)

export_summs(modelo_ceap_uf, scale = F, digits = 5)

hist(modelo_ceap_uf$residuals, breaks=100)

chart_lm_residuals(modelo_ceap_uf)

sf.test(modelo_ceap_uf$residuals)

ols_vif_tol(modelo_ceap_uf)

####################################################################
#Removendo as variáveis explicativas que apresentam alta correlação
####################################################################
ceap_uf <- ceap_uf %>% dplyr::select(-one_of(c("cota")))

#Estimando a Regressão Múltipla
modelo_ceap_uf <- lm(formula = valor ~ .,
                     data = ceap_uf)

#Visualizando o modelo
summary(modelo_ceap_uf)

ols_vif_tol(modelo_ceap_uf)

ols_test_breusch_pagan(modelo_ceap_uf)

library(lmtest)

bptest(modelo_ceap_uf)

####################################################################################
#REMOVEMOS A VARIÁVEL PREDITORA QUE APRESENTA ALTA CORRELAÇÃO COM A EXPLICATIVA
####################################################################################
ceap_uf <- ceap_uf %>% dplyr::select(-one_of(c("vagas")))

#Estimando a Regressão Múltipla
modelo_ceap_uf <- lm(formula = valor/vagas ~ distancia,
                     data = ceap_uf)

#Visualizando o modelo
summary(modelo_ceap_uf)

ols_vif_tol(modelo_ceap_uf)

ols_test_breusch_pagan(modelo_ceap_uf)

library(lmtest)

bptest(modelo_ceap_uf)

########## STEPWISE #######################
k <- qchisq(p = 0.05, df = 1, lower.tail = F)

modelo_ceap_uf_step = step(modelo_ceap_uf, k = k)

summary(modelo_ceap_uf_step)

sf.test(modelo_ceap_uf$residuals)

chart_lm_residuals(modelo_ceap_uf_step)

############  FIM  ########################

###########  BOX-COX  #####################

#ceap_uf$valor_positivo <- ceap_uf$valor+(-1*min(ceap_uf$valor))+1

lambda_BC <- powerTransform(ceap_uf$valor)
lambda_BC

ceap_uf$valor_bc <- (((ceap_uf$valor ^ lambda_BC$lambda) - 1) / 
                    lambda_BC$lambda)


modelo_ceap_uf_bc <- lm(formula = valor_bc ~ . -valor,
                  data = ceap_uf)

summary(modelo_ceap_uf_bc)

anova(modelo_ceap_uf_bc)
fix(sf.test)
sf.test(modelo_ceap_uf_bc$residuals)
hist(modelo_ceap_uf_bc$residuals, breaks=10)
############  FIM  ########################

######  BOX-COX STEPWISE  #################

modelo_ceap_uf_bc_step = step(modelo_ceap_uf_bc, k = k)
summary(modelo_ceap_uf_bc_step)
sf.test(modelo_ceap_uf_bc_step$residuals)

chart_lm_residuals(modelo_ceap_uf_bc)

ols_vif_tol(modelo_ceap_uf_bc)

hist(modelo_ceap_uf_bc_step$residuals, breaks=100)

#dummies
ceap_uf_dummies <- dummy_columns(.data = ceap_uf,
                              select_columns = c("anolegislatura"),
                              remove_selected_columns = T,
                              remove_most_frequent_dummy = T)

modelo_ceap_uf_dummies <- lm(formula = valor ~ . -valor_bc -valor_positivo,
                          data = ceap_uf_dummies)
#Parâmetros do modelo
summary(modelo_ceap_uf_dummies)
confint(modelo_ceap_uf_dummies, level = 0.95) # siginificância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap_uf_dummies, confint = T, digits = 3, ci.width = .95)
export_summs(modelo_ceap_uf_dummies, scale = F, digits = 5)


#stepwise
k <- qchisq(p = 0.05, df = 1, lower.tail = F)
modelo_step_dummies = step(modelo_ceap_uf_dummies, k = k)
summary(modelo_step_dummies)
#Este procedimento no R removeu a variável 'endividamento'. Note que a variável
#'disclosure' também acabou sendo excluída após o procedimento Stepwise, nesta
#forma funcional linear!

export_summs(modelo_step_dummies, scale = F, digits = 5)

sf.test(modelo_step_dummies$residuals)

hist(modelo_ceap_uf_dummies$residuals)

confint(modelo_ceap_uf_dummies, level = 0.90) # siginificância de 5%

ggplotly(
  ceap_uf %>% 
    ggplot() +
    geom_point(aes(x = eleitores, y = valor),
               color = "grey20", alpha = 0.6, size = 2) +
    labs(x = "Eleitores",
         y = "Valor") +
    theme_bw()
)

table(ceap_uf$tipo)

a <- ceap_uf %>% dplyr::filter(valor > 0)

lambda_BC <- powerTransform(a$valor)
lambda_BC

MASS::boxcox(step_dummies)

ceap_uf %>%
  mutate(residuos = modelo_ceap_uf$residuals) %>%
  ggplot(aes(x = residuos)) +
  geom_histogram(aes(y = ..density..), 
                 color = "grey50", 
                 fill = "grey90", 
                 bins = 30,
                 alpha = 0.6) +
  stat_function(fun = dnorm, 
                args = list(mean = mean(modelo_ceap_uf$residuals),
                            sd = sd(modelo_ceap_uf$residuals)),
                aes(color = "Curva Normal Teórica"),
                size = 2) +
  scale_color_manual("Legenda:",
                     values = "#FDE725FF") +
  labs(x = "Resíduos",
       y = "Frequência") +
  theme(panel.background = element_rect("white"),
        panel.grid = element_line("grey95"),
        panel.border = element_rect(NA),
        legend.position = "bottom")

summary(ceap_uf$valor)
a <- sd(ceap_uf$valor)
var(ceap_uf$valor)

z <- 1.96
b <- 100
num = nrow(ceap_uf)*var(ceap_uf$valor)
den = (nrow(ceap_uf)-1)*(b*b)/(z*z)+var(ceap_uf$valor)

n = num/den
n
