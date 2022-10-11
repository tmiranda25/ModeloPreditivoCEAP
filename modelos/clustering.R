rm("init");
rm(list = ls())
source("/media/thiago/Arquivos/web/TCC/src/r/init.R")

########################################
#
#   CHAMANDO BIBLIOTECAS IMPORTANTES
#
########################################

library(tidyverse) #pacote para manipulacao de dados
library(cluster) #algoritmo de cluster
library(dendextend) #compara dendogramas
library(factoextra) #algoritmo de cluster e visualizacao
library(fpc) #algoritmo de cluster e visualizacao
library(gridExtra) #para a funcao grid arrange
library(readxl)

#LEITURA DOS DADOS
View(ceap)

#df <- ceap[,c(6:8)]
#View(df)

df_fim <- as.data.frame(ceap %>% 
  pivot_wider(
    names_from = tipo, 
    values_from = valor,
    values_fill = 0,
    values_fn = Reduce("+", list(breaks = sum))
  )
)

View(df_fim)

fim <- df_fim[,12:29]

glimpse(fim)

chart.Correlation(fim, histogram = TRUE, pch = "+")

rho_ceap <- cor(fim)

afpc_atlas <- prcomp(fim)
summary(afpc_atlas)

data.frame(eigenvalue = afpc_atlas$sdev ^ 2,
           var_compartilhada = summary(afpc_atlas)$importance[2,],
           var_cumulativa = summary(afpc_atlas)$importance[3,]) -> relatorio

relatorio %>% 
  kable() %>%
  kable_styling(bootstrap_options = "striped", 
                full_width = T, 
                font_size = 12)

# Visualizando os pesos que cada variável tem em cada componente principal 
# obtido pela PCA
ggplotly(
  data.frame(afpc_atlas$rotation) %>%
    mutate(var = names(fim)) %>%
    melt(id.vars = "var") %>%
    mutate(var = factor(var)) %>%
    ggplot(aes(x = var, y = value, fill = var)) +
    geom_bar(stat = "identity", color = "black") +
    facet_wrap(~variable) +
    labs(x = NULL, y = NULL, fill = "Legenda:") +
    scale_fill_viridis_d() +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90))
)

# Scree Plot - apenas ignorar os warnings
ggplotly(
  fviz_eig(X = afpc_atlas,
           ggtheme = theme_bw(), 
           barcolor = "black", 
           barfill = "dodgerblue4",
           linecolor = "darkgoldenrod4")
)

#Extraindo as Cargas Fatoriais

k <- sum((afpc_atlas$sdev ^ 2) > 1) 
cargas_fatoriais <- afpc_atlas$rotation[, 1:k] %*% diag(afpc_atlas$sdev[1:k])

# Visualizando as cargas fatoriais
data.frame(cargas_fatoriais) %>%
  rename(F1 = X1,
         F2 = X2) %>%
  kable() %>%
  kable_styling(bootstrap_options = "striped", 
                full_width = T, 
                font_size = 12)

#Visualizando as Comunalidades
data.frame(rowSums(cargas_fatoriais ^ 2)) %>%
  rename(comunalidades = 1) %>%
  kable() %>%
  kable_styling(bootstrap_options = "striped", 
                full_width = T, 
                font_size = 12)

# Relatório das cargas fatoriais e das comunalidades
data.frame(cargas_fatoriais) %>%
  rename(F1 = X1,
         F2 = X2) %>%
  mutate(Comunalidades = rowSums(cargas_fatoriais ^ 2)) %>%
  kable() %>%
  kable_styling(bootstrap_options = "striped", 
                full_width = T, 
                font_size = 12)

# Plotagem das Cargas Fatoriais
data.frame(cargas_fatoriais) %>%
  ggplot(aes(x = X1, y = X2)) +
  geom_point(color = "orange") +
  geom_hline(yintercept = 0, color = "darkorchid") +
  geom_vline(xintercept = 0, color = "darkorchid") +
  geom_text_repel(label = row.names(cargas_fatoriais)) +
  labs(x = "F1",
       y = "F2") +
  theme_bw()

# Scores Fatoriais
scores_fatoriais <- t(afpc_atlas$rotation)/afpc_atlas$sdev 
colnames(scores_fatoriais) <- colnames(ceap)

scores_fatoriais

scores_fatoriais %>%
  t() %>%
  data.frame() %>%
  rename(PC1 = 1,
         PC2 = 2) %>%
  select(PC1, PC2) %>%
  kable() %>%
  kable_styling(bootstrap_options = "striped", 
                full_width = T, 
                font_size = 12)


