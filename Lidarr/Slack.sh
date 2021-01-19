#!/bin/bash
pushkey="Bearer xoxb-your-token" # Your Slack API key
pushtag="" # Your Slack channel tag

# Format content
lidarr_album_releaseday=( $(echo $lidarr_album_releasedate | cut -d " " -f1) )

pushmessage = $lidarr_artist_name + " - " + $lidarr_album_title + "Release Date: " + $lidarr_album_releaseday + "`r`nMusicBrainz: https://musicbrainz.org/release-group/"+ $lidarr_album_mbid + "`r`n"

pushmessage=$lidarr_artist_name
pushmessage+=" - "
pushmessage+=$lidarr_album_title
pushmessage+=$'\n'
pushmessage+=$'Release Date: '
pushmessage+=$lidarr_album_releaseday
pushmessage+=$'\n\nMusicBrainz: https://musicbrainz.org/release-group/'
pushmessage+=$lidarr_album_mbid
pushmessage+=$'\n'

# Prepare push notification body
pushbody=$( jq -n \
    --arg text "$pushmessage" \
    --arg channel "$pushtag" \
)

# Send push notification
curl -u "$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://slack.com/api/chat.postMessage