import sys, os
import pandas as pd
import numpy as np
from keras.models import load_model, Model
from keras.metrics import top_k_categorical_accuracy
from speaker_identification_data_generator import SpeakerIdentificationBatchGenerator
import scipy.io as io

MODEL_LOCATION = "/home/sanjeev/Documents/HeadMotionData/models/k-fold/2019-09-12/Mocap-functional_CNN_maxpool_lstm_glob-fold-4-weights-improvement-102-0.97-0.88-0.99.hdf5"
TEST_FOLDS = ["/home/sanjeev/Documents/HeadMotionData/Folds/data-fold-6.mat", "/home/sanjeev/Documents/HeadMotionData/Folds/data-fold-7.mat"]
OUT_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output.csv"

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
    
custom_objects = {"top_k_accuracy" : top_k_accuracy, "top_k_categorical_accuracy" : top_k_categorical_accuracy}
best_model = load_model(MODEL_LOCATION, custom_objects)
user_predictions = {}
intermediate_model = Model(inputs = best_model.input, outputs = best_model.get_layer("global_averager").output)

data = []
labels = []

for fold in TEST_FOLDS:
    df = io.loadmat(fold)
    data.append(df["data"])
    labels.append(df["labels"])

data = np.concatenate(data, axis = 0)
labels = np.concatenate(labels, axis = 0)
labels = np.argmax(labels, axis = 1).reshape(-1, 1)

intermediate_predictions = intermediate_model.predict(data)
intermediate_predictions = np.concatenate( (intermediate_predictions, labels), axis = 1)
#print(labels)
#print(intermediate_predictions.shape)
#sys.exit()

#intermediate_representations = []
#for i in range(num_steps):
#	x, y = next(data_generator)
#	y = np.argmax(y, axis = 1).reshape(-1, 1)
#	intermediate_output = intermediate_model.predict(x)
#	intermediate_output = np.concatenate((intermediate_output, y), axis = 1)
#	intermediate_representations.append(intermediate_output)

#intermediate_rep = np.concatenate(intermediate_representations, axis = 0)
df = pd.DataFrame(intermediate_predictions)
df.to_csv(OUT_LOCATION, index = False)
