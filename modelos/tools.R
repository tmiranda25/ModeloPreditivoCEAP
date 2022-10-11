#' Calculate the sampling size and strata parameters
#' 
#' @param df An dataframe.
#' @param value_col The name of the value column
#' @param b Maximum estimation error.
#' @param cols A string or string vector containing columns names
#' @pram z Critical value
#' @return samples_size and a dataframe with size and other parameters for each strata
write_csv <- function(df, dest, prefix = 'sample_'){
  while(TRUE){
    destino_download <- paste(dest, '/', prefix, print(stri_rand_strings(1, 8))[1], '.csv', sep='')
    if(!file.exists(destino_download)){
      break;
    }
  }
  write.csv(df, destino_download)
}

chart_lm_residuals <- function(lm){
  lm$model %>%
    mutate(residuos = lm$residuals) %>%
    ggplot(aes(x = residuos)) +
    geom_histogram(aes(y = ..density..), 
                   color = "grey50", 
                   fill = "grey90", 
                   bins = 30,
                   alpha = 0.6) +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(lm$residuals),
                              sd = sd(lm$residuals)),
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
}
