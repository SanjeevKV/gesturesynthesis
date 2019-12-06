function synchronizeAudioMarkersAll(audioPath, handDistancePath, delayPath)

  %Create output directory if it does not exist
  if exist(delayPath) ~= 7
    disp('Folder does not exist: Creating one');
    mkdir(delayPath);
  end
  
  %List all the files in the inputPath
  audioSuffix = '.wav';
  list = dir([audioPath,'*',audioSuffix]);
  handDistanceSuffix = '.mat';
  delaySuffix = '.txt';

  %Parse all the files in the inputPath
  list
  for i=1:length(list)
    fileName = strsplit(list(i).name,'.');
    synchronizeAudioMarkers([audioPath,list(i).name], strjoin([handDistancePath, fileName(1), handDistanceSuffix],''), strjoin([delayPath,fileName(1), delaySuffix],''));
  end

end
