#!/bin/bash
apikey="" # Your Sonarr API key 
sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
pushkey="" # Your Boxcar API key
pushsecret="" # Your Boxcar API secret
pushtag="" # Optional push channel tag if you need it

# Grab Episode information
sonarr_episode_title=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.episodeFileId==$sonarr_episodefile_id) | .title")
sonarr_episode_description=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.episodeFileId==$sonarr_episodefile_id) | .overview")

# Format content
pushmessage=$sonarr_series_title
pushmessage+=" - S" 
pushmessage+=$sonarr_episodefile_seasonnumber
pushmessage+=":E"
pushmessage+=$sonarr_episodefile_episodenumbers

# Create credentials
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