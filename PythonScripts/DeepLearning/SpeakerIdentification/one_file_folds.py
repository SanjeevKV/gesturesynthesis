import numpy as np
import scipy.io
import pandas as pd
import os
import argparse


def FrameData(alldata,Nw,Ns):
	Nl = alldata.shape[0];
	data=np.zeros( ( ( ( Nl - Nw ) // Ns ) + 1, VFPS * NUM_STEPS, NUM_CHANNELS ) )
	for idx, j in enumerate( range( 0, Nl - Nw, Ns ) ):
		data[idx, :, :] = alldata[j : j + Nw, : ] - np.mean(data, axis = 0)
	return(data)

if __name__ == "__main__":

	parser = argparse.ArgumentParser(description = "Description for my parser")
	parser.add_argument("-r", "--root", help = "Data Root Location", required = True)
	parser.add_argument("-f", "--folds_path", help = "Location to write the folds", required = True)
	parser.add_argument("-d", "--window_duration", help = "Duration of single window (sec)", required = True)
	parser.add_argument("-s", "--skip_duration", help = "Duration to skip before next window (sec)", required = True)
	argument = parser.parse_args()
	
	if os.path.isdir(argument.folds_path) == False:
		os.mkdir(argument.folds_path)

	DATA_ROOT = argument.root
	FOLDS_PATH = argument.folds_path

	NUM_FILES_PER_USER = 10
	OUT_SIZE = 24 # Number of subjects / classes
	NUM_CHANNELS = 3 # Number of features per frame
	NUM_SKIP_STEPS = int(argument.skip_duration) # Number of seconds to skip for generating next sample from the same file
	NUM_STEPS = int(argument.window_duration) # Duration (in seconds) of a sample
	VFPS = 120
	COLUMNS = ["X", "Y", "Z"]

	speakers = os.listdir(DATA_ROOT)
	shuffled_speaker_files = {}

	for i in speakers:
		speaker_files = os.listdir( os.path.join(DATA_ROOT, i) )
		#np.random.shuffle(speaker_files)
                speaker_files = sorted(speaker_files)
                print(speaker_files)
		speaker_files = [os.path.join(DATA_ROOT,i, sp_file) for sp_file in speaker_files]
		shuffled_speaker_files[i] = speaker_files

	for it in range(NUM_FILES_PER_USER):    
		data=np.zeros((1, VFPS * NUM_STEPS, NUM_CHANNELS));
		labels=np.zeros((1, OUT_SIZE))

		for speaker, sh_files in shuffled_speaker_files.items():
			pd_frm = pd.read_csv( sh_files[it] )
			cur_data = np.array( pd_frm[COLUMNS] )
			#print([data.shape,type(data)])
			frms = FrameData(cur_data, VFPS * NUM_STEPS, VFPS * NUM_SKIP_STEPS)
			#print(data.shape, frms.shape)
			data = np.concatenate( (data,frms), axis=0 )
			lab = np.zeros( (frms.shape[0], OUT_SIZE) )
			subname = speaker
			#print(subname)
			sidx = speakers.index(subname)
			lab[:, sidx] = 1
			labels = np.concatenate( (labels,lab), axis=0 )
			print([data.shape,labels.shape,sidx])
		
		scipy.io.savemat(os.path.join(FOLDS_PATH, "data-fold-" + str(it) + ".mat" , ) ,{"data" : data, "labels" : labels} )

	    





