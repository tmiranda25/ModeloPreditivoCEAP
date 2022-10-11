y2ybc <- function(y, lambda){
  return (((y ^ lambda) - 1) / lambda)
}

ybc2y <- function(ybc, lambda){
  return (((ybc * lambda) +1) ^ (1/lambda))
}
