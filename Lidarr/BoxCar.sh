#!/bin/bash
pushkey="" # Your Boxcar API key
pushsecret="" # Your Boxcar API secret
pushtag="" # Optional push channel tag if you need it

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