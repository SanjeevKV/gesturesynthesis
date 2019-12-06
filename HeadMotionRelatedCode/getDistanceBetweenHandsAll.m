function getDistanceBetweenHandsAll(inputPath, outputPath, handMarkerNamesPath)
  
  %Create output directory if it does not exist
  if exist(outputPath) ~= 7
    disp('Folder does not exist: Creating one');
    mkdir(outputPath);
  end
  
  %List all the files in the inputPath
  inputSuffix = '.mat';
  list = dir([inputPath,'*',inputSuffix]);
  outputSuffix = '.mat';

  %Parse all the files in the inputPath
  list
  for i=1:length(list)
    %disp([inputPath,list(i).name]);
    %disp(strjoin([outputPath,strsplit(list(i).name,'.')(1),outputSuffix],''));
    %disp(strjoin([outputPath,strsplit(list(i).name,'.')(1), outputSuffix],''));
    fileName = strsplit(list(i).name,'.');
    getDistanceBetweenHands([inputPath,list(i).name], strjoin([outputPath,fileName(1), outputSuffix],''), handMarkerNamesPath);
  end

end