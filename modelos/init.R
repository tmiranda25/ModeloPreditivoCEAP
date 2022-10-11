##################################################################################
#                 INSTALAÇÃO E CARREGAMENTO DE PACOTES NECESSÁRIOS               #
##################################################################################
#Pacotes utilizados
f_pacotes = function(){
  pacotes <- c("plotly","tidyverse","ggrepel","fastDummies","knitr","kableExtra",
               "splines","reshape2","PerformanceAnalytics","metan","correlation",
               "see","ggraph","nortest","rgl","car","olsrr","jtools","ggstance",
               "magick","cowplot","beepr","Rcpp", "tigerstats")
  
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



##################################################################################
#                        CARREGAMENTO DA BASE DE DADOS                           #
##################################################################################

if(!exists("init")){
  #setar ambiente
  setwd("/media/thiago/Arquivos/web/TCC/src/r")
  #ler pacotes
  f_pacotes()
  
  #aumenta o número máx de registros no teste shapiro.francia
  fix(sf.test)
  
  init <- TRUE
}

f_grafico_residuos <- function(data, residuos){
  data %>%
    mutate(residuos = residuos) %>%
    ggplot(aes(x = residuos)) +
    geom_histogram(aes(y = ..density..), 
                   color = "grey50", 
                   fill = "grey90", 
                   bins = 30,
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
