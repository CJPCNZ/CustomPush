#!/bin/bash
apikey="" # Your Radarr API key 
radarr_address="http://localhost:7878" # Your Radarr address (including base_url)
ffmpeg = "" #Path to FFMPEG e.g. /bin/ffmpeg.exe

# Single Output File
$ffpmeg -i $radarr_moviefile_path -sn -profile:v baseline -level 3.0 -start_number 0 -hls_flags single_file -hls_list_size 0 "$radarr_movie_path/output.m3u8"
rm $radarr_moviefile_path

# Multiple Output Files
#$ffmpeg -i $radarr_moviefile_path -sn -profile:v baseline -level 3.0 -start_number 0 -hls_time 10 -hls_list_size 0 "$radarr_movie_path/output.m3u8"
#rm $radarr_moviefile_path

pushbody=$( jq -n \
    --arg name "RefreshMovie" \
    --arg movieIds [$radarr_movie_id] \
    '{name: $name, movieIds: $movieIds}'
)

curl -s $radarr_address/api/command --header "X-Api-Key:$apikey;Content-Type: application/json" --data-binary "$pushbody" --request POST

pushbody=$( jq -n \
    --arg folder "$$radarr_movie_path" \
    --arg movieId [$radarr_movie_id] \
    '{folder: $folder, movieId: $movieId, filterExistingFiles:true}'
)

curl -s $radarr_address/api/manualImport --header "X-Api-Key:$apikey;Content-Type: application/json" --data-binary "$pushbody" --request POST
