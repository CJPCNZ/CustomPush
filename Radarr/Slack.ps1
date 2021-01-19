# Define required variables
$radarr_movie_id = $env:radarr_movie_id 
$radarr_movie_title = $env:radarr_movie_title 
$radarr_moviefile_quality = $env:radarr_moviefile_quality

$apikey="" # Your Radarr API key 
$radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
$pushkey="Bearer xoxp-xxxxxxxxx-xxxx" # Your Slack API key
$pushtag="" # Your Slack channel tag

# Grab movie information
$radarr_movie=$(Invoke-WebRequest -URI $radarr_address/api/movie/$radarr_movie_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
$radarr_description = $radarr_movie | Select-Object -ExpandProperty overview

# Format content
$pushmessage = $radarr_movie_title + " - " + $radarr_moviefile_quality  + " : " + $radarr_description

$headers = @{"Content-Type" = "application/json"; "Authorization" = $pushkey}

# Prepare push notification body
$pushbody = @{
    "text" = $pushmessage
    "channel" = $pushtag
}

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://slack.com/api/chat.postMessage" -UseBasicParsing -Header $headers -Body $pushBody