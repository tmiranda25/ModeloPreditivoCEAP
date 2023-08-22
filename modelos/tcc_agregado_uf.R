#ATENÇÃO O COMANDO ABAIXO LIMPA A MEMÓRIA
rm(list = ls())
source("init.R")

#################################################################################
#                 LENDO OS DADOS                                                #
#################################################################################
ceap_uf <- read.csv("../dados/passagem.csv")
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

#Estimando a Regressão Múltipla
f_lm(ceap_uf, valor ~ .)


####################################################################
#Removendo as variáveis explicativas que apresentam alta correlação
####################################################################
ceap_uf <- ceap_uf %>% dplyr::select(-one_of(c("eleitores")))

ceap_uf %>%
  correlation(method = "pearson") %>%
  plot()


f_lm(ceap_uf, valor ~ .)

###########  BOX-COX  #####################
f_boxcox(ceap_uf)


############  FIM  ########################

####################################################################################
#REMOVEMOS A VARIÁVEL PREDITORA QUE APRESENTA ALTA CORRELAÇÃO COM A DEPENDENTE
####################################################################################
ceap_uf <- ceap_uf %>% dplyr::select(-one_of(c("distancia")))

ceap_uf %>%
  correlation(method = "pearson") %>%
  plot()

f_lm(ceap_uf, valor ~ .)

########## STEPWISE #######################

f_lm(ceap_uf, valor ~ ., step=TRUE)

############  FIM  ########################



######  BOX-COX STEPWISE  #################

f_boxcox(ceap_uf, step=TRUE)

#dummies
ceap_uf_dummies <- dummy_columns(.data = ceap_uf,
                              select_columns = c("legislatura"),
                              remove_selected_columns = T,
                              remove_most_frequent_dummy = T)

modelo_ceap_uf_dummies <- lm(formula = valor ~ . -valor_bc,
                          data = ceap_uf_dummies)
#Parâmetros do modelo

summary(modelo_ceap_uf_dummies)

confint(modelo_ceap_uf_dummies, level = 0.95) # significância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap_uf_dummies, confint = T, digits = 3, ci.width = .95)

export_summs(modelo_ceap_uf_dummies, scale = F, digits = 5)

sf.test(modelo_ceap_uf_dummies$residuals)

ols_vif_tol(modelo_ceap_uf_dummies)

ols_test_breusch_pagan(modelo_ceap_uf_dummies)

bptest(modelo_ceap_uf_dummies)

modelo_ceap_uf_bc %>% plot()

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
    geom_point(aes(x = distancia, y = valor),
               color = "grey20", alpha = 0.6, size = 2) +
    labs(x = "Distancia",
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
