#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep  2 08:53:19 2019

@author: sanjeev
"""

import keras
from scipy.io import wavfile as wav
import pandas as pd
import numpy as np
import os
import sys
from keras.utils import to_categorical

class Speaker(object):
    def __init__(self, speaker_id, motion_data_folder, num_steps_motion, skip_steps_motion):
        self.speaker_id = speaker_id
        self.motion_data_folder = motion_data_folder
#        self.skip_steps_motion = skip_steps_motion
#        self.num_steps_motion = num_steps_motion
        self.motion_data_files = sorted(os.listdir(self.motion_data_folder))
        self.total_motion_files = len(self.motion_data_files)
        self.current_file_idx = 0
        self.current_file_offset = 0
        self.motion_data = pd.DataFrame()
        self.assign_motion_frame_for_current_file() # Current Motion File's data - Assigned to self.motion_data
     
    def assign_motion_frame_for_current_file(self):
        df = pd.read_csv(os.path.join(self.motion_data_folder, self.motion_data_files[self.current_file_idx]))
        self.motion_data = df 
        
    def return_sample(self, num_steps_motion, skip_steps_motion, column_names, num_classes):
        if self.current_file_offset + num_steps_motion >= self.motion_data.shape[0]:
            self.current_file_idx = (self.current_file_idx + 1) % self.total_motion_files
            self.current_file_offset = 0
            self.assign_motion_frame_for_current_file()
        x = np.array(self.motion_data.loc[self.current_file_offset : self.current_file_offset + 
                                          num_steps_motion - 1][column_names]).reshape(1, -1, len(column_names))
        y = to_categorical(self.speaker_id, num_classes = num_classes)
        #y = to_categorical(np.random.randint(num_classes), num_classes = num_classes)
        return x, y
"""
fps - Frames per second
num_steps - Number of frames in one sample (in seconds) - Should be a multiple of LCM of (1 / fps, 1 / vfps)
skip_steps - Number of frames to skip before next sample starts (in seconds) - Should be a multiple of LCM of (1 / fps, 1 / vfps)
"""
class SpeakerIdentificationBatchGenerator(object):
    def __init__(self, motion_data_path, num_steps, batch_size = 10, vfps = 25, skip_steps=0.5, out_size = 2, input_channels = 1, train = True):
        #List all the files in the path - Both Audio and Motion
        self.motion_data_path = motion_data_path
        self.vfps = vfps
        self.batch_size = batch_size
        self.input_channels = input_channels
        self.out_size = out_size
    
        self.motion_data_folders = sorted(os.listdir(self.motion_data_path))
        
            
        LCM  = 1 / self.vfps
        if (round(num_steps / LCM, 1) % 1 != 0.0):
            sys.exit("num_steps should be a multiple of LCM of (1 / fps, 1 / vfps)")
            
        if (round(skip_steps / LCM, 1) % 1 != 0.0):
            sys.exit("skip_steps should be a multiple of LCM of (1 / fps, 1 / vfps)")
            
        #self.total_speakers = len(self.motion_data_folders)
        #if self.total_speakers != self.out_size:
        #    sys.exit("total_folders in the motion_data_path should be equal to out_size")
            
        self.num_steps_motion = int(num_steps * self.vfps)
        self.skip_steps_motion = int(skip_steps * self.vfps)
        
        # this will track the progress of the batches sequentially through the
        # data set - once the data reaches the end of the data set it will reset
        # back to zero
        self.speaker_counter = 0
        self.speakers = []
        self.initialize_speakers()
        
    def initialize_speakers(self):
        self.speakers = []
        for id_num, mdf in enumerate(self.motion_data_folders):
            self.speakers.append(Speaker(id_num, os.path.join(self.motion_data_path,mdf), self.num_steps_motion, self.skip_steps_motion))
               

            
    """
    Multiple output random input generator
    """        
    def generate_head_motion_data_for_speaker_identification_mul_rand(self, column_names, layers_names, number_of_chunks):
        x = np.zeros((self.batch_size, self.num_steps_motion, self.input_channels))
        y = np.zeros((self.batch_size, self.out_size))
        while True:
            for i in range(self.batch_size):
                    
                x[i, :, :], y[i, :] = self.speakers[np.random.randint(self.out_size)].return_sample(self.num_steps_motion, 
                                             self.skip_steps_motion, column_names, self.out_size)
                #self.speaker_counter = (self.speaker_counter + 1) % self.total_speakers
                
            chunk_output = []
            for i in range(number_of_chunks):
                chunk_output.append(y)
            Y = {}
            #for i in layers_names:
            #    Y[i] = y
            Y["final_predictor"] = y
            Y["chunk_predictor"] = y#np.array(chunk_output).reshape((self.batch_size, -1, self.out_size))
            yield x, Y
        
    """
    Single output random input generator
    """        
    def generate_head_motion_data_for_speaker_identification_sin_rand(self, column_names):
        x = np.zeros((self.batch_size, self.num_steps_motion, self.input_channels))
        y = np.zeros((self.batch_size, self.out_size))
        while True:
            for i in range(self.batch_size):
                    
                x[i, :, :], y[i, :] = self.speakers[np.random.randint(self.out_size)].return_sample(self.num_steps_motion, 
                                             self.skip_steps_motion, column_names, self.out_size)
            x[i, :, :] = x[i, : , :] - np.mean(x[i, :, :], axis = 0) #mean normalization - Comment this line if you do not require mean normalization   
            x[i, :, :] = x[i, :, :] + np.abs(np.min(x[i, :, :], axis = 0)) 
            yield x, y 
            
    """
    Single output Sequential input generator
    """        
    def generate_head_motion_data_for_speaker_identification_sin_seq(self, column_names):
        x = np.zeros((self.batch_size, self.num_steps_motion, self.input_channels))
        y = np.zeros((self.batch_size, self.out_size))
        while True:
            for i in range(self.batch_size):
                    
                x[i, :, :], y[i, :] = self.speakers[self.speaker_counter].return_sample(self.num_steps_motion, 
                                             self.skip_steps_motion, column_names, self.out_size)
                self.speaker_counter = (self.speaker_counter + 1) % self.out_size
                x[i, :, :] = x[i, : , :] - np.mean(x[i, :, :], axis = 0) #mean normalization - Comment this line if you do not require mean normalization
                x[i, :, :] = x[i, :, :] + np.abs(np.min(x[i, :, :], axis = 0))
            yield x, y                    
            
            
               
