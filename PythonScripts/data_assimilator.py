#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon May 20 09:08:09 2019

@author: sanjeev
"""

import argparse
from scipy.io import loadmat
from scipy import stats
import pandas as pd
from pandasql import sqldf
import numpy as np
from collections import Counter
import os

"""
Takes a series of timestamps as the input and maps every frame as -1 if it is not the corresponding region.
Annotates with corresponding counter value for spoken and silent regions.
"""
def annotate_spoken_regions(sr):
    length = len(sr)
    prev_occ = -2
    spoken_regions = []
    silent_regions = []
    prev_occ_sil = False
    sil_rc = 0
    src = 0 #Spoken Region Counter
    for i in range(length):
        #If series is nan, then it falls in the silent region
        if np.isnan(sr[i]) == True:
            spoken_regions.append(-1)
            if prev_occ_sil == True:
                silent_regions.append(sil_rc)
            else:
                sil_rc += 1
                prev_occ_sil = True
                silent_regions.append(sil_rc)
        else:
            prev_occ_sil = False
            silent_regions.append(-1)
            #If series is in the spoken region and equal to previous start_time, keep the same counter
            if(sr[i] == prev_occ):
                spoken_regions.append(src)
            #If the start time has changed, it is src is increased by 1    
            else:
                src += 1
                prev_occ = sr[i]
                spoken_regions.append(src)
    return spoken_regions, silent_regions

"""
Takes a series (iterator) of Booleans as input. Creates a counter for False values. Annotates -1 for all the True values
"""
def annotate_sentence_numbers(sr):
    length = len(sr)
    sc = 0
    new_sentence = False
    sentences = []
    for i in range(length):
        if sr[i] == True:
            sentences.append(-1)
            new_sentence = True
        else:
            if new_sentence == True:
                new_sentence = False
                sc += 1    
            sentences.append(sc)       
    return sentences

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description = "Description for my parser")
    parser.add_argument("-e", "--euler", help = "Euler Angles Location", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/EulerAngles/2016-05-28_16-17-34_PavanIn_Story1En.mat")
    parser.add_argument("-p", "--prosody", help = "Prosody location", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/ProsodyData-PitchIntensity/2016-05-28_16-17-34_PavanIn_Story1En.csv")
    parser.add_argument("-d", "--delay", help = "Delay (Audio Peak - Prosody Peak)", required = False, default = '/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/Delay/2016-05-28_16-17-34_PavanIn_Story1En.txt')
    parser.add_argument("-o", "--output", help = "Concatenated Output location", required = False, default = '/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/TrainingData/2016-05-28_16-17-34_PavanIn_Story1En.csv')
    parser.add_argument("-c", "--coordinates", help = "Location of Coordinates", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/Coordinates/2016-05-28_16-17-34_PavanIn_Story1En.mat")
    parser.add_argument("-s", "--sad", help = "Speech Activity Detection", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/SAD/2016-05-28_16-17-34_PavanIn_Story1En.csv")
    parser.add_argument("-f", "--faw", help = "Force aligned words", required = False, default = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/asr_audio_segments/2016-05-28_16-17-34_PavanIn_Story1En.csv")


    argument = parser.parse_args()

    FPS = 120
    SAD_THRESHOLD = 60 #Number of frames - Amounts to (SAD_THRESHOLD / FPS) seconds
    
    #Get Euler angles calculated for every frame
    euler_angles = loadmat(argument.euler)
    euler_angles = euler_angles['data'][:,-6:-3]
    edf = pd.DataFrame(euler_angles, columns = ["X","Y","Z"])
    
    #Get Coordinates for every frame and append it to DF containing Euler Angles
    coordinates = loadmat(argument.coordinates)
    cd = coordinates["markerData"]
    for i in range(0,20,2):
        edf[cd[0][i][0] + "-X"] = cd[0][i + 1][:,0]
        edf[cd[0][i][0] + "-Y"] = cd[0][i + 1][:,1]
        edf[cd[0][i][0] + "-Z"] = cd[0][i + 1][:,2]

    #Get prosody features for it's corresponding frames 
    #REMEMBER: Till now, prosody features and spatial features are not synced with each other
    #However, in the previous script, prosody_features_extractor we resample it to 120 FPS
    prosody_features = pd.read_csv(argument.prosody)

    #Get the delay between prosody and spatial features - Calculated in a MATLAB script
    with open(argument.delay, 'r') as f:
        delay = float(f.read().strip())

    #Neglect (delay * FPS) frames of prosody at the beginning and whatever is extra at the end
    pdf = prosody_features.loc[delay * FPS:,:].reset_index(drop = True).loc[:euler_angles.shape[0],:].reset_index(drop = True)

    #Concatenate the synced up prosody and spatial features
    spdf = pd.concat((pdf,edf), axis = 1)
    
    #Get the SAD output from Kaldi
    ldf = pd.read_csv(argument.sad, sep = " ")
    pysqldf = lambda q: sqldf(q, globals())
    df = pysqldf(
            """
            SELECT * 
            FROM spdf
            LEFT JOIN ldf
            ON ldf.start_time < spdf.time
            AND ldf.end_time >= spdf.time
            """
            )
    df["spoken_regions"], df["silent_regions"] = annotate_spoken_regions(df["start_time"])
    c = Counter(df["silent_regions"]).most_common() #Sort the counter output
    
    sentence_gaps_sr = list(map(lambda x : x[0], filter(lambda x: x[1] >= SAD_THRESHOLD and x[0] != -1 , c))) #Remove silent_regions with counts less than threshold
    df["sentences"] = annotate_sentence_numbers(df["silent_regions"].apply( lambda x : x in sentence_gaps_sr))
    
    # Merge with the force-aligned data only if it is available (processed)
    if os.path.isfile(argument.faw):
        fawdf = pd.read_csv(argument.faw)
        set_sent_num = sorted(set(fawdf["sentence_number"]))
    
        df = pysqldf(
                """
                SELECT * 
                FROM df
                LEFT JOIN fawdf
                ON fawdf.sentence_number <= df.spoken_regions
                AND fawdf.word_start_time + fawdf.batch_start_time <= df.time
                AND fawdf.word_end_time + fawdf.batch_start_time > df.time
                """
                )
    df.to_csv(argument.output, index = False)
