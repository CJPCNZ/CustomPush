# Define required variables
$lidarr_artist_id = $env:lidarr_artist_id
$lidarr_album_title = $env:lidarr_album_title
$lidarr_artist_name = $env:lidarr_artist_name
$lidarr_album_releasedate = $env:lidarr_album_releasedate
$lidarr_album_mbid = $env:lidarr_album_mbid

$pushkey="" # Your Boxcar API key
$pushsecret="" # Your Boxcar API secret
$pushtag="" # Optional push channel tag if you need it

# Format content
$lidarr_album_releaseday=$lidarr_album_releasedate.split(" ")[1]
$pushmessage = $lidarr_artist_name + " - " + $lidarr_album_title + "Release Date: " + $lidarr_album_releaseday + "`r`nMusicBrainz: https://musicbrainz.org/release-group/"+ $lidarr_album_mbid + "`r`n"

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