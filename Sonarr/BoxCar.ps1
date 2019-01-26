# Define Variables
$sonarr_episodefile_id = $env:sonarr_episodefile_id
$sonarr_series_id = $env:sonarr_series_id
$sonarr_series_title = $env:sonarr_series_title
$sonarr_episodefile_seasonnumber = $env:sonarr_episodefile_seasonnumber
$sonarr_episodefile_episodenumbers = $env:sonarr_episodefile_episodenumbers

$apikey="" # Your Sonarr API key 
$sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
$pushkey="" # Your Boxcar API key
$pushsecret="" # Your Boxcar API secret
$pushtag="" # Optional push channel tag if you need it

# Grab series information
$sonarr_series=$(Invoke-WebRequest -URI $sonarr_address/api/episode?seriesId=$sonarr_series_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json

# Grab episode details
$sonarr_episode_title = $sonarr_series | where {$_.episodeFileId -eq $sonarr_episodefile_id} | Select -ExpandProperty title
# $sonarr_episode_description = $sonarr_series | where {$_.episodeFileId -eq $sonarr_episodefile_id} | Select -ExpandProperty overview

# Format content
$pushmessage = $sonarr_series_title + " - S" + $sonarr_episodefile_seasonnumber + ":E" + $sonarr_episodefile_episodenumbers + " : " + $sonarr_episode_title

# Create credentials
$credentials=$pushkey + ":" + $pushsecret
$bytes = [System.Text.Encoding]::ASCII.GetBytes($credentials)
$base64 = [System.Convert]::ToBase64String($bytes)
$credentials = "Basic $base64"

$headers = @{"Content-Type" = "application/json"; "Authorization" = $credentials}

# Prepare push notification body
$pushbody=@{
    'aps' = 
        [Ordered]@{
            'badge'='auto'
            'alert'=$pushmessage
        }
    'tags' = @{'or' = @($pushtag)}
    'implicit_tag_creation'=$true
} | ConvertTo-Json

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://boxcar-api.io/api/push/" -UseBasicParsing -Headers $headers -Body $pushBody