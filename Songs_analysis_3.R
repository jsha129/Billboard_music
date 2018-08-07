rm(list = ls())
library(lubridate)
library(data.table) #reads multiple files
library(dplyr)
if(grepl("Monthly", getwd())){
  setwd("../")
}
source("library.R")

## HIgher level
# Creating a data frame that will store all types of charts/labels, input and output files
# setwd("../")
inputs <- c("Raw_charts/ALL_SONGS")
out <- paste0(inputs,"_2016_hot_100_ranked.csv")
inputs <- paste0(inputs,".csv")

#merge all different charts
path <- paste0(getwd(),"/Raw_charts/")
f <- list.files(path)
# f <- "ALL_hot_100.csv"
remove_list <- c("_ranked.csv", "ALL_SONGS", "headers", "Previous")
for(i in remove_list){
  f <-  f[!grepl(i, f)]
}
print(f)

ALL <- do.call(rbind, lapply(paste0(path,f), read.csv)) #
ALL <- dplyr::distinct(ALL)
write.csv(ALL[,1:5], paste0(path,"ALL_SONGS.csv"), row.names = F)

year <- 1990
month <- 1 # start month for exporting playlists
num.top.songs <- 50 # Tells how many unique songs to write to a file after removing duplicates
min_median <- 20 # median rank a song has to be in top 30

rank_songs(inputFile = inputs,
           output = out,
           minYear = 2016, maxYear = 2017, 
           numWeeks = 0.9, # select songs that has 'numWeeks' in 90th percentile, ie appeared in top 10% of numWeek score
           minMedian = 10,
           presortMinRank = 20) # PresortMinRank keeps only songs that were less than this number before ranking begins; helps speed up matrix calculations when dealing with lots of data, 

## Part 2: Get previous month's ranking and identify new songs
# Select all songs after 2018-01-01, export all songs before 2018-04 and then only for 2018-04, exclude 2018-05 onwards
if(grepl("Monthly", getwd())){
  setwd("../")
}

df <- fread(out)
df$Week <- as.Date(df$Week)
df <- na.omit(df)

initial <- as.Date(paste(year, month, "01", sep = "-"))
counter_month <- as.Date(paste(year, month, "01", sep = "-"))
setwd(paste0(getwd(),"/Monthly_charts")) # important for the while loop

while(counter_month <= today(tzone = "GMT")){
  counter_month <- as.Date(paste(year, month, "01", sep = "-"))
  if (month >= 12){
    year <- year + 1
    month <- 1
  } else {
    month <- month +1
  }
  
  nxt_month <- as.Date(paste(year, month, "01", sep = "-")) # month already incremeted
  
  # selecting songs for a given month, regardless of duplicated previous entries
  small.df <- subset(df, (Week >= counter_month & Week < nxt_month) & Median_Rank <= min_median)
  
  f.list <- list.files(getwd())
  f.list <- f.list[grep("01.csv", f.list)]

  small.df <- small.df[order(small.df$Median_Rank),] 
  if(nrow(small.df) >= num.top.songs){ #top 'n' songs
    small.df <- small.df[1:num.top.songs,]
  } 
  write.csv(small.df, file = paste0(as.character(counter_month),".csv"), row.names = F)
  # write.csv(prev, file = paste0(as.character(counter_month),"_prev.csv"), row.names = F)
  
  # small.df <- subset(df, Week >= counter_month & Week < nxt_month) 
  
  counter_month <- nxt_month
}

