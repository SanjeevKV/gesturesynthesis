#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 27 12:27:22 2019

@author: sanjeev
"""
import os

os.environ["CUDA_DEVICE_ORDER"]="PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"]="2"

from keras.models import Sequential
from keras.layers import Bidirectional, TimeDistributed, GlobalAveragePooling1D, SpatialDropout1D, Conv1D, BatchNormalization, MaxPooling1D, Dense, Activation, Flatten, LSTM, Dropout
from keras import optimizers
from keras.callbacks import ModelCheckpoint, EarlyStopping
from keras.metrics import top_k_categorical_accuracy
import argparse
from speaker_identification_data_generator import SpeakerIdentificationBatchGenerator
import sys

def cnn1d(input_shape, num_classes):
    CONV_1D_KERNEL_SIZE = 3
    model = Sequential(name='Emo1D')
    	
    # LFLB1
    model.add(Conv1D(filters = 32,kernel_size = (CONV_1D_KERNEL_SIZE),strides=1,padding='same',data_format='channels_last',input_shape=input_shape))	
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    model.add(MaxPooling1D(pool_size = 4, strides = 2))
    model.add(SpatialDropout1D(0.5))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 128)))
    
    #LFLB2
    model.add(Conv1D(filters=32, kernel_size = CONV_1D_KERNEL_SIZE, strides=1,padding='same'))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    model.add(MaxPooling1D(pool_size = 4, strides = 2))
    model.add(SpatialDropout1D(0.5))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 128)))
    
    #LFLB3
    #model.add(Conv1D(filters=128, kernel_size = CONV_1D_KERNEL_SIZE, strides=1,padding='same'))
    #model.add(BatchNormalization())
    #model.add(Activation('relu'))
    #model.add(MaxPooling1D(pool_size = 4, strides = 2))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 256)))
    
    #LFLB4
    #model.add(Conv1D(filters=128, kernel_size = CONV_1D_KERNEL_SIZE, strides=1,padding='same'))
    #model.add(BatchNormalization())
    #model.add(Activation('relu'))
    #model.add(MaxPooling1D(pool_size = 4, strides = 2))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 256)))
    		
    #LSTM
    model.add(LSTM(units = lstm_out_units))
    #model.add(Dropout(0.7))
    #FC
    #model.add(Flatten())
    #model.add(Dense(units = 8, activation = 'relu'))
    #model.add(Dense(units = 8, activation = 'relu'))
    model.add(Dense(units=num_classes,activation='softmax'))
    
    #Model compilation	
    #opt = optimizers.SGD(lr = learning_rate, decay=decay, momentum=momentum, nesterov=True)
    #top_k = top_k_categorical_accuracy(k = 5)
    model.compile(optimizer='adam',loss='categorical_crossentropy',metrics=['categorical_accuracy', top_k_accuracy])
    	
    return model

def lstm_lstm(input_shape, num_classes):
    CONV_1D_KERNEL_SIZE = 3
    model = Sequential()
    #1 LSTM
    #model.add(Conv1D(filters = 32,kernel_size = (CONV_1D_KERNEL_SIZE),strides=1,padding='same',data_format='channels_last',input_shape=input_shape))
    #model.add(BatchNormalization())
    #model.add(Activation('relu'))
    #model.add(MaxPooling1D(pool_size = 4, strides = 2))

    #2 LSTM
    #model.add(Conv1D(filters = 32,kernel_size = (CONV_1D_KERNEL_SIZE),strides=1,padding='same',data_format='channels_last'))
    #model.add(BatchNormalization())
    #model.add(Activation('relu'))
    #model.add(MaxPooling1D(pool_size = 4, strides = 2))

    model.add(LSTM(150, return_sequences=True,activation='sigmoid', input_shape = input_shape))  # returns a sequence of vectors of dimension 32
    model.add(Bidirectional(LSTM(150, return_sequences=True,activation='sigmoid')))  # returns a sequence of vectors of dimension 32
    model.add(TimeDistributed(Dense(100, activation='tanh')))
    model.add(GlobalAveragePooling1D())
    model.add(Dense(num_classes, activation='softmax'))
    model.compile(optimizer='adam', loss='categorical_crossentropy',metrics=['accuracy', 'categorical_accuracy'])
    return model

def top_k_accuracy(y_true, y_pred):
    return top_k_categorical_accuracy(y_true, y_pred, k=5)

lstm_out_units = 64
num_epochs = 150 #best model will be saved before number of epochs reach this value
learning_rate = 0.0001
decay = 1e-6
momentum = 0.9

out_size = 24
channels = 3
batch_size = 24

train_generator_obj = SpeakerIdentificationBatchGenerator('/home2/data/Sanjeev/data/CoordinatesData/train', num_steps = 10, batch_size = batch_size, skip_steps=10, out_size = out_size, input_channels = channels)
valid_generator_obj = SpeakerIdentificationBatchGenerator('/home2/data/Sanjeev/data/CoordinatesData/valid', num_steps = 10, batch_size = batch_size, skip_steps=10, out_size = out_size, input_channels = channels)

model = lstm_lstm(input_shape=(train_generator_obj.num_steps_motion, channels),num_classes=out_size)
model.summary()
#sys.exit()
filepath="/home2/data/Sanjeev/models/speaker-identification-2019-09-03/10-weights-improvement-{epoch:02d}-{categorical_accuracy:.2f}-{val_categorical_accuracy:.2f}.hdf5"
checkpoint = ModelCheckpoint(filepath, monitor='categorical_accuracy', verbose=1, save_best_only=True, mode='max')
#es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', verbose = 1, min_delta = 5)
callbacks_list = [checkpoint]

model.fit_generator(generator = train_generator_obj.generate_head_motion_data_for_speaker_identification([" p_rx", " p_ry", " p_rz"]), epochs = 150, verbose = 2, steps_per_epoch = 540,
                    validation_data = valid_generator_obj.generate_head_motion_data_for_speaker_identification([" p_rx", " p_ry", " p_rz"]), validation_steps = 180, callbacks = callbacks_list)
