# Swap to a dev profiled
renv::activate(profile = "dev")

library(httr)
library(callr)

api_port <- 3325

# Run in background
bg_job <- callr::r_bg(function(api_port) {
  plumber::pr('plumber.R') |>
    plumber::pr_set_docs(FALSE) |>
    plumber::pr_run(port = api_port)
  }, args = list(api_port = api_port))

# Interactive... run selected as background job from GUI
# plumber::pr('plumber.R') |>
#   plumber::pr_run(port = 3325)

# API Route URL
pangoroURL <- paste0('http://127.0.0.1:', api_port)

# Fake data to provide
lineages <- c('B.1.1.529.1', 'B.1.1.529.2.75.1.2', 'BA.1', NA_character_)

# Expand test
POST(file.path(pangoroURL, 'expand'),
    body = jsonlite::toJSON(lineages)) |>
  content(simplifyVector = TRUE)

# Collapse test
POST(file.path(pangoroURL, 'collapse'),
     body = jsonlite::toJSON(lineages)) |>
  content(simplifyVector = TRUE)

# Search test   
POST(file.path(pangoroURL, 'search'),
     body = jsonlite::toJSON(list(input= c('BA.5', 'BA.5'), 
                                 search = c('BA.5.1', 'BL.1'),
                                 direction = 'both'))) |>
  content(simplifyVector = TRUE)

# Refresh check
GET(file.path(pangoroURL, 'latest')) |> content()
PUT(file.path(pangoroURL, 'refresh')) |> content()
GET(file.path(pangoroURL, 'latest')) |> content()


# Clean up
bg_job$is_alive()
bg_job$kill()

# Swap back to default (for entire project), or those just for plumber
# renv::activate(profile = NULL)
# renv::activate(profile = "plumber")

