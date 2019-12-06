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
from keras.layers import AveragePooling1D, CuDNNLSTM, Concatenate, Lambda, Reshape, Input, Bidirectional, TimeDistributed, GlobalAveragePooling1D, SpatialDropout1D, Conv1D, BatchNormalization, MaxPooling1D, Dense, Activation, Flatten, LSTM, Dropout
from keras import optimizers
from keras.callbacks import ModelCheckpoint, EarlyStopping
from keras.metrics import top_k_categorical_accuracy
import argparse
from speaker_identification_data_generator import SpeakerIdentificationBatchGenerator
import sys
import tensorflow as tf
import scipy.io
import numpy as np
from sklearn.model_selection import KFold as kf

TRAIN_DATA_PATH = "/home/sanjeev/Documents/HeadMotionData/MocapData/train_data.mat"
TEST_DATA_PATH = "/home/sanjeev/Documents/HeadMotionData/MocapData/test_data.mat"
MODEL_ROOT_LOCATION = "/tmp/models"
MODEL_FILE_PATH_TEMPLATE = "-weights-improvement-{epoch:02d}-{categorical_accuracy:.2f}-{val_categorical_accuracy:.2f}.hdf5"
MODEL_PREFIX = "Mocap-kernel-24-linear-mean"

OPTIMIZER = "adam"
LOSS = "categorical_crossentropy"
METRICS = ["categorical_accuracy"]


def functional_CNN_pool( input_shape, num_classes ):
    motion_input = Input(shape = input_shape, name = "input")
    conv_output = Conv1D(24, 10, activation = 'relu', name = "convolution")(motion_input)
    #lap = AveragePooling1D(pool_size = 120, strides = 120)(motion_input)
    #print(lap.shape)
    global_avg_output = GlobalAveragePooling1D(name = "global_averager")(conv_output)
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

COLUMNS = ["X", "Y", "Z"]
NUM_EPOCHS = 150
LEARNING_RATE = 0.0001
DECAY = 1e-6
MOMENTUM = 0.9
OUT_SIZE = 24 # Number of subjects / classes
NUM_CHANNELS = 3 # Number of features per frame
BATCH_SIZE = 10 # Number of samples in a batch
NUM_SKIP_STEPS = 10 # Number of seconds to skip for generating next sample from the same file
NUM_STEPS = 30 # Duration (in seconds) of a sample
AVG_DURATION_PER_FILE = 300 # Duration (in seconds) of a recording (per person, per recording)
TRAIN_FILES = 6 # Number of files per subject used for training
VALID_FILES = 2 # Number of files per subject used for validation
VFPS = 120

input_shape = (VFPS * NUM_STEPS, NUM_CHANNELS)

#model = functional_CNN_pool(input_shape, OUT_SIZE)
#model.summary();
tr_data=scipy.io.loadmat(TRAIN_DATA_PATH);
test_data=scipy.io.loadmat(TEST_DATA_PATH);

x_train=tr_data['data']
y_train=tr_data['labels']
x_test=test_data['data']
y_test=test_data['labels']

print([x_train.shape,y_train.shape,x_test.shape,y_test.shape]);
#filepath = os.path.join(MODEL_ROOT_LOCATION,MODEL_PREFIX + MODEL_FILE_PATH_TEMPLATE)

#checkpoint = ModelCheckpoint(filepath, monitor='val_categorical_accuracy', verbose=1, save_best_only=True, mode='max')
#es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', patience = 20)# - Uncomment this line for early stopping
#callbacks_list = [checkpoint, es]
#mu=np.mean(x_train,axis=1);
#mu=mu[:,np.newaxis,:];
#x_train=x_train-mu;
#mu=np.mean(x_val,axis=1);
#mu=mu[:,np.newaxis,:];
#x_val=x_val-mu;
#splitter = kf(n_splits = 5)
#print(np.sum(y_train, axis = 0))
#for k, (train_idx, valid_idx) in enumerate(splitter.split(x_train, y_train)): #train_idx, valid_idx in splitter.split(x_train, y_train):
#    model = functional_CNN_pool(input_shape, OUT_SIZE)
#    filepath = os.path.join(MODEL_ROOT_LOCATION,MODEL_PREFIX + "-fold-" + str(k) + MODEL_FILE_PATH_TEMPLATE)

#    checkpoint = ModelCheckpoint(filepath, monitor='val_categorical_accuracy', verbose=1, save_best_only=True, mode='max')
#    es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', patience = 20)# - Uncomment this line for early stopping
#    callbacks_list = [checkpoint, es]
#    model.fit(x = x_train[train_idx], y = y_train[train_idx], batch_size=32, epochs=100, callbacks = callbacks_list, validation_data = (x_train[valid_idx], y_train[valid_idx]) );
