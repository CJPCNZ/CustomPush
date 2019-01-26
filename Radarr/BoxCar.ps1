# Define required variables
$radarr_movie_id = $env:radarr_movie_id 
$radarr_movie_title = $env:radarr_movie_title 
$radarr_moviefile_quality = $env:radarr_moviefile_quality

$apikey="" # Your Radarr API key 
$radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
$pushkey="" # Your Boxcar API key
$pushsecret="" # Your Boxcar API secret
$pushtag="" # Optional push channel tag if you need it

# Grab movie information
$radarr_movie=$(Invoke-WebRequest -URI $radarr_address/api/movie/$radarr_movie_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
# $radarr_description = $radarr_movie | Select -ExpandProperty overview

# Format content
$pushmessage = $radarr_movie_title + " - " + $radarr_moviefile_quality # + " : " + $radarr_description

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