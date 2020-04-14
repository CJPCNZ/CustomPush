#!/bin/bash
apikey="" # Your Sonarr API key 
radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
MailHost="" # Your email SMTP server (e.g. smtp.gmail.com)
MailPort="25" # Your email SMTP port (usually 25)
FromAddr="<>" # Your email address (gmail requires <> to be included)
ToAddr="<>" # Recipient email address (gmail requires <> to be included)
Username="" # Your email username (the part before @gmail.com)
Password="" # Your email password (If you use 2FA please generate an app-specific password here: https://myaccount.google.com/apppasswords)

# Grab movie information
radarr_description=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey") | jq .overview

# Format content
Subject=$radarr_movie_title 
Subject+=" - " 
Subject+=$radarr_moviefile_quality

Message=$radarr_description

# Format Username and Password
Username=$(echo -ne $Username | base64)
Password=$(echo -ne $Password | base64)

# Send email - Credit to dldnh on StackOverflow https://stackoverflow.com/a/10001357
function checkStatus {
  expect=250
  if [ $# -eq 3 ] ; then
    expect="${3}"
  fi
  if [ $1 -ne $expect ] ; then
    echo "Error: ${2}"
    exit
  fi
}

(
sleep 3
echo "HELO ${MailHost}"
sleep 3
echo "AUTH LOGIN"
sleep 3
echo "${Username}"
sleep 3
echo "${Password}"
sleep 3
echo "MAIL FROM: ${FromAddr}"
sleep 3
echo "RCPT TO: ${ToAddr}"
sleep 3
echo "DATA"
sleep 3
echo "Subject: ${Subject}"
echo "${Message}"
echo "."
sleep 3
echo "QUIT"
) | openssl s_client -starttls smtp -connect $MailHost:$MailPort -crlf