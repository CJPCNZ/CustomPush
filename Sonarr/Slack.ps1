# Define Variables
$sonarr_episodefile_id = $env:sonarr_episodefile_id
$sonarr_series_id = $env:sonarr_series_id
$sonarr_series_title = $env:sonarr_series_title
$sonarr_episodefile_seasonnumber = $env:sonarr_episodefile_seasonnumber
$sonarr_episodefile_episodenumbers = $env:sonarr_episodefile_episodenumbers

$apikey="" # Your Sonarr API key 
$sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
$pushkey="Bearer xoxp-xxxxxxxxx-xxxx" # Your Slack API key
$pushtag="" # Your Slack channel tag

# Grab series information
$sonarr_series=$(Invoke-WebRequest -URI $sonarr_address/api/episode?seriesId=$sonarr_series_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json

# Grab episode details
$sonarr_episode_title = $sonarr_series | Where-Object {$_.episodeFileId -eq $sonarr_episodefile_id} | Select-Object -ExpandProperty title

# Format content
$pushmessage = $sonarr_series_title + " - S" + $sonarr_episodefile_seasonnumber + ":E" + $sonarr_episodefile_episodenumbers + " : " + $sonarr_episode_title

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