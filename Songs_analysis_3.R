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
out <- paste0(inputs,"temp_ranked.csv")
inputs <- paste0(inputs,".csv")

#merge all different charts
path <- paste0(getwd(),"/Raw_charts/")
f <- list.files(path)

remove_list <- c("_ranked.csv", "ALL_SONGS", "headers", "Previous")
for(i in remove_list){
  f <-  f[!grepl(i, f)]
}
print(f)
# ALL <- do.call(rbind, lapply(paste0(path,f), function(i){
#   print(i)
#   read.csv(i, quote ="", fill = FALSE)
# })) #
ALL <- do.call(rbind, lapply(paste0(path,f), read.csv)) #
ALL <- dplyr::distinct(ALL)
write.csv(ALL[,1:5], paste0(path,"ALL_SONGS.csv"), row.names = F)
#
# f2 <- file(paste0(getwd(),"/Raw_charts/", f[2]), open = "r")
# lines <- readLines(f2)
# temp <- sapply(lines, function(i){
#   nchar(i)
# })
# lines[which(temp == 0)]
# close(f2)


# read.csv(paste0(getwd(),"/Raw_charts/",f[2]))
year <- 2016
month <- 1
num.top.songs <- 50 # Tells how many unique songs to write to a file after removing duplicates
min_median <- 30 # median rank a song has to be in top 30

rank_songs(inputFile = inputs,
           output = out,
           minYear = 1990, maxYear = 1992, # this will include all years.
           numWeeks = 0.80,
           presortMinRank = 40) # increased numWeeks to 4 because a song that is on multiple charts will have higher numWeeks

## Part 2: Get previous month's ranking and identify new songs
# Select all songs after 2018-01-01, export all songs before 2018-04 and then only for 2018-04, exclude 2018-05 onwards
if(grepl("Monthly", getwd())){
  setwd("../")
}

df <- fread(out)
df$Week <- as.Date(df$Week)
df <- na.omit(df)
str(df)
# write.csv(subset(df, Week >= "2017-01-01" & Week < "2017-02-01"), file = "2017-01-01.csv", row.names = F)

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
  # print(f.list)
  # print(nrow(small.df ))
  
  # if (counter_month > initial){
  #   # reading all previous files, when counter has passed intial date
  #   prev <- do.call(rbind,
  #                   lapply(f.list,
  #                          fread)) 
  #   prev$Week <- as.Date(prev$Week)
  #   # print(range(prev$Week))
  #   print(sum(small.df$Artist_Song %in% prev$Artist_Song))
  #   small.df <- subset(small.df,!(small.df$Artist_Song %in% prev$Artist_Song))
  #   temp2 <- rbind(prev, small.df[1:num.top.songs,])
  # } 
  # print(str(small.df))
  small.df <- small.df[order(small.df$Median_Rank),] 
  if(nrow(small.df) >= num.top.songs){ #top 'n' songs
    small.df <- small.df[1:num.top.songs,]
  } 
  write.csv(small.df, file = paste0(as.character(counter_month),".csv"), row.names = F)
  # write.csv(prev, file = paste0(as.character(counter_month),"_prev.csv"), row.names = F)
  
  # small.df <- subset(df, Week >= counter_month & Week < nxt_month) 
  
  counter_month <- nxt_month
}


# ## practicce joining two df
# setwd("../")
# raw <- fread(out)
# length(unique(paste(raw$Artist, raw$Song, sep = " - ")))
# a <- subset(df, Week <= as.Date("2018-02-28"))
# b <- subset(df, Week >= as.Date("2018-1-31"))
# 
# 
# # Vector subsetting
# temp <- subset(b,!(b$Artist_Song %in% a$Artist_Song))
# temp2 <- rbind(a, temp[1:20])
# 
# d <- table(temp2$Artist_Song)
# sum(d > 1)
# 
# boxplot(temp$Median_Rank)
# 
# 
# 

