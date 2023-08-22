library(stringi)

ano <- format(Sys.Date(), "%Y")

url_download <- 'https://www.camara.leg.br/cotas/Ano-'
metodo_download <- 'wget'
destino_download <- paste('./cota_', print(stri_rand_strings(1, 8))[1], '.zip', sep='')

pasta_dados <- './../dados_brutos'

for(i in 2015:ano){
  url <- paste(url_download, i, '.csv.zip', sep="")
  print(url)
  
  status <- download.file(url, destino_download, method = metodo_download, mode='wb')
  if(status != 0){
    print(paste('Erro ao fazer download da URL', url))
  }
  
  tryCatch({
    unzip(destino_download, exdir = pasta_dados, overwrite = TRUE);
  },
  finally = {
    #Limpeza final
    if (file.exists(destino_download)) {
      unlink(destino_download)
      print(paste('Limpando arquivo', destino_download))
    }
  })
}
