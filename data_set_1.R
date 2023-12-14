library(tidyverse)


bilans <- readRDS("data/bilans.RDS") |> filter(!is.na(data_publikacji1)) |> na.omit() |> rename(data_publikacji = data_publikacji1)


rzis <- readRDS("data/rzis.RDS") |> filter(!is.na(data_publikacji)) |> na.omit()


cash_f <- readRDS("data/cf.RDS") |> filter(!is.na(data_publikacji)) |> 
  select(-platnosci_z_tytulu_umow_leasingu) |> na.omit()


full_dataset <- bilans |> inner_join(rzis, by = c("ticker", "data_publikacji")) |> 
  inner_join(cash_f, by = c("ticker", "data_publikacji"))


full_dataset |> saveRDS("data/full_dataset.RDS")
