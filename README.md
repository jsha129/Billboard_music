# Billboard_music
Web scarping script in R to download multiple Billboard musical charts to identify popular Top 40 songs.

# What is the problem?
I love music! I mostly listen to Top 40 songs; however, it is increasing becoming difficult for me to discover new music due to time constrains. There is no shortage of top musical charts on radio and streaming apps such as Spotify, but popular songs tend to dominate these charts, leaving little room to discover popular Top 40 songs. 

# Approach
1. Use R to web scrape multiple billboard charts (https://www.billboard.com/charts) to prepare a data frame consisting of ranking of songs in multiple charts (Mining_script_V1.R). 
2. Rank a song by its median position and number of weeks it has been on multiple charts (Songs_analysis_3.R). 
3. A user supplies mininum median ranking and number of weeks to filter songs and export a list of new songs each month (Songs_analysis_3.R).
4. Ideally, Spotify web API (https://developer.spotify.com/documentation/web-api/) is used to create a monthly playlist and add songs identified from the previous steps to playlists (Rspotify.R). Due to some issues with authentication on Spotify, I am currently unable to create a playlist. A temporary solution to this problem is to manually create a playlist, get the corresponding Spotify playlist id from the R script (Rspotify.R) and use the Spotify API to add songs to the playlist. Additionally, Rspotify.R is able to read monthly charts exported from Songs_analysis_3.R and report Spotify song ids for the songs. 

# Disclaimer
Billboard (https://www.billboard.com) and Spotify (https://www.spotify.com/) reserve the rights to the data and Web API. I only own the scripts to mine the data and analyse it. 




