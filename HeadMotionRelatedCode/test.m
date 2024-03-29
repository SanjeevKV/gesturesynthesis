

audioListStruct = dir(['/media/prr/PRR/Optitrack/Data/Tamil/Ashwini/Wav','/*.wav']);

audioFileNames=cell(1, length(audioListStruct));
for i = 1:length(audioListStruct)
    temp = audioListStruct(i).name;
    tempCell = strsplit(temp, '.');
    audioFileNames{i} = tempCell{1};
end

for i=1:length(audioFileNames)
    
    audioFile=audioFileNames{i};
    [y ,Fs] = wavread(['/media/prr/PRR/Optitrack/Data/Tamil/Ashwini/Wav','/',audioFile]);
    
    markerDataFile = dir(['/media/prr/PRR/Optitrack/Data/Tamil/Ashwini/FBX','/*',audioFile,'.fbx.mat']);
    
    audioFile
    markerDataFile.name
    
    eval(['load ', '/media/prr/PRR/Optitrack/Data/Tamil/Ashwini/FBX','/',markerDataFile.name]);
    s = strsplit(markerDataFile.name,'.');
    handDistFilename=s{1};
    if exist([markerDataPath,'/',handDistFilename,'HandMarkerDistance.mat'], 'file') == 2
        eval(['load ',markerDataPath,'/',handDistFilename,'HandMarkerDistance.mat']);
        disp('Hand Distance file loaded');
        d=(tempDist-min(tempDist))/range(tempDist);
    else
        disp('Calculating Distance between hands');
        tempDist=getDistanceBetweenHands(markerData, '/home/prr/my_project/HeadMotionRelatedCode/HandMarkerNames.txt');
        d=(tempDist-min(tempDist))/range(tempDist);
        eval(['save ',markerDataPath,'/',handDistFilename,'HandMarkerDistance.mat tempDist;'])
    end
    delay=0;
    if exist([markerDataPath,'/',markerDataFile.name,'Delay.txt'],'file') == 2
        fr = fopen([markerDataPath,'/',markerDataFile.name,'Delay.txt'],'r');
        s = fgetl(fr);
        initdelay = str2double(s);
        initdelay
        fclose(fr);
        clear fr;
        delay=finddelay(y(1:Fs*40), Fs, d(1:120*40), 120, initdelay);
    else
        delay=finddelay(y(1:Fs*30), Fs, d(1:120*30), 120, 0);
    end
    
    %fid=fopen([markerDataPath,'\',markerDataFile.name,'Delay.txt'], 'w');
    %fprintf(fid,'%.4f', delay);
    %fclose(fid);
end

clear

