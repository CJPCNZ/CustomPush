# Define required variables
$lidarr_artist_id = $env:lidarr_artist_id
$lidarr_album_title = $env:lidarr_album_title
$lidarr_artist_name = $env:lidarr_artist_name
$lidarr_album_releasedate = $env:lidarr_album_releasedate
$lidarr_album_mbid = $env:lidarr_album_mbid
$pushkey="" # Your PushBullet API key
$pushtag="" # Add the tag for your Pushbullet Channel or leave blank for direct push notifications

# Format content
$lidarr_album_releaseday=$lidarr_album_releasedate.split(" ")[1]
$pushtitle = $lidarr_artist_name + " - " + $lidarr_album_title
$pushmessage = "Release Date: " + $lidarr_album_releaseday + "`r`nMusicBrainz: https://musicbrainz.org/release-group/"+ $lidarr_album_mbid + "`r`n"

# Prepare push notification body
$pushbody = @{
    type = 'note'
    "title" = $pushtitle
    "body" = $pushmessage
    channel_tag = $pushtag
}

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://api.pushbullet.com/v2/pushes" -UseBasicParsing -Header @{"Access-Token" = $pushkey} -Body $pushBody