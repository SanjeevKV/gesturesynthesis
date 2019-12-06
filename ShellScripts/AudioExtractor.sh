audio_visual_file=$1
audio_file=$2

ffmpeg -i $audio_visual_file -ac 1 -f "wav" -ar 8000 $audio_file
