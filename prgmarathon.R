library(jsonlite)
library(dplyr)
library(tidyr)
library(lubridate)
library(feather)
library(ggplot2)
library(scales)
library(stringr)
library(readr)
library(extrafont)

# aa <- read_feather("prgmarathon.feather")
pmd <- read_csv("prgmarathon.csv")

grpvars <- names(pmd)[c(c(3:9), c(11:20), c(22:28))]
grpvars <- lapply(c(grpvars, "birthYear"), as.symbol)

pmds <- pmd %>%
  select(-subeventSplit.finish, -subeventSplit.subeventId, -subeventSplit.id,
         -id, -id_race, -runnerProfileId, -occupationId, -entryState, -eventId) %>% 
  mutate(birthDate = parse_date_time(birthDate, "d.m.Y"),
         birthYear = year(birthDate),
         startTime = parse_date_time(startTime, "d.m.Y h:m:s"),
         splitTime = parse_date_time(splitTime, "d.m.Y h:m:s")) %>%
  group_by_(.dots = grpvars) %>% 
  nest()

rm(pmd)
  
pmds %>% 
  unnest() %>% 
  group_by(ageGroup) %>% 
  mutate(agediff = mean(birthYear) - birthYear) %>%
  ungroup() %>% 
  mutate(plotorder = rnorm(n(), 0, 1)) %>% # mix up order so best don't show on
  arrange(plotorder) %>%                   # top of plot
  ggplot(aes(subeventSplit.distance, 
               subeventSplit.length/splitFinishTime.seconds*3.6, group=runnerId,
               colour=agediff)) +
  geom_line(alpha=.1) +
  scale_color_continuous(low="green",high="yellow") +
  scale_y_continuous(limits=c(3.6,5*3.6)) + 
  facet_wrap( ~ageGroup) +
  theme_bw()

pmds %>% 
  unnest() %>% 
  group_by(occupation, sex, ageGroup) %>%
  arrange(finishTime.seconds) %>% 
  mutate(newrank = min_rank(finishTime.seconds)) %>% 
  filter(firstName=="Petr", lastName == "Bouchal") %>% 
  select(newrank)

pmds %>%
  unnest() %>% 
  group_by(occupation, ageGroup, subeventSplit.title) %>%
  arrange(finishTime.seconds) %>% 
  mutate(newrank = min_rank(finishTime.seconds)) %>% 
  filter(firstName=="Petr", lastName == "Bouchal") %>% 
  select(newrank, rank, pace)

pmds %>%
  unnest() %>% 
  group_by(sex) %>%
  mutate(timedecile = ntile(chipTime.seconds_race, 5)) %>% 
  group_by(timedecile, subeventSplit.title, sex) %>% 
  mutate(meanpace = mean(1/pace*60, na.rm=T),
         grp = paste(timedecile, sex)) %>% 
  ggplot(aes(subeventSplit.distance, meanpace, group=grp, colour=sex)) + 
  geom_line() + facet_grid(timedecile ~ .) +
  labs(caption="Data from runczech.cz", title="Pace over splits",
       subtitle="Prague Marathon May 2016") +
  theme(text=element_text(family="Newslab"))

