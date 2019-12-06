#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu May  2 20:10:38 2019

@author: sanjeev
"""

import argparse
import pandas as pd
import numpy as np
import math
import scipy.signal as signal
import sys, os

def resample_by_interpolation(signal, input_fs, output_fs):

    scale = output_fs / input_fs
    # calculate new length of sample
    n = round(len(signal) * scale)

    # use linear interpolation
    # endpoint keyword means than linspace doesn't go all the way to 1.0
    # If it did, there are some off-by-one errors
    # e.g. scale=2.0, [1,2,3] should go to [1,1.5,2,2.5,3,3]
    # but with endpoint=True, we get [1,1.4,1.8,2.2,2.6,3]
    # Both are OK, but since resampling will often involve
    # exact ratios (i.e. for 44100 to 22050 or vice versa)
    # using endpoint=False gets less noise in the resampled sound
    resampled_signal = np.interp(
        np.linspace(0.0, 1.0, n, endpoint=False),  # where to interpret
        np.linspace(0.0, 1.0, len(signal), endpoint=False),  # known positions
        signal,  # known data points
    )
    return resampled_signal

"""
Function to compute the first order derivative
Input: arr (RxC); window_size - Size of the window to smoothen the derivative
Output: y - Array (RxC) consisting of derivatives
y(n) =  (sum_{i=1}^{N} i*(x(n+i)-x(n-i))) / (2* sum_{i=1}^{N} i^2)
"""
def compute_first_derivative(arr, window_size):
    R,C = arr.shape
    y = np.zeros(arr.shape)
    first_row = np.reshape(arr[0], (1,C))
    last_row = np.reshape(arr[-1], (1,C))
#    print(first_row.shape, last_row.shape, arr_shape)
    helper_matrix = np.concatenate((np.repeat(first_row, window_size, axis = 0),
                                   arr, np.repeat(last_row, window_size, axis = 0)), axis = 0)
    #return helper_matrix
    for i in range(window_size):
        st_after = window_size + i
        st_before = window_size - i
        y = y + (helper_matrix[st_after:st_after +  R, :] -
                helper_matrix[st_before:st_before + R, :]) * i

    factor = window_size * (window_size + 1) * (2 * window_size + 1) / 3
    return y/factor

"""
Calls compute_first_derivative `n` times to compute nth derivative
"""
def compute_n_derivative(arr, n, window_size):
    derivative = np.copy(arr)
    for i in range(n):
        derivative = compute_first_derivative(derivative, window_size)
    return derivative

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-i", "--input", help = "Example: Input Location", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/Misc/prosody_test.csv")
    parser.add_argument("-o", "--output", help = "Example: Output Location", required = False, default = "/tmp/prosody_features_extractor_test.csv")
    parser.add_argument("-w", "--window_size", help = "Window length for computing derivative", required = False, default = 2)
    parser.add_argument("-p", "--python", help = "Python Scripts folder", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/gesturesynthesis/PythonScripts")

    argument = parser.parse_args()
    
    sys.path.append(argument.python)
    import project_constants as pc

    WINDOW_SIZE = int(argument.window_size)
    FS_OUT = 120
    FS_IN = 60
    
    prosody_df = pd.read_csv(argument.input).replace("--undefined--", np.nan).astype(float)
    
    #Interpolates pitch and intensity values to fill the undefined values
    values_pitch = np.array(list(filter(lambda row : np.isnan(row[1]) == False, np.array(prosody_df[[pc.TIME, pc.PITCH]]))))
    prosody_df[pc.INTERPOLATED_VALUES_PITCH] = np.interp(prosody_df[pc.TIME], values_pitch[:,0], values_pitch[:,1])

    values_intensity = np.array(list(filter(lambda row : np.isnan(row[1]) ==  False, np.array(prosody_df[[pc.TIME, pc.INTENSITY]]))))
    prosody_df[pc.INTERPOLATED_VALUES_INTENSITY] = np.interp(prosody_df["Time"],values_intensity[:,0], values_intensity[:,1])

    #Computes first and second derivatives of pitch and intensity
    prosody_df[pc.FIRST_DERIVATIVE_PITCH] = compute_first_derivative(prosody_df[pc.INTERPOLATED_VALUES_PITCH].values.reshape(-1,1), WINDOW_SIZE)
    prosody_df[pc.SECOND_DERIVATIVE_PITCH] = compute_first_derivative(prosody_df[pc.FIRST_DERIVATIVE_PITCH].values.reshape(-1,1), WINDOW_SIZE)

    prosody_df[pc.FIRST_DERIVATIVE_INTENSITY] = compute_first_derivative(prosody_df[pc.INTERPOLATED_VALUES_INTENSITY].values.reshape(-1,1), WINDOW_SIZE)
    prosody_df[pc.SECOND_DERIVATIVE_INTENSITY] = compute_first_derivative(prosody_df[pc.FIRST_DERIVATIVE_INTENSITY].values.reshape(-1,1), WINDOW_SIZE)


    #Resample the prosody features to equal the framing rate of the MOCAP
    #resampled_data = signal.resample_poly(concatenated_data, up = FS_OUT, down = FS_IN)
    resampled_data = []
    for col_name in prosody_df.columns:
        resampled_data.append(resample_by_interpolation(prosody_df[col_name], FS_IN, FS_OUT))
    resampled_data = np.array(resampled_data).T
    
    df = pd.DataFrame(resampled_data, columns = prosody_df.columns) #.fillna(0)

    df.to_csv(argument.output,index = False)
