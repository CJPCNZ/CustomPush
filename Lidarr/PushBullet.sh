#!/bin/bash
pushkey="" # Your PushBullet API key
pushtag="" # Optional push channel if you need it

# Format content
lidarr_album_releaseday=( $(echo $lidarr_album_releasedate | cut -d " " -f1) )

pushtitle=$lidarr_artist_name
pushtitle+=" - "
pushtitle+=$lidarr_album_title

pushmessage=$'Release Date: '
pushmessage+=$lidarr_album_releaseday
pushmessage+=$'\n\nMusicBrainz: https://musicbrainz.org/release-group/'
pushmessage+=$lidarr_album_mbid
pushmessage+=$'\n'

# Prepare push notification body
pushbody=$( jq -n \
    --arg title "$pushtitle" \
    --arg body "$pushmessage" \
    --arg channel "$pushtag" \
    '{body: $body, title: $title, type: "note", channel_tag: $channel}' )

# Send push notification
curl -s --header "Access-Token:$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushbullet.com/v2/pushes