import cv2

VIDEO_LOCATION = "/home/sanjeev/Documents/Misc/ShortestStoryTelling.mp4"
OUT_LOCATION = "/home/sanjeev/Documents/Misc/Frames/"

video_cap = cv2.VideoCapture(VIDEO_LOCATION)

#frame_num = 1
#ret = 1
#while ret:
#    ret, frame = video_cap.read()
#    cv2.imwrite(OUT_LOCATION + str(frame_num) + ".jpg", frame)
#    frame_num += 1

#video_cap.release();
#cv2.destroyAllWindows()


vidcap = cv2.VideoCapture(VIDEO_LOCATION)
success,image = vidcap.read()
frame_num = 1
success = True
while success:
  cv2.imwrite(OUT_LOCATION + str(frame_num) + ".jpg", image)     # save frame as JPEG file
  success,image = vidcap.read()
  #print 'Read a new frame: ', success
  frame_num += 1
