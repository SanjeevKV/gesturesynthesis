function prepareAllEulerAngles(inputPath, outputPath, headMarkerCount, headMarkersPath)
	
  %List all the files in the inputPath
  inputSuffix = '.mat';
  disp([inputPath,'*',inputSuffix])
  list = dir([inputPath,'*',inputSuffix]);
  outputSuffix = '.mat';
  
  disp(outputPath)
  %Create output directory if it does not exist
  if exist(outputPath) ~= 7
    disp('Folder does not exist: Creating one');
    mkdir(outputPath);
  end

  %Parse all the files in the inputPath
  list
  for i=1:length(list)
    fileName = strsplit(list(i).name,'.')
    disp(strjoin([outputPath, fileName(1), outputSuffix],''));
    prepareEulerAngles([inputPath,list(i).name], strjoin([outputPath,fileName(1), outputSuffix],''), headMarkerCount, headMarkersPath);
  end

end
