
# SandP1500 Wikipedia scraping
## Code by https://github.com/ruboin


#@@@@@@@@@@@@@@@@@@@
# Preparations #####
#@@@@@@@@@@@@@@@@@@@


### Which years are you interested in?

from_year <- 2000 # change to your desired lowest included year
to_year <- 2023 # change to your desired highest included year


### Required packages

required_Packages_Install <- c("tidyverse", "rvest")

for (Package in required_Packages_Install){
  if (!require(Package, character.only = TRUE)) {
    install.packages(Package, dependencies = TRUE)
  }
  library(Package, character.only = TRUE)
}

### Create folder
if (!dir.exists("SandP1500_data")) {
  dir.create("SandP1500_data")
}


#@@@@@@@@@@@@@@
# S&P 500 #####
#@@@@@@@@@@@@@@

wikispx <- read_html('https://en.wikipedia.org/wiki/List_of_S%26P_500_companies')
currentconstituents <- wikispx %>%
  html_node('#constituents') %>%
  html_table(header = TRUE)

currentconstituents

spxchanges <- wikispx %>%
  html_node('#changes') %>%
  html_table(header = FALSE, fill = TRUE) %>%
  filter(row_number() > 2) %>% # First two rows are headers
  `colnames<-`(c('Date','AddTicker','AddName','RemovedTicker','RemovedName','Reason')) %>%
  mutate(Date = parse_date_time(Date, orders = c('B d, Y'), quiet = TRUE),
         Date = as.Date(Date),
         year = year(Date),
         month = month(Date))

spxchanges


# Start at the current constituents...
currentmonth <- as.Date(format(Sys.Date(), '%Y-%m-01'))
monthseq <- seq.Date(as.Date('1990-01-01'), currentmonth, by = 'month') %>% rev()

spxstocks <- currentconstituents %>% mutate(Date = currentmonth) %>% select(Date, Ticker = Symbol, Name = Security)
lastrunstocks <- spxstocks

# Iterate through months, working backwards
for (i in 2:length(monthseq)) {
  d <- monthseq[i]
  y <- year(d)
  m <- month(d)
  changes <- spxchanges %>% 
    filter(year == year(d), month == month(d)) 
  
  # Remove added tickers (we're working backwards in time, remember)
  tickerstokeep <- lastrunstocks %>% 
    anti_join(changes, by = c('Ticker' = 'AddTicker')) %>%
    mutate(Date = d)
  
  # Add back the removed tickers...
  tickerstoadd <- changes %>%
    filter(!RemovedTicker == '') %>%
    transmute(Date = d,
              Ticker = RemovedTicker,
              Name = RemovedName)
  
  thismonth <- tickerstokeep %>% bind_rows(tickerstoadd)
  spxstocks <- spxstocks %>% bind_rows(thismonth)  
  
  lastrunstocks <- thismonth
}

spxstocks

###

spxstocks <- spxstocks %>%
  mutate(year = lubridate::year(as.Date(Date))) %>% 
  filter(year >= from_year & year <= to_year)

SandP500_data_year_ticker_wik <- spxstocks %>%
  distinct(year, Ticker, .keep_all = TRUE) %>%
  arrange(Ticker, year) %>% 
  select(-Date)

###

write.csv(SandP500_data_year_ticker_wik, "SandP1500_data\\SandP500_data_year_ticker_wikipedia.csv", row.names=FALSE) # Use write.csv2(...) for separator ";" instead of ",".


#@@@@@@@@@@@@@@
# S&P 400 #####
#@@@@@@@@@@@@@@

# Load S&P 400 Wikipedia Page
wikispx <- read_html('https://en.wikipedia.org/wiki/List_of_S%26P_400_companies')

# Extract Current Constituents (First table)
currentconstituents <- wikispx %>%
  html_nodes('table.wikitable') %>%
  .[[1]] %>%
  html_table(header = TRUE)

print(head(currentconstituents)) # Check structure

# Extract Historical Changes Table (Second `wikitable`)
spxchanges <- wikispx %>%
  html_nodes('table.wikitable') %>%
  .[[2]] %>%  
  html_table(header = FALSE, fill = TRUE) %>%
  filter(row_number() > 2) %>%  # Remove header rows
  `colnames<-`(c('Date','AddTicker','AddName','RemovedTicker','RemovedName','Reason')) %>%
  mutate(Date = parse_date_time(Date, orders = c('B d, Y'), quiet = TRUE),
         Date = as.Date(Date),
         year = year(Date),
         month = month(Date))

print(head(spxchanges)) # Check structure

# Generate a sequence of months (S&P 400 started in 1991)
currentmonth <- as.Date(format(Sys.Date(), '%Y-%m-01'))
monthseq <- seq.Date(as.Date('1991-01-01'), currentmonth, by = 'month') %>% rev()

# Start from Current Constituents
spxstocks <- currentconstituents %>% mutate(Date = currentmonth) %>% select(Date, Ticker = Symbol, Name = Security)
lastrunstocks <- spxstocks

# Iterate through months, working backwards
for (i in 2:length(monthseq)) {
  d <- monthseq[i]
  y <- year(d)
  m <- month(d)
  changes <- spxchanges %>% 
    filter(year == y, month == m) 
  
  # Remove added tickers (working backwards)
  tickerstokeep <- lastrunstocks %>% 
    anti_join(changes, by = c('Ticker' = 'AddTicker')) %>%
    mutate(Date = d)
  
  # Add back the removed tickers
  tickerstoadd <- changes %>%
    filter(RemovedTicker != "") %>%
    transmute(Date = d,
              Ticker = RemovedTicker,
              Name = RemovedName)
  
  thismonth <- tickerstokeep %>% bind_rows(tickerstoadd)
  spxstocks <- spxstocks %>% bind_rows(thismonth)  
  lastrunstocks <- thismonth
}

print(head(spxstocks)) # Check structure

# Filter relevant years
spxstocks <- spxstocks %>%
  mutate(year = year(as.Date(Date))) %>% 
  filter(year >= from_year & year <= to_year)

SandP400_data_year_ticker_wik <- spxstocks %>%
  distinct(year, Ticker, .keep_all = TRUE) %>%
  arrange(Ticker, year) %>% 
  select(-Date)

# Save to CSV
write.csv(SandP400_data_year_ticker_wik, "SandP1500_data/SandP400_data_year_ticker_wikipedia.csv", row.names=FALSE)


#@@@@@@@@@@@@@@
# S&P 600 #####
#@@@@@@@@@@@@@@

# Load S&P 600 Wikipedia Page
wikispx <- read_html('https://en.wikipedia.org/wiki/List_of_S%26P_600_companies')

# Extract Current Constituents
currentconstituents <- wikispx %>%
  html_node('#constituents') %>%
  html_table(header = TRUE)

print(head(currentconstituents)) # Check structure

# Extract Historical Changes Table (Second `wikitable` on the page)
spxchanges <- wikispx %>%
  html_nodes('table.wikitable') %>%
  .[[2]] %>%  # Assuming it's the second table on the page
  html_table(header = FALSE, fill = TRUE) %>%
  filter(row_number() > 2) %>% # Remove header rows
  `colnames<-`(c('Date','AddTicker','AddName','RemovedTicker','RemovedName','Reason')) %>%
  mutate(Date = parse_date_time(Date, orders = c('B d, Y'), quiet = TRUE),
         Date = as.Date(Date),
         year = year(Date),
         month = month(Date))

print(head(spxchanges)) # Check structure

# Generate a sequence of months (S&P 600 started in 1994)
currentmonth <- as.Date(format(Sys.Date(), '%Y-%m-01'))
monthseq <- seq.Date(as.Date('1994-01-01'), currentmonth, by = 'month') %>% rev()

# Start from Current Constituents
spxstocks <- currentconstituents %>% mutate(Date = currentmonth) %>% select(Date, Ticker = Symbol, Name = Company)
lastrunstocks <- spxstocks

# Iterate through months, working backwards
for (i in 2:length(monthseq)) {
  d <- monthseq[i]
  y <- year(d)
  m <- month(d)
  changes <- spxchanges %>% 
    filter(year == y, month == m) 
  
  # Remove added tickers (working backwards)
  tickerstokeep <- lastrunstocks %>% 
    anti_join(changes, by = c('Ticker' = 'AddTicker')) %>%
    mutate(Date = d)
  
  # Add back the removed tickers
  tickerstoadd <- changes %>%
    filter(RemovedTicker != "") %>%
    transmute(Date = d,
              Ticker = RemovedTicker,
              Name = RemovedName)
  
  thismonth <- tickerstokeep %>% bind_rows(tickerstoadd)
  spxstocks <- spxstocks %>% bind_rows(thismonth)  
  lastrunstocks <- thismonth
}

print(head(spxstocks)) # Check structure

# Filter relevant years
spxstocks <- spxstocks %>%
  mutate(year = year(as.Date(Date))) %>% 
  filter(year >= from_year & year <= to_year)

SandP600_data_year_ticker_wik <- spxstocks %>%
  distinct(year, Ticker, .keep_all = TRUE) %>%
  arrange(Ticker, year) %>% 
  select(-Date)

# Save to CSV
write.csv(SandP600_data_year_ticker_wik, "SandP1500_data/SandP600_data_year_ticker_wikipedia.csv", row.names=FALSE)


#@@@@@@@@@@@@@@@@@@@@@@@@@
# Combining datasets #####
#@@@@@@@@@@@@@@@@@@@@@@@@@

SandP500_data_year_ticker_wik <- read_csv("SandP1500_data/SandP500_data_year_ticker_wikipedia.csv")
SandP400_data_year_ticker_wik <- read_csv("SandP1500_data/SandP400_data_year_ticker_wikipedia.csv")
SandP600_data_year_ticker_wik <- read_csv("SandP1500_data/SandP600_data_year_ticker_wikipedia.csv")

SandP500_data_year_ticker_wik$Index <- "SandP500"
SandP400_data_year_ticker_wik$Index <- "SandP400"
SandP600_data_year_ticker_wik$Index <- "SandP500"

SandP1500_data_year_ticker_wik <- rbind(SandP500_data_year_ticker_wik, SandP400_data_year_ticker_wik, SandP600_data_year_ticker_wik)

###

write.csv(SandP1500_data_year_ticker_wik, "SandP1500_data\\SandP1500_data_year_ticker_wikipedia.csv", row.names=FALSE) # Use write.csv2(...) for separator ";" instead of ",".
