import cv2
import os

IMAGE_LOCATION = "/home/sanjeev/Documents/ganimation_replicate/emotion/imgs_original/man.jpg"
OUT_LOCATION = "/home/sanjeev/Documents/Misc/Repeated/"
FRAMES_LOCATION = '/home/sanjeev/Documents/Misc/Frames/'
frames = [name for name in os.listdir(FRAMES_LOCATION) if os.path.isfile(os.path.join(FRAMES_LOCATION, name))]

img = cv2.imread(IMAGE_LOCATION)

for frame in frames:
    cv2.imwrite(OUT_LOCATION + str(frame), img)

cv2.destroyAllWindows()
