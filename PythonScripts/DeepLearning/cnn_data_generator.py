#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 26 11:31:24 2019

@author: sanjeev
"""

import keras
from scipy.io import wavfile as wav
import pandas as pd
import numpy as np
import os
import sys
from keras.utils import to_categorical

"""
fps - Frames per second
num_steps - Number of frames in one sample (in seconds)
skip_step - Number of frames to skip before next sample starts (in seconds)
"""
class KerasCnnBatchGenerator(object):
    def __init__(self, audio_data_path, motion_data_path, num_steps, batch_size, fps = 8000, skip_step=0.5, out_size = 1, train = True):
        #List all the files in the path - Both Audio and Motion
        self.audio_data_path = audio_data_path
        self.motion_data_path = motion_data_path
        self.audio_data_files = sorted(os.listdir(self.audio_data_path))
        self.motion_data_files = sorted(os.listdir(self.motion_data_path))
        
        if len(self.audio_data_files) != len(self.motion_data_files):
            sys.exit("Audio and Motion data files should be equal in number")
            
        self.total_files = len(self.audio_data_files)
        self.current_file_idx = 0
        
        self.assign_audio_frame_for_current_file() # Current Audio File's data - Assigned to self.audio_data
        self.assign_motion_frame_for_current_file() # Current Motion File's data - Assigned to self.motion_data
        self.num_steps = int(num_steps * fps)
        self.batch_size = batch_size
        self.fps = fps
        # this will track the progress of the batches sequentially through the
        # data set - once the data reaches the end of the data set it will reset
        # back to zero
        self.current_idx = 0
        # skip_step is the number of words which will be skipped before the next
        # batch is skimmed from the data set
        self.skip_step = skip_step * fps
        self.out_size = out_size

        self.num_steps_sec = num_steps
        self.skip_step_sec = skip_step
        self.median_velocity = self.motion_data["velocity"].median()
        self.mean_velocity = self.motion_data["velocity"].mean()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        self.velocity_buckets = []
        self.sample_counter = 0
        self.train = train
        
    def get_mean_avg_velocities(self):
        velocities = []
        for i in np.arange(0,max(self.motion_data["timestamp"]), self.skip_step_sec):
            relevant_y = self.motion_data[(self.motion_data["timestamp"] >= i) & 
                                              (self.motion_data["end_timestamp"] < i + self.num_steps_sec)]
            velocities.append(relevant_y["velocity"].values.mean())
        self.velocity_buckets = self.smoothen_categories((velocities > np.median(velocities)).astype(int))
        return np.median(velocities)

    def assign_audio_frame_for_current_file(self):
        fps, audio_clip = wav.read(os.path.join(self.audio_data_path, self.audio_data_files[self.current_file_idx]))
        audio_clip = audio_clip / max(np.abs(audio_clip))
        self.audio_data = pd.DataFrame(audio_clip, columns = ["audio"])
        
    def assign_motion_frame_for_current_file(self):
        coords = pd.read_csv(os.path.join(self.motion_data_path, self.motion_data_files[self.current_file_idx]))
        coords["end_timestamp"] = coords[" timestamp"].shift(-1)
        coords["timestamp"] = coords[" timestamp"]
        imp_coords = coords[["timestamp", "end_timestamp", " X_0", " Y_0", " Z_0"]]
        coords = pd.DataFrame(np.asarray(imp_coords), columns = ["timestamp", "end_timestamp", "X_0", "Y_0", "Z_0"])
        coords["velocity"] = (coords["X_0"] - coords["X_0"].shift(-1)) ** 2 + \
                                (coords["Y_0"] - coords["Y_0"].shift(-1)) ** 2 + \
                                (coords["Z_0"] - coords["Z_0"].shift(-1)) ** 2
        coords["velocity"] = np.sqrt(coords["velocity"])
        self.motion_data = coords        

    def assign_angular_frame_for_current_file(self):
        coords = pd.read_csv(os.path.join(self.motion_data_path, self.motion_data_files[self.current_file_idx]))
        coords["end_timestamp"] = coords[" timestamp"].shift(-1)
        coords["timestamp"] = coords[" timestamp"]
        imp_coords = coords[["timestamp", "end_timestamp", " p_rx"]]
        coords = pd.DataFrame(np.asarray(imp_coords), columns = ["timestamp", "end_timestamp", "p_rx"])
        coords["velocity"] = np.abs(coords["p_rx"] - coords["p_rx"].shift(-1)) 
        self.motion_data = coords  
        
    def generate(self):
        x = np.zeros((self.batch_size, self.num_steps, 1))
        y = np.zeros((self.batch_size, self.out_size))
        while True:
            for i in range(self.batch_size):
                if self.current_idx + self.num_steps >= len(self.audio_data):
                    # reset the index back to the start of the data set
                    self.current_idx = 0
                    self.current_file_idx = (self.current_file_idx + 1) % self.total_files
                    self.assign_audio_frame_for_current_file()
                    self.assign_motion_frame_for_current_file()
                    
                    self.median_velocity = self.motion_data["velocity"].median()
                    self.mean_velocity = self.motion_data["velocity"].mean()
                    self.median_avg_velocities = self.get_mean_avg_velocities()
                    
                x[i, :, :] = self.audio_data.loc[self.current_idx:self.current_idx + self.num_steps - 1]["audio"].values.reshape((-1,1))
                current_idx_sec = self.current_idx / self.fps
                relevant_y = self.motion_data[(self.motion_data["timestamp"] >= current_idx_sec) & 
                                              (self.motion_data["end_timestamp"] < current_idx_sec + self.num_steps_sec)]
                
                y[i, :] = to_categorical(int(relevant_y["velocity"].values.mean() > self.median_avg_velocities), num_classes = 2)
                self.current_idx += self.skip_step
            yield x, y
       
    def smoothen_categories(self, arr, cts_length = 3):
        i = 0
        current_value = arr[i]
        rewrite = False
        while i <= len(arr) - cts_length:
            if arr[i] == current_value:
                i += 1
                continue
            else:
                for j in range(cts_length):
                    if arr[i + j] == current_value:
                        rewrite = True
                        break
                if rewrite:
                    for j in range(cts_length):
                        arr[i + j] = current_value
                    rewrite = False
                else:
                    current_value = arr[i]
                i = i + cts_length
        return arr
            
                
                        
    def generate_angular_data(self):
        x = np.zeros((self.batch_size, self.num_steps, 1))
        y = np.zeros((self.batch_size, self.out_size))
        self.assign_angular_frame_for_current_file()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        while True:
            for i in range(self.batch_size):
                if self.current_idx + self.num_steps >= len(self.audio_data):
                    # reset the index back to the start of the data set
                    self.current_idx = 0
                    self.current_file_idx = (self.current_file_idx + 1) % self.total_files
                    self.assign_audio_frame_for_current_file()
                    self.assign_angular_frame_for_current_file()
                    
                    self.median_velocity = self.motion_data["velocity"].median()
                    self.mean_velocity = self.motion_data["velocity"].mean()
                    self.median_avg_velocities = self.get_mean_avg_velocities()
                    self.sample_counter = 0
                    
                x[i, :, :] = self.audio_data.loc[self.current_idx:self.current_idx + self.num_steps - 1]["audio"].values.reshape((-1,1))
                current_idx_sec = self.current_idx / self.fps
                relevant_y = self.motion_data[(self.motion_data["timestamp"] >= current_idx_sec) & 
                                              (self.motion_data["end_timestamp"] < current_idx_sec + self.num_steps_sec)]
                if not self.train:
                    y[i, :] = to_categorical(int(relevant_y["velocity"].values.mean() > self.median_avg_velocities), num_classes = 2)
                else:
                    y[i, :] = to_categorical( self.velocity_buckets[self.sample_counter], num_classes = 2)
                    
                self.sample_counter += 1
                self.current_idx += self.skip_step
            yield x, y