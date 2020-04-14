# Define required variables
$lidarr_artist_id = $env:lidarr_artist_id
$lidarr_album_title = $env:lidarr_album_title
$lidarr_artist_name = $env:lidarr_artist_name

$apikey="" # Your lidarr API key 
$lidarr_address="http://localhost:7878" # Your lidarr address (including base_url) 
$pushkey="" # Your PushBullet API key
$pushtag="" # Add the tag for your Pushbullet Channel or leave blank for direct push notifications

# Change $null to "username" / "password" if you use basic authentication in lidarr
$user = $null
$pass = $null

if (($null -ne $user) -and ($null -ne $pass)){
# Create authentication value
$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"

# Grab movie information
#$lidarr_album=$(Invoke-WebRequest  -URI $lidarr_address/api/v1/album/$lidarr_artist_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey; "Authorization" = $basicAuthValue }) | ConvertFrom-Json
$lidarr_image = $lidarr_address + "/MediaCover/" + $lidarr_artist_id + "/fanart.jpg"
Invoke-WebRequest $lidarr_image -UseBasicParsing -OutFile "$PSScriptRoot\fanart.jpg" -Header @{"Authorization" = $basicAuthValue }
} Else {
# Grab movie information
#$lidarr_album=$(Invoke-WebRequest  -URI $lidarr_address/api/v1/album/$lidarr_artist_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
$lidarr_image = $lidarr_address + "/MediaCover/" + $lidarr_artist_id + "/fanart.jpg"
Invoke-WebRequest $lidarr_image -UseBasicParsing -OutFile "$PSScriptRoot\fanart.jpg"
}

# Upload Poster
$pushbody = @{
    "file_name" = "fanart.jpg"
    "file_type" = "image/jpeg"
}

$uploadImage = Invoke-WebRequest -Method POST -Uri "https://api.pushbullet.com/v2/upload-request" -UseBasicParsing -Header @{"Access-Token" = $pushkey} -Body $pushbody | convertfrom-json
$uploadData = $uploadImage.data[0]

$FilePath = "$PSScriptRoot\fanart.jpg";
$fileBytes = [System.IO.File]::ReadAllBytes($FilePath);
$fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes);
$boundary = [System.Guid]::NewGuid().ToString(); 
$LF = "`r`n";

$bodyLines = ( 
    "--$boundary",
    "Content-Disposition: form-data; name=`"awsaccesskeyid`"$LF", 
    $uploadData.awsaccesskeyid,
    "--$boundary",
    "Content-Disposition: form-data; name=`"acl`"$LF", 
    $uploadData.acl,
    "--$boundary",
    "Content-Disposition: form-data; name=`"key`"$LF", 
    $uploadData.key,
    "--$boundary",
    "Content-Disposition: form-data; name=`"signature`"$LF", 
    $uploadData.signature,
    "--$boundary",
    "Content-Disposition: form-data; name=`"policy`"$LF", 
    $uploadData.policy,
    "--$boundary",
    "Content-Disposition: form-data; name=`"content-type`"$LF", 
    "image/jpeg",
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"$LF", 
    $fileEnc,
    "--$boundary--$LF" 
) -join $LF

Invoke-RestMethod -Uri $uploadImage.upload_url -Method Post -UseBasicParsing -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines | convertfrom-json

Remove-Item "$PSScriptRoot\fanart.jpg"

# Format content
$pushtitle = $lidarr_artist_name
$pushmessage = $lidarr_album_title

# Prepare push notification body

$pushbody = @{
    title = $pushtitle
    type = 'file'
    file_name = $uploadImage.file_name
    body = $pushmessage
    file_type = $uploadImage.file_type
    file_url = $uploadImage.file_url
    channel_tag = $pushtag
}

# Send push notification
Invoke-WebRequest -Method POST -Uri "https://api.pushbullet.com/v2/pushes" -UseBasicParsing -Header @{"Access-Token" = $pushkey} -Body $pushBody