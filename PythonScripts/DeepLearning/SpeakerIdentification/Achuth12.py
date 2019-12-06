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
def functional_CNN_pool():
    motion_input = Input(shape = (3600,3), name = "input")
    conv_output = Conv1D(24, 10, activation = 'relu', name = "convolution")(motion_input)
    #lap = AveragePooling1D(pool_size = 120, strides = 120)(motion_input)
    #print(lap.shape)
    global_avg_output = GlobalAveragePooling1D(name = "global_averager")(conv_output)
    #global_avg_output = Flatten()(lap)
    softmax_output = Dense(24, activation = 'softmax', name = "final_predictor")(global_avg_output)
    model = Model(inputs = [motion_input], outputs = [softmax_output])
    model.compile(optimizer='adam',loss=['categorical_crossentropy'],metrics=['categorical_accuracy'])
    return model


def functional_LSTM():
    motion_input = Input(shape = (3600,3), name = "input")
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


model = functional_CNN_pool()
model.summary();
tr_data=scipy.io.loadmat('./Achuth_data/tr_data.mat');
val_data=scipy.io.loadmat('./Achuth_data/val_data.mat');

x_train=tr_data['trdata']
y_train=tr_data['trlabels']
x_val=val_data['trdata']
y_val=val_data['trlabels']
print([x_train.shape,y_train.shape,x_val.shape,y_val.shape]);
checkpoint = ModelCheckpoint('./Achuth_data/best_model', monitor='val_categorical_accuracy', verbose=1, save_best_only=True, mode='max')
es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', patience = 20)# - Uncomment this line for early stopping
callbacks_list = [checkpoint, es]
mu=np.mean(x_train,axis=1);
mu=mu[:,np.newaxis,:];
x_train=x_train-mu;
mu=np.mean(x_val,axis=1);
mu=mu[:,np.newaxis,:];
x_val=x_val-mu;
model.fit(x=x_train,y=y_train,batch_size=32,epochs=100,callbacks=callbacks_list,validation_data=(x_val,y_val));
