%
%Function to add prefixes to file names if it is not present (Eg :- Aravind_Story1En.wav
%is converted to 2016-06-08_18-11-50_Aravind_Story1En.wav
%Input - Folder location containing files with prefix (Any extension - Corresponding change in the variables is required)
%Folder location containing files without extension and Ouput folder location
%Output - Files with prefix appended is written to the outputPath
%
function addDateTimePrefix(pathContainingPrefix, pathNotContainingPrefix, outputPath)
  
  %Create output directory if it does not exist
  if exist(outputPath) ~= 7
    disp('Folder does not exist: Creating one');
    mkdir(outputPath);
  end  
  %Used to list only the required extension files
  pathContainingPrefix_suffix = '.fbx';
  pathNotContainingPrefix_suffix = '.MTS';
  pathDelimiter = '/';
  
  %Enlist all the files in both the paths
  filesContainingPrefix = dir([pathContainingPrefix,'*',pathContainingPrefix_suffix])
  filesNotContainingPrefix = dir([pathNotContainingPrefix, '*', pathNotContainingPrefix_suffix])
  
  
  %For all the files not containing the prefix
  for i=1:length(filesNotContainingPrefix)
    fileNCP = filesNotContainingPrefix(i).name;
    fileNCP_name = strsplit(fileNCP,'.');
    fileNCP_withoutExtension = char(fileNCP_name(1)); %Get the name of the file without extension
    for j=1:length(filesContainingPrefix)
      fileCP = filesContainingPrefix(j).name;
      fileCP
      fileNCP_withoutExtension
      if(numel(strfind(fileCP, fileNCP_withoutExtension)) > 0) %If there is an occurrence of fileName in the fieNameWithPrefix
        fileCP_withoutExtension_name = strsplit(fileCP,'.');  
        fileCP_withoutExtension = fileCP_withoutExtension_name(1); %Get the file name with prefix, without extension
        copyfile([pathNotContainingPrefix,fileNCP], strjoin([outputPath,fileCP_withoutExtension,pathNotContainingPrefix_suffix],''));
      end
      
    end
    
  end
  
end