import cv2, time, os

WIDTH = 5

def format_number(number, width):
    return str(number).zfill(width)
# video = cv2.VideoCapture(0)
#
# while True:
#     check, frame = video.read()
#     cv2.imshow("Capturing", frame)
#
#     key = cv2.waitKey(1)
#     if key == ord("q"):
#         break
#
# video.release()
IMAGES_PATH = "/tmp/RealTime/"
frame_num = 0
while True:
    file_path = os.path.join(IMAGES_PATH, format_number(frame_num,WIDTH)) + ".png"
    print(file_path)
    if os.path.isfile(file_path):
        img = cv2.imread(file_path, 0)
        frame_num += 1
        cv2.imshow("Displaying", img)
    cv2.waitKey(1)
    #time.sleep(0.01)

cv2.destroyAllWindows()
