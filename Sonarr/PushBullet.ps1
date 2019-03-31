# Define Variables
$sonarr_episodefile_id = $env:sonarr_episodefile_id
$sonarr_series_id = $env:sonarr_series_id
$sonarr_series_title = $env:sonarr_series_title
$sonarr_episodefile_seasonnumber = $env:sonarr_episodefile_seasonnumber
$sonarr_episodefile_episodenumbers = $env:sonarr_episodefile_episodenumbers

$apikey="" # Your Sonarr API key 
$sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
$pushkey="" # Your PushBullet API key
$pushtag="" # Add the tag for your Pushbullet Channel or leave blank for direct push notifications

# Grab series information
$sonarr_series=$(Invoke-WebRequest -URI $sonarr_address/api/episode?seriesId=$sonarr_series_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json

# Grab episode details
$sonarr_episode_title = $sonarr_series | Where-Object {$_.Id -eq $sonarr_episodefile_id} | Select-Object -ExpandProperty title
$sonarr_episode_description = $sonarr_series | Where-Object {$_.Id -eq $sonarr_episodefile_id} | Select-Object -ExpandProperty overview

# Format content
$pushtitle = $sonarr_series_title + " - S" + $sonarr_episodefile_seasonnumber + ":E" + $sonarr_episodefile_episodenumbers
$pushmessage = $sonarr_episode_title + " - " + $sonarr_episode_description

# Prepare push notification body
$pushbody = @{
    type = 'note'
    "title" = $pushtitle
    "body" = $pushmessage
    channel_tag = $pushtag
}

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://api.pushbullet.com/v2/pushes" -UseBasicParsing -Header @{"Access-Token" = $pushkey} -Body $pushBody