#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 29 16:23:27 2019

@author: sanjeev
"""

from keras.models import Sequential
from keras.layers import Conv1D, BatchNormalization, AveragePooling1D, MaxPooling1D, Dense, Activation, Flatten, LSTM, Dropout
from keras import optimizers
from keras.callbacks import ModelCheckpoint, EarlyStopping
import argparse
from rnn_data_generator import KerasRnnBatchGenerator

def rnn(input_shape, num_classes):
    		
    model = Sequential(name='Velocity')
    #LSTM
    model.add(AveragePooling1D(input_shape = input_shape, pool_size = 2, stride = 2))
    model.add(LSTM(units = 64))
    #model.add(Dropout(0.7))
    #FC
    #model.add(Flatten())
    #model.add(Dense(units = 8, activation = 'relu'))
    #model.add(Dense(units = 8, activation = 'relu'))
    model.add(Dense(units=100,activation='softmax'))
    
    #Model compilation	
    opt = optimizers.SGD(lr = learning_rate, decay=decay, momentum=momentum, nesterov=True)
    model.compile(optimizer='adam',loss='categorical_crossentropy',metrics=['categorical_accuracy'])
    	
    return model


num_fc = 64
batch_size = 32
num_epochs = 1500 #best model will be saved before number of epochs reach this value
learning_rate = 0.0001
decay = 1e-6
momentum = 0.9

train_generator_obj = KerasRnnBatchGenerator('/tmp/train_face_coordinates/', 1, 30, skip_steps=1, out_size = 2)
valid_generator_obj = KerasRnnBatchGenerator('/tmp/valid_face_coordinates/', 10, 1, skip_steps=1, out_size = 2)

model = rnn(input_shape=(20, 100),num_classes=2)
model.summary()

model.fit_generator(generator = train_generator_obj.simple_sequence_generator(), epochs = 100, verbose = 2, steps_per_epoch = 60,
                    validation_data = valid_generator_obj.simple_sequence_generator(), validation_steps = 600)
#train_generator_obj = KerasRnnBatchGenerator('/tmp/train_face_coordinates/', 20, 30, skip_steps=1, out_size = 2)

#generator = train_generator_obj.simple_sequence_generator()

#next(generator)
#df = train_generator_obj.motion_data