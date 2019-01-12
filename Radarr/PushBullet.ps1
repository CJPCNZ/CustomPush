# Define required variables
$radarr_movie_id = $env:radarr_movie_id 
$radarr_movie_title = $env:radarr_movie_title 
$radarr_moviefile_quality = $env:radarr_moviefile_quality

$apikey="" # Your Radarr API key 
$radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
$pushkey="" # Your PushBullet API key
$pushtag="" # Add the tag for your Pushbullet Channel or leave blank for direct push notifications

# Grab movie information
$radarr_movie=$(Invoke-WebRequest -URI $radarr_address/api/movie/$radarr_movie_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
$radarr_description = $radarr_movie | Select -ExpandProperty overview

# Format content
$pushtitle = $radarr_movie_title + " - " + $radarr_moviefile_quality
$pushmessage = $radarr_description

# Prepare push notification body
$pushbody = @{
    type = 'note'
    "title" = $pushtitle
    "body" = $pushmessage
    channel_tag = $pushtag
}

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://api.pushbullet.com/v2/pushes" -UseBasicParsing -Header @{"Access-Token" = $pushkey} -Body $pushBody