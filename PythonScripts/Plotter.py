#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 13 09:56:26 2019

@author: sanjeev
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider
import pandas as pd
from sklearn.preprocessing import normalize

FACTORS = ["Head-RR",
           "Head-LL",
           "Head-CL",
           "Head-CR",
           "Nose-Down",
           "Nose-Up",]

DIMENSIONS = ["X",
              "Y",
              "Z",]

df = pd.read_csv("/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/TrainingData/2016-05-28_16-17-34_PavanIn_Story1En.csv")
df = df.loc[1:,:]

for f in FACTORS:
    diff_2 = []
    for d in DIMENSIONS:
        diff_2.append((df[f + "-" + d] - df[f + "-" + d].shift(1)) ** 2)
    df[f] = np.sum(np.array(diff_2).T, axis = 1)
    #df[f] = df[f] / np.nanmax(df[f])

df["word_location"] = df["batch_start_time"] + (df["word_start_time"] + df["word_end_time"]) / 2

FACTORS.extend(["interpolated_values_pitch", "interpolated_values_intensity"])
for i in FACTORS:#df.columns[df.dtypes == 'float64']:
    df[i] = (df[i] - np.nanmin(df[i])) / (np.nanmax(df[i]) - np.nanmin(df[i]))
    
fig, ax = plt.subplots(nrows = 1, squeeze = True, sharex = True, sharey = True)
#plt.subplots_adjust(bottom=0.25)

t = df["Time"]#np.arange(0.0, 100.0, 0.05)

for n, f in enumerate(FACTORS):
    ax.plot(t, df[f] + n)    
    
ax.plot(t, df["interpolated_values_pitch"] + 6)
ax.plot(t, df["interpolated_values_intensity"] + 7)
#s = 100 * np.sin(2*np.pi*t)
#l, = ax[1].plot(t,s)
plt.axis([20, 30, 0, 8])

axcolor = 'lightgoldenrodyellow'
axpos = plt.axes([0.2, 0.05, 0.65, 0.03], facecolor=axcolor)

sposx = Slider(axpos, 'Pos - X', 0, 300, valstep = 1)

def update(val):
    posx = sposx.val
    ax.axis([posx,posx+ 10, 0,8])#posy,posy + 0.1])
    fig.canvas.draw_idle()

sposx.on_changed(update)
sposy.on_changed(update)

for i in pd.DataFrame(sorted(filter(lambda x : np.isnan(x[1]) == False, zip(df["Time"], df["sentences"])), key = lambda x: x[0]), columns = ["Time", "col"]).groupby("col").max()["Time"]:
    ax.axvline(x = i, ls = '-', color = 'red', linewidth = 3.0)

for i in pd.DataFrame(sorted(filter(lambda x : np.isnan(x[1]) == False, zip(df["Time"], df["sentences"])), key = lambda x: x[0]), columns = ["Time", "col"]).groupby("col").min()["Time"]:
    ax.axvline(x = i, ls = '--', color = 'red', linewidth = 3.0)   
    
word_end_points = []
word_start_points = []
words = []
for i, j in pd.DataFrame(sorted(filter(lambda x : np.isnan(x[1]) == False, zip(df["Time"], df["word_location"], df["sentences"], df["word"])), key = lambda x: x[0]), columns = ["Time", "col", "sentences", "word"]).groupby(["col"]):
    max_sen = max(j["sentences"])
    ts = j["Time"][j["sentences"] == max_sen]
    word_end_points.append(max(ts))
    word_start_points.append(min(ts))
    words.append(j["word"].values[0])
    
for i, j in zip(word_start_points, word_end_points):
    ax.axvline(x = i, ls = '--', color = 'green')
    ax.axvline(x = j, ls = '-', color = 'green')

for n, i in enumerate(zip(words, word_start_points, word_end_points)):
#for i in set(zip(df["word"],df["word_start_time"], df["word_end_time"], df["batch_start_time"])):
        ax.text(x = (i[1] + i[2]) / 2, y = n % 8 + 0.5, s = i[0])
plt.show()
#pd.DataFrame(sorted(filter(lambda x : np.isnan(x[1]) == False, zip(df["Time"], df["word_location"])), key = lambda x: x[0]), columns = ["Time", "col"]).groupby("col").max()

