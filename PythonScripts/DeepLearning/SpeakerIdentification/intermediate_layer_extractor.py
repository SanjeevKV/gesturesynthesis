import sys, os
import pandas as pd
import numpy as np
from keras.models import load_model, Model
from speaker_identification_data_generator import SpeakerIdentificationBatchGenerator

MODEL_LOCATION = "/home/sanjeev/Documents/HeadMotionData/models/k-fold/2019-09-11/Mocap-functional_CNN_maxpool_lstm_glob-fold-4-weights-improvement-92-0.93-0.76-0.97.hdf5"
DATA_ROOT_LOCATION = "/home/sanjeev/Documents/HeadMotionData/MocapData"
OUT_LOCATION = "/home/sanjeev/Documents/HeadMotionData/outputs/global_avg_output_train_linear_mean.csv"

model = load_model(MODEL_LOCATION)
#print(model.get_layer("global_averager"))
#sys.exit()

OUT_SIZE = 24 # Number of subjects / classes
NUM_CHANNELS = 3 # Number of features per frame
BATCH_SIZE = 10 # Number of samples in a batch
NUM_SKIP_STEPS = 10 # Number of seconds to skip for generating next sample from the same file
NUM_STEPS = 30 # Duration (in seconds) of a sample
AVG_DURATION_PER_FILE = 300 # Duration (in seconds) of a recording (per person, per recording)
NUM_FILES = 6 # Number of files per subject used for intermediate_layer_extraction
VFPS = 120
COLUMNS = ["X", "Y", "Z"]
num_steps = int( (AVG_DURATION_PER_FILE * NUM_FILES * OUT_SIZE) / (NUM_SKIP_STEPS * BATCH_SIZE) )

data_generator_obj = SpeakerIdentificationBatchGenerator(os.path.join(DATA_ROOT_LOCATION, "train"), vfps = VFPS, num_steps = NUM_STEPS, batch_size = BATCH_SIZE, skip_steps=NUM_SKIP_STEPS, out_size = OUT_SIZE, input_channels = NUM_CHANNELS)

intermediate_model = Model(inputs = model.input, outputs = model.get_layer("global_averager").output)
data_generator = data_generator_obj.generate_head_motion_data_for_speaker_identification_sin_seq(column_names = COLUMNS)
#x, y = next(data_generator)
#y = np.argmax(y, axis = 1).reshape(-1, 1)
#intermediate_output = intermediate_model.predict(x)
#intermediate_output = np.concatenate((intermediate_output, y), axis = 1)
#print(intermediate_output.shape, y)
#sys.exit()
intermediate_representations = []
for i in range(num_steps):
	x, y = next(data_generator)
	y = np.argmax(y, axis = 1).reshape(-1, 1)
	intermediate_output = intermediate_model.predict(x)
	intermediate_output = np.concatenate((intermediate_output, y), axis = 1)
	intermediate_representations.append(intermediate_output)

intermediate_rep = np.concatenate(intermediate_representations, axis = 0)
df = pd.DataFrame(intermediate_rep)
df.to_csv(OUT_LOCATION, index = False)
