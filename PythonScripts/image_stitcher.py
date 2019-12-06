import cv2
import numpy as np
import os

def SortMap(file_names):
    prefixes = list(map(lambda x : int(x.split(".")[0].split("_")[0]), file_names))
    sorted_prefixes = sorted(prefixes)
    print(sorted_prefixes)
    mapping = dict()
    for i, prefix in enumerate(sorted_prefixes):
        mapping[i] = str(prefix) + "_" + str(prefix) + ".jpg"
    return mapping

IMAGES_LOCATION = "/home/sanjeev/Documents/ganimation_replicate/video_results/emotion_ganimation_30/"
OUT_VIDEO_LOCATION = "/home/sanjeev/Documents/ganimation_replicate/video_results/emotion_ganimation_30/video.avi"
FRAME_RATE = 30

img_array = []
file_names = []
current_mapping = dict()

frames = [name for name in os.listdir(IMAGES_LOCATION) if os.path.isfile(os.path.join(IMAGES_LOCATION, name))]
for i, filename in enumerate(frames):
    print(filename)
    file_names.append(filename)
    img = cv2.imread(os.path.join(IMAGES_LOCATION,filename))
    height, width, layers = img.shape
    size = (width,height)
    img_array.append(img)
    current_mapping[filename] = i

sorted_mapping = SortMap(file_names)
out = cv2.VideoWriter(OUT_VIDEO_LOCATION,cv2.VideoWriter_fourcc(*'DIVX'), FRAME_RATE, size)
 
for i in range(len(img_array)):
    out.write(img_array[current_mapping[sorted_mapping[i]]])
out.release()
