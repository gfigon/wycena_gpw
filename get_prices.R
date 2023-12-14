#box::unload(gpw)
library(tidyverse)
box::use(./mod/gpw)


ticker_list <- readRDS("data/full_dataset.RDS") |> count(ticker)

price_data <- gpw$get_stooq_data(ticker_list$ticker[301:nrow(ticker_list)])



prices1 <- readRDS("data/prices1.RDS")
prices2 <- readRDS("data/prices2.RDS")
prices3 <- readRDS("data/prices3.RDS")
prices4 <- readRDS("data/prices4.RDS")



prices1 |> left_join(prices2, by="Date") |> 
  left_join(prices3, by="Date") |> 
  left_join(prices4, by="Date") |> saveRDS("data/all_prices.RDS")

all_prices <- readRDS("data/all_prices.RDS")
#all_prices |> filter(Date > "2023-01-01")
