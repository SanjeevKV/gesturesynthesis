common_data_folder=$1
scripts_root_folder=$2
out_folder=$3
folds_sub_folder="Folds/"
log_sub_folder="Logs/"
models_sub_folder="Models/"
incremental_sub_folder="Incremental/"
model_ext=".hdf5"
csv_ext=".csv"
inc_acc="-inc_acc"
bool_acc="-bool_acc"
steps=5
max_duration=70
skip_steps=10
batch_size=32
epochs=200

#=========================================== Folder Creation ========================================
mkdir -p $out_folder
for((i=steps ; i<=$max_duration; i = $i + $steps))
do
echo mkdir -p $out_folder$i
mkdir -p $out_folder$i
done

#exit

#=========================================== Data Preparation ========================================

for((i=steps ; i<=max_duration; i = $i + $steps))
do

cur_folds_folder=$out_folder$i"/"$folds_sub_folder

mkdir -p $cur_folds_folder

echo python $scripts_root_folder"one_file_folds.py" -r $common_data_folder -f $cur_folds_folder -d $i -s $skip_steps
python $scripts_root_folder"one_file_folds.py" -r $common_data_folder -f $cur_folds_folder -d $i -s $skip_steps

done

#=========================================== Training Phase ========================================

for((i=steps ; i<=max_duration; i = $i + $steps))
do

cur_folds_folder=$out_folder$i"/"$folds_sub_folder
cur_log_folder=$out_folder$i"/"$log_sub_folder
cur_models_folder=$out_folder$i"/"$models_sub_folder

mkdir -p $cur_log_folder
mkdir -p $cur_models_folder

echo python $scripts_root_folder"n_fold_models.py" -f $cur_folds_folder -l $cur_log_folder -m $cur_models_folder -d $i -s $skip_steps -b $batch_size -e $epochs
python $scripts_root_folder"n_fold_models.py" -f $cur_folds_folder -l $cur_log_folder -m $cur_models_folder -d $i -s $skip_steps -b $batch_size -e $epochs

done

#=========================================== Evaluation Phase ========================================

for((i=steps ; i<=max_duration; i = $i + $steps))
do

cur_folds_folder=$out_folder$i"/"$folds_sub_folder
cur_models_folder=$out_folder$i"/"$models_sub_folder
cur_log_folder=$out_folder$i"/"$log_sub_folder
cur_incremental_folder=$out_folder$i"/"$incremental_sub_folder

mkdir -p $cur_incremental_folder

fold_prefixes=`ls $cur_log_folder`
    for fp in $fold_prefixes
    do
    
    fold="$(echo $fp | cut -d '-' -f2)"
    f1=$(( ($fold * 2 + 8) % 10 ))
    f2=$(( ($fold * 2 + 9) % 10 ))
    echo python $scripts_root_folder"incremental_predictor.py" -m $cur_models_folder$fp$model_ext -f $cur_folds_folder -i $cur_incremental_folder$fp$inc_acc$csv_ext -b $cur_incremental_folder$fp$bool_acc$csv_ext -t $f1,$f2
    python $scripts_root_folder"incremental_predictor.py" -m $cur_models_folder$fp$model_ext -f $cur_folds_folder -i $cur_incremental_folder$fp$inc_acc$csv_ext -b $cur_incremental_folder$fp$bool_acc$csv_ext -t $f1,$f2
    
    done

done

#echo python one_file_folds.py -r /home/sanjeev/Documents/HeadMotionData/CommonMocapData -f /home/sanjeev/Documents/HeadMotionData/Folds/10 -d 10 -s 10
#python one_file_folds.py -r /home/sanjeev/Documents/HeadMotionData/CommonMocapData -f /home/sanjeev/Documents/HeadMotionData/Folds/10 -d 10 -s 10

#echo python n_fold_models.py -f /home/sanjeev/Documents/HeadMotionData/Folds/10 -l /tmp/models/lo
#g_files -m /tmp/models/best_models -d 10 -s 10 -b 32
#python n_fold_models.py -f /home/sanjeev/Documents/HeadMotionData/Folds/10 -l /tmp/models/lo
#g_files -m /tmp/models/best_models -d 10 -s 10 -b 32 -e 1

#echo python incremental_predictor.py -m /tmp/models/best_models/Mocap-0.hdf5 -f /home/sanjeev/Doc
#uments/HeadMotionData/Folds/10 -i /tmp/incremental_file -b /tmp/boolean_file -t 8,9
#python incremental_predictor.py -m /tmp/models/best_models/Mocap-0.hdf5 -f /home/sanjeev/Doc
#uments/HeadMotionData/Folds/10 -i /tmp/incremental_file -b /tmp/boolean_file -t 8,9

