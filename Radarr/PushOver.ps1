# Define required variables
$radarr_movie_id = $env:radarr_movie_id 
$radarr_movie_title = $env:radarr_movie_title 
$radarr_moviefile_quality = $env:radarr_moviefile_quality

$apikey="" # Your Radarr API key 
$radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
$pushkey="" # Your PushBullet API key
$pushuser="" # Your PushOver User Key

# Grab movie information
$radarr_movie=$(Invoke-WebRequest -URI $radarr_address/api/movie/$radarr_movie_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
$radarr_description = $radarr_movie | Select-Object -ExpandProperty overview

# Format content
$pushtitle = $radarr_movie_title + " - " + $radarr_moviefile_quality
$pushmessage = $radarr_description

# Prepare push notification body
$pushbody = @{
    "token" = $pushkey
    "user" = $pushuser
    "title" = $pushtitle
    "body" = $pushmessage
}

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://api.pushover.net/1/messages.json" -UseBasicParsing -Body $pushBody