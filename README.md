# Billboard_music
Web scarping script in R to download multiple Billboard musical charts to identify popular Top 40 songs.

# What is the problem?
I love music! I mostly listen to Top 40 songs; however, it is increasing becoming difficult for me to discover new music due to time constrains. There is no shortage of top musical charts on radio and streaming apps such as Spotify, but popular songs tend to dominate these charts, leaving little room to discover popular Top 40 songs. 

# Approach
1. Use R to web scrape multiple billboard charts (https://www.billboard.com/charts) to prepare a data frame consisting of ranking of songs in multiple charts. 
2. Rank a song by its median position and number of weeks it has been on multiple charts. 
3. A user supplies mininum median ranking and number of weeks to filter songs and export a list of new songs each month.


