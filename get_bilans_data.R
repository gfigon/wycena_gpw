#box::unload(gpw)
library(tidyverse)
box::use(./mod/gpw)



companies_links <- gpw$get_companies_links_bilans("https://www.biznesradar.pl/spolki-raporty-finansowe-bilans/akcje_gpw")





get_table_s <- purrr::safely(gpw$get_table)

tabele <- map(companies_links$link, get_table_s)

tabele <- map(tabele, ~ .$result[[1]])

tabele_clean <- map(tabele, gpw$clean_bilans) 


for(t in 1:length(tabele_clean)){
  
  print(t)
  tabele_clean[[t]] <- tabele_clean[[t]] |> mutate(ticker = companies_links$ticker[t])
  
  
}

bind_rows(tabele_clean) |> saveRDS("data/bilans.RDS")
