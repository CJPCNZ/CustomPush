# Define required variables
$lidarr_artist_id = $env:lidarr_artist_id
$lidarr_album_title = $env:lidarr_album_title
$lidarr_artist_name = $env:lidarr_artist_name
$lidarr_album_releasedate = $env:lidarr_album_releasedate
$lidarr_album_mbid = $env:lidarr_album_mbid

$pushkey="12345678:replace-me-with-real-token" # Your Telegram Bot API key
$pushtag="@channelusername" # Your Teleram Chat ID

# Format content
$lidarr_album_releaseday=$lidarr_album_releasedate.split(" ")[1]
$pushmessage = $lidarr_artist_name + " - " + $lidarr_album_title + "Release Date: " + $lidarr_album_releaseday + "`r`nMusicBrainz: https://musicbrainz.org/release-group/"+ $lidarr_album_mbid + "`r`n"

$headers = @{"Content-Type" = "application/json"}

# Prepare push notification body
# Prepare push notification body
$pushbody = @"
{
    "text": "$pushmessage",
    "chat_id": $pushtag
}
"@ 

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://api.telegram.org/bot$pushkey/sendMessage" -UseBasicParsing -Header $headers -Body $pushBody