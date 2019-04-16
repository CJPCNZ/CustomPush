# Define required variables
$radarr_movie_id = $env:radarr_movie_id 
$radarr_movie_title = $env:radarr_movie_title 
$radarr_moviefile_quality = $env:radarr_moviefile_quality

$apikey="" # Your Radarr API key 
$radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
$pushkey="" # Your PushBullet API key
$pushtag="" # Add the tag for your Pushbullet Channel or leave blank for direct push notifications

# Change $null to "username" / "password" if you use basic authentication in Radarr
$user = $null
$pass = $null

if (($user -ne $null) -and ($pass -ne $null)){
# Create authentication value
$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"

# Grab movie information
$radarr_movie=$(curl -URI $radarr_address/api/movie/$radarr_movie_id -UseBasicParsing -Credential $basicAuthValue -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
$radarr_description = $radarr_movie | Select-Object -ExpandProperty overview
$radarr_image = $radarr_address + "/MediaCover/" + $radarr_movie_id + "/poster.jpg"
Invoke-WebRequest $radarr_image -UseBasicParsing -OutFile "$PSScriptRoot\poster.jpg" -Credential $basicAuthValue
} Else {
# Grab movie information
$radarr_movie=$(curl -URI $radarr_address/api/movie/$radarr_movie_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
$radarr_description = $radarr_movie | Select-Object -ExpandProperty overview
$radarr_image = $radarr_address + "/MediaCover/" + $radarr_movie_id + "/poster.jpg"
Invoke-WebRequest $radarr_image -UseBasicParsing -OutFile "$PSScriptRoot\poster.jpg"
}

# Upload Poster
$pushbody = @{
    "file_name" = "poster.jpg"
    "file_type" = "image/jpeg"
}

$uploadImage = Invoke-WebRequest -Method POST -Uri "https://api.pushbullet.com/v2/upload-request" -UseBasicParsing -Header @{"Access-Token" = $pushkey} -Body $pushbody | convertfrom-json
$uploadData = $uploadImage.data[0]

$FilePath = "$PSScriptRoot\poster.jpg";
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

rm "$PSScriptRoot\poster.jpg"

# Format content
$pushtitle = $radarr_movie_title + " - " + $radarr_moviefile_quality
$pushmessage = $radarr_description

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