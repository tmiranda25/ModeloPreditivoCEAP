rm(list = ls())

source("/media/thiago/Arquivos/web/TCC/src/r/init.R")
source("proportional_stratified_sampling.R")
source("y_boxcox.R")

#amostragem
cols <- c("ano", "tipo")
value_col = "valor"
z = 0.95

#amostragem por ano e tipo com b = 500 e z = 0.95
# com 400 também fitou

#rng <- seq(10, 500, by = 10)
#rng <- as.data.frame(rng)
#colnames(rng) <- c('b')
#rng$sample_size <- 0

#for(i in 1:nrow(rng)){
#  pss <- create_pss(ceap, value_col, cols, b = rng[i, 1], z = z)
#  rng[i, 2] <- pss$sample_size
#}

b <- 400
pss <- create_pss(ceap, value_col, cols, b = b, z = z)

df_sample <- sample_pss(pss)
df_sample

lambda_BC <- powerTransform(df_sample$valor)
lambda_BC

df_sample$valor_bc <- y2ybc(df_sample$valor, lambda_BC$lambda)
df_sample$valor_bc

#dummies
df_sample_dummies <- dummy_columns(.data = df_sample,
                              select_columns = c("anolegislatura", "uf", "tipo", "partido"),
                              remove_selected_columns = T,
                              remove_most_frequent_dummy = T)


MASS::boxcox(df_sample_dummies)


modelo_df_sample_dummies <- lm(formula = valor_bc ~ . - orig.id -valor -ano -legislatura,
                  data = df_sample_dummies)


summary(modelo_df_sample_dummies)

sf.test(modelo_df_sample_dummies$residuals)

f_grafico_residuos(df_sample_dummies, modelo_df_sample_dummies$residuals)

k <- qchisq(p = 0.05, df = 1, lower.tail = F)
step_df_sample_dummies = step(modelo_df_sample_dummies, k = k)
summary(step_df_sample_dummies)

sf.test(step_df_sample_dummies$residuals)

f_grafico_residuos(df_sample_dummies, step_df_sample_dummies$residuals)

step_df_sample_dummies %>%
  ggplot() +
  geom_density(aes(x = step_df_sample_dummies$residuals), fill = "#55C667FF") +
  labs(x = "Resíduos do Modelo Stepwise",
       y = "Densidade") +
  theme_bw()

ols_test_breusch_pagan(step_df_sample_dummies)



ceap_dummies <- dummy_columns(.data = ceap,
                                   select_columns = c("anolegislatura", "uf", "tipo", "partido"),
                                   remove_selected_columns = T,
                                   remove_most_frequent_dummy = T)

ceap_dummies$yhat_bc <-predict(step_df_sample_dummies, ceap_dummies)
ceap_dummies$yhat <- ybc2y(ceap_dummies$yhat_bc, lambda_BC$lambda)
ceap_dummies$yhat - ceap_dummies$valor


summary(ceap_dummies$yhat)
sd(ceap_dummies$yhat)
var(ceap_dummies$yhat)
summary(ceap_dummies$valor)
sd(ceap_dummies$valor)
var(ceap_dummies$valor)
