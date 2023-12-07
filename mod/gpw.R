box::use(httr[...],
         jsonlite[...],
         xts[...],
         zoo[...],
         rvest[...],
         dplyr[...],
         purrr = purrr[map, slowly, rate_delay],
         readr = readr[read_csv]
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

