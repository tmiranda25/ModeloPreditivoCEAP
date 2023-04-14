#Setar o Working dir para o diretório deste arquivo
rm(list = ls())
source("init.R")

#executa o script do banco de dados
#if(!file.exists('../dados/ceap.csv')){
#  system('../script/db.sh')
#}

ceap <- read.csv("../dados/ceap.csv")
#"ano", "anolegislatura", "legislatura", "uf", "tipo", "partido", "mes", "valor", "eleitores", "distancia", "representatividade")
ceap <- ceap %>% dplyr::select(-one_of('id'))

ceap$anolegislatura <- as.factor(ceap$anolegislatura)
ceap$legislatura <- as.factor(ceap$legislatura)
ceap$ano <- as.factor(ceap$ano)
ceap$mes <- as.factor(ceap$mes)
ceap$uf <- as.factor(ceap$uf)
ceap$tipo <- as.factor(ceap$tipo)
ceap$partido <- as.factor(ceap$partido)

#################################################################################
#                 OBSERVANDO OS DADOS CARREGADOS DO DATASET                     #
#################################################################################
ceap[1:100,] %>%
  kable() %>%
  kable_styling(bootstrap_options = "striped",
                full_width = F,
                font_size = 22)

#Visualizando as observações e as especificações referentes às variáveis do dataset
glimpse(ceap) 

#Estatísticas univariadas
summary(ceap)

#Requer instalação e carregamento dos pacotes see e ggraph para a plotagem
ceap %>%
  correlation(method = "pearson") %>%
  plot()

#dummies para partido, estado, tipo, anolegislatura

#Estimando a Regressão Múltipla
modelo_ceap <- lm(formula = valor ~ .,
                    data = ceap)

anova(modelo_ceap)
hist(modelo_ceap$residuals, breaks=100)

#Parâmetros do modelo
summary(modelo_ceap)
confint(modelo_ceap, level = 0.95) # siginificância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap, confint = T, digits = 3, ci.width = .99)
export_summs(modelo_ceap, scale = F, digits = 5)

#stepwise
k <- qchisq(p = 0.05, df = 1, lower.tail = F)
step_ceap = step(modelo_ceap, k = k)
summary(step_ceap)

lambda_BC <- powerTransform(ceap$valor)
lambda_BC

ceap$valor_bc <- (((ceap$valor ^ lambda_BC$lambda) - 1) / 
                                   lambda_BC$lambda)


modelo_ceap <- lm(formula = valor_bc ~ .,
                  data = ceap)

summary(modelo_ceap)

anova(modelo_ceap)
fix(sf.test)
sf.test(modelo_ceap$residuals)

ceap %>%
  mutate(residuos = step_ceap$residuals) %>%
  ggplot(aes(x = residuos)) +
  geom_histogram(aes(y = ..density..), 
                 color = "grey50", 
                 fill = "grey90", 
                 bins = 30,
                 alpha = 0.6) +
  stat_function(fun = dnorm, 
                args = list(mean = mean(step_ceap$residuals),
                            sd = sd(step_ceap$residuals)),
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

ols_vif_tol(step_ceap)

hist(modelo_ceap$residuals, breaks=100)

f <- rf(10000, df1=80, df2=2000000)

hist(f, breaks=100, )

qf(0.5, df=80, df2=2000000, lower.tail=T)

#dummies
ceap_dummies <- dummy_columns(.data = ceap,
                                   select_columns = c("anolegislatura", "tipo", "uf"),
                                   remove_selected_columns = T,
                                   remove_most_frequent_dummy = T)

modelo_ceap_dummies <- lm(formula = valor ~ . -masculino -feminino -naoinformado -mes -legislatura -ano -carteira -partido -distancia - total -uf -anolegislatura,
                  data = ceap)
#Parâmetros do modelo
summary(modelo_ceap_dummies)
confint(modelo_ceap_dummies, level = 0.95) # siginificância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap_dummies, confint = T, digits = 3, ci.width = .95)
export_summs(modelo_ceap_dummies, scale = F, digits = 5)


#stepwise
k <- qchisq(p = 0.05, df = 1, lower.tail = F)
step_dummies = step(modelo_ceap_dummies, k = k)
summary(step_dummies)
#Este procedimento no R removeu a variável 'endividamento'. Note que a variável
#'disclosure' também acabou sendo excluída após o procedimento Stepwise, nesta
#forma funcional linear!

export_summs(modelo_ceap_step, scale = F, digits = 5)

sf.test(modelo_ceap_dummies$residuals)

hist(modelo_ceap_dummies$residuals)

confint(modelo_ceap_dummies, level = 0.90) # siginificância de 5%

ggplotly(
  ceap %>% 
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
