##################################################################################
#                 INSTALAÇÃO E CARREGAMENTO DE PACOTES NECESSÁRIOS               #
##################################################################################
#Pacotes utilizados
f_pacotes = function(){
  pacotes <- c("plotly","tidyverse","ggrepel","fastDummies","knitr","kableExtra",
               "splines","reshape2","PerformanceAnalytics","metan","correlation",
               "see","ggraph","nortest","rgl","car","olsrr","jtools","ggstance",
               "magick","cowplot","beepr","Rcpp", "tigerstats", "stringi")
  
  if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
    instalador <- pacotes[!pacotes %in% installed.packages()]
    for(i in 1:length(instalador)) {
      install.packages(instalador, dependencies = T)
      break()}
    sapply(pacotes, require, character = T) 
  } else {
    sapply(pacotes, require, character = T) 
  }
}
f_pacotes()
options(scipen = 100)
library(lmtest)



##################################################################################
#                        CARREGAMENTO DA BASE DE DADOS                           #
##################################################################################

if(!exists("init")){
  #ler pacotes
  f_pacotes()
  
  #aumenta o número máx de registros no teste shapiro.francia
  #fix(sf.test)
  
  init <- TRUE
}

f_grafico_residuos <- function(data, residuos){
  data %>%
    mutate(residuos = residuos) %>%
    ggplot(aes(x = residuos)) +
    geom_histogram(aes(y = ..density..), 
                   color = "grey50", 
                   fill = "grey90", 
                   bins = 10,
                   alpha = 0.6) +
    stat_function(fun = dnorm, 
                  args = list(mean = mean(residuos),
                              sd = sd(residuos)),
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

f_tabela <- function(dt){
  
  n <- if(nrow(dt) < 100) nrow(dt) else 100
  
  dt[1:n,] %>% 
    kable() %>%
    kable_styling(bootstrap_options = "striped",
                  full_width = F,
                  font_size = 12)
}

f_lm <- function(dt, formula, step=FALSE){
  #Estimando a Regressão Múltipla
  lm_model <- lm(formula = formula,
                       data = dt)
  
  if(step){
    k <- qchisq(p = 0.05, df = 1, lower.tail = F)
    
    lm_model = step(lm_model, k = k)    
  }
  
  #Visualizando o modelo
  print(summary(lm_model))
  
  #print(summ(lm_model, confint = T, digits = 3, ci.width = .99))
  
  #print(export_summs(lm_model, scale = F, digits = 5))
  
  if(ncol(dt) > 2){
    print(ols_vif_tol(lm_model))
  }
  
  #print(ols_test_breusch_pagan(lm_model))

  print(bptest(lm_model))
  
  print(sf.test(lm_model$residuals))   
  
  #print(lm_model %>% plot())
}

f_boxcox <- function(dt, step=FALSE){
  
  lambda_BC <- powerTransform(dt$valor)
  
  print(lambda_BC)
  
  dt$valor_bc <- (((dt$valor ^ lambda_BC$lambda) - 1) / 
                         lambda_BC$lambda)
  
  
  bc_model <- lm(formula = valor_bc ~ . -valor,
                          data = dt)
  
  if(step){
    k <- qchisq(p = 0.05, df = 1, lower.tail = F)
    bc_model = step(bc_model, k = k)
  }
  
  print(summary(bc_model))
  
  
  print(ols_test_breusch_pagan(bc_model))
  
  print(bptest(bc_model))
  
  print(sf.test(bc_model$residuals))
  
  #print(chart_lm_residuals(bc_model))
  
  #print(bc_model %>% plot())
  
  dt$valor_bc <- NULL
  
  lista <- list(bc_model, lambda_BC$lambda)
  
  names(lista) <- c('model', 'lambda')
  
  return(lista)
}
