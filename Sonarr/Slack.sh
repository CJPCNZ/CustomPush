#!/bin/bash
apikey="" # Your Sonarr API key 
sonarr_address="http://localhost:8989" # Your Sonarr address (including base_url) 
pushkey="Bearer xoxb-your-token" # Your Slack API key
pushtag="" # Your Slack channel tag

# Grab Episode information
sonarr_episode_title=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.Id==$sonarr_episodefile_id) | .title")
sonarr_episode_description=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.Id==$sonarr_episodefile_id) | .overview")

# Format content
pushmessage=$sonarr_series_title
pushmessage+=" - S" 
pushmessage+=$sonarr_episodefile_seasonnumber
pushmessage+=":E"
pushmessage+=$sonarr_episodefile_episodenumbers

# Prepare push notification body
pushbody=$( jq -n \
    --arg text "$pushmessage" \
    --arg channel "$pushtag" \
    '{text: $text, channel: $pushtag}'
)

# Send push notification
curl -u "$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://slack.com/api/chat.postMessage