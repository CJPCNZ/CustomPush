#!/bin/bash
apikey="" # Your Sonarr API key 
sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
pushkey="" # Your PushOver API key
pushuser="" # Your PushOver User Key

# Grab Episode information
sonarr_episode_title=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.Id==$sonarr_episodefile_id) | .title")
sonarr_episode_description=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.Id==$sonarr_episodefile_id) | .overview")

# Format content
pushtitle=$sonarr_series_title
pushtitle+=" - S" 
pushtitle+=$sonarr_episodefile_seasonnumber
pushtitle+=":E"
pushtitle+=$sonarr_episodefile_episodenumbers
pushmessage=$sonarr_episode_title

pushmessage+=" - "
pushmessage+=$sonarr_episode_description

pushbody=$( jq -n \
    --arg token "$pushkey" \
    --arg user "$pushuser" \
    --arg title "$pushtitle" \
    --arg message "$pushmessage" \
    '{token: $token, user: $user, title: $title, message: $message}' )

# Send push notification   
curl --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushover.net/1/messages.json