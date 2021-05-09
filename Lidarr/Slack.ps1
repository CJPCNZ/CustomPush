# Define required variables
$lidarr_artist_id = $env:lidarr_artist_id
$lidarr_album_title = $env:lidarr_album_title
$lidarr_artist_name = $env:lidarr_artist_name
$lidarr_album_releasedate = $env:lidarr_album_releasedate
$lidarr_album_mbid = $env:lidarr_album_mbid
$pushkey="Bearer xoxp-xxxxxxxxx-xxxx" # Your Slack API key
$pushtag="" # Your Slack channel tag

# Format content
$lidarr_album_releaseday=$lidarr_album_releasedate.split(" ")[1]
$pushmessage = $lidarr_artist_name + " - " + $lidarr_album_title + "Release Date: " + $lidarr_album_releaseday + "`r`nMusicBrainz: https://musicbrainz.org/release-group/"+ $lidarr_album_mbid + "`r`n"

$headers = @{"Content-Type" = "application/json"; "Authorization" = $pushkey}

# Prepare push notification body
$pushbody = @"
{
    "text": "$pushmessage",
    "channel: "$pushtag"
}
"@

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://slack.com/api/chat.postMessage" -UseBasicParsing -Header $headers -Body $pushBody