#modelo fitou com amostragem ano, uf, b = 1000 e z = 0.95
source('pss.R')
cols <- c("ano", "uf", "tipo")
value_col = "valor"
z = 0.95

#rng <- seq(10, 500, by = 10)
#rng <- as.data.frame(rng)
#colnames(rng) <- c('b')
#rng$sample_size <- 0

#for(i in 1:nrow(rng)){
#  pss <- create_pss(ceap, value_col, cols, b = rng[i, 1], z = z)
#  rng[i, 2] <- pss$sample_size
#}

b <- 10
pss <- create_pss(ceap, value_col, cols, b = b, z = z)

df_sample <- sample_pss(pss)
df_sample

pss$df_strata$size


summary(df_sample)

modelo_ceap <- lm(formula = valor ~ . -orig.id,
                  data = df_sample)

anova(modelo_ceap)
hist(modelo_ceap$residuals, breaks=100)

#Parâmetros do modelo
summary(modelo_ceap)
confint(modelo_ceap, level = 0.95) # significância de 5%

#Outro modo de apresentar os outputs do modelo - função summ do pacote jtools
summ(modelo_ceap, confint = T, digits = 3, ci.width = .99)
export_summs(modelo_ceap, scale = F, digits = 5)

#stepwise
k <- qchisq(p = 0.05, df = 1, lower.tail = F)
step_ceap = step(modelo_ceap, k = k)
summary(step_ceap)

lambda_BC <- powerTransform(ceap$valor)
lambda_BC

df_sample$valor_bc <- (((df_sample$valor ^ lambda_BC$lambda) - 1) / 
                    lambda_BC$lambda)


modelo_ceap <- lm(formula = valor_bc ~ . -valor -orig.id,
                  data = df_sample)

summary(modelo_ceap)

anova(modelo_ceap)
fix(sf.test)
sf.test(modelo_ceap$residuals)

step_ceap = step(modelo_ceap, k = k)
summary(step_ceap)

df_sample %>%
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

hist(step_ceap$residuals, breaks=100)

MASS::boxcox(step_ceap)

sf.test(modelo_ceap$residuals)