rho %>% 
  melt() %>% 
  ggplot() +
  geom_tile(aes(x = Var1, y = Var2, fill = value)) +
  geom_text(aes(x = Var1, y = Var2, label = round(x = value, digits = 3)),
            size = 4) +
  labs(x = NULL,
       y = NULL,
       fill = "Correlações") +
  scale_fill_gradient2(low = "dodgerblue4", 
                       mid = "white", 
                       high = "brown4",
                       midpoint = 0) +
  theme(panel.background = element_rect("white"),
        panel.grid = element_line("grey95"),
        panel.border = element_rect(NA),
        legend.position = "bottom",
        axis.text.x = element_text(angle = 0))
warnings()


########################################
#
#         CLUSTER HIERARQUICO - juntos
#
########################################

rownames(df_fim) <- df_fim[,1]

df_fim <- df_fim[,-1]

df_fim.k2 <- kmeans(df_fim, centers = 2)

#Visualizar os clusters
fviz_cluster(df_fim.k2, data = df_fim, main = "Cluster K2")

#Criar clusters
df_fim.k3 <- kmeans(df_fim, centers = 3)
df_fim.k4 <- kmeans(df_fim, centers = 4)
df_fim.k5 <- kmeans(df_fim, centers = 5)

#Criar graficos
G1 <- fviz_cluster(df_fim.k2, geom = "point", data = df_fim) + ggtitle("k = 2")
G2 <- fviz_cluster(df_fim.k3, geom = "point",  data = df_fim) + ggtitle("k = 3")
G3 <- fviz_cluster(df_fim.k4, geom = "point",  data = df_fim) + ggtitle("k = 4")
G4 <- fviz_cluster(df_fim.k5, geom = "point",  data = df_fim) + ggtitle("k = 5")

#Imprimir graficos na mesma tela
grid.arrange(G1, G2, G3, G4, nrow = 2)

#VERIFICANDO ELBOW 
fviz_nbclust(df_fim, kmeans, method = "wss")








#CALCULANDO MATRIZ DE DISTANCIAS
d <- dist(df_fim, method = "euclidean")
d

#DEFININDO O CLUSTER A PARTIR DO METODO ESCOLHIDO
#metodos disponiveis "average", "single", "complete" e "ward.D"
hc1 <- hclust(d, method = "single" )
hc2 <- hclust(d, method = "complete" )
hc3 <- hclust(d, method = "average" )
hc4 <- hclust(d, method = "ward.D" )

#DESENHANDO O DENDOGRAMA
plot(hc1, cex = 0.6, hang = -1)
plot(hc2, cex = 0.6, hang = -1)
plot(hc3, cex = 0.6, hang = -1)
plot(hc4, cex = 0.6, hang = -1)

#BRINCANDO COM O DENDOGRAMA PARA 2 GRUPOS
rect.hclust(hc4, k = 2)

#COMPARANDO DENDOGRAMAS
#comparando o metodo average com ward
dend3 <- as.dendrogram(hc3)
dend4 <- as.dendrogram(hc4)
dend_list <- dendlist(dend3, dend4) 
#EMARANHADO, quanto menor, mais iguais os dendogramas sao
tanglegram(dend3, dend4, main = paste("Emaranhado =", round(entanglement(dend_list),2)))
#agora comparando o metodo single com complete
dend1 <- as.dendrogram(hc1)
dend2 <- as.dendrogram(hc2)
dend_list2 <- dendlist(dend1, dend2) 
#EMARANHADO, quanto menor, mais iguais os dendogramas sao
tanglegram(dend1, dend2, main = paste("Emaranhado =", round(entanglement(dend_list2),2)))

#criando 2 grupos de alunos
grupo_alunos2 <- cutree(hc4, k = 2)
table(grupo_alunos2)

#transformando em data frame a saida do cluster
alunos_grupos <- data.frame(grupo_alunos2)

#juntando com a base original
Base_alunos_fim <- cbind(df_fim, alunos_grupos)

# entendendo os clusters
#FAZENDO ANALISE DESCRITIVA
#MEDIAS das variaveis por grupo
mediagrupo_alunos <- Base_alunos_fim %>% 
  group_by(grupo_alunos2) %>% 
  summarise(n = n(),
            Portugues = mean(Portugues), 
            Matematica = mean(Matematica))
mediagrupo_alunos


########################################
#
#     CLUSTER HIERARQUICO - MCDonald
#
########################################

#Carregar base de dados: 
mcdonalds <- read.table("dados/MCDONALDS.csv", sep = ";", dec = ",", header = T)
#transformar o nome dos lanches em linhas
rownames(mcdonalds) <- mcdonalds[,1]
mcdonalds <- mcdonalds[,-1]

#Padronizar variaveis
mcdonalds.padronizado <- scale(mcdonalds)

#calcular as distancias da matriz utilizando a distancia euclidiana
distancia <- dist(mcdonalds.padronizado, method = "euclidean")

#Calcular o Cluster: metodos disponiveis "average", "single", "complete" e "ward.D"
cluster.hierarquico <- hclust(distancia, method = "single" )

