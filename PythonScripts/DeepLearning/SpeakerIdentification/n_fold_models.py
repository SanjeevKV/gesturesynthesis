#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 27 12:27:22 2019

@author: sanjeev
"""
import os

os.environ["CUDA_DEVICE_ORDER"]="PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"]="2"

from keras.models import Sequential, Model
from keras.layers import SeparableConv1D, AveragePooling1D, CuDNNLSTM, Concatenate, Lambda, Reshape, Input, Bidirectional, TimeDistributed, GlobalAveragePooling1D, SpatialDropout1D, Conv1D, BatchNormalization, MaxPooling1D, Dense, Activation, Flatten, LSTM, Dropout
from keras import optimizers
from keras.callbacks import ModelCheckpoint, EarlyStopping, Callback
from keras.metrics import top_k_categorical_accuracy
import argparse
from speaker_identification_data_generator import SpeakerIdentificationBatchGenerator
import sys
import tensorflow as tf
import scipy.io as io
import numpy as np
from sklearn.model_selection import KFold as kf
import math

class LogBestModelName(Callback):
    def __init__(self, log_path, file_prefix):
        super().__init__()
        self.current_val_acc = -math.inf
        self.file_prefix = file_prefix
        self.log_path = log_path
        
        if os.path.isdir(self.log_path) == False:
            os.mkdir(self.log_path)
        
    def on_epoch_begin(self, epoch, logs={}):
        self.losses = []
        
    def on_batch_end(self, batch, logs={}):
        self.losses.append(logs.get("categorical_accuracy"))

    def on_epoch_end(self, epoch, logs={}):
        #print(logs.keys())
        if logs.get("val_categorical_accuracy") > self.current_val_acc:
            self.current_val_acc = logs.get("val_categorical_accuracy")        
            with open( os.path.join(self.log_path, self.file_prefix), "w") as myfile:
                myfile.write( str(epoch) + "-" + str( round( np.mean(self.losses), 2) ) + "-" + str( round(logs.get("val_categorical_accuracy"), 2) ) )


"""
Simple 1D-CNN, GlobalAvgPooling, Softmax
Valid Acc (5-fold): 44 - 51 
"""
def functional_CNN_pool( input_shape, num_classes ):
    motion_input = Input(shape = input_shape, name = "input")
    conv_output = Conv1D(50, 10, activation = 'relu', name = "convolution")(motion_input)
    bn = BatchNormalization()(conv_output) #Trial
    #lap = AveragePooling1D(pool_size = 120, strides = 120)(motion_input)
    #print(lap.shape)
    global_avg_output = GlobalAveragePooling1D(name = "global_averager")(bn)#(conv_output)
    #global_avg_output = Flatten()(lap)
    softmax_output = Dense(24, activation = 'softmax', name = "final_predictor")(global_avg_output)
    model = Model(inputs = [motion_input], outputs = [softmax_output])
    model.compile(optimizer='adam',loss=['categorical_crossentropy'],metrics=METRICS)
    return model

"""
1D-CNN, BatchNormalization, 1DMaxPooling, LSTM, BatchNormalization, GlobAvgPooling, Softmax
Valid Acc (5-fold): 83 - 92
"""
def functional_CNN_pool_lstm_glob( input_shape, num_classes ):
    motion_input = Input(shape = input_shape, name = "input")
    conv_output = Conv1D(24, 10, activation = 'relu', name = "convolution")(motion_input)#Conv1D(24, 10, activation = 'relu', name = "convolution")(motion_input)
    bn = BatchNormalization()(conv_output) #Trial
    lap = MaxPooling1D(pool_size = 10)(bn) #Trial - conv_output
    lstm = LSTM(units = 24, return_sequences = True, name = "lstm")(lap)
    bn_2 = BatchNormalization()(lstm) #Trial
    #print(lap.shape)
    global_avg_output = GlobalAveragePooling1D(name = "global_averager")(bn_2) #Trial - lstm
    #global_avg_output = Flatten()(lap)
    softmax_output = Dense(24, activation = 'softmax', name = "final_predictor")(global_avg_output)
    model = Model(inputs = [motion_input], outputs = [softmax_output])
    model.compile(optimizer='adam',loss=['categorical_crossentropy'],metrics=['categorical_accuracy'])
    return model

"""
1D-CNN, 1DMaxPooling(3), 1D-CNN MaxPooling(3), LSTM, GlobAvgPooling, Softmax
Valid Acc: 64
"""
def functional_CNN_pool_sk_lstm_glob( input_shape, num_classes ):
    motion_input = Input(shape = input_shape, name = "input")
    conv_output = Conv1D(24, 3, activation = 'relu', name = "convolution")(motion_input)
    lap = MaxPooling1D(pool_size = 3)(conv_output)
    conv_output_2 = Conv1D(24, 3, activation = 'relu', name = "convolution_2")(lap)
    lap_2 = MaxPooling1D(pool_size = 3)(conv_output_2)
    lstm = LSTM(units = 24, return_sequences = True)(lap_2)
    #print(lap.shape)
    global_avg_output = GlobalAveragePooling1D(name = "global_averager")(lstm)
    #global_avg_output = Flatten()(lap)
    softmax_output = Dense(24, activation = 'softmax', name = "final_predictor")(global_avg_output)
    model = Model(inputs = [motion_input], outputs = [softmax_output])
    model.compile(optimizer='adam',loss=['categorical_crossentropy'],metrics=['categorical_accuracy'])
    return model
    
def functional_LSTM(input_shape, num_classes):
    motion_input = Input(shape = input_shape, name = "input")
    conv_output = Conv1D(24, 10, activation = 'relu', name = "convolution")(motion_input)
    lap = AveragePooling1D(pool_size = 10)(motion_input)
    lstm1=LSTM(24,return_sequences=True)(lap);
    #print(lap.shape)
    global_avg_output = GlobalAveragePooling1D(name = "global_averager")(lstm1)
    #global_avg_output = Flatten()(lap)
    softmax_output = Dense(24, activation = 'softmax', name = "final_predictor")(global_avg_output)
    model = Model(inputs = [motion_input], outputs = [softmax_output])
    model.compile(optimizer='adam',loss=['categorical_crossentropy'],metrics=['categorical_accuracy'])
    return model

def top_k_accuracy(y_true, y_pred):
    return top_k_categorical_accuracy(y_true, y_pred, k=5)
    
def get_data(num_files, fold_files, sr, cur_pos):

    train_data = []
    train_labels = []
    valid_data = []
    valid_labels = []
    test_data = []
    test_labels = []
    
    files_covered = 0
    
    for i in range(sr[0]):
        data = io.loadmat( fold_files[ (files_covered + cur_pos + i) % num_files ] )
        train_data.append(data["data"])
        train_labels.append(data["labels"])
    
    train_data = np.concatenate(train_data, axis = 0)
    train_labels = np.concatenate(train_labels, axis = 0)
    files_covered += sr[0]
    
    for i in range(sr[1]):
        data = io.loadmat( fold_files[ (files_covered + cur_pos + i) % num_files ] )
        valid_data.append(data["data"])
        valid_labels.append(data["labels"])

    valid_data = np.concatenate(valid_data, axis = 0)
    valid_labels = np.concatenate(valid_labels, axis = 0)    
    files_covered += sr[1]
    
    for i in range(sr[2]):
        data = io.loadmat( fold_files[ (files_covered + cur_pos + i) % num_files ] )
        test_data.append(data["data"])
        test_labels.append(data["labels"]) 

    test_data = np.concatenate(test_data, axis = 0)
    test_labels = np.concatenate(test_labels, axis = 0)
    
    print(train_data.shape, train_labels.shape, valid_data.shape, valid_labels.shape)        
    return train_data, train_labels, valid_data, valid_labels, test_data, test_labels
    

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-f", "--folds_path", help = "Location to read the folds from", required = True)
    parser.add_argument("-d", "--window_duration", help = "Duration of single window (sec)", required = True)
    parser.add_argument("-s", "--skip_duration", help = "Duration to skip before next window (sec)", required = True)
    parser.add_argument("-l", "--log_path", help = "Directory containing log files", required = True)
    parser.add_argument("-m", "--models_path", help = "Log file", required = True)
    parser.add_argument("-e", "--epochs", help = "Maximum number of epochs", required = True)
    parser.add_argument("-b", "--batch_size", help = "Batch Size", default =  32, required = False)
    argument = parser.parse_args()
	
    MODEL_PREFIX = "Mocap-"
    COLUMNS = ["X", "Y", "Z"]
    NUM_EPOCHS = int(argument.epochs)
    LEARNING_RATE = 0.0001
    DECAY = 1e-6
    MOMENTUM = 0.9
    OUT_SIZE = 24 # Number of subjects / classes
    NUM_CHANNELS = 3 # Number of features per frame
    OPTIMIZER = "adam"
    LOSS = "categorical_crossentropy"
    METRICS = ["categorical_accuracy"]
    VFPS = 120
    TRAIN_VALID_TEST_SPLIT = [6, 2, 2]

    DATA_PATH = argument.folds_path
    BATCH_SIZE = int(argument.batch_size) # Number of samples in a batch
    NUM_SKIP_STEPS = int(argument.skip_duration) # Number of seconds to skip for generating next sample from the same file
    NUM_STEPS = int(argument.window_duration) # Duration (in seconds) of a sample
    MODEL_ROOT_LOCATION = argument.models_path

    input_shape = (VFPS * NUM_STEPS, NUM_CHANNELS)

    if os.path.isdir(argument.models_path) == False:
        os.mkdir(argument.models_path)    
    
    cur_pos = 0
    increment = min(TRAIN_VALID_TEST_SPLIT)
    num_files = sum(TRAIN_VALID_TEST_SPLIT)
    num_folds = int(num_files / increment)
    fold_files = os.listdir(DATA_PATH)
    fold_files = [os.path.join(DATA_PATH, ff) for ff in fold_files]



    #num_folds = 1 #Comment this line if you want k-fold validation to run               
    for k in range(num_folds):
        print("Starting another fold: " + str(k) )
        model = functional_CNN_pool_lstm_glob(input_shape, OUT_SIZE)
        model.summary();
        train_data, train_labels, valid_data, valid_labels, test_data, test_labels = get_data(num_files, fold_files,  TRAIN_VALID_TEST_SPLIT, cur_pos)
        cur_pos += increment       

        filepath = os.path.join(MODEL_ROOT_LOCATION, MODEL_PREFIX + str(k) + ".hdf5")

        checkpoint = ModelCheckpoint(filepath, monitor='val_categorical_accuracy', verbose=1, save_best_only=True, mode='max')
        es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', patience = 20)# - Uncomment this line for early stopping
        log_file = LogBestModelName(argument.log_path, MODEL_PREFIX + str(k) )
        callbacks_list = [checkpoint, es, log_file]
        model.fit(train_data, train_labels, batch_size = BATCH_SIZE, epochs = NUM_EPOCHS, callbacks = callbacks_list, validation_data = (valid_data, valid_labels))

