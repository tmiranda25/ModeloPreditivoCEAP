#ATENÇÃO O COMANDO ABAIXO LIMPA A MEMÓRIA
rm(list = ls())
source("init.R")

#################################################################################
#                 LENDO OS DADOS                                                #
#################################################################################
combustiveis <- read.csv("../dados/combustiveis.csv")
rownames(combustiveis) <- combustiveis$uf
combustiveis$uf <- NULL
combustiveis$vagas <- NULL
#################################################################################
#                 OBSERVANDO OS DADOS CARREGADOS DO DATASET                     #
#################################################################################

#Plotando a relação entre as variáveis
combustiveis %>% plot()

#Lista a tabela, limitado a 100 ou número de linhas
f_tabela(combustiveis)

#Visualizando as observações e as especificações referentes às variáveis do dataset
glimpse(combustiveis) 

#Estatísticas univariadas
summary(combustiveis)

#Verificamos a existência de correlação entre as variáveis
#Requer instalação e carregamento dos pacotes see e ggraph para a plotagem
combustiveis %>%
  correlation(method = "pearson") %>%
  plot()

#Estimando a Regressão Múltipla
f_lm(combustiveis, valor ~ .)


####################################################################
#Removendo as variáveis explicativas que apresentam alta correlação
####################################################################
combustiveis <- combustiveis %>% dplyr::select(-one_of(c("cota", "eleitores")))

combustiveis %>%
  correlation(method = "pearson") %>%
  plot()


f_lm(combustiveis, valor ~ .)

###########  BOX-COX  #####################
f_boxcox(combustiveis)


############  FIM  ########################


####################################################################################
#REMOVEMOS A VARIÁVEL PREDITORA QUE APRESENTA ALTA CORRELAÇÃO COM A DEPENDENTE
####################################################################################
combustiveis <- combustiveis %>% dplyr::select(-one_of(c("eleitores")))
combustiveis$eleitores <- NULL

combustiveis %>%
  correlation(method = "pearson") %>%
  plot()

f_lm(combustiveis, valor ~ .)

########## STEPWISE #######################

lm_model <- lm(formula = valor ~ .,
               data = combustiveis)
k <- qchisq(p = 0.05, df = 1, lower.tail = F)
  
lm_model = step(lm_model, k = k)    
lm_model
#Visualizando o modelo
print(summary(lm_model))

############  FIM  ########################



######  BOX-COX STEPWISE  #################

f_boxcox(combustiveis, step=TRUE)

#dummies
combustiveis_dummies <- dummy_columns(.data = combustiveis,
                              select_columns = c("legislatura"),
                              remove_selected_columns = T,
                              remove_most_frequent_dummy = T)

modelo_combustiveis_dummies <- lm(formula = valor ~ . -valor_bc,
                          data = combustiveis_dummies)
#Parâmetros do modelo

summary(modelo_combustiveis_dummies)

confint(modelo_combustiveis_dummies, level = 0.95) # significância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_combustiveis_dummies, confint = T, digits = 3, ci.width = .95)

export_summs(modelo_combustiveis_dummies, scale = F, digits = 5)

sf.test(modelo_combustiveis_dummies$residuals)

ols_vif_tol(modelo_combustiveis_dummies)

ols_test_breusch_pagan(modelo_combustiveis_dummies)

bptest(modelo_combustiveis_dummies)

modelo_combustiveis_bc %>% plot()

#stepwise
k <- qchisq(p = 0.05, df = 1, lower.tail = F)
modelo_step_dummies = step(modelo_combustiveis_dummies, k = k)
summary(modelo_step_dummies)
#Este procedimento no R removeu a variável 'endividamento'. Note que a variável
#'disclosure' também acabou sendo excluída após o procedimento Stepwise, nesta
#forma funcional linear!

export_summs(modelo_step_dummies, scale = F, digits = 5)

sf.test(modelo_step_dummies$residuals)

hist(modelo_combustiveis_dummies$residuals)

confint(modelo_combustiveis_dummies, level = 0.90) # siginificância de 5%

ggplotly(
  combustiveis %>% 
    ggplot() +
    geom_point(aes(x = distancia, y = valor),
               color = "grey20", alpha = 0.6, size = 2) +
    labs(x = "Distancia",
         y = "Valor") +
    theme_bw()
)

table(combustiveis$tipo)

a <- combustiveis %>% dplyr::filter(valor > 0)

lambda_BC <- powerTransform(combustiveis$valor)
lambda_BC

MASS::boxcox(combustiveis)

combustiveis %>%
  mutate(residuos = modelo_combustiveis$residuals) %>%
  ggplot(aes(x = residuos)) +
  geom_histogram(aes(y = ..density..), 
                 color = "grey50", 
                 fill = "grey90", 
                 bins = 30,
                 alpha = 0.6) +
  stat_function(fun = dnorm, 
                args = list(mean = mean(modelo_combustiveis$residuals),
                            sd = sd(modelo_combustiveis$residuals)),
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

summary(combustiveis$valor)
a <- sd(combustiveis$valor)
var(combustiveis$valor)

z <- 1.96
b <- 100
num = nrow(combustiveis)*var(combustiveis$valor)
den = (nrow(combustiveis)-1)*(b*b)/(z*z)+var(combustiveis$valor)

n = num/den
n
