import pandas as pd
from sklearn.manifold import TSNE as tsne
from matplotlib import pyplot as plt
import seaborn as sns

DATA_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output.csv"
OUT_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_embed.csv"

data_df = pd.read_csv(DATA_LOCATION)
data_df.iloc[:, -1] = data_df.iloc[:, -1].astype(int)

embedder = tsne()

data_embedded = embedder.fit_transform(data_df.iloc[:, :-1])
df = pd.DataFrame(data_embedded, columns = ["x", "y"])
df["target"] = data_df.iloc[:, -1]
df.to_csv(OUT_LOCATION, index = False)

print(set(df["target"]))
ax = sns.scatterplot(x = "x", y = "y", hue = "target", data = df, palette = sns.color_palette("deep", len(set(df["target"])) ) )
#palette = sns.color_palette("deep", 4)
plt.show()
