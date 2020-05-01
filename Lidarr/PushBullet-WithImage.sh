#!/bin/bash
apikey="" # Your Lidarr API key 
lidarr_address="http://localhost:8686" # Your Lidarr address (including base_url) 
pushkey="" # Your PushBullet API key
pushtag="" # Optional push channel if you need it
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to "username" / "password" if you use basic authentication in Lidarr
user=""
pass=""

if [ -n "$user" ] && [ -n "$pass" ] ;
then
wget --user=$user --password=$pass -q -O "$DIR/cover.jpg" $lidarr_address/MediaCover/Albums/$lidarr_album_id/cover.jpg --header "X-Api-Key:$apikey"
else 
wget -q -O "$DIR/cover.jpg" $lidarr_address/MediaCover/Albums/$lidarr_album_id/cover.jpg --header "X-Api-Key:$apikey"
fi

# Get important data
curl -s --header "Access-Token:$pushkey" -d file_name=cover.jpg -d file_type=image/jpeg https://api.pushbullet.com/v2/upload-request -o "$DIR/Lidarr.json"
uploadImage=( $(cat $DIR/Lidarr.json | jq -r '.data[]' ) )
uploadURL=( $(cat $DIR/Lidarr.json | jq -r '.upload_url') )
fileURL=( $(cat $DIR/Lidarr.json | jq -r '.file_url') )

# Upload the File
curl -s -X POST $uploadURL\
    -F awsaccesskeyid=${uploadImage[1]} \
    -F acl=${uploadImage[0]} \
    -F key=${uploadImage[3]} \
    -F signature=${uploadImage[5]} \
    -F policy=${uploadImage[4]} \
    -F content-type=${uploadImage[2]} \
    -F file=@"$DIR/cover.jpg"

rm $DIR/cover.jpg
rm $DIR/Lidarr.json

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
    --arg file_url "$fileURL" \
    --arg body "$pushmessage" \
    --arg channel "$pushtag" \
    '{body: $body, title: $title, type: "file", channel_tag: $channel, file_name: "cover.jpg", file_type: "image/jpeg", file_url: $file_url}' )

# Send push notification
curl -s --header "Access-Token:$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushbullet.com/v2/pushes
