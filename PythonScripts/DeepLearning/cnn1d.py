#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 27 12:27:22 2019

@author: sanjeev
"""

from keras.models import Sequential
from keras.layers import Conv1D, BatchNormalization, MaxPooling1D, Dense, Activation, Flatten, LSTM, Dropout
from keras import optimizers
from keras.callbacks import ModelCheckpoint, EarlyStopping
import argparse
from cnn_data_generator import KerasCnnBatchGenerator

def cnn1d(input_shape, num_classes):
    CONV_1D_KERNEL_SIZE = 20
    model = Sequential(name='Emo1D')
    	
    # LFLB1
    model.add(Conv1D(filters = 128,kernel_size = (CONV_1D_KERNEL_SIZE),strides=1,padding='same',data_format='channels_last',input_shape=input_shape))	
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    model.add(MaxPooling1D(pool_size = 4, strides = 4))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 128)))
    
    #LFLB2
    model.add(Conv1D(filters=128, kernel_size = CONV_1D_KERNEL_SIZE, strides=1,padding='same'))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    model.add(MaxPooling1D(pool_size = 4, strides = 4))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 128)))
    
    #LFLB3
    model.add(Conv1D(filters=256, kernel_size = CONV_1D_KERNEL_SIZE, strides=1,padding='same'))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    model.add(MaxPooling1D(pool_size = 4, strides = 4))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 256)))
    
    #LFLB4
    model.add(Conv1D(filters=256, kernel_size = CONV_1D_KERNEL_SIZE, strides=1,padding='same'))
    model.add(BatchNormalization())
    model.add(Activation('relu'))
    model.add(MaxPooling1D(pool_size = 4, strides = 4))
    #model.add(Dropout(0.7, noise_shape = (None, 1, 256)))
    		
    #LSTM
    model.add(LSTM(units = 64))
    #model.add(Dropout(0.7))
    #FC
    #model.add(Flatten())
    #model.add(Dense(units = 8, activation = 'relu'))
    #model.add(Dense(units = 8, activation = 'relu'))
    model.add(Dense(units=num_classes,activation='softmax'))
    
    #Model compilation	
    opt = optimizers.SGD(lr = learning_rate, decay=decay, momentum=momentum, nesterov=True)
    model.compile(optimizer=opt,loss='categorical_crossentropy',metrics=['categorical_accuracy'])
    	
    return model

num_fc = 64
batch_size = 32
num_epochs = 1500 #best model will be saved before number of epochs reach this value
learning_rate = 0.0001
decay = 1e-6
momentum = 0.9

train_generator_obj = KerasCnnBatchGenerator('/tmp/train_face_audio/', '/tmp/train_face_coordinates/', 1, 30, fps = 8000, skip_step=1, out_size = 2)
valid_generator_obj = KerasCnnBatchGenerator('/tmp/valid_face_audio/', '/tmp/valid_face_coordinates/', 10, 1, fps = 8000, skip_step=10, out_size = 2)

model = cnn1d(input_shape=(train_generator_obj.num_steps, 1),num_classes=2)
model.summary()

filepath="weights-improvement-{epoch:02d}-{val_acc:.2f}.hdf5"
checkpoint = ModelCheckpoint(filepath, monitor='val_acc', verbose=1, save_best_only=True, mode='max')
es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', verbose = 1, min_delta = 5)
callbacks_list = [checkpoint, es]

model.fit_generator(generator = train_generator_obj.generate_angular_data(), epochs = 150, verbose = 2, steps_per_epoch = 60,
                    validation_data = valid_generator_obj.generate_angular_data(), validation_steps = 60, callbacks = callbacks_list)  


generator_ang = train_generator_obj.generate_angular_data()
next(generator_ang)