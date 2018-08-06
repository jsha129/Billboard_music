# Billboard_music
Web scarping scripts written in R to download multiple Billboard musical charts to identify popular Top 40 songs.

# What is the problem?
I love music! I mostly listen to Top 40 songs; however, it is increasing becoming difficult for me to discover new music due to time constrains. There is no shortage of top musical charts on radio and streaming apps such as Spotify, but popular songs tend to be repeated in these charts, leaving little room to discover newer, non-repeated Top 40 songs. 

The aim of this project is to automatically compile a monthly list of songs that were in top 40 for a given month, and not repeated in previous months. 

# Approach
1. Use R to web scrape multiple billboard charts (https://www.billboard.com/charts) to prepare a data frame consisting of ranking of songs in multiple charts ([Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R)). 
2. Rank a song by its median position and number of weeks it has been on multiple charts ([Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R)). Math used for ranking is quite simple. Concatenate songs and artists to create unique SongIDs for a song and use its weekly position in columns. In other words, create **SongID x Week** sparse matrix using the R package Reshape2. Since the data is in matrix format, use R's apply function to get median ranking of a song as well number of weeks it occupied in all charts. Ranked songs are exported as file. 
3. A user supplies mininum median ranking and number of weeks to filter songs and export a list of new songs each month ([Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R)).
4. Ideally, Spotify web API (https://developer.spotify.com/documentation/web-api/) is used to create a monthly playlist and add songs identified from the previous steps to playlists ([Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R)). Due to some issues with authentication on Spotify, I am currently unable to create a playlist from the R script. A temporary solution to this problem is to manually create a playlist in Spotify app, get the corresponding Spotify playlist id from the R script ([Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R)) and use the Spotify API to add songs to the playlist. Additionally, [Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R) is able to read monthly charts exported from [Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R) and report Spotify song ids for the songs. 

All scripts are functional as of August 5th, 2018.

# Disclaimer
Billboard (https://www.billboard.com) and Spotify (https://www.spotify.com/) reserve the rights to the data and Web API. I only own the scripts to mine the data and analyse it. 

# Usage/minimum working example
1. Determine the charts to web scrape and add them to charts.csv with name and url. I put all charts in this file and provided a way to filter a subset of charts in the [Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R) (step 2).
2. Install necessary packages etc in R and run [Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R). This R script has CSS field names used for web scraping as well as function for data wrangling, and tunable parameters for defining time period in years to webscrape. For convention, data for each chart is exported to **Raw_charts** folder. By default, this folder contains [empty_headers.csv](https://github.com/jsha129/Billboard_music/blob/master/Raw_charts/empty_headers.csv) for copying file structure. 
3. Run [Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R) to rank each song and export monthly charts (in **Monthly_charts** folder).
4. To add songs on Spotify using Web API, register an app on Spotify and the website will create 'client' and 'secret' codes for you. Add them in the [Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R). 

# Additional comments and limitations
- While ranking each song, I only used artist_song as unique IDs and ignored chart names. This approach has a benefit that songs appearing in multiple charts will have a higher value for number of weeks than those who only appear in specific charts. For example, let's say, a latin song  appears in respective latin music chart. If the same song spreads to mainstream music, it could appear in 'hot 100' or other charts, and the script will consider data from other charts to calculate 'number of weeks' parameter.
- First appearance of a song dictactes which monthly chart it will reported in. Many songs take 3-4 weeks to be in Top 40; however, the script will only use its first appearance, regardless of its ranking in the opening week, to export it in monthly charts.
- Because this algorithm emphasises on  popular music, it needs at least a month of data and is not suitable to discover trending or viral songs. 
- Feedback is much appreciated. Thank you. 
