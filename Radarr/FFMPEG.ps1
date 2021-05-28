# Define required variables
$radarr_moviefile_path = $env:radarr_moviefile_path
$radarr_moviefile_relativepath = $env:radarr_moviefile_relativepath
$ffmpeg = "" #Path to FFMPEG e.g. C:\ffmpeg\bin\ffmpeg.exe

# Single Output File
Start-Process $ffpmeg -i $radarr_moviefile_path -profile:v baseline -level 3.0 -start_number 0 -hls_flags single_file -hls_list_size 0 "$radarr_moviefile_relativepath/output.m3u8"
Remove-Item $radarr_moviefile_path

# Multiple Output Files
Start-Process $ffmpeg -i $radarr_moviefile_path -profile:v baseline -level 3.0 -start_number 0 -hls_time 10 -hls_list_size 0 "$radarr_moviefile_relativepath/output.m3u8"
Remove-Item $radarr_moviefile_path