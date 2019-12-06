import numpy as np
import scipy.io
import pandas as pd
import os

tr = 0
DATA_ROOT = "/home/sanjeev/Documents/HeadMotionData/MocapData"

if(tr==1):

   allfiles = np.genfromtxt(os.path.join(DATA_ROOT, "TrainFiles"),dtype='str')

else:

   allfiles = np.genfromtxt(os.path.join(DATA_ROOT, "TestFiles"),dtype='str')

SPEAKERS_NAMES = "Speakers"
OUT_SIZE = 24 # Number of subjects / classes
NUM_CHANNELS = 3 # Number of features per frame
NUM_SKIP_STEPS = 10 # Number of seconds to skip for generating next sample from the same file
NUM_STEPS = 30 # Duration (in seconds) of a sample
VFPS = 120
COLUMNS = ["X", "Y", "Z"]

allspkrps=np.genfromtxt( os.path.join(DATA_ROOT,SPEAKERS_NAMES) ,dtype='str');
allspkrps=allspkrps.tolist();


def FrameData(alldata,Nw,Ns):
    Nl=alldata.shape[0];
    data=np.zeros( ( ( ( Nl-Nw ) // Ns ) + 1, VFPS * NUM_STEPS, NUM_CHANNELS ) );
    for idx, j in enumerate( range( 0, Nl - Nw, Ns ) ):
        data[idx, :, :] = alldata[j : j + Nw, : ] - np.mean(data, axis = 0)
    return(data);


mytrdata=np.zeros((1, VFPS * NUM_STEPS, NUM_CHANNELS));
mytrlabels=np.zeros((1, OUT_SIZE));

for filename in allfiles:
    pd_frm = pd.read_csv( os.path.join(DATA_ROOT, filename) );
    data = np.array( pd_frm[COLUMNS] )
    print([data.shape,type(data)]);
    frms=FrameData(data, VFPS * NUM_STEPS, VFPS * NUM_SKIP_STEPS);
       
    mytrdata=np.concatenate( (mytrdata,frms), axis=0 );
    lab=np.zeros( (frms.shape[0], OUT_SIZE) );
    subname=filename.split('/')[-2]
    print(subname)
    sidx = allspkrps.index(str(subname))
    lab[:, sidx] = 1;
    mytrlabels = np.concatenate( (mytrlabels,lab), axis=0 );
    print([mytrdata.shape,mytrlabels.shape,sidx]);
     
if(tr==1):

   scipy.io.savemat(os.path.join(DATA_ROOT, "train_data.mat") ,{"data" : mytrdata, "labels" : mytrlabels} );

else:

   scipy.io.savemat(os.path.join(DATA_ROOT, "test_data.mat"),{"data" : mytrdata, "labels" : mytrlabels});

    





