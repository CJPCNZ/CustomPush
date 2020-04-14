# Define Variables
$sonarr_episodefile_id = $env:sonarr_episodefile_id
$sonarr_series_id = $env:sonarr_series_id
$sonarr_series_title = $env:sonarr_series_title
$sonarr_episodefile_seasonnumber = $env:sonarr_episodefile_seasonnumber
$sonarr_episodefile_episodenumbers = $env:sonarr_episodefile_episodenumbers

$apikey="" # Your Sonarr API key 
$sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
$MailHost="" # Your email SMTP server (e.g. smtp.gmail.com)
$MailPort="587" # Your email SMTP port (usually 587 for TLS)
$FromAddr="<>" # Your email address (gmail requires <> to be included)
$ToAddr="<>" # Recipient email address (gmail requires <> to be included)
$Username="" # Your email username (the part before @gmail.com)
$Password="" # Your email password (If you use 2FA please generate an app-specific password here: https://myaccount.google.com/apppasswords)

# Grab series information
$sonarr_series=$(Invoke-WebRequest -URI $sonarr_address/api/episode?seriesId=$sonarr_series_id -UseBasicParsing -Header @{"X-Api-Key" = $apikey}) | ConvertFrom-Json

# Grab episode details
$sonarr_episode_title = $sonarr_series | Where-Object {$_.episodeFileId -eq $sonarr_episodefile_id} | Select-Object -ExpandProperty title
$sonarr_episode_description = $sonarr_series | Where-Object {$_.episodeFileId -eq $sonarr_episodefile_id} | Select-Object -ExpandProperty overview

# Format content
$Subject = $sonarr_series_title + " - S" + $sonarr_episodefile_seasonnumber + ":E" + $sonarr_episodefile_episodenumbers
$Message = $sonarr_episode_title + " - " + $sonarr_episode_description

# Send email
$Credentials = New-Object Management.Automation.PSCredential $Username,($Password | ConvertTo-SecureString -AsPlainText -Force);
Send-MailMessage -From $FromAddr -to $ToAddr -Subject $Subject -Body $Message -SmtpServer $MailHost -port $MailPort -UseSsl -Credential $Credentials