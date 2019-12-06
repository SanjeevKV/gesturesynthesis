from sklearn.cluster import KMeans as km
import pandas as pd
import numpy as np

train_df = pd.read_csv("/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output_train.csv")
valid_df = pd.read_csv("/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output_valid.csv")

OUT_SIZE = 24

kmeans = km(n_clusters = OUT_SIZE)
kmeans.fit(train_df.iloc[:, :-1])
train_labels = pd.Series(kmeans.labels_, name = "labels")
valid_labels = pd.Series(kmeans.predict(valid_df.iloc[:, :-1]), name = "labels")
train_predicted_labels = pd.Series(kmeans.predict(train_df.iloc[:, :-1]), name = "labels")

train_df = pd.concat(( train_labels, train_df.iloc[:, -1].astype(int)), axis = 1)
valid_df = pd.concat(( valid_labels, valid_df.iloc[:, -1].astype(int)), axis =  1)
train_predicted_df = pd.concat(( train_predicted_labels, train_df.iloc[:, -1].astype(int)), axis =  1) 

train_df.to_csv("/home/sanjeev/Documents/HeadMotionData/outputs/k-means-train-labels.csv", index = False)
valid_df.to_csv("/home/sanjeev/Documents/HeadMotionData/outputs/k-means-valid-labels.csv", index = False)
train_predicted_df.to_csv("/home/sanjeev/Documents/HeadMotionData/outputs/k-means-train_predicted-labels.csv", index = False)
