#!/bin/bash
apikey="" # Your Radarr API key 
radarr_address="http://localhost:7878" # Your Radarr address (including base_url) 
pushkey="" # Your PushBullet API key
pushtag="" # Optional push channel if you need it
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Change to "username" / "password" if you use basic authentication in Radarr
user=""
pass=""

if [ -n "$user" ] && [ -n "$pass" ] ;
then
# Grab movie information
radarr_description=$(curl -u $user:$pass -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq -r .overview);
radarr_year=$(curl -u $user:$pass -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq -r .year);
radarr_youTubeTrailerId=$(curl -u $user:$pass -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq -r .youTubeTrailerId);
wget --user=$user --password=$pass -q -O "$DIR/poster.jpg" $radarr_address/MediaCover/$radarr_movie_id/poster.jpg --header "X-Api-Key:$apikey"
else 
# Grab movie information
radarr_description=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq -r .overview);
radarr_year=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq -r .year);
radarr_youTubeTrailerId=$(curl -s $radarr_address/api/movie/$radarr_movie_id --header "X-Api-Key:$apikey" | jq -r .youTubeTrailerId);
wget -q -O "$DIR/poster.jpg" $radarr_address/MediaCover/$radarr_movie_id/poster.jpg --header "X-Api-Key:$apikey"
fi

# Get important data
curl -s --header "Access-Token:$pushkey" -d file_name=poster.jpg -d file_type=image/jpeg https://api.pushbullet.com/v2/upload-request -o "$DIR/Radarr.json"
uploadImage=( $(cat $DIR/Radarr.json | jq -r '.data[]' ) )
uploadURL=( $(cat $DIR/Radarr.json | jq -r '.upload_url') )
fileURL=( $(cat $DIR/Radarr.json | jq -r '.file_url') )

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
rm $DIR/Radarr.json

# Format content
pushtitle=$radarr_movie_title 
pushtitle+=" (" 
pushtitle+=$radarr_year
pushtitle+=") ["
pushtitle+=$radarr_moviefile_quality
pushtitle+="]"

pushmessage=$'Description:\n'
pushmessage+=$radarr_description
pushmessage+=$'\n\nIMDb: https://imdb.com/title/'
pushmessage+=$radarr_movie_imdbid
pushmessage+=$'\nTrailer: https://www.youtube.com/watch?v='
pushmessage+=$radarr_youTubeTrailerId
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
