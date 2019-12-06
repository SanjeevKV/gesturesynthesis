audio_visual_file=$1
temp_path=$2
file_name=$3
coordinates_file=$4

root_location="/home/sanjeev/Documents/OpenFace/build/bin/"
$root_location"FeatureExtraction" -mloc $root_location"model/main_ceclm_general.txt" -f $audio_visual_file  -out_dir $temp_path
cp $temp_path$file_name $coordinates_file
rm -rf $temp_path