# Dendrograma
plot(cluster.hierarquico, cex = 0.6, hang = -1)

#Criar o grafico e destacar os grupos
rect.hclust(cluster.hierarquico, k = 2)

#VERIFICANDO ELBOW 
fviz_nbclust(mcdonalds.padronizado, FUN = hcut, method = "wss")


#criando 4 grupos de lanches
grupo_lanches4 <- cutree(cluster.hierarquico, k = 4)
table(grupo_lanches4)

#transformando em data frame a saida do cluster
Lanches_grupos <- data.frame(grupo_lanches4)

#juntando com a base original
Base_lanches_fim <- cbind(mcdonalds, Lanches_grupos)

#FAZENDO ANALISE DESCRITIVA
#MEDIAS das variaveis por grupo
mediagrupo <- Base_lanches_fim %>% 
  group_by(grupo_lanches4) %>% 
  summarise(n = n(),
            Valor.Energetico = mean(Valor.Energetico), 
            Carboidratos = mean(Carboidratos), 
            Proteinas = mean(Proteinas),
            Gorduras.Totais = mean(Gorduras.Totais), 
            Gorduras.Saturadas = mean(Gorduras.Saturadas), 
            Gorduras.Trans = mean(Gorduras.Trans),
            Colesterol = mean(Colesterol), 
            Fibra.Alimentar = mean(Fibra.Alimentar), 
            Sodio = mean(Sodio),
            Calcio = mean(Calcio), 
            Ferro = mean(Ferro) )
mediagrupo


########################################
#
#    CLUSTER NAO HIERARQUICO - Mcdonald
#
########################################

#AGRUPANDO LANCHES PELO METODO NAO HIERARQUICO

#Rodar o modelo
mcdonalds.k2 <- kmeans(mcdonalds.padronizado, centers = 2)

#Visualizar os clusters
fviz_cluster(mcdonalds.k2, data = mcdonalds.padronizado, main = "Cluster K2")

#Criar clusters
mcdonalds.k3 <- kmeans(mcdonalds.padronizado, centers = 3)
mcdonalds.k4 <- kmeans(mcdonalds.padronizado, centers = 4)
mcdonalds.k5 <- kmeans(mcdonalds.padronizado, centers = 5)

#Criar graficos
G1 <- fviz_cluster(mcdonalds.k2, geom = "point", data = mcdonalds.padronizado) + ggtitle("k = 2")
G2 <- fviz_cluster(mcdonalds.k3, geom = "point",  data = mcdonalds.padronizado) + ggtitle("k = 3")
G3 <- fviz_cluster(mcdonalds.k4, geom = "point",  data = mcdonalds.padronizado) + ggtitle("k = 4")
G4 <- fviz_cluster(mcdonalds.k5, geom = "point",  data = mcdonalds.padronizado) + ggtitle("k = 5")

#Imprimir graficos na mesma tela
grid.arrange(G1, G2, G3, G4, nrow = 2)

#VERIFICANDO ELBOW 
fviz_nbclust(mcdonalds.padronizado, kmeans, method = "wss")


########################################
#
#    CLUSTER NAO HIERARQUICO - Municipios
#
########################################

#carregar base municipio
municipios <- read.table("dados/municipios.csv", sep = ";", header = T, dec = ",")
rownames(municipios) <- municipios[,1]
municipios <- municipios[,-1]


#padronizar dados
municipios.padronizado <- scale(municipios)


#Agora vamos rodar de 3 a 6 centros  e visualizar qual a melhor divisao
municipios.k3 <- kmeans(municipios.padronizado, centers = 3)
municipios.k4 <- kmeans(municipios.padronizado, centers = 4)
municipios.k5 <- kmeans(municipios.padronizado, centers = 5)
municipios.k6 <- kmeans(municipios.padronizado, centers = 6)

#Graficos
G1 <- fviz_cluster(municipios.k3, geom = "point", data = municipios.padronizado) + ggtitle("k = 3")
G2 <- fviz_cluster(municipios.k4, geom = "point",  data = municipios.padronizado) + ggtitle("k = 4")
G3 <- fviz_cluster(municipios.k5, geom = "point",  data = municipios.padronizado) + ggtitle("k = 5")
G4 <- fviz_cluster(municipios.k6, geom = "point",  data = municipios.padronizado) + ggtitle("k = 6")

#Criar uma matriz com 4 graficos
grid.arrange(G1, G2, G3, G4, nrow = 2)

#VERIFICANDO ELBOW 
fviz_nbclust(municipios.padronizado, FUN = hcut, method = "wss")

#juntando dados
municipios2 <- read.table("dados/municipios.csv", sep = ";", header = T, dec = ",")
municipiosfit <- data.frame(municipios.k6$cluster)

#Agrupar cluster e base
MunicipioFinal <-  cbind(municipios2, municipiosfit)



