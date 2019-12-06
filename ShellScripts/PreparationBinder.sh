project_base_folder=$1
base_data_path=$2
base_code_path=$3

hand_markers_path=$1$3"HeadMotionRelatedCode/Old_HandMarkerNames.txt"
head_markers_path=$1$3"HeadMotionRelatedCode/Old_HeadMarkerNames.txt"
head_motion_related_code=$1$3"HeadMotionRelatedCode/"

mocap_output_path=$1$2"MocapOutput/"
coordinates_path=$1$2"Coordinates/"
hand_distance_path=$1$2"HandDistance/"
euler_angles_path=$1$2"EulerAngles/"
praat_output_path=$1$2"PitchIntensity/"
prosody_output_path=$1$2"ProsodyData-PitchIntensity/"
sound_input_path=$1$2"Audio/"
kaldi_sad_path=$1"kaldi/egs/aspire/sad/"
sad_path=$1$2"SAD/"
delay_path=$1$2"Delay/"
training_path=$1$2"TrainingData/"
asr_path=$1$2"asr_audio_segments/"
audio_visual_path=$1$2"AudioVisual/"
open_face_coordinates_path=$1$2"open_face_coordinates/"
open_face_audio_path=$1$2"open_face_audio/"

head_markers_count=6
text_suffix=".txt"
wav_suffix=".wav"
csv_suffix=".csv"
mat_suffix=".mat"
video_suffix=".MTS"

prepare=1
#====================================================================== STAGE 1 : Coordinates Parser ========================================================================================================
prepare=2 #Comment this line if Parser need to run
if [ $prepare -le 1 ]; then
  echo matlab -nodesktop -r "cd $head_motion_related_code; pipeline('$mocap_output_path','$coordinates_path','$hand_distance_path','$hand_markers_path','$head_markers_path',$head_markers_count,'$euler_angles_path'); synchronizeAudioMarkersAll('$sound_input_path', '$hand_distance_path', '$delay_path'); exit"
  matlab -nodesktop -r "cd $head_motion_related_code; pipeline('$mocap_output_path','$coordinates_path','$hand_distance_path','$hand_markers_path','$head_markers_path',$head_markers_count,'$euler_angles_path'); synchronizeAudioMarkersAll('$sound_input_path', '$hand_distance_path', '$delay_path'); exit"
fi

mkdir -p $praat_output_path
mkdir -p $prosody_output_path
mkdir -p $training_path
mkdir -p $sad_path
mkdir -p $open_face_coordinates_path
mkdir -p $open_face_audio_path

#====================================================================== STAGE 2 : SAD Kaldi =================================================================================================================
prepare=3 # Comment this line if SAD of Kaldi needs to run
if [ $prepare -le 2 ]; then
  echo sh $1$3"ShellScripts/SpeechActivityDetection.sh" $sound_input_path $sad_path $kaldi_sad_path
  sh $1$3"ShellScripts/SpeechActivityDetection.sh" $sound_input_path $sad_path $kaldi_sad_path
fi

#====================================================================== STAGE 3 : Coordinates Parser =======================================================================================================
prepare=4 # Comment this line if Prosody features and data assimilator needs to run
if [ $prepare -le 3 ]; then
  for i in `ls $sound_input_path`
  do
    file_prefix="$(echo $i | cut -d '.' -f1)"
    echo praat --run $1$3"PraatScripts/PitchCalculator.praat" $sound_input_path$file_prefix$wav_suffix $praat_output_path$file_prefix$text_suffix
    praat --run $1$3"PraatScripts/PitchCalculator.praat" $sound_input_path$file_prefix$wav_suffix $praat_output_path$file_prefix$text_suffix
    echo python $1$3"PythonScripts/prosody_features_extractor.py" -i $praat_output_path$file_prefix$text_suffix -o $prosody_output_path$file_prefix$csv_suffix -p $base_code_path"PythonScripts/"
    python $1$3"PythonScripts/prosody_features_extractor.py" -i $praat_output_path$file_prefix$text_suffix -o $prosody_output_path$file_prefix$csv_suffix -p $base_code_path"PythonScripts/"
    echo python $1$3"PythonScripts/data_assimilator.py" -f $asr_path$file_prefix$csv_suffix -s $sad_path$file_prefix$csv_suffix -e $euler_angles_path$file_prefix$mat_suffix -c $coordinates_path$file_prefix$mat_suffix -p $prosody_output_path$file_prefix$csv_suffix -d $delay_path$file_prefix$text_suffix -o $training_path$file_prefix$csv_suffix
    python $1$3"PythonScripts/data_assimilator.py" -f $asr_path$file_prefix$csv_suffix -s $sad_path$file_prefix$csv_suffix -e $euler_angles_path$file_prefix$mat_suffix -c $coordinates_path$file_prefix$mat_suffix -p $prosody_output_path$file_prefix$csv_suffix -d $delay_path$file_prefix$text_suffix -o $training_path$file_prefix$csv_suffix
  done
fi

#====================================================================== STAGE 4 : Openface Coordinates Parser ===============================================================================================
#prepare=5 # Comment this line if OpenFace extraction needs to run
if [ $prepare -le 4 ]; then
  for i in `ls $audio_visual_path`
  do
    file_prefix="$(echo $i | cut -d '.' -f1)"
    echo sh $1$3"ShellScripts/OpenFaceCoordinates.sh" $audio_visual_path$file_prefix$video_suffix "/tmp/$file_prefix/" $file_prefix$csv_suffix $open_face_coordinates_path$file_prefix$csv_suffix
    sh $1$3"ShellScripts/OpenFaceCoordinates.sh" $audio_visual_path$file_prefix$video_suffix "/tmp/$file_prefix/" $file_prefix$csv_suffix $open_face_coordinates_path$file_prefix$csv_suffix
    echo sh $1$3"ShellScripts/AudioExtractor.sh" $audio_visual_path$file_prefix$video_suffix $open_face_audio_path$file_prefix$wav_suffix
    sh $1$3"ShellScripts/AudioExtractor.sh" $audio_visual_path$file_prefix$video_suffix $open_face_audio_path$file_prefix$wav_suffix
  done
fi
