#ATENÇÃO O COMANDO ABAIXO LIMPA A MEMÓRIA
rm(list = ls())
source("init.R")

#CONSTRUIR SOMENTE 

install.packages("rlang")

########################
# Instalação de pacotes
pacotes <- c(
  'tidyverse',  # Pacote básico de datawrangling
  'rpart',      # Biblioteca de árvores
  'rpart.plot', # Conjunto com Rpart, plota a parvore
  'gtools',     # funções auxiliares como quantcut,
  'Rmisc',      # carrega a função sumarySE para a descritiva
  'scales',     # importa paletas de cores
  'viridis',    # Escalas 'viridis' para o ggplot2
  'caret',       # Funções úteis para machine learning
  'AMR',
  'randomForest',
  'fastDummies',
  'rattle',
  'xgboost',
  'doParallel',
  'ipred'
)

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T) 
} else {
  sapply(pacotes, require, character = T) 
}

ceap <- read.csv("../dados/combustiveis.csv")
ceap$id <- NULL
ceap$ano <- as.factor(ceap$ano)
ceap$anolegislatura <- as.factor(ceap$anolegislatura)
ceap$legislatura <- as.factor(ceap$legislatura)
ceap$uf <- as.factor(ceap$uf)
ceap$tipo <- as.factor(ceap$tipo)
ceap$partido <- as.factor(ceap$partido)

summary(ceap)
ceap[is.na(ceap)] <- 0

ceap %>% correlation(method = "pearson") %>%
  plot()

ceap_passagens <- filter(ceap, tipo == 'PASSAGEM AÉREA')

ceap_passagens$cota <- NULL
ceap_passagens$eleitores <- NULL
ceap_passagens$tipo <- NULL

library(doParallel)
cl <- makePSOCKcluster(5)
registerDoParallel(cl)

library(caret)
set.seed(825)
inTraining <- createDataPartition(ceap_passagens$valor, p = .75, list = FALSE)
treino <- ceap_passagens[ inTraining,]
teste  <- ceap_passagens[-inTraining,]

library(randomForest)
set.seed(825)
rf <-randomForest(valor~.,data=treino, ntree=100, importance = TRUE) 
print(rf)
plot(rf)
ceap$p <- predict(rf, teste)
ceap$r <- ceap$valor - ceap$p
varImpPlot(rf)

stopCluster(cl)


controle <- caret::trainControl(
  "cv",
  number = 3
)
# trainControl("cv", 
#              number = 10)

summary(treino)

modelo <- caret::train(
  valor ~., 
  data = treino, 
  method = "xgbTree",
  trControl = controle,
  tuneGrid = NULL,
  verbosity = TRUE)

modelo


fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 20,
  ## repeated ten times
  repeats = 5)

set.seed(825)
gbmFit1 <- train(valor ~ ., data = treino, 
                 method = "gbm", 
                 trControl = fitControl,
                 ## This last option is actually one
                 ## for gbm() that passes through
                 verbose = TRUE)
gbmFit1

fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 10,
                           ## Estimate class probabilities
                           classProbs = TRUE)

gbmGrid <-  expand.grid(interaction.depth = c(1, 5, 9), 
                        n.trees = (1:30)*50, 
                        shrinkage = 0.1,
                        n.minobsinnode = 20)

set.seed(825)
gbmFit3 <- train(valor ~ ., data = treino, 
                 method = "gbm", 
                 trControl = fitControl, 
                 verbose = TRUE)
gbmFit3

controle <- caret::trainControl(
  method='repeatedcv', # Solicita um K-Fold com repetições
  number=25, # Número de FOLDS (o k do k-fold)
  repeats=2, # Número de repetições
  classProbs = TRUE # Necessário para calcular a curva ROC
)

# agora vamos especificar o grid
grid <- base::expand.grid(.mtry=c(1:10))

# Vamos treinar todos os modelos do grid-search com cross-validation
gridsearch_rf <- caret::train(valor ~ .,         # Fórmula (todas as variáveis)
                              data = treino,       # Base de dados
                              method = 'xgbTree',        # Random-forest
                              trControl = controle, # Parâmetros de controle do algoritmo
                              ntree=10,
                              na.action=na.exclude)      # Percorre o grid especificado aqui

print(gridsearch_rf)
plot(gridsearch_rf)


paleta <- scales::viridis_pal(begin=.75, end=1)(20)

rpart.plot::rpart.plot(tree,
                       box.palette = paleta) # Paleta de cores

# Valores preditos
ceap$p <- predict(tree, ceap)
ceap$r <- ceap$valor - ceap$p

#### RANDOM ####


set.seed(123)

# assess 10-50 bagged trees
ntree <- 10:30

# create empty vector to store OOB RMSE values
rmse <- vector(mode = "numeric", length = length(ntree))

for (i in seq_along(ntree)) {
  # reproducibility
  set.seed(123)
  
  # perform bagged model
  model <- bagging(
    formula = valor ~ .,
    data    = treino,
    coob    = TRUE,
    nbagg   = ntree[i]
  )
  # get OOB error
  rmse[i] <- model$err
}

plot(ntree, rmse, type = 'l', lwd = 2)
abline(v = 25, col = "red", lty = "dashed")