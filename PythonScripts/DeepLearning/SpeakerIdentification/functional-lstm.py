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
from keras.layers import CuDNNLSTM, Concatenate, Lambda, Reshape, Input, Bidirectional, TimeDistributed, GlobalAveragePooling1D, SpatialDropout1D, Conv1D, BatchNormalization, MaxPooling1D, Dense, Activation, Flatten, LSTM, Dropout
from keras import optimizers
from keras.callbacks import ModelCheckpoint, EarlyStopping
from keras.metrics import top_k_categorical_accuracy
import argparse
from speaker_identification_data_generator import SpeakerIdentificationBatchGenerator
import sys
import tensorflow as tf

def functional_lstm(input_shape, num_classes):
    #def extractor(tensor):
    #    return tensor[:,i,:,:]
    #def extract_shape(input_shapes):
    #    return tuple([input_shapes[2], input_shapes[3]])
    
    motion_input = Input(shape = input_shape)
    lst = list(input_shape)
    lst.append(int(input_shape[0] / number_of_chunks))
    lst[0] = number_of_chunks
    lst[-1], lst[-2] = lst[-2], lst[-1]
    print(lst)
    reshaped_input = Reshape(tuple(lst))(motion_input)
    lstm_output_chunks = []
    lstm_prediction_chunks = []
    lstm = LSTM(32)
    dense = Dense(num_classes, activation = 'sigmoid', name = "chunk_predictor")
    for i in range(number_of_chunks):
        #extract_layers.append(Lambda(extractor))
        sliced_time_chunk = Lambda(lambda x: x[:,i,:,:])(reshaped_input)
        lstm_output_chunk = lstm(sliced_time_chunk)
        lstm_output_chunks.append(lstm_output_chunk)
        lstm_prediction = dense(lstm_output_chunk)
        lstm_prediction_chunks.append(lstm_prediction)
        
        
    #output = extract_layers[5](reshaped_input)
    summary = Reshape((lst[0], -1))(Concatenate(axis = -1)(lstm_output_chunks))
    lstm_prediction = LSTM(num_classes, activation = 'sigmoid', name = 'final_predictor')(summary)
    model = Model(inputs = [motion_input], outputs = [lstm_prediction, *lstm_prediction_chunks])#[lstm_prediction, *lstm_prediction_chunks])
    model.compile(optimizer='adam',loss='categorical_crossentropy',metrics=['categorical_accuracy'])
    return model

def functional_lstm_global_pooling(input_shape, num_classes):
    #def extractor(tensor):
    #    return tensor[:,i,:,:]
    #def extract_shape(input_shapes):
    #    return tuple([input_shapes[2], input_shapes[3]])  
    motion_input = Input(shape = input_shape)
    lstm =  CuDNNLSTM(32, return_sequences = True)(motion_input)
    avg_output = GlobalAveragePooling1D()(lstm)
    dense = Dense(units = 32, activation = 'relu')(avg_output)
    output = Dense(units = num_classes, activation = 'softmax')(dense)
    #layer = Lambda(lambda x : tf.nn.moments(x, axes = [1]))
    #output = layer(lstm)        
    
    model = Model(inputs = [motion_input], outputs = [output])#[lstm_prediction, *lstm_prediction_chunks])
    model.compile(optimizer='adam',loss='categorical_crossentropy',metrics=['categorical_accuracy'])
    return model

def top_k_accuracy(y_true, y_pred):
    return top_k_categorical_accuracy(y_true, y_pred, k=5)

lstm_out_units = 64
num_epochs = 150 #best model will be saved before number of epochs reach this value
learning_rate = 0.0001
decay = 1e-6
momentum = 0.9

columns = [" pose_Rx", " pose_Ry", " pose_Rz"]
layers_names = ["chunk_predictor", "final_predictor"]

out_size = 5
channels = 3
batch_size = 10
number_of_chunks = 30

train_generator_obj = SpeakerIdentificationBatchGenerator('/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/CoordinatesData/train', num_steps = 30, batch_size = batch_size, skip_steps=10, out_size = out_size, input_channels = channels)
valid_generator_obj = SpeakerIdentificationBatchGenerator('/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/CoordinatesData/valid', num_steps = 30, batch_size = batch_size, skip_steps=10, out_size = out_size, input_channels = channels)

model = functional_lstm_global_pooling(input_shape=(train_generator_obj.num_steps_motion, channels),num_classes=out_size)
model.summary()
#sys.exit()
#filepath="/tmp/models/10-weights-improvement-{epoch:02d}-{final_predictor_categorical_accuracy:.2f}-{val_final_predictor_categorical_accuracy:.2f}.hdf5"
#checkpoint = ModelCheckpoint(filepath, monitor='val_final_predictor_categorical_accuracy', verbose=1, save_best_only=True, mode='max')
#es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', verbose = 1, min_delta = 5)
#callbacks_list = [checkpoint]

#model.fit_generator(generator = train_generator_obj.generate_head_motion_data_for_speaker_identification(column_names = columns, layers_names = layers_names, number_of_chunks = number_of_chunks), epochs = 150, verbose = 2, steps_per_epoch = 540,
#                    validation_data = valid_generator_obj.generate_head_motion_data_for_speaker_identification(column_names = columns, layers_names = layers_names, number_of_chunks = number_of_chunks), validation_steps = 180, callbacks = callbacks_list)
