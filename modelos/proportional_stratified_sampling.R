sample_stratum1 <- function(row, pss){

  col_length <- length(pss$cols)
  
  #generate the index using the cols
  col_name1 <- cols[1]
  idx <- row[[col_name1]]
  
  if(col_length > 1){
    
    for(i in 2:col_length){
      
      col_name <- cols[i]
      
      idx <- paste(idx, row[[col_name]], sep = '.')
    }
  }
  
  df_split <- pss$df_split
  
  #get the dataframe by index
  df_sample <- df_split[[idx]]
  
  #number of samples
  size <- row[["size"]]
  
  #sample size rows from df_sample
  return(sample(df_sample, ceiling(size)))
}
#' Generate a sample of the dataframe filtered by row values
#' 
#' @param pss Value returned by function create pss.
#' @param row An row containing cols and values
#' @return the sampling dataframe
sample_stratum <- function(row, pss){
  
  df <- pss$df_origin
  
  col_length <- length(pss$cols)
  
  #if number of cols is lower or equal 3, filter without loop, else filter incrementally
    
  if(col_length == 1){
    col_name1 = cols[1]
    df <- df %>% 
      filter(df[[col_name1]] == row[[col_name1]])
  }
  else if(col_length == 2){
    col_name1 = cols[1]
    col_name2 = cols[2]
    df <- df %>% 
      filter(df[[col_name1]] == row[[col_name1]], df[[col_name2]] == row[[col_name2]])
  }else if(col_length == 3){
    col_name1 = cols[1]
    col_name2 = cols[2]
    col_name3 = cols[3]
    df <- df %>% 
      filter(df[[col_name1]] == row[[col_name1]], df[[col_name2]] == row[[col_name2]], df[[col_name3]] == row[[col_name3]])
  }else{
  
    for(i in 1:length(pss$cols)){
      
      col_name <- cols[i]
      
      df <- df %>% filter(df[[col_name]] == row[[col_name]])
    }
  }
  
  size <- row[["size"]]

  return(sample(df, ceiling(size)))
}

#' Create samples from a proportional stratified sampling
#' 
#' @param pss A list containing the original data, the strata
#' @return the sampling dataframe
sample_pss <- function(pss){

  n <- nrow(pss$df_strata)
  
  #copy the structure of original dataframe
  df_sample <- pss$df_origin[0,]
  
  for(i in 1:n){
    row <- pss$df_strata[i,]
    df_sample <- rbind(df_sample, sample_stratum1(row, pss))
    #message(paste(i, " linha de ", n))
  }
  
  return(df_sample)
}

#' Calculate the sampling size and strata parameters
#' 
#' @param df An dataframe.
#' @param value_col The name of the value column
#' @param b Maximum estimation error.
#' @param cols A string or string vector containing columns names
#' @pram z Critical value
#' @return samples_size and a dataframe with size and other parameters for each strata
create_pss <- function(df, value_col, cols, b, z = 0.95){
  
  count_total <- nrow(df)   
  
  df_strata <- df %>% 
    group_by_at(cols)  %>% 
    summarise(.groups = "keep", n = n(), sum = sum(get(value_col)), v = var(get(value_col))) %>%
    filter(n > 1)
  
  df_strata$w <- df_strata$n/count_total
  
  df_strata$numerator <- df_strata$n^2*df_strata$v/df_strata$w
  df_strata$denominator <- df_strata$n*df_strata$v
  
  z_critico <- qnorm((1-z)/2)
  denominator_const = count_total^2*b^2/z_critico^2
  
  sample_size <- sum(df_strata$numerator)/(denominator_const + sum(df_strata$denominator))
  
  df_strata$size = df_strata$w * sample_size
  
  f <- df %>% dplyr::select(all_of(cols))
  
  df_split <- split(df, f = f)  
  
  lista <- list(sample_size, df_strata, df_split, df, value_col, cols, b, z)  
  names(lista) <- c("sample_size", "df_strata", "df_split", "df_origin", "value_col", "cols", "b", "z")
  
  return (lista)
}