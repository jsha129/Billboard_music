# Billboard_music
Web scarping scripts written in R to download multiple Billboard musical charts to identify popular Top 40 songs.

# What is the problem?
I love music! I mostly listen to Top 40 songs; however, it is increasing becoming difficult for me to discover new music due to time constrains. There is no shortage of top musical charts on radio and streaming apps such as Spotify, but popular songs tend to be repeated and dominate these charts, leaving little room to discover newer Top 40 songs. 

# Approach
1. Use R to web scrape multiple billboard charts (https://www.billboard.com/charts) to prepare a data frame consisting of ranking of songs in multiple charts ([Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R)). 
2. Rank a song by its median position and number of weeks it has been on multiple charts ([Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R)). 
3. A user supplies mininum median ranking and number of weeks to filter songs and export a list of new songs each month ([Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R)).
4. Ideally, Spotify web API (https://developer.spotify.com/documentation/web-api/) is used to create a monthly playlist and add songs identified from the previous steps to playlists ([Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R)). Due to some issues with authentication on Spotify, I am currently unable to create a playlist from the R script. A temporary solution to this problem is to manually create a playlist in Spotify app, get the corresponding Spotify playlist id from the R script ([Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R)) and use the Spotify API to add songs to the playlist. Additionally, [Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R) is able to read monthly charts exported from [Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R) and report Spotify song ids for the songs. 

All scripts are functional as of August 5th, 2018.

# Disclaimer
Billboard (https://www.billboard.com) and Spotify (https://www.spotify.com/) reserve the rights to the data and Web API. I only own the scripts to mine the data and analyse it. 

# Usage/minimum working example
1. Determine the charts to web scrape and add them to charts.csv with name and url. I put all charts in this file and provided a way to filter a subset of charts in the [Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R) (step 2).
2. Install necessary packages etc in R and run [Mining_script_V1.R](https://github.com/jsha129/Billboard_music/blob/master/Mining_script_V1.R). This R script has CSS field names used for web scraping as well as function for data wrangling, and tunable parameters for defining time period in years to webscrape. For convention, data for each chart is exported to **Raw_charts** folder. By default, this folder contains [empty_headers.csv](https://github.com/jsha129/Billboard_music/blob/master/Raw_charts/empty_headers.csv) for copying file structure. 
3. Run [Songs_analysis_3.R](https://github.com/jsha129/Billboard_music/blob/master/Songs_analysis_3.R) to rank each song and export monthly charts (in **Monthly_charts** folder).
4. To add songs on Spotify using Web API, register an app on Spotify and the website will create 'key' and 'secret' for you. Add them in the [Rspotify.R](https://github.com/jsha129/Billboard_music/blob/master/Rspotify.R). 




