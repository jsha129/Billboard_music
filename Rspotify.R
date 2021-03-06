## how to use
# 1, Run R scripts to get top songs for a month
# 2, Create a playlist in Spotify manually and run this script. Get autherization code, copy the ID for the newly created playlist
# 3, https://developer.spotify.com/console/post-playlist-tracks/
# 4, paste playlist ID, and URIs of the songs from this script
# 5, Add and that's it.

## things I cannot automate yet
# 1, add a playlist from script or web api
# 2, add songs from terminal or R. but can be done through web api with above token
# For now, add an album manually, make spotify uris from above function, paste that on web api to add songs

## Script
rm(list = ls())
library(httr)
library(Rspotify) #https://github.com/tiagomendesdantas/Rspotify

## variables
app_id <- "Fresh Finds" # any name will do
user_id <- client <-  secret <- scopes <- ""
scopes <- c("user-read-private","playlist-modify-private",
            "playlist-modify-public", "playlist-read-private")

## functions
my_getPlaylist<-function(select=""){
  req<-httr::GET("https://api.spotify.com/v1/me/playlists",httr::config(token = token))
  json1<-httr::content(req)
  json2<-jsonlite::fromJSON(jsonlite::toJSON(json1))$items
  id<-unlist(json2$id)
  name<-unlist(json2$name)
  ownerid<-unlist(json2$owner$id)
  tracks<-unlist(json2$tracks$total)
  dados<-data.frame(id,name,ownerid,tracks,stringsAsFactors = F)
  dados <- dados[grep(select, dados$name),]
  return(dados)
}

getSongIDs <- function(df){ 
  # function that uses a df as input, searches spotify by name and artist and returns list of spotify song IDs in URI format.
  ids <- sapply(1:nrow(df), function(i){
    temp_str <- strsplit(as.vector(df[i,"Artist_Song"]), "-")
    temp_song <- trimws(temp_str[[1]][2])
    temp_artist <- trimws(temp_str[[1]][1])
    temp_artist <- trimws(strsplit(temp_artist, " ")[[1]][1]) # having entire artist name is too specific, gives NA later
    temp_return <- try(searchTrack(paste(temp_artist, temp_song), token)) # does not include artist yet
    if(nrow(temp_return) >0){
      return(as.vector(temp_return[1,"id"]))
    } else {
      return(NA)
    }
  })
  # analysis
  if(anyNA(ids)){
    print("Spotify song IDs were not found for following song and they were removed: ")
    print(ids[is.na(ids)])
    ids <- ids[!(is.na(ids))]

  } else{print("All songs in the query have matching spotify IDs!")}
  songs <- paste0("spotify:track:", ids)
  songs <- gsub(" ", ",", Reduce(paste, songs))
  return(songs)
}
## --

## Authication. 'authorization flow'
user_id <<- ""
client <<- ""
secret <<- ""

spotifyR <- oauth_endpoint(
  authorize = "https://accounts.spotify.com/authorize",
  access = "https://accounts.spotify.com/api/token")
myapp <- oauth_app(app_id, client, secret)
token <- oauth2.0_token(spotifyR, myapp,scope = Reduce(paste, scopes))

## Can above authication allow to add songs to an alubm? A: Not in Terminal through curl or in R. but yes on web api.
# https://developer.spotify.com/console/post-playlist-tracks/

data <- read.csv("Raw_charts/ALL_SONGS_2016_hot_100_ranked.csv")
spotifyURIs <- try(getSongIDs(data))

# Create a playlist on Spotify App MANUALLY, and store its name in 'playlist' variable.
# Following functions fetches the spotify's id for the playlist you just created. 
playlist <- "2018"
my_getPlaylist(playlist)

# Can't add more than 100 songs at a time. Printing 100 songs at a time
# songs ids
print(spotifyURIs)
# Access tokens for the Web API.
print(token[["credentials"]][["access_token"]])


