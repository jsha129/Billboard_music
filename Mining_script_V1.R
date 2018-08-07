rm (list = ls())
### Required packages
list.of.packages <- c("rvest", "lubridate", "data.table", "dplyr", "httr", "reshape2", "devtools", "Rspotify")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) {install.packages(new.packages)}
if(!any(grep("Rspotify", installed.packages()))){install_github("tiagomendesdantas/Rspotify")}

### -- Preset, loads all of above packages
lapply(list.of.packages, require, character.only = TRUE)

# - define variables for CSS
css_no1_song <- ".chart-number-one__title"
css_no1_artist <- ".chart-number-one__artist"
css_song_rank <- ".chart-list-item__rank"
css_song_name <- ".chart-list-item__title-text"
css_song_artist <- ".chart-list-item__artist"

# - custom functions
getWeeks <- function(startYear, endYear = startYear){
  require(lubridate)
  
  startDate <- ymd(paste(startYear, "01", "01",sep="-"))
  # print(paste("Running week:", startDate))
  while (wday(startDate) != 1){ #gets first sunday of the year
    startDate <- startDate + 1
  }
  
  #getting all Sundays of a year
  suns <- startDate
  while(year(startDate) <= endYear){
    startDate <- startDate + 7
    suns <- append(suns, startDate)
  }
  suns <- suns[which(suns <= today("US/Pacific"))]
  return(as.character(suns[1: length(suns)-1]))
}

fetchSongs <- function(week=NA, filename = "songs.csv", category="hot_100", printUrl = FALSE){
  if(is.na(week)){week <- today(tzone = "US/Pacific")}
  my_url <- paste0(as.character(charts[charts$Chart == category, "url"]),
                   "/", week)
  if(printUrl){print(my_url)}
  
  ## - Begin Web scarpin
  require(rvest)
  webpage <- read_html(my_url)
  
  # All except No 1 song
  # temp <- read.csv("Raw_charts/empty_headers.csv")
  tempRank <- cleanStr(html_text(html_nodes(webpage, css_song_rank)))
  tempSong <- cleanStr(html_text(html_nodes(webpage, css_song_name)))
  tempArtist <- cleanStr(html_text(html_nodes(webpage, css_song_artist)))
  
  temp <- data.frame(Rank = tempRank,
                     Song = tempSong,
                     Artist = tempArtist,
                     Category = category,
                     Week = week)
  # No 1 headings are different than rest
  tempRank <- "1"
  tempSong <- cleanStr(html_text(html_nodes(webpage, css_no1_song)))
  tempArtist <- cleanStr(html_text(html_nodes(webpage, css_no1_artist)))
  
  temp <- rbind(temp, data.frame(Rank = tempRank,
                                 Song = tempSong,
                                 Artist = tempArtist,
                                 Category = category,
                                 Week = week))
  
  ## Writing to the file
  # create a file if it does not exist
  if(!any(grepl(strsplit(filename, "/")[[1]][2],  list.files("Raw_charts/")))){
    df <- read.table("Raw_charts/empty_headers.csv", header = T, sep =",")
    write.table(df, file =  filename, sep =",", row.names = F)
  } else{
    df <- read.table(filename, sep=",", header = T )
    
  }
  
  write.table(rbind(df, temp), file = filename, sep =",", row.names = F)
}

cleanStr <- function(text){
  original <- c("\"", "\n",",")
  replacement <- c("","","_")
  
  for(i in 1:length(original)){
    text <- gsub(original[i], replacement[i] , text, fixed = T)
  }
  return(text)
  
}


### -- Start
charts <- read.csv("charts.csv")
# selected_charts <- c("hot_100", "pop", "hot_dance", "club_dance", "radio_songs", 
#                      "digital_songs", "streaming_songs", "hot_dance_airplay", "UK_top_40")
selected_charts <- c("hot_100")
charts <- subset(charts, Chart %in% selected_charts)
startYear <- 2016
stopYear <- 2017

# week_list <- as.character(today("US/Pacific") - 1) # NA here will allow all weeks in the for loop, otherwise specify a particular week here
for(i_chart in 1:nrow(charts)){
  # filename <- paste0("Raw_charts/", "ALL_2010s.csv")
  filename <- NA
  week_list <- NA
  
  current_chart <- as.character(charts[i_chart, "Chart"])
  print(paste0("--- ", current_chart, " ---"))
  
  if(is.na(filename)){
    filename <- paste0("Raw_charts/", "ALL_", current_chart, ".csv")
  }
  print(paste("Output:", filename))
  
  if(is.na(week_list)){
    week_list <- getWeeks(startYear, stopYear)
  } 
  ## some filtering of weeks to remove data that already exist for weeks present in the file
  week_list <- week_list[which(week_list >= as.Date(charts[i_chart, "startWeek"]))]
  
  # checking if file exists before using its data for filtering
  if(any(grepl(strsplit(filename, "/")[[1]][2],  list.files("Raw_charts/")))){
    temp <- read.csv(filename)
    existingWeeks <- unique(as.character(temp$Week))
    week_list <- setdiff(week_list, existingWeeks)
    week_list <- week_list[which(week_list <= today("US/Pacific"))]
  }
  print(paste("Mining",length(week_list), "weeks"))
  
  for(week in week_list){
    try(fetchSongs(week, category = current_chart, printUrl = F,
                   filename = filename))
    print(week) # After the data has been fetched to make sure previous threasd was successful
  }
  print(paste(current_chart, "completed"))
  
}

