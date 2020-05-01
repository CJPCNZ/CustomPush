#!/bin/bash
apikey="" # Your Radarr API key 
radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
pushkey="" # Your PushOver API key
pushuser="" # Your PushOver User Key

# Grab movie information
radarr_description=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq .overview)

# Format content
pushtitle+="Downloading: "
pushtitle+=$radarr_movie_title 
pushtitle+=" ("
pushtitle+=$radarr_movie_year
pushtitle+=")"

pushmessage=$radarr_description

# Prepare push notification body
pushbody=$( jq -n \
    --arg token "$pushkey" \
    --arg user "$pushuser" \
    --arg title "$pushtitle" \
    --arg message "$pushmessage" \
    '{token: $token, user: $user, title: $title, message: $message}' )

# Send push notification   
curl --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushover.net/1/messages.json