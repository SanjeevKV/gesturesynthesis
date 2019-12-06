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
from shuffle_speaker_identification_data_generator import SpeakerIdentificationBatchGenerator
import sys
import tensorflow as tf

DATA_ROOT_LOCATION = "/home/sanjeev/Documents/HeadMotionData/CommonMocapData"
MODEL_ROOT_LOCATION = "/tmp/models"
MODEL_FILE_PATH_TEMPLATE = "-weights-improvement-{epoch:02d}-{categorical_accuracy:.2f}-{val_categorical_accuracy:.2f}.hdf5"
MODEL_PREFIX = "Mocap-kernel-24-relu-mean-shuffle"

OPTIMIZER = "adam"
LOSS = "categorical_crossentropy"
METRICS = ["categorical_accuracy"]

def functional_CNN_pool(input_shape, num_classes):
    motion_input = Input(shape = input_shape, name = "input")
    conv_output = Conv1D(24, 1, activation = 'relu', name = "convolution")(motion_input)
    #lap = AveragePooling1D(pool_size = 120, strides = 120)(motion_input)
    #print(lap.shape)
    global_avg_output = GlobalAveragePooling1D(name = "global_averager")(conv_output)
    #global_avg_output = Flatten()(lap)
    softmax_output = Dense(num_classes, activation = 'softmax', name = "final_predictor")(global_avg_output)
    model = Model(inputs = [motion_input], outputs = [softmax_output])
    model.compile(optimizer=OPTIMIZER,loss=LOSS,metrics=METRICS)
    return model

def top_k_accuracy(y_true, y_pred):
    return top_k_categorical_accuracy(y_true, y_pred, k=5)

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

train_steps_per_epoch = int( (AVG_DURATION_PER_FILE * TRAIN_FILES * OUT_SIZE) / (NUM_SKIP_STEPS * BATCH_SIZE) )
valid_steps_per_epoch = int( (AVG_DURATION_PER_FILE * VALID_FILES * OUT_SIZE) / (NUM_SKIP_STEPS * BATCH_SIZE) )

generator_obj = SpeakerIdentificationBatchGenerator(DATA_ROOT_LOCATION, vfps = VFPS,  num_steps = NUM_STEPS, batch_size = BATCH_SIZE, skip_steps=NUM_SKIP_STEPS, out_size = OUT_SIZE, input_channels = NUM_CHANNELS, split = [6, 2, 2])

model = functional_CNN_pool(input_shape=(generator_obj.num_steps_motion, NUM_CHANNELS),num_classes=OUT_SIZE)
model.summary()
#sys.exit() # Comment this line if you want to train your model 

filepath = os.path.join(MODEL_ROOT_LOCATION,MODEL_PREFIX + MODEL_FILE_PATH_TEMPLATE)
print(filepath)
checkpoint = ModelCheckpoint(filepath, monitor='val_categorical_accuracy', verbose=1, save_best_only=True, mode='max')
es = EarlyStopping(monitor = 'val_categorical_accuracy', mode = 'max', patience = 20)# - Uncomment this line for early stopping
callbacks_list = [checkpoint, es]

model.fit_generator(generator = generator_obj.generate_head_motion_data_for_speaker_identification_sin_rand(column_names = COLUMNS, dataset_name = "train"), epochs = NUM_EPOCHS, steps_per_epoch = train_steps_per_epoch,
                    validation_data = generator_obj.generate_head_motion_data_for_speaker_identification_sin_rand(column_names = COLUMNS, dataset_name = "valid"), validation_steps = valid_steps_per_epoch, callbacks = callbacks_list)
