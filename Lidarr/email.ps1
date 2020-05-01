# Define Variables
$lidarr_artist_id = $env:lidarr_artist_id
$lidarr_album_title = $env:lidarr_album_title
$lidarr_artist_name = $env:lidarr_artist_name
$lidarr_album_releasedate = $env:lidarr_album_releasedate
$lidarr_album_mbid = $env:lidarr_album_mbid

$MailHost="" # Your email SMTP server (e.g. smtp.gmail.com)
$MailPort="587" # Your email SMTP port (usually 587 for TLS)
$FromAddr="<>" # Your email address (gmail requires <> to be included)
$ToAddr="<>" # Recipient email address (gmail requires <> to be included)
$Username="" # Your email username (the part before @gmail.com)
$Password="" # Your email password (If you use 2FA please generate an app-specific password here: https://myaccount.google.com/apppasswords)

# Format content
$lidarr_album_releaseday=$lidarr_album_releasedate.split(" ")[1]
$Subject = $lidarr_artist_name + " - " + $lidarr_album_title
$Message = "Release Date: " + $lidarr_album_releaseday + "`r`nMusicBrainz: https://musicbrainz.org/release-group/"+ $lidarr_album_mbid + "`r`n"

# Send email
$Credentials = New-Object Management.Automation.PSCredential $Username,($Password | ConvertTo-SecureString -AsPlainText -Force);
Send-MailMessage -From $FromAddr -to $ToAddr -Subject $Subject -Body $Message -SmtpServer $MailHost -port $MailPort -UseSsl -Credential $Credentials