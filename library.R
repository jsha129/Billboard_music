rank_songs <- function(inputFile = "2018_hot_club.csv", 
                       outputFile = "",
                       numWeeks = 4,
                       minYear = 2016, maxYear=2017, 
                       minMedian = NA,
                       presortMinRank = 100){
  # minimum number of weeks that a song is listed in top 100. Highly ranked songs spend roughtly 10-16 weeks in top 100 charts.
  
  df <- read.csv(inputFile, stringsAsFactors = F, row.names = NULL)
  df$Unique <- paste(df$Artist, df$Song, sep =" - ") # original
  # df$Rank <- as.numeric(df$Rank)
  # df$Unique <- paste(df$Artist, df$Song, df$Category,sep =" - ") # works too, but opted for above
  
  # matrix of songs vs rangking
  library(reshape2)
  df.backup <- df
  df <- subset(df, year(as.Date(df$Week)) >= minYear & year(as.Date(df$Week)) <= maxYear & Rank <= presortMinRank)
  df <- df[, c("Rank","Unique","Week", "Category")]
  df$Unique <- trimws(df$Unique)
  
  
  # 2017 songs
  # df <- df[grep("/17", df$Week),]
  df <- droplevels(df)
  
  # mat.songs <- acast(df, Unique ~ Week, value.var = "Rank") # works too, opted for below. ategory already in the 'Unique'
  mat.songs <- acast(df, Unique ~ Week + Category, value.var = "Rank") # original, this merges number of weeks in ALL charts, so a song can have high num_weeks in a short time after release if appreared on multiple charts
  median.mat.songs <- apply(mat.songs, 1, median, na.rm = T, na.omit = T)
  # median.mat.songs <- sort(median.mat.songs)
  
  weeks.mat.songs <- apply(mat.songs, 1, function(i){
    return(ncol(mat.songs) - sum(is.na(i)))
  })
  
  #compare raws before merging
  # match(names(median.mat.songs), names(weeks.mat.songs))
  
  songs <- data.frame(Artist_Song = names(median.mat.songs), 
                      Median_Rank = median.mat.songs, 
                      Num_Weeks = weeks.mat.songs)
  # songs$Prod <- songs$Median_Rank * songs$Num_Weeks
  numWeeks <- ifelse(numWeeks < 1, quantile(songs$Num_Weeks, numWeeks), numWeeks) # by quantile
  songs <- subset(songs, Num_Weeks >= numWeeks) # removes only a small number of songs
  if(!is.na(minMedian)){
    songs <- subset(songs, Median_Rank <= minMedian)
  }
  
  
  final <- merge(songs, df, by.x ="Artist_Song", by.y = "Unique")
  final <- final[order(final$Week, decreasing = F),]
  final <- subset(final, !duplicated(final$Artist_Song), -4)
  final$YouTube <- paste0("https://www.youtube.com/results?search_query=",
                          sub("&", " ",final$Artist_Song, fixed = T))
  final <- final[order(final$Median_Rank, decreasing = F),]

  write.csv(final, file = outputFile, row.names = F)
  # return(final)
  
}

