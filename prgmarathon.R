library(jsonlite)
library(dplyr)
library(tidyr)
library(lubridate)
library(feather)
library(ggplot2)
library(scales)

aa <- read_feather("prgmarathon.feather")

yy <- aa %>% 
  mutate(birthDate = parse_date_time(birthDate, "d.m.Y"),
         birthYear = year(birthDate)) %>% 
         birthYear = year(birthDate),
         startTime = parse_date_time(startTime, "d.m.Y h:m:s"),
         splitTime = parse_date_time(splitTime, "d.m.Y h:m:s")) %>%
  group_by_(.dots = grpvars) %>% 
  nest()
  
yy %>% 
  unnest() %>% 
  group_by(ageGroup) %>% 
  mutate(agediff = mean(birthYear) - birthYear) %>%
  ungroup() %>% 
  mutate(plotorder = rnorm(n(), 0, 1)) %>% # mix up order so best don't show on
  arrange(plotorder)                       # top of plot


ggplot(yy, aes(subeventSplit.distance, 
               subeventSplit.length/splitFinishTime.seconds*3.6, group=runnerId,
               colour=agediff)) +
  geom_line(alpha=.1) +
  scale_color_continuous(low="green",high="yellow") +
  scale_y_continuous(limits=c(3.6,5*3.6)) + 
  facet_wrap( ~ageGroup) +
  theme_bw()

xx %>% 
  group_by(occupation, sex, ageGroup) %>%
  arrange(finishTime.seconds) %>% 
  mutate(newrank = min_rank(finishTime.seconds)) %>% 
  filter(firstName=="Petr", lastName == "Bouchal") %>% 
  select(newrank)

yy %>% 
  group_by(occupation, ageGroup, subeventSplit.title) %>%
  arrange(finishTime.seconds) %>% 
  mutate(newrank = min_rank(finishTime.seconds)) %>% 
  filter(firstName=="Petr", lastName == "Bouchal") %>% 
  select(newrank, rank, pace)

