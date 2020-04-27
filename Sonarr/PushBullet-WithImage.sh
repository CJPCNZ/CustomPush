#!/bin/bash
apikey="" # Your Sonarr API key 
sonarr_address="http://localhost:7878" # Your Sonarr address (including base_url) 
pushkey="" # Your PushBullet API key
pushtag="" # Optional push channel if you need it
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to "username" / "password" if you use basic authentication in Sonarr
user=""
pass=""

if [ -n "$user" ] && [ -n "$pass" ] ;
then
# Grab Episode information
sonarr_episode_title=$(curl -u $user:$pass -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.episodeFileId==$sonarr_episodefile_id) | .title")
sonarr_episode_description=$(curl -u $user:$pass -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.episodeFileId==$sonarr_episodefile_id) | .overview")
sonarr_serie_network=$(curl -u $user:$pass -s $sonarr_address/api/series/$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r .network)
wget --user=$user --password=$pass -q -O "$DIR/poster.jpg" $sonarr_address/MediaCover/$sonarr_series_id/poster.jpg --header "X-Api-Key:$apikey"
else 
# Grab Episode information
sonarr_episode_title=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.episodeFileId==$sonarr_episodefile_id) | .title")
sonarr_episode_description=$(curl -s $sonarr_address/api/episode?seriesId=$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r ".[] | select(.episodeFileId==$sonarr_episodefile_id) | .overview")
sonarr_serie_network=$(curl -s $sonarr_address/api/series/$sonarr_series_id --header "X-Api-Key:$apikey" | jq -r .network)
wget -q -O "$DIR/poster.jpg" $sonarr_address/MediaCover/$sonarr_series_id/poster.jpg --header "X-Api-Key:$apikey"
fi

# Get important data
curl -s --header "Access-Token:$pushkey" -d file_name=poster.jpg -d file_type=image/jpeg https://api.pushbullet.com/v2/upload-request -o "$DIR/Sonarr.json"
uploadImage=( $(cat $DIR/Sonarr.json | jq -r '.data[]' ) )
uploadURL=( $(cat $DIR/Sonarr.json | jq -r '.upload_url') )
fileURL=( $(cat $DIR/Sonarr.json | jq -r '.file_url') )

# Upload the File
curl -s -X POST $uploadURL\
    -F awsaccesskeyid=${uploadImage[1]} \
    -F acl=${uploadImage[0]} \
    -F key=${uploadImage[3]} \
    -F signature=${uploadImage[5]} \
    -F policy=${uploadImage[4]} \
    -F content-type=${uploadImage[2]} \
    -F file=@"$DIR/poster.jpg"

rm $DIR/poster.jpg
rm $DIR/Sonarr.json

# Format content
pushtitle=$sonarr_series_title
pushtitle+=" - S"
pushtitle+=$sonarr_episodefile_seasonnumber
pushtitle+="E"
pushtitle+=$sonarr_episodefile_episodenumbers
pushtitle+=" ["
pushtitle+=$sonarr_episodefile_quality
pushtitle+="]"

pushmessage=$'Network: '
pushmessage+=$sonarr_serie_network
pushmessage+=$'\nTitle: '
pushmessage+=$sonarr_episode_title
pushmessage+=$'\n\nDescription:\n'
pushmessage+=$sonarr_episode_description
pushmessage+=$'\n\nIMDb: https://imdb.com/title/'
pushmessage+=$sonarr_series_imdbid
pushmessage+=$'\n'

# Prepare push notification body
pushbody=$( jq -n \
    --arg title "$pushtitle" \
    --arg file_url "$fileURL" \
    --arg body "$pushmessage" \
    --arg channel "$pushtag" \
    '{body: $body, title: $title, type: "file", channel_tag: $channel, file_name: "poster.jpg", file_type: "image/jpeg", file_url: $file_url}' )

# Send push notification
curl -s --header "Access-Token:$pushkey" --header 'Content-Type: application/json' --data-binary "$pushbody" --request POST https://api.pushbullet.com/v2/pushes
