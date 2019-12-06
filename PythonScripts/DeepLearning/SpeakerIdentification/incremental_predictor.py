from keras.models import load_model, Model
import numpy as np
import scipy.io as io
from keras.metrics import top_k_categorical_accuracy
import math
import argparse
import pandas as pd
import os

def top_k_accuracy(y_true, y_pred):
    return top_k_categorical_accuracy(y_true, y_pred, k=5)

def Normalize(seq):
    num_trues = 0
    num_falses = 0
    for i in range(len(seq)):
        if(seq[i] == True):
            num_trues += 1
        else:
            num_falses += 1
        if(num_trues > num_falses):
            seq[i] = True
        else:
            seq[i] = False
    return seq

def EqualizeLength(seq, mp):
    while len(seq) < mp:
        seq = np.append(seq, seq[-1])
    return seq.reshape(1,-1)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-m", "--model_location", help = "Location of the model", required = True)
    parser.add_argument("-f", "--folds_path", help = "Location to write the folds", required = True)
    parser.add_argument("-t", "--test_folds", help = "Comma sep test fold file nums", required = True)
    parser.add_argument("-i", "--inc_file", help = "Incremental acc file", required = True)
    parser.add_argument("-b", "--bool_file", help = "Boolean acc file", required = True)
    argument = parser.parse_args()
	
    MODEL_LOCATION = argument.model_location
    file_nums = argument.test_folds.split(",")
    files = os.listdir(argument.folds_path)
    TEST_FOLDS = []
    for f in files:
        for n in file_nums:
            if f.find("-" + n + ".mat") != -1:
                #print("-" + n + ".mat")
                TEST_FOLDS.append(os.path.join(argument.folds_path, f))
#    TEST_FOLDS = ["/home/sanjeev/Documents/HeadMotionData/Folds/data-fold-8.mat", "/home/sanjeev/Documents/HeadMotionData/Folds/data-fold-9.mat"]
    print(TEST_FOLDS)
        
    custom_objects = {"top_k_accuracy" : top_k_accuracy, "top_k_categorical_accuracy" : top_k_categorical_accuracy}
    best_model = load_model(MODEL_LOCATION, custom_objects)
    user_predictions = {}

    data = []
    labels = []

    for fold in TEST_FOLDS:
        df = io.loadmat(fold)
        data.append(df["data"])
        labels.append(df["labels"])

    data = np.concatenate(data, axis = 0)
    labels = np.concatenate(labels, axis = 0)

    for idx, sample in enumerate(data):
        #print(idx)
        #print(sample.shape)
        cur_prediction = np.argmax( best_model.predict(sample.reshape(1, -1, 3)) )
        cur_user = np.argmax(labels[idx])
        existing_predictions = user_predictions.get(cur_user, [])
        existing_predictions.append(cur_prediction)
        user_predictions[cur_user] = existing_predictions

    user_correct_predictions = {}

    #print(user_predictions)
    max_predictions = - math.inf    
    for user, predictions in user_predictions.items():
        #print(user, predictions)
        user_correct_predictions[user] = Normalize(predictions == user)
        if len(predictions) > max_predictions:
            max_predictions = len(predictions)

    predictions_list = []
    for user, predictions in user_correct_predictions.items():
        predictions_list.append( EqualizeLength(predictions, max_predictions) )        

    #print(predictions_list)
    pred_arr = np.concatenate(predictions_list, axis = 0)
    boolean_df = pd.DataFrame(pred_arr)
    boolean_df.to_csv(argument.bool_file, index = False)
    #print(pred_arr)
    chunk_wise_prediction = []
    for i in range(pred_arr.shape[1]):
        acc = np.sum(pred_arr[:, i]) / pred_arr.shape[0]
        chunk_wise_prediction.append([i+1, acc])
        #print("Accuracy after chunk {0} is : {1}".format(i, acc))
        
    arr = np.array(chunk_wise_prediction)
    print("Writing incremental accuracy at location: {0}".format(argument.inc_file))
    df = pd.DataFrame(arr, columns = ["Chunk", "Acc"])
    df.to_csv(argument.inc_file, index = False) 
