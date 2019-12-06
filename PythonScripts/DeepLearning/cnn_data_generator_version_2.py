#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep  1 12:11:34 2019

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
num_steps - Number of frames in one sample (in seconds) - Should be a multiple of LCM of (1 / fps, 1 / vfps)
skip_steps - Number of frames to skip before next sample starts (in seconds) - Should be a multiple of LCM of (1 / fps, 1 / vfps)
"""
class KerasCnnBatchGenerator(object):
    def __init__(self, audio_data_path, motion_data_path, num_steps, batch_size = 10, fps = 8000, vfps = 25, skip_steps=0.5, out_size = 2, input_channels = 1, train = True):
        #List all the files in the path - Both Audio and Motion
        self.audio_data_path = audio_data_path
        self.motion_data_path = motion_data_path
        self.fps = fps
        self.vfps = vfps
        self.batch_size = batch_size
        self.input_channels = input_channels
    
        self.audio_data_files = sorted(os.listdir(self.audio_data_path))
        self.motion_data_files = sorted(os.listdir(self.motion_data_path))
        
        if len(self.audio_data_files) != len(self.motion_data_files):
            sys.exit("Audio and Motion data files should be equal in number")
            
        LCM  = np.lcm(fps, vfps) / (fps * vfps)
        if (round(num_steps / LCM, 1) % 1 != 0.0):
            sys.exit("num_steps should be a multiple of LCM of (1 / fps, 1 / vfps)")
            
        if (round(skip_steps / LCM, 1) % 1 != 0.0):
            sys.exit("skip_steps should be a multiple of LCM of (1 / fps, 1 / vfps)")
            
        self.total_files = len(self.audio_data_files)
        self.current_file_idx = 0
        self.audio_data = pd.DataFrame()
        self.motion_data = pd.DataFrame()
        
        self.assign_audio_frame_for_current_file() # Current Audio File's data - Assigned to self.audio_data
        self.assign_motion_frame_for_current_file() # Current Motion File's data - Assigned to self.motion_data
        self.num_steps_audio = int(num_steps * self.fps)
        self.num_steps_motion = int(num_steps * self.vfps)
        self.skip_steps_audio = int(skip_steps * self.fps)
        self.skip_steps_motion = int(skip_steps * self.vfps)
        
        # this will track the progress of the batches sequentially through the
        # data set - once the data reaches the end of the data set it will reset
        # back to zero
        self.current_idx_audio = 0
        self.current_idx_motion = 0

        self.out_size = out_size

        self.median_velocity = self.motion_data["velocity"].median()
        self.mean_velocity = self.motion_data["velocity"].mean()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        self.velocity_buckets = []
        self.sample_counter = 0
        self.train = train
        
    def get_mean_avg_velocities(self):
        velocities = []
        for i in np.arange(0, len(self.motion_data) - self.num_steps_motion, self.skip_steps_motion):
            relevant_y = self.motion_data.loc[i : i + self.num_steps_motion - 1]
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
        x = np.zeros((self.batch_size, self.num_steps_audio, 1))
        y = np.zeros((self.batch_size, self.out_size))
        self.assign_motion_frame_for_current_file()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        while True:
            for i in range(self.batch_size):
                if self.current_idx_audio + self.num_steps_audio >= len(self.audio_data):
                    # reset the index back to the start of the data set
                    self.current_idx_audio = 0
                    self.current_idx_motion = 0
                    self.current_file_idx = (self.current_file_idx + 1) % self.total_files
                    self.assign_audio_frame_for_current_file()
                    self.assign_motion_frame_for_current_file()
                    
                    self.median_velocity = self.motion_data["velocity"].median()
                    self.mean_velocity = self.motion_data["velocity"].mean()
                    self.median_avg_velocities = self.get_mean_avg_velocities()
                    
                x[i, :, :] = self.audio_data.loc[self.current_idx_audio:self.current_idx_audio + self.num_steps_audio - 1]["audio"].values.reshape((-1,1))
                
                relevant_y = self.motion_data.loc[self.current_idx_motion : self.current_idx_motion + self.skip_steps_motion - 1]
                
                y[i, :] = to_categorical(int(relevant_y["velocity"].values.mean() > self.median_avg_velocities), num_classes = 2)
                self.current_idx_audio += self.skip_steps_audio
                self.current_idx_motion += self.skip_steps_motion
            yield x, y
            
    """
    Takes in a list of numbers. If a number is not succeeded by cts_length of it's same kind (same number)
    it is replaced by the previous number (The continuous series till that point)
    """
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
        x = np.zeros((self.batch_size, self.num_steps_audio, 1))
        y = np.zeros((self.batch_size, self.out_size))
        self.assign_angular_frame_for_current_file()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        while True:
            for i in range(self.batch_size):
                if self.current_idx_audio + self.num_steps_audio >= len(self.audio_data):
                    # reset the index back to the start of the data set
                    self.current_idx_audio = 0
                    self.current_idx_motion = 0
                    self.sample_counter = 0
                    self.current_file_idx = (self.current_file_idx + 1) % self.total_files
                    self.assign_audio_frame_for_current_file()
                    self.assign_angular_frame_for_current_file()
                    
                    self.median_velocity = self.motion_data["velocity"].median()
                    self.mean_velocity = self.motion_data["velocity"].mean()
                    self.median_avg_velocities = self.get_mean_avg_velocities()
                    
                x[i, :, :] = self.audio_data.loc[self.current_idx_audio:self.current_idx_audio + self.num_steps_audio - 1]["audio"].values.reshape((-1,1))
                relevant_y = self.motion_data[self.current_idx_motion : self.current_idx_motion + self.skip_steps_motion - 1]
                if not self.train:
                    y[i, :] = to_categorical(int(relevant_y["velocity"].values.mean() > self.median_avg_velocities), num_classes = 2)
                else:
                    y[i, :] = to_categorical( self.velocity_buckets[self.sample_counter], num_classes = 2)
                    
                self.current_idx_audio += self.skip_steps_audio
                self.current_idx_motion += self.skip_steps_motion
                self.sample_counter += 1
            yield x, y
            
#    def generate_head_motion_data_for_speaker_identification(self):
#        x = np.zeros((self.batch_size, self.num_steps_motion, 1))