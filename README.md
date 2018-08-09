# SpotifyR
A web scraping script written in R to text-mine multiple Billboard musical charts to identify popular Top 40 songs, and add them to a user's Spotify account.

# What is the problem?
I love music; however, it is increasing becoming difficult for me to discover new music due to time constrains. There is no shortage of top musical charts on radio and streaming apps such as Spotify, but popular songs tend to be repeated in these charts, leaving little room to rapidly discover newer, non-repeated Top 40 songs. 

The aim of this project is to automatically compile a monthly playlists of songs that were in top 40 for a given month, and not repeated in previous months. Furthermore, it provides tools to add the songs/playlists to a user's Spotify account. 

# Approach
1. Use R to web scrape multiple billboard charts (https://www.billboard.com/charts) to prepare a data frame consisting of ranking of songs in multiple charts ([Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R)). 
2. Rank a song by its median position and number of weeks it has been on multiple charts ([Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R)). Math used for ranking is quite simple. Concatenate songs and artists to create unique SongIDs for a song and use its weekly position in columns. In other words, create **SongID x Week** sparse matrix using the R package Reshape2. Since the data is in matrix format, use R's apply function to get median ranking of a song as well number of weeks it occupied in all charts. Ranked songs are exported as file. 
3. A user supplies mininum median ranking and number of weeks to filter songs and export a list of new songs each month ([Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R)).
4. Ideally, Spotify web API (https://developer.spotify.com/documentation/web-api/) is used to create a monthly playlist and add songs identified from the previous steps to playlists ([Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R)). Due to some issues with authentication on Spotify, I am currently unable to create a playlist from the R script. A temporary solution to this problem is to manually create a playlist in Spotify app, get the corresponding Spotify playlist id from the R script ([Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R)) and use the Spotify API to add songs to the playlist. Additionally, [Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R) is able to read monthly charts exported from [Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R) and report Spotify song ids for the songs. 

All scripts are functional as of August 5th, 2018.

# Disclaimer
Billboard (https://www.billboard.com) and Spotify (https://www.spotify.com/) reserve the rights to the data and Web API. I only own the scripts to mine the data and analyse it. 

# Usage
1. Determine the charts to web scrape and add them to [charts.csv](https://github.com/jsha129/Billboard_music/blob/master/charts.csv) with name and url. I put all charts in this file and provided a way to filter a subset of charts in the [Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R) (step 2).
2. Install necessary packages etc in R and run [Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R). This R script has CSS field names used for web scraping as well as function for data wrangling, and tunable parameters for defining time period in years to webscrape. For convention, data for each chart is exported to **Raw_charts** folder. By default, this folder contains [empty_headers.csv](https://github.com/jsha129/Billboard_music/blob/master/Raw_charts/empty_headers.csv) for copying file structure. 
3. Run [Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R) to rank each song and export monthly charts (in **Monthly_charts** folder).
4. To add songs on Spotify using Web API, register an app on Spotify and the website will create 'client' and 'secret' codes for you. Add them in the [Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R). 

# Minimal working example
**Identification top 10 songs of 2016 and 2017 from the Billboard top 100 chart.**

All files should have following parameters. Change them if necessary. 

Run following files in the order indicated. 
1. [Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R)
  
  ```r
  charts <- read.csv("charts.csv")
  selected_charts <- c("hot_100")
  charts <- subset(charts, Chart %in% selected_charts)
  startYear <- 2016
  stopYear <- 2017 
  ```
  ## Output
 - 105 weeks mined ([Mining_script_V1.log](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.log)). 
 - Data exported to [Raw_charts/ALL_hot_100.csv](https://github.com/jsha129/SpotifyR/blob/master/Raw_charts/ALL_hot_100.csv).
  
  
  2.  [Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R)
  ```r
  year <- 2016
  month <- 1 # start month for exporting playlists
  num.top.songs <- 50 # Tells how many unique songs to write to a file after removing duplicates
  min_median <- 20 # median rank a song has to be in top 30

  rank_songs(inputFile = inputs,
           output = out,
           minYear = 2016, maxYear = 2017, 
           numWeeks = 0.9, # select songs that has 'numWeeks' in 90th percentile, ie appeared in top 10% of numWeek score
           minMedian = 10,
           presortMinRank = 20) 
           # PresortMinRank keeps only songs that were less than this number before ranking begins; helps speed up matrix calculations when dealing with lots of data.

  ```
## Output
1. All selected charts were merged in one file, [Raw_charts/ALL_SONGS.csv](https://github.com/jsha129/SpotifyR/blob/master/Raw_charts/ALL_SONGS.csv).
2. Songs ranked [Raw_charts/ALL_SONGS_2016_hot_100_ranked.csv](https://github.com/jsha129/SpotifyR/blob/master/Raw_charts/ALL_SONGS_2016_hot_100_ranked.csv).

![GitHub Logo](https://github.com/jsha129/SpotifyR/blob/master/Songs_ranked.png)

3. Monthly charts exported based on above criteria to 
  
  
  3. Add songs to Spotify. 
  First, register an app on Spotify Web API to get your client and secret codes. You don't actually have to write an app to do so; you just need those codes to access ID of songs and playlists from the R script. 
  You will also need to get your spotify id, which is easily doable from the spotify App.
  
  ```r
  user_id <<- ""
  client <<- ""
  secret <<- ""
  ```
  Once the authentication is successful, go to https://developer.spotify.com/console/post-playlist-tracks/ to add songs and fill in user_name.
  
  Next, create a playlist MANUALLY in Spotify App where you want to add songs, and store the name in a variable (see code below).
  
  Following code will print out the playlist id, and spotify id for each songs. Fill them on the Web API. 
  
  ```r
  data <- read.csv("Monthly_charts/ALL_SONGS_2016_hot_100_ranked.csv")
spotifyURIs <- try(getSongIDs(data))

# Create a playlist on Spotify App MANUALLY, and store itss name in 'playlist' variable.
# Following functions fetches the spotify's id for the playlist you just created. 
playlist <- "2018"
my_getPlaylist(playlist)

# Can't add more than 100 songs at a time. Printing 100 songs at a time
# songs ids, paste them on WEB API
print(spotifyURIs)
# Access tokens for the Web API.
print(token[["credentials"]][["access_token"]])
  ```
  
  Click 'Try it!'. It should be done now!

# Additional comments and limitations
- While ranking each song, I only used artist_song as unique IDs and ignored chart names. This approach has a benefit that songs appearing in multiple charts will have a higher value for number of weeks than those who only appear in specific charts. For example, let's say, a latin song  appears in respective latin music chart. If the same song spreads to mainstream music, it could appear in 'hot 100' or other charts, and the script will consider data from other charts to calculate 'number of weeks' parameter.
- First appearance of a song dictactes which monthly chart it will reported in. Many songs take 3-4 weeks to be in Top 40; however, the script will only use its first appearance in Billboard top 100 or whatever chart you are using, regardless of its ranking in the opening week, to export it in monthly charts.
- Because this algorithm emphasises on  popular music, it needs at least a month of data for reliable prediction and is not suitable to discover trending or viral songs. 
- Feedback is much appreciated. Thank you. 
