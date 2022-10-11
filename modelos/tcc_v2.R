rm(list = ls())
source("/media/thiago/Arquivos/web/TCC/src/r/init.R")

#################################################################################
#                 PREPARANDO OS DADOS                                           #
#################################################################################
#executa o script do banco de dados
if(!file.exists('./final_v2.csv')){
  system('./database/db_v2.sh')
}

ceap <- read.csv("./final_v3.csv")
ceap <- ceap %>% dplyr::select("ano", "anolegislatura", "uf", "tipo", "valor", "eleitores", "distancia", "vagas", "cota")
ceap <- ceap %>% dplyr::filter(valor < 1000 & valor > 0)
#retirei legislatura por ser relacionado a ano
ceap$anolegislatura <- as.factor(ceap$anolegislatura)
ceap$ano <- as.factor(ceap$ano)
ceap$iddeputado <- as.factor(ceap$iddeputado)
ceap$uf <- as.factor(ceap$uf)
ceap$tipo <- as.factor(ceap$tipo)
ceap$valor <- ceap$valor
#ceap$mediaeleitor <- ceap$valor/ceap$eleitores
#ceap$valor <- NULL

#################################################################################
#                 OBSERVANDO OS DADOS CARREGADOS DO DATASET                     #
#################################################################################
ceap[1:100,] %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped",
                full_width = F,
                font_size = 12)

#boxplot(ceap$valor)
#boxplot(ceap$mediavaga)


#Visualizando as observações e as especificações referentes às variáveis do dataset
glimpse(ceap) 

#Estatísticas univariadas
summary(ceap)

#Requer instalação e carregamento dos pacotes see e ggraph para a plotagem
ceap %>%
  correlation(method = "pearson") %>%
  plot()

source('proportional_stratified_sampling.R')
cols <- c("ano", "", "uf")
value_col = "valor"
z = 0.95

b <- 50
pss <- create_pss(ceap, value_col, cols, b = b, z = z)

ceap_amostra <- sample_pss(pss)

source("tools.R")
write_csv(ceap_amostra, './samples');

summary(ceap_amostra)

ceap_amostra$orig.id <- NULL

#dummies para partido, estado, tipo, anolegislatura

#Estimando a Regressão Múltipla
modelo_ceap <- lm(formula = valor ~ . -cota,
                  data = ceap_amostra)

anova(modelo_ceap)
#Parâmetros do modelo
summary(modelo_ceap)

confint(modelo_ceap, level = 0.95) # significância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap, confint = T, digits = 3, ci.width = .99)

export_summs(modelo_ceap, scale = F, digits = 5)

hist(modelo_ceap$residuals, breaks=100)

chart_lm_residuals(modelo_ceap)

sf.test(modelo_ceap$residuals)


########## STEPWISE #######################
k <- qchisq(p = 0.05, df = 1, lower.tail = F)

modelo_ceap_step = step(modelo_ceap, k = k)

summary(modelo_ceap_step)

sf.test(modelo_ceap$residuals)

chart_lm_residuals(modelo_ceap_step)

############  FIM  ########################

###########  BOX-COX  #####################

ceap_amostra$valor_positivo <- ceap_amostra$valor+(-1*min(ceap_amostra$valor))+1

lambda_BC <- powerTransform(ceap_amostra$valor_positivo)
lambda_BC

ceap_amostra$valor_bc <- (((ceap_amostra$valor_positivo ^ lambda_BC$lambda) - 1) / 
                    lambda_BC$lambda)


modelo_ceap_bc <- lm(formula = valor_bc ~ . -valor - valor_positivo -cota,
                  data = ceap_amostra)

summary(modelo_ceap_bc)

anova(modelo_ceap_bc)
fix(sf.test)
sf.test(modelo_ceap_bc$residuals)
hist(modelo_ceap_bc$residuals, breaks=100)
############  FIM  ########################

######  BOX-COX STEPWISE  #################

modelo_ceap_bc_step = step(modelo_ceap_bc, k = k)
summary(modelo_ceap_bc_step)
sf.test(modelo_ceap_bc_step$residuals)

chart_lm_residuals(modelo_ceap_bc)

ols_vif_tol(modelo_ceap_bc)

hist(modelo_ceap_bc$residuals, breaks=100)

#dummies
ceap_dummies <- dummy_columns(.data = ceap_amostra,
                              select_columns = c("ano", "tipo", "uf", "anolegislatura"),
                              remove_selected_columns = T,
                              remove_most_frequent_dummy = T)

modelo_ceap_dummies <- lm(formula = valor ~ . -valor_bc -valor_positivo,
                          data = ceap_dummies)
#Parâmetros do modelo
summary(modelo_ceap_dummies)
confint(modelo_ceap_dummies, level = 0.95) # siginificância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap_dummies, confint = T, digits = 3, ci.width = .95)
export_summs(modelo_ceap_dummies, scale = F, digits = 5)


#stepwise
k <- qchisq(p = 0.05, df = 1, lower.tail = F)
modelo_step_dummies = step(modelo_ceap_dummies, k = k)
summary(modelo_step_dummies)
#Este procedimento no R removeu a variável 'endividamento'. Note que a variável
#'disclosure' também acabou sendo excluída após o procedimento Stepwise, nesta
#forma funcional linear!

export_summs(modelo_step_dummies, scale = F, digits = 5)

sf.test(modelo_step_dummies$residuals)

hist(modelo_ceap_dummies$residuals)

confint(modelo_ceap_dummies, level = 0.90) # siginificância de 5%

ggplotly(
  ceap_amostra %>% 
    ggplot() +
    geom_point(aes(x = distancia, y = valor),
               color = "grey20", alpha = 0.6, size = 2) +
    labs(x = "Distância",
         y = "Valor") +
    theme_bw()
)

table(ceap$tipo)

a <- ceap %>% dplyr::filter(valor > 0)

lambda_BC <- powerTransform(a$valor)
lambda_BC

MASS::boxcox(step_dummies)

ceap %>%
  mutate(residuos = modelo_ceap$residuals) %>%
  ggplot(aes(x = residuos)) +
  geom_histogram(aes(y = ..density..), 
                 color = "grey50", 
                 fill = "grey90", 
                 bins = 30,
                 alpha = 0.6) +
  stat_function(fun = dnorm, 
                args = list(mean = mean(modelo_ceap$residuals),
                            sd = sd(modelo_ceap$residuals)),
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

summary(ceap$valor)
a <- sd(ceap$valor)
var(ceap$valor)

z <- 1.96
b <- 100
num = nrow(ceap)*var(ceap$valor)
den = (nrow(ceap)-1)*(b*b)/(z*z)+var(ceap$valor)

n = num/den
n
