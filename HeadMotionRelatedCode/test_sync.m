audio_file='/home/prr/my_project/optitrack/Astha/Audio/Astha_baba.wav'
marker_file='/home/prr/my_project/optitrack/Astha/FBX/2017-06-15_12-23-56_AsthaBaaBaa.fbx.mat'

[y ,Fs] = audioread(audio_file);
eval(['load ', marker_file]);

disp('Calculating Distance between hands');
tempDist=getDistanceBetweenHands(markerData, '/home/prr/my_project/HeadMotionRelatedCode/HandMarkerNames.txt');
d=(tempDist-min(tempDist))/range(tempDist);
eval(['save ','/home/prr/my_project/optitrack/Astha/FBX/','baba_','HandMarkerDistance.mat tempDist;']);

delay=finddelay(y(1:Fs*30), Fs, d(1:120*30), 120, 0);
fid=fopen(['/home/prr/my_project/optitrack/Astha/FBX/','baba_','Delay.txt'], 'w');
fprintf(fid,'%.4f', delay);
fclose(fid);