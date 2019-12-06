import numpy as np
import scipy.io
import pandas as pd
tr=0;

if(tr==1):

   data_path='/home/sanjeev/Documents/HeadMotionData/MocapData/train/';
   allfiles=np.genfromtxt('/tmp/allfiles',dtype='str');

else:

   data_path='/home/sanjeev/Documents/HeadMotionData/MocapData/valid/';
   allfiles=np.genfromtxt('/tmp/allfiles_val',dtype='str');



allspkrps=np.genfromtxt('/tmp/spkrs',dtype='str');
allspkrps=allspkrps.tolist();


def FrameData(alldata,Nw,Ns):
    Nl=alldata.shape[0];
    data=np.zeros((((Nl-Nw)//Ns)+1,3600,3));
    for idx,j in enumerate(range(0,Nl-Nw,Ns)):
        data[idx,:,:]=alldata[j:j+Nw,:] - np.mean(data, axis = 0)
    return(data);


mytrdata=np.zeros((1,3600,3));
mytrlabels=np.zeros((1,24));

for filename in allfiles:
    pd_frm=pd.read_csv(data_path+filename);
    data = np.array(pd_frm[["X", "Y", "Z"]])
    print([data.shape,type(data)]);
    frms=FrameData(data,3600,1200);
       
    mytrdata=np.concatenate((mytrdata,frms),axis=0);
    lab=np.zeros((frms.shape[0],24));
    subname=filename.split('/')[1]
    sidx=allspkrps.index(str(subname))
    lab[:,sidx]=1;
    mytrlabels=np.concatenate((mytrlabels,lab),axis=0);
    print([mytrdata.shape,mytrlabels.shape,sidx]);
     
if(tr==1):

   scipy.io.savemat('./Achuth_data/tr_data.mat',{'trdata':mytrdata,'trlabels':mytrlabels});

else:

   scipy.io.savemat('./Achuth_data/val_data.mat',{'trdata':mytrdata,'trlabels':mytrlabels});

exit(0);
for i in allfiles:
    print(i)
    





