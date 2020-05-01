#!/bin/bash
pushkey="" # Your PushOver API key
pushuser="" # Your PushOver User Key

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

pushbody=$( jq -n \
    --arg token "$pushkey" \
    --arg user "$pushuser" \
    --arg title "$pushtitle" \
    --arg message "$pushmessage" \
    '{token: $token, user: $user, title: $title, message: $message}' )

# Send push notification   
curl --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushover.net/1/messages.json