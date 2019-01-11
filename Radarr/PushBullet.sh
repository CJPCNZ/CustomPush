#!/bin/bash
apikey="" # Your Radarr API key 
radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
pushkey="" # Your PushBullet API key
pushtag="" # Optional push channel if you need it

# Grab movie information
radarr_description=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey") | jq .overview

# Format content
pushtitle=$radarr_movie_title 
pushtitle+=" - " 
pushtitle+=$radarr_moviefile_quality

pushmessage=$radarr_description

# Prepare push notification body
pushbody=$( jq -n \
    --arg title "$pushtitle" \
    --arg body "$pushmessage" \
    --arg channel "$pushtag" \
    '{body: $body, title: $title, type: "note", channel_tag: $channel}' )

# Send push notification
curl --header "Access-Token:$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushbullet.com/v2/pushes