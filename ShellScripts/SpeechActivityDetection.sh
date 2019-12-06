sound_input_path=$1
sad_path=$2
kaldi_sad_path=$3

sad_input=$sad_path"input/"
sad_output=$sad_path"output/"
sad_work=$sad_path"work/"
sad_mfcc=$sad_path"mfcc/"
kaldi_mdl=$kaldi_sad_path"exp/segmentation_1a/tdnn_stats_asr_sad_1a/"
segments_file=$sad_output"_seg/segments"

csv_suffix=".csv"

#====================================================================== STAGE 1: Call kaldi detect_speech_activity script ==================================================================================

mkdir -p $sad_input

echo -n > $sad_input"spk2utt"
echo -n > $sad_input"utt2spk"
echo -n > $sad_input"wav.scp"

for i in `ls $sound_input_path`
do
  utt="$(echo $i | cut -d '.' -f1)"
  spk="$(echo $utt | cut -d '_' -f3)"
  echo $spk $utt >> $sad_input"spk2utt"
  echo $utt $spk >> $sad_input"utt2spk"
  echo "$utt /usr/bin/sox -t wav $sound_input_path$i -c 1 -b 16 -r 8000 -t wav - |" >> $sad_input"wav.scp" 
done

cd $kaldi_sad_path
sh $kaldi_sad_path"detect_speech_activity.sh" $sad_input $kaldi_mdl $sad_mfcc $sad_work $sad_output

#====================================================================== STAGE 2: Process kaldi output into structured format ================================================================================
seg_iterator=`sort $segments_file | cut -d " " -f2 | uniq -c | rev | cut -d " " -f1,2 | rev | tr " " +`
#echo $seg_iterator
it_low=0
for it in $seg_iterator
do
  cur_window=`echo $it | cut -d "+" -f1`
  cur_file=`echo $it | cut -d "+" -f2`
  it_high=`expr $it_low + $cur_window`
  sort $segments_file | cut -d " " -f3,4 | head -$it_high | tail -$cur_window > $sad_path$cur_file$csv_suffix
  echo 'start_time end_time' | cat - $sad_path$cur_file$csv_suffix > temp && mv temp $sad_path$cur_file$csv_suffix
  it_low=$it_high
done


