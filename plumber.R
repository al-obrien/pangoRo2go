# Routing for pangoRo package functionality

library(plumber)
library(pangoRo)

# Create global object to share (avoid many pulls)
pangoro_obj <- pangoro(refresh = TRUE, offline = FALSE)

# For refresh purposes (global)
time_stamp <- Sys.time()
date_stamp <- format(time_stamp, '%Y-%m-%d')

#* @apiTitle Plumber API for {pangoRo}

#* Search pangoro
#* @post /search
#* @parser json list(simplifyVector = TRUE)
#* @serializer unboxedJSON
function(req) {
  if(length(req$body$direction) > 1) stop('Vector must be of length 1 for direction parameter')
  check_input_size(req$body$input)
  check_input_size(req$body$search)
  refresh_pangoro(date_stamp)

  mapply(req$body$input, req$body$search, req$body$direction,
         FUN = \(x, y, z) search_pangoro(pangoro_obj, x, y, z))
}

#* Expand pangoro
#* @post /expand
#* @parser json list(simplifyVector = TRUE)
#* @serializer unboxedJSON
function(req) {
  check_input_size(req$body)
  refresh_pangoro(date_stamp)

  pangoro_obj |> 
    expand_pangoro(req$body)
}

#* Collapse pangoro
#* @post /collapse
#* @parser json list(simplifyVector = TRUE)
#* @serializer unboxedJSON
function(req) {
  check_input_size(req$body)
  refresh_pangoro(date_stamp)
  
  pangoro_obj |> 
    collapse_pangoro(req$body)
}

#* Refresh pangoro object
#* @put /refresh
function() {
  refresh_pangoro(date_stamp = date_stamp)
}

#* Retrieve latest time refreshed
#* @get /latest
function() {
  date_stamp
}

# Function to detect timing of last refresh of pangoro object
refresh_pangoro <- function(date_stamp, date_span = 1, envir = .GlobalEnv) {
  curr_date <- Sys.Date()
  if( difftime(curr_date, date_stamp, units = 'days') >= date_span) {
    assign("pangoro_obj",  pangoRo::pangoro(refresh = TRUE), envir = envir)
    assign("date_stamp", curr_date, envir = envir)
  }
}

# Function for input length control
check_input_size <- function(input, threshold = 1e5) {
  if(length(input) > threshold) stop('Input provided is too large.')
}
