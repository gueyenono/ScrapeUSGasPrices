# Tutorial link: https://www.bnosac.be/index.php/blog/50-taskscheduler-r-package-to-schedule-r-scripts-with-the-windows-task-manager-2

library(taskscheduleR)

script <- here::here("scrape_data.R")

taskscheduler_create(
  taskname = "scrape_gas_prices",
  rscript = script,
  schedule = "DAILY",
  startdate = format(Sys.Date(), "%m/%d/%Y"),
  starttime = format(Sys.time() + 10, "%H:%M") 
)

taskscheduler_delete(taskname = "scrape_gas_prices")
