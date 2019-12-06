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
import random

"""
fps - Frames per second
num_steps - Number of frames in one sample (in seconds)
skip_step - Number of frames to skip before next sample starts (in seconds)

Note**: Step duration is equal to skip_steps for sequence prediction
"""
class KerasRnnBatchGenerator(object):
    def __init__(self, motion_data_path, num_steps, batch_size, vfps = 25, skip_steps = 1, step_duration = 1, out_size = 1, train = True):
        #List all the files in the path - Both Audio and Motion
        self.motion_data_path = motion_data_path
        self.motion_data_files = sorted(os.listdir(self.motion_data_path))
        
            
        self.total_files = len(self.motion_data_files)
        self.current_file_idx = 0
        
        self.assign_angular_frame_for_current_file() # Current Motion File's data - Assigned to self.motion_data
        self.batch_size = batch_size
        # this will track the progress of the batches sequentially through the
        # data set - once the data reaches the end of the data set it will reset
        # back to zero
        self.current_idx = 0
        # skip_step is the number of words which will be skipped before the next
        # batch is skimmed from the data set
        self.out_size = out_size
        
        self.skip_steps = skip_steps * vfps
        self.step_duration = step_duration * vfps
        self.num_steps = num_steps * vfps
        self.median_velocity = self.motion_data["velocity"].median()
        self.mean_velocity = self.motion_data["velocity"].mean()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        self.velocity_buckets = []
        self.sample_counter = 0
        self.train = train
        self.motion_duration = 0
        self.vfps = vfps
        
    def get_mean_avg_velocities(self):
        velocities = []
        for i in range(0,len(self.motion_data["timestamp"]) - self.skip_steps, self.skip_steps):
            relevant_y = self.motion_data.loc[i : i + self.skip_steps - 1]
            velocities.append(relevant_y["velocity"].values.mean())
        self.velocity_buckets = (velocities > np.median(velocities)).astype(int)
        return np.median(velocities)
         

    def assign_angular_frame_for_current_file(self):
        coords = pd.read_csv(os.path.join(self.motion_data_path, self.motion_data_files[self.current_file_idx]))
        coords["end_timestamp"] = coords[" timestamp"].shift(-1)
        coords["timestamp"] = coords[" timestamp"]
        imp_coords = coords[["timestamp", "end_timestamp", " p_rx"]]
        coords = pd.DataFrame(np.asarray(imp_coords), columns = ["timestamp", "end_timestamp", "p_rx"])
        coords["velocity"] = np.abs(coords["p_rx"] - coords["p_rx"].shift(-1)) 
        coords["velocity"] = coords["velocity"] / np.max(coords["velocity"]) #normalization
        #print(coords["velocity"].mean())
        self.motion_data = coords  
        self.motion_duration = int(np.max(self.motion_data["timestamp"]))
        
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
            
                
                        
    def generate_angular_data_sequence(self):
        x = np.zeros((self.batch_size, self.num_steps, 1))
        y = np.zeros((self.batch_size, self.out_size))
        self.assign_angular_frame_for_current_file()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        while True:
            for i in range(self.batch_size):
                if self.current_idx + self.num_steps >= len(self.velocity_buckets):
                    # reset the index back to the start of the data set
                    self.current_idx = 0
                    self.current_file_idx = (self.current_file_idx + 1) % self.total_files
                    self.assign_angular_frame_for_current_file()
                    
                    self.median_velocity = self.motion_data["velocity"].median()
                    self.mean_velocity = self.motion_data["velocity"].mean()
                    self.median_avg_velocities = self.get_mean_avg_velocities()
                    self.sample_counter = 0
                    
                #print(self.current_idx, self.current_idx + self.num_steps, len(self.velocity_buckets))
                #print(np.array(self.velocity_buckets[self.current_idx : self.current_idx + self.num_steps]).reshape(-1,1))
                x[i, :, :] = np.array(self.velocity_buckets[self.current_idx : self.current_idx + self.num_steps]).reshape(-1,1)

                y[i, :] = to_categorical( self.velocity_buckets[self.current_idx + self.num_steps], num_classes = 2)
                    
                self.current_idx += self.skip_steps
            yield x, y
            
    def generate_angular_data(self):
        x = np.zeros((self.batch_size, self.num_steps, 1))
        y = np.zeros((self.batch_size, self.out_size))
        self.assign_angular_frame_for_current_file()
        self.median_avg_velocities = self.get_mean_avg_velocities()
        while True:
            for i in range(self.batch_size):
                if (self.current_idx + self.num_steps)  >= self.motion_data.index[-1]:
                    # reset the index back to the start of the data set
                    self.current_idx = 0
                    self.current_file_idx = (self.current_file_idx + 1) % self.total_files
                    self.assign_angular_frame_for_current_file()
                    
                    self.median_velocity = self.motion_data["velocity"].median()
                    self.mean_velocity = self.motion_data["velocity"].mean()
                    self.median_avg_velocities = self.get_mean_avg_velocities()
                    self.sample_counter = 0
                    
                #print(self.current_idx, self.current_idx + self.num_steps, len(self.velocity_buckets))
                #print(np.array(self.velocity_buckets[self.current_idx : self.current_idx + self.num_steps]).reshape(-1,1))
                #print(self.motion_data["velocity"].mean())
                #print(self.current_idx, self.current_idx + self.num_steps, len(self.velocity_buckets), self.motion_data.index[-1])
                #print(self.motion_data.loc[self.current_idx * self.vfps : (self.current_idx + self.num_steps) * self.vfps - 1,:]["velocity"].values.shape)
                x[i, :, :] = np.array(self.motion_data.loc[self.current_idx  : self.current_idx + self.num_steps - 1,:]["velocity"].values).reshape(-1,1)

                y[i, :] = to_categorical( self.velocity_buckets[self.sample_counter], num_classes = 2)
                    
                self.current_idx += self.skip_steps
                self.sample_counter += 1
            yield x, y
            
            
    def simple_sequence_generator(self):
        self.num_steps = 20
        x = np.zeros((self.batch_size, self.num_steps, 100))
        y = np.zeros((self.batch_size, 100))
        while True:
            for i in range(self.batch_size):
                numbers = []
                for j in range(self.num_steps):
                    numbers.append( np.array(to_categorical(random.randint(0, 99), num_classes = 100)) )
                x[i, :, :] = np.array(numbers).reshape(-1,100)
                #for k in numbers:
                #    print(np.argmax(k))
                #print(np.argmax(numbers[-2]))
                y[i, :] = numbers[-2]
            yield x, y