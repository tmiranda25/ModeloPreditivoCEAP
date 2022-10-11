

cor(distancia, valor, ceap)

ggplotly(
  df_sample %>% 
    ggplot() +
    geom_point(aes(y = valor, x = eleitores, color = partido), alpha = 0.6, size = 2) +
    labs(x = "Eleitores",
         y = "Valor") +
    theme_bw()
)

summary(df_sample$valor)
summary(ceap$valor)
