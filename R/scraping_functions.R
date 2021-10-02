
generate_state_page_urls <- function(){
  state_page_urls <- glue("https://gasprices.aaa.com/?state={sort(c(state.abb, 'DC'))}")
}

scrape_state_page_urls <- function(state_page_url){
  
  state <- str_extract(string = state_page_url, pattern = ".{2}$")
  html_page <- read_html(state_page_url)
  
  city <- html_page %>%
    html_elements(css = ".accordion-prices > h3") %>%
    html_text()
  
  html_page %>%
    html_elements(css = "table[class = 'table-mob']") %>%
    html_table() %>%
    map_dfr(function(x){
      x %>%
        select(-1) %>%
        slice(1) %>%
        setNames(c("regular", "mid", "premium", "diesel")) %>%
        mutate(date = Sys.Date(),
               across(.cols = regular:diesel,
                      .fns = ~ str_remove(string = .x, pattern = "\\$") %>% as.numeric()))
    }) %>%
    mutate(location = c("average", city), state = state)
  
}
