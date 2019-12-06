from sklearn.cluster import KMeans as km
import pandas as pd
import numpy as np
import math
import sys
from matplotlib import pyplot as plt

def FindDistance(a, b):
    return np.sqrt(np.sum((a - b) ** 2))

def GetMapping(cs_1, cs_2):
    mapping = {}
    for i, c_1 in enumerate(cs_1):
        cur_min_dist = math.inf
        for j, c_2 in enumerate(cs_2):
            cur_dist = FindDistance(c_1, c_2)
            if cur_dist < cur_min_dist:
                cur_min_dist = cur_dist
                mapping[i] = j
    return mapping                

def GetSubMapping(df):
    unique_pairs = set(zip(df["24"], df["labels"]))
    if len(unique_pairs) != 24:
        #print(unique_pairs)
        sys.exit("Number of pairs does not match with the OUT_SIZE : " + str(len(unique_pairs)) )
    sub_mapping = {}
    for sub, clus in unique_pairs:
        sub_mapping[sub] = clus
    return sub_mapping
    
train_df = pd.read_csv("/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output_train.csv")
valid_df = pd.read_csv("/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output_valid.csv")

OUT_SIZE = 24

kmeans_train = km(n_clusters = OUT_SIZE)
kmeans_valid = km(n_clusters = OUT_SIZE)

#************************** TRAIN - TRAIN *************************************************
#train_len = (len(train_df) * 7) // 10
#kmeans_train.fit(train_df.iloc[:train_len, : -1])
#train_labels = pd.Series(kmeans_train.predict(train_df.iloc[train_len : , : -1]), name = "labels")
##print(train_df.iloc[train_len:, -1].astype(int).reset_index(drop = True), len(train_labels), len(train_df.iloc[train_len:, -1]))
#predicted_df = pd.concat(( train_labels, train_df.iloc[train_len:, -1].astype(int).reset_index(drop = True)), axis =  1) 
#subject_mapping = GetSubMapping(predicted_df)
#print(subject_mapping)

#original_labels = pd.Series(kmeans_train.predict(train_df.iloc[ :train_len , : -1]), name = "labels")
#original_df = pd.concat(( original_labels, train_df.iloc[ : train_len, -1].astype(int).reset_index(drop = True)), axis =  1) 
#subject_original_mapping = GetSubMapping(original_df)
#print(subject_original_mapping)

#************************** TRAIN - VALIDATION *********************************************
kmeans_train.fit(train_df.iloc[:, :-1])
kmeans_valid.fit(valid_df.iloc[:, :-1])

train_labels = pd.Series(kmeans_train.labels_, name = "labels")
valid_labels = pd.Series(kmeans_valid.labels_, name = "labels")

train_labels_df = pd.concat(( train_labels, train_df.iloc[:, -1].astype(int)), axis = 1)
valid_labels_df = pd.concat(( valid_labels, valid_df.iloc[:, -1].astype(int)), axis =  1)

train_centers = kmeans_train.cluster_centers_
valid_centers = kmeans_valid.cluster_centers_

train_valid_mapping = GetMapping(train_centers, valid_centers)
valid_train_mapping = GetMapping(valid_centers, train_centers)

train_subject_mapping = GetSubMapping(train_labels_df)
valid_subject_mapping = GetSubMapping(valid_labels_df)

print(train_valid_mapping)
print(valid_train_mapping)
print("******************** SUBJECT MAPPING *************************")
print(train_subject_mapping)
print(valid_subject_mapping)

#************************* CLUSTER CENTERS ***********************************************
#kmeans_train.fit(train_df.iloc[:, : -1])
#print(kmeans_train.cluster_centers_)
fig_train, ax_train = plt.subplots(nrows = 8, ncols = 3, sharex = True, sharey = True)
fig_train.suptitle('Train Centers', fontsize=16)
for i, c in enumerate(kmeans_train.cluster_centers_):
    ax_train[i // 3][i % 3].plot(c)
    
fig_valid, ax_valid = plt.subplots(nrows = 8, ncols = 3, sharex = True, sharey = True)
fig_valid.suptitle('Valid Centers', fontsize=16)
for i, c in enumerate(kmeans_valid.cluster_centers_):
    ax_valid[i // 3][i % 3].plot(c)
plt.show()

