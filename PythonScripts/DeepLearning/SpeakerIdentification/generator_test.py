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

generator_obj = SpeakerIdentificationBatchGenerator(DATA_ROOT_LOCATION, vfps = VFPS,  num_steps = NUM_STEPS, batch_size = BATCH_SIZE, skip_steps=NUM_SKIP_STEPS, out_size = OUT_SIZE, input_channels = NUM_CHANNELS, split = [7,2,1])

train_generator = generator_obj.generate_head_motion_data_for_speaker_identification_sin_rand(column_names = COLUMNS, dataset_name = "train")
next(train_generator)

valid_generator = generator_obj.generate_head_motion_data_for_speaker_identification_sin_rand(column_names = COLUMNS, dataset_name = "valid")
next(valid_generator)

test_generator = generator_obj.generate_head_motion_data_for_speaker_identification_sin_rand(column_names = COLUMNS, dataset_name = "test")
next(test_generator)
