library(rvest)
library(dplyr)
library(stringr)
library(purrr)
library(here)
library(magrittr)


# Generate state URLS ----------------------------------------------------

master <- 
  tibble(
    state_abbs = c(state.abb, "DC") %>% sort(),
    state_urls = paste0("https://gasprices.aaa.com/?state=", state_abbs)
  )


# Create HTML folder for current gas prices (current means today) (if needed)

if(!dir.exists(here("html", Sys.Date()))){
  dir.create(path = here("html", Sys.Date()))
}


# Download HTML files into today's folder

walk2(master$state_urls, master$state_abbs, ~ download.file(url = .x, destfile = here("html", Sys.Date(), paste0(.y, ".html"))))


# Add file paths to the master dataset

master %<>% mutate(state_paths = list.files(here("html", Sys.Date()), full.names = TRUE))


# Function for scraping city data

scrape_city_data <- function(url){
  
  page_html <- read_html(url)
  
  city <- page_html %>%
    html_nodes("h3") %>%
    html_text()
  
  prices <- page_html %>%
    html_nodes("[class='table-mob']") %>%
    html_table() %>%
    .[-1] %>%
    invoke(rbind, .)
  
  colnames(prices)[1] <- "Average"
  prices$City <- rep(city, each = 5)
  
  prices %>%
    mutate_at(.vars = vars(Regular:Diesel), .funs = list(~stringr::str_replace(string = .x, pattern = "\\$", replacement = "") %>% as.numeric())) %>%
    mutate(Date = Sys.Date()) %>%
    tidyr::pivot_longer(cols = Regular:Diesel, names_to = "Fuel_Type", values_to = "Price") %>%
    select(Date, City, Fuel_Type, Average, Price)
}

scrape_city_data_possibly <- possibly(scrape_city_data, otherwise = NA)


# Generate state URLs

master %<>%
  mutate(data = map(state_paths, scrape_city_data_possibly)) %>%
  tidyr::unnest(data) %>%
  janitor::clean_names() %>%
  select(date, city, state = state_abbs, url = state_urls, fuel_type, average, price)


# Save data to disk

# Create data folder for current gas prices (current means today) (if needed)

if(!dir.exists(here("data", Sys.Date()))){
  dir.create(path = here("data", Sys.Date()))
}

readr::write_csv(master, here("data", paste0(Sys.Date(), ".csv")))
