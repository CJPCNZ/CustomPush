#!/bin/bash
apikey="" # Your Radarr API key 
radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
pushkey="Bearer xoxb-your-token" # Your Slack API key
pushtag="" # Your Slack channel tag

# Grab movie information
radarr_description=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq .overview)

# Format content
pushmessage=$radarr_movie_title 
pushmessage+=" - " 
pushmessage+=$radarr_moviefile_quality
pushmessage+=" : "
pushmessage+=$radarr_description

# Prepare push notification body
pushbody=$( jq -n \
    --arg text "$pushmessage" \
    --arg channel "$pushtag" \
    '{text: $text, channel: $pushtag}'
)

# Send push notification
curl -u "$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://slack.com/api/chat.postMessage