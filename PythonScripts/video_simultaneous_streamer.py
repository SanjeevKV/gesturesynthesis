import cv2, time, os, imutils
import subprocess
import librosa
from scipy import signal
import numpy as np

video_file = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/Video/PavanIn_Story1En.MTS"
audio_video_file = "/tmp/PavanIn_Story1En.wav"
audio_file = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/Audio/2016-05-28_16-17-34_PavanIn_Story1En.wav"
command = "yes | /usr/local/bin/ffmpeg -i " + video_file + " -ab 160k -ac 2 -ar 44100 -vn " + audio_video_file

subprocess.call(command, shell=True)

audio_data, audio_fs  = librosa.load(audio_file)
audio_video_data, audio_video_fs = librosa.load(audio_video_file)
audio_video_data_resampled = librosa.resample(audio_video_data, audio_video_fs, audio_fs)

diff_sec = (np.argmax(audio_data) - np.argmax(audio_video_data)) / audio_fs

WIDTH = 5

def format_number(number, width):
    return str(number).zfill(width)

VIDEO_WINDOW_TITLE = "Video"
ANIMATION_WINDOW_TITLE = "Animation"
VIDEO_LOCATION = "/Users/sanjeev/Documents/Projects/ProjectAssistant/HeadMotionData/Kannada/PavanIn/Video/PavanIn_Story1En.MTS"
FPS = 60
IMAGES_PATH = "/tmp/RealTime/"

video_cap = cv2.VideoCapture(VIDEO_LOCATION)
video_cap.set(cv2.CAP_PROP_FPS, FPS)

frame_num = 0 + int(np.abs(diff_sec)) * FPS
while True:

    file_path = os.path.join(IMAGES_PATH, format_number(frame_num,WIDTH)) + ".png"
    print(file_path)
    if os.path.isfile(file_path):
        ret, frame = video_cap.read()
        frame = imutils.resize(frame, width=450)
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        cv2.imshow(VIDEO_WINDOW_TITLE, frame)

        img = cv2.imread(file_path, 0)
        img = imutils.resize(img, width=450)
        #img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        frame_num += 1
        cv2.imshow(ANIMATION_WINDOW_TITLE, img)

    #cv2.waitKey(1)

    if cv2.waitKey(1) & 0xFF == ord('q'):
       break

    #time.sleep(0.01)



video_cap.release();
cv2.destroyAllWindows()


# 
# while True:
#     file_path = os.path.join(IMAGES_PATH, format_number(frame_num,WIDTH)) + ".png"
#     print(file_path)
#     if os.path.isfile(file_path):
#         img = cv2.imread(file_path, 0)
#         frame_num += 1
#         cv2.imshow("Displaying", img)
#     cv2.waitKey(1)
#     time.sleep(0.01)
#
# cv2.destroyAllWindows()
