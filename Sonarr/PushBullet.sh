#!/bin/bash
apikey="" # Your Sonarr API key 
sonarr_address="http://localhost:7878" # Your Sonarr address (including base_url) 
pushkey="" # Your PushBullet API key
pushtag="" # Optional push channel if you need it

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

# Prepare push notification body
pushbody=$( jq -n \
    --arg title "$pushtitle" \
    --arg body "$pushmessage" \
    --arg channel "$pushtag" \
    '{body: $body, title: $title, type: "note", channel_tag: $channel}' )

# Send push notification
curl --header "Access-Token:$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushbullet.com/v2/pushes