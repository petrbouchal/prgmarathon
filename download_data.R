library(jsonlite)
library(dplyr)
library(tidyr)
library(lubridate)
library(readr)

initialjson <- fromJSON("http://www.runczech.com/srv/www/api/runner-results/v1/results/?subeventId=11875&page=1&per_page=1", simplifyDataFrame = T, flatten=T)
numpages <- ceiling(initialjson$totalNumberOfRecords / 1000) 

baseurl <- "http://www.runczech.com/srv/www/api/runner-results/v1/results/?subeventId=11875&per_page=1000&page="

if(exists("xx")) rm(xx)
for (i in 1:numpages) {
  maraurl = paste0(baseurl, i)
  piece <- fromJSON(maraurl , simplifyDataFrame = T, flatten = T)
  piece <- as.data.frame(piece$data)
  print(maraurl)
  print(piece$lastName[1])
  print(dim(piece))
  if(!exists("xx")) {
    print("creating xx")
    xx <- piece
  } else {
    print("adding rows")
    xx <- bind_rows(xx, piece)
  }
  rm(piece)
}

library(feather)

xx %>% select(-subeventId, id_race = id, rank_race = rank, pace_race = pace,
              finishTime.seconds_race = finishTime.seconds,
              finishTime.time_race = finishTime.time,
              chipTime.time_race = chipTime.time,
              chipTime.seconds_race = chipTime.seconds) %>% 
  unnest(splitResults) %>%
  write_feather("prgmarathon.feather") %>% 
  write_csv("prgmarathon.csv")
