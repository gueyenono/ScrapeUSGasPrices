pacman::p_load(targets)

# Source custom functions ----

source(here::here("R/scraping_functions.R"))

# Set target-specific options such as packages.
tar_option_set(packages = c(
  "rvest",
  "dplyr",
  "stringr",
  "purrr",
  "here",
  "glue",
  "rvest"
))


# Targets ----

list(
  
  ##
  tar_target(state_page_urls, generate_state_page_urls()),
  
  ##
  tar_target(gasprice_data,
             purrr::map_dfr(state_page_urls, scrape_state_page_urls) %>%
               relocate(date, .before = regular)),
  
  ##
  tar_target(gasprice_data_city, {
    out <- gasprice_data[gasprice_data$location != "average", ]
    colnames(out)[colnames(out) == "location"] <- "city"
    out
  }),
  
  ## 
  
  tar_target(gasprice_data_state, {
    out <- gasprice_data[gasprice_data$location == "average", ]
    out$location <- NULL
    out
  }),
  
  ##
  tar_target(save_gasprice_data_city, {
    write.csv(x = gasprice_data_city, file = here::here("data/city", paste0(Sys.Date(), "-usa_gas_price-city.csv")))
    here::here("data/city", paste0(Sys.Date(), "-usa_gas_price-city.csv"))
  }, format = "file"),
  
  ##
  tar_target(save_gasprice_data_state, {
    write.csv(x = gasprice_data_state, file = here::here("data/state", paste0(Sys.Date(), "-usa_gas_price-state.csv")))
    here::here("data/state", paste0(Sys.Date(), "-usa_gas_price-state.csv"))
  }, format = "file")
  
)