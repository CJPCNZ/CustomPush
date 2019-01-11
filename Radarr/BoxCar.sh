#!/bin/bash
apikey="" # Your Radarr API key 
radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
pushkey="" # Your Boxcar API key
pushsecret="" # Your Boxcar API secret
pushtag="" # Optional push channel tag if you need it

# Grab movie information
radarr_description=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey") | jq .overview

# Format content
pushmessage=$radarr_movie_title 
pushmessage+=" - " 
pushmessage+=$radarr_moviefile_quality
pushmessage+=" : "
pushmessage+=$radarr_description

credentials=$pushkey
credentials+=":"
credentials+=$pushsecret

# Prepare push notification body
pushbody=$( jq -n \
    --arg body "$pushmessage" \
    --arg channel "$pushtag" \
    '{"aps":{"badge":"auto","alert":$body},"tags":{"or":[$channel]},"implicit_tag_creation":true}' )

# Send push notification
curl -u "$credentials" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://boxcar-api.io/api/push/