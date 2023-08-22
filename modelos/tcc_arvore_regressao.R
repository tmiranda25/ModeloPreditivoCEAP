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

ceap <- read.csv("../dados/ceap.csv")
ceap <- filter(ceap, tipo == 'PASSAGEM AÉREA')
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

ceap$cota <- NULL
ceap$eleitores <- NULL
ceap$tipo <- NULL

library(tidymodels)
library(tidyverse)
library(workflows)
library(tune)

set.seed(234589)
# split the data into trainng (75%) and testing (25%)
ceap_split <- initial_split(ceap, 
                                prop = 3/4)
ceap_split

ceap_train <- training(ceap_split)
ceap_test <- testing(ceap_split)

ceap_cv <- vfold_cv(ceap_train)

# define the recipe
ceap_recipe <- 
  # which consists of the formula (outcome ~ predictors)
  recipe(valor ~ ., 
         data = ceap) %>%
  # and some pre-processing steps
  step_normalize(all_numeric_predictors()) %>%
  step_impute_knn(all_predictors())

ceap_train_preprocessed <- ceap_recipe %>%
  # apply the recipe to the training data
  prep(ceap_train) %>%
  # extract the pre-processed training dataset
  juice()
ceap_train_preprocessed

rf_model <- 
  # specify that the model is a random forest
  rand_forest() %>%
  # specify that the `mtry` parameter needs to be tuned
  #set_args(mtry = 3) %>%
  # select the engine/package that underlies the model
  set_engine("ranger", importance = "impurity") %>%
  # choose either the continuous regression or binary classification mode
  set_mode("regression") 

# set the workflow
rf_workflow <- workflow() %>%
  # add the recipe
  add_recipe(ceap_recipe) %>%
  # add the model
  add_model(rf_model)

rf_fit <- rf_workflow %>%
  # fit on the training set and evaluate on test set
  last_fit(ceap_split)

rf_fit

test_performance <- rf_fit %>% collect_metrics()
test_performance

test_predictions <- rf_fit %>% collect_predictions()
test_predictions

final_model <- fit(rf_workflow, ceap)
final_model

passagem <- tribble(~valor, ~ano, ~anolegislatura, ~legislatura, ~uf, ~partido, ~vagas, ~distancia,
                     200, as.factor(2022), as.factor(4), as.factor(56), as.factor('GO'), as.factor('PT'), 17, 0)
passagem

ceap$p <- predict(final_model, new_data = ceap)

