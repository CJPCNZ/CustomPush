# Define Variables
$sonarr_episodefile_id = $env:sonarr_episodefile_id
$sonarr_series_id = $env:sonarr_series_id
$sonarr_series_title = $env:sonarr_series_title
$sonarr_episodefile_seasonnumber = $env:sonarr_episodefile_seasonnumber
$sonarr_episodefile_episodenumbers = $env:sonarr_episodefile_episodenumbers

$apikey="" # Your Sonarr API key 
$sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
$pushkey="12345678:replace-me-with-real-token" # Your Telegram Bot API key
$pushtag="@channelusername" # Your Teleram Chat ID

# Grab series information
$sonarr_series=$(Invoke-WebRequest -URI $sonarr_address/api/episode?seriesId=$sonarr_series_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json

# Grab episode details
$sonarr_episode_title = $sonarr_series | Where-Object {$_.episodeFileId -eq $sonarr_episodefile_id} | Select-Object -ExpandProperty title

# Format content
$pushmessage = $sonarr_series_title + " - S" + $sonarr_episodefile_seasonnumber + ":E" + $sonarr_episodefile_episodenumbers + " : " + $sonarr_episode_title

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