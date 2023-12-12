box::use(httr[...],
         jsonlite[...],
         xts[...],
         zoo[...],
         rvest[...],
         dplyr[...],
         tidyr = tidyr[separate],
         purrr = purrr[map, slowly, rate_delay],
         readr = readr[read_csv],
         janitor = janitor[clean_names],
         sjmisc = sjmisc[rotate_df],
         stats = stats[na.omit],
         stringr = stringr[str_remove_all],
         readr = readr[parse_number]
)




#' @export
stooq_dw <- function(symbol, close_only = TRUE){
  
  s_link <- "https://stooq.pl/q/d/l/?s="
  s_symbol <- symbol
  s_end <- "&i=d"
  
  full_link <- paste0(s_link, s_symbol, s_end)
  
  my_data <- read_csv(full_link)
  my_data <- my_data %>% dplyr::select(Data,Otwarcie,Najwyzszy,Najnizszy,Zamkniecie)
  colnames(my_data) <- c("Date", "Open", "High", "Low", "Close")
  my_data <- na.locf(my_data)
  
  if(close_only == TRUE){
    my_data <- my_data %>% dplyr::select(Date, Close) %>% rename_with(~ gsub("[^[:alnum:] ]", "", s_symbol), .cols = Close)
    
    
    
  }else{
    my_data
  }
  
  
  
}



#' @export
get_stooq_data <- function(ticks){
  
  
  xy <- map(ticks, stooq_dw)
  
  
  
  W20 <- read_csv("https://stooq.pl/q/d/l/?s=fw20&i=d")
  #saveRDS(W20, "W20.RDS")
  
  
  
  master_t <- tibble(Date = W20$Data)
  
  for(n in seq_along(xy)){
    print(n)
    master_t <- master_t %>% left_join(xy[[n]], by = "Date")
    
    
  }
  master_t
  
}


#' @export
get_table <- function(table_url){
  
  table_path <- '//*[@id="profile-finreports"]/table'
  
  set_config(add_headers(`User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36"))
  
  get_delayed <- slowly(~ GET(.), 
                        rate = rate_delay(3))
  
  get_result <- get_delayed(table_url)
  
  raw_html <- read_html(get_result)
  
  raw_html %>% html_nodes(xpath = table_path) %>% 
    html_table()
  
}


#' @export
get_companies <- function(table_url){
  
  table_path <- '//*[@id="right-content"]/div/table'
  
  set_config(add_headers(`User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36"))
  
  get_delayed <- slowly(~ GET(.), 
                        rate = rate_delay(3))
  
  get_result <- get_delayed(table_url)
  
  raw_html <- read_html(get_result)
  
  raw_html %>% html_nodes(xpath = table_path) %>% 
    html_table()
  
}

#' @export
get_companies_links <- function(table_url){
  
  table_path <- '//*[@id="right-content"]/div/table'
  
  set_config(add_headers(`User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36"))
  
  get_delayed <- slowly(~ GET(.), 
                        rate = rate_delay(3))
  
  get_result <- get_delayed(table_url)
  
  raw_html <- read_html(get_result)
  
  companies <- raw_html |> html_elements(xpath = table_path) |> html_table()
  companies <- companies[[1]] |> clean_names() |>
    separate(col = profil, into = c("ticker", "name"), sep = " ") |> select(ticker) |> 
    filter(nchar(ticker) == 3)
  
  c_links <- tibble(link = paste0("https://www.biznesradar.pl", 
                                  raw_html |> html_elements(xpath = table_path)  |> 
                      html_elements(".bvalue") |> html_elements("a") |> html_attr("href"),
           ",", "Q"))
  
  c_links <- c_links |> filter(link != "https://www.biznesradar.pl/raporty-finansowe-rachunek-zyskow-i-strat/SVRS,Q")

  companies$link <- c_links$link
  companies
  
}


#' @export
clean_rzis <- function(tb){
  tb |> clean_names() |> rotate_df(cn = TRUE) |> as_tibble() |> clean_names() |> 
    mutate(data_publikacji = as.Date(data_publikacji)) |>
    mutate(across(przychody_ze_sprzedazy:ebitda, str_remove_all, " ")) |> 
    mutate(across(przychody_ze_sprzedazy:ebitda, parse_number)) |> na.omit() 
}




