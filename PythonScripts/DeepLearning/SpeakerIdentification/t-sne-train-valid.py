import pandas as pd
from sklearn.manifold import TSNE as tsne
from matplotlib import pyplot as plt
import seaborn as sns

TRAIN_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output_train.csv"
VALID_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output_valid.csv"
OUT_TRAIN_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_embed_train.csv"
OUT_VALID_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_embed_valid.csv"

train_df = pd.read_csv(TRAIN_LOCATION)
valid_df = pd.read_csv(VALID_LOCATION)
train_df.iloc[:, -1] = train_df.iloc[:, -1].astype(int)
valid_df.iloc[:, -1] = valid_df.iloc[:, -1].astype(int)

embedder = tsne()

embedder.fit(train_df.iloc[:, :-1])

train_embedded = embedder.transform(train_df.iloc[:, :-1])
valid_embedded = embedder.tranform(valid_df.iloc[:, -1])
train_df = pd.DataFrame(train_embedded, columns = ["x", "y"])
valid_df = pd.DataFrame(valid_embedded, columns = ["x", "y"])
train_df["target"] = train_df.iloc[:, -1]
valid_df["target"] = valid_df.iloc[:, -1]

train_df.to_csv(OUT_TRAIN_LOCATION, index = False)
valid_df.to_csv(OUT_VALID_LOCATION, index = False)

f, axes = plt.subplots(1, 2)
sns.scatterplot( y="y", x= "x", data=train_df,  orient='v' , ax=axes[0], hue = "target")
sns.scatterplot(  y="y", x= "x", data=valid_df,  orient='v' , ax=axes[1], hue = "target")
#ax = sns.scatterplot(x = "x", y = "y", hue = "target", data = df)
plt.show()
