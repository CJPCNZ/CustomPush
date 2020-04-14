# Define Variables
$sonarr_episodefile_id = $env:sonarr_episodefile_id
$sonarr_series_id = $env:sonarr_series_id
$sonarr_series_title = $env:sonarr_series_title
$sonarr_episodefile_seasonnumber = $env:sonarr_episodefile_seasonnumber
$sonarr_episodefile_episodenumbers = $env:sonarr_episodefile_episodenumbers

$apikey="" # Your Sonarr API key 
$radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
$MailHost="" # Your email SMTP server (e.g. smtp.gmail.com)
$MailPort="587" # Your email SMTP port (usually 587 for TLS)
$FromAddr="<>" # Your email address (gmail requires <> to be included)
$ToAddr="<>" # Recipient email address (gmail requires <> to be included)
$Username="" # Your email username (the part before @gmail.com)
$Password="" # Your email password (If you use 2FA please generate an app-specific password here: https://myaccount.google.com/apppasswords)

# Grab movie information
$radarr_movie=$(Invoke-WebRequest -URI $radarr_address/api/movie/$radarr_movie_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json
$radarr_description = $radarr_movie | Select-Object -ExpandProperty overview

# Format content
$Subject = $radarr_movie_title + " - " + $radarr_moviefile_quality
$Message = $radarr_description

# Send email
$Credentials = New-Object Management.Automation.PSCredential $Username,($Password | ConvertTo-SecureString -AsPlainText -Force);
Send-MailMessage -From $FromAddr -to $ToAddr -Subject $Subject -Body $Message -SmtpServer $MailHost -port $MailPort -UseSsl -Credential $Credentials