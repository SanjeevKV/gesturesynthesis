%{

Currently the case where markerName contains an '_' (underscore) is NOT
handled. It may or may not work. (Mostly won't)

To understand or handle that, please look at the getMarkerName function. It
splits the given line at '_' before getting markerName.

****Open Any of the FBX files in a text editor to follow the pattern matching****
%}
function markerData=parseFBX(inputFilePath, outputFilePath, markerCount)

data = textread(inputFilePath, '%s', 'delimiter', '\r');
lines = length(data);

%Create Cells with size mc X 1 to hold the names. 1 X mc*2 to hold the coordinates (Mostly)
markerNames = cell(markerCount, 1);
markerData = cell(1, markerCount*2);
lineNumber = 1;
for index = 1:lines
    line = data(index);
    if strcmp(line, 'Connections:  {')
        tmpIndex = index+2;
        count = 1;
        markerCount;
        while(count <= markerCount)
            markerNames(count) = getMarkerName(char(data(tmpIndex)));
            count = count+1;
            tmpIndex = tmpIndex+1;
        end
        lineNumber = tmpIndex;
        break;
    end
end
disp('Markers Names');
markerNames
markerIndex = 1;
markerDataIndex = 1;
for index = lineNumber:lines
    index / lines * 100
    line = char(data(index));
    markerNames(markerIndex)
    markerName = strtrim(char(markerNames(markerIndex))); %Head-LL
    %strfind(line, markerName)
    %Find the first line of the json containing all the information about the current marker (markerName)
    %
    %Json for a particular marker, say Head-LL, has all the X-coordinates together, Y separtely together and so with the Z
    if ~isempty(strfind(line, markerName))
        tmpIndex = index + 7; %Gives the Line Containing keycount - KeyCount: 27897
        tmpLine = char(data(tmpIndex));
        tmp1 = strsplit(tmpLine, ':');
        frames = str2num(char(strtrim(tmp1(2)))); %frames = 27897
        
        %coords = zeros(frames, 3);
        markerVarName = strrep(markerName, '-', ''); %Remove the hyphens HeadLL
        %Not sure why markerVarName = zeros(frames,3) is not used without eval - markerVarName is a string and we want a variable created with that name
        eval([markerVarName, '=', 'zeros(frames, 3);']);
        coordIndex = 1;
		    tmpIndex = tmpIndex + 1;
        
        dataLine = char(data(tmpIndex));
        
        %Substring 'Color' exists in the last line of a particular set of coordinates (Either X, Y or Z) 
        while isempty(strfind(dataLine, 'Color'))
			
            tmpCoords = getCoordsFromLine(dataLine);
            
            %if a particular line has no coordinates, read the next line and continue
            if isempty(tmpCoords)
                disp('No Coords on line');
                tmpIndex = tmpIndex + 1;
                dataLine = char(data(tmpIndex));
                continue;
            end
            
            %We should have actually looped over the entire tmpCoords rather than this if-else ladder
            
            eval([markerVarName, '(coordIndex, 1)', '=', 'tmpCoords(1);']);
            coordIndex = coordIndex + 1;
            
            if length(tmpCoords) > 1
              eval([markerVarName, '(coordIndex, 1)', '=', 'tmpCoords(2);']);
              coordIndex = coordIndex + 1;
            end
            
            if length(tmpCoords) > 2
              eval([markerVarName, '(coordIndex, 1)', '=', 'tmpCoords(3);']);
              coordIndex = coordIndex + 1;
            end
            
            if length(tmpCoords) > 3
              eval([markerVarName, '(coordIndex, 1)', '=' ,'tmpCoords(4);']);
              coordIndex = coordIndex + 1;
            end
			
            tmpIndex = tmpIndex + 1;
            dataLine = char(data(tmpIndex));
            
        end
        
        %Once 'Color' substring is encountered and we know it is the end of one coordinate group,
        %we skip the lines till we get Key
        while isempty(strfind(strtrim(dataLine), 'Key:'))
                tmpIndex = tmpIndex+1;
                dataLine = char(data(tmpIndex)); %Seems to be redundant - Should have been read outside the loop
        end
        
        coordIndex = 1;
        %Same procedure repeated for Y coordinate
        while isempty(strfind(dataLine, 'Color'))
			
            tmpCoords = getCoordsFromLine(dataLine);
            
            if isempty(tmpCoords)
                disp('No Coords on line');
                tmpIndex = tmpIndex + 1;
                dataLine = char(data(tmpIndex));
                continue;
            end
            
            eval([markerVarName, '(coordIndex, 2)', '=', 'tmpCoords(1);']);
            coordIndex = coordIndex + 1;
            
            if length(tmpCoords) > 1
              eval([markerVarName, '(coordIndex, 2)', '=', 'tmpCoords(2);']);
              coordIndex = coordIndex + 1;
            end
            
            if length(tmpCoords) > 2
              eval([markerVarName, '(coordIndex, 2)', '=', 'tmpCoords(3);']);
              coordIndex = coordIndex + 1;
            end
            
            if length(tmpCoords) > 3
              eval([markerVarName, '(coordIndex, 2)', '=', 'tmpCoords(4);']);
              coordIndex = coordIndex + 1;
            end
			
            tmpIndex = tmpIndex + 1;
            dataLine = char(data(tmpIndex));
            
        end
        
        while isempty(strfind(strtrim(dataLine), 'Key:'))
                tmpIndex = tmpIndex+1;
                dataLine = char(data(tmpIndex));
        end
        
        coordIndex = 1;
        %Same procedure repeated for Z coordinates
        while isempty(strfind(dataLine, 'Color'))
			
            tmpCoords = getCoordsFromLine(dataLine);
            
            if isempty(tmpCoords)
                disp('No Coords on line');
                tmpIndex = tmpIndex + 1;
                dataLine = char(data(tmpIndex));
                continue;
            end
            
            eval([markerVarName, '(coordIndex, 3)', '=', 'tmpCoords(1);']);
            coordIndex = coordIndex + 1;
            
            if length(tmpCoords) > 1
              eval([markerVarName, '(coordIndex, 3)', '=', 'tmpCoords(2);']);
              coordIndex = coordIndex + 1;
            end
            
            if length(tmpCoords) > 2
              eval([markerVarName, '(coordIndex, 3)', '=' ,'tmpCoords(3);']);
              coordIndex = coordIndex + 1;
            end
            
            if length(tmpCoords) > 3
              eval([markerVarName, '(coordIndex, 3)', '=', 'tmpCoords(4);']);
              coordIndex = coordIndex + 1;
            end
			
			      tmpIndex = tmpIndex + 1;
            dataLine = char(data(tmpIndex));
            
        end
        
        %markerData is a cell array, which contains markerName followed by markerData
        %markerIndex points to the current marker (markerName)
        %markerDataIndex points to either the current markerName or the markerData - Incremented twice as frequently as markerIndex
        markerData{markerDataIndex} = markerName;
        markerDataIndex=markerDataIndex+1;
        eval(['markerData{', num2str(markerDataIndex),'} =', markerVarName]);
        disp([markerName ' Done']);
        
        if markerIndex < markerCount
            markerIndex = markerIndex + 1;
            markerDataIndex = markerDataIndex + 1;
        else
            break;
        end
        
    end %if condition - The line doesn't contain the markerName
    
end %for loop - Looping through all the line

%eval(['save ',filename,'.mat ', 'markerData']);
save(outputFilePath,'markerData')

end

%
%  Input - Connect: "OO", "Model::C3D:Face Template_Head-LL", "Model::C3D:optical"
%  Output - Head-LL
%
function markerName = getMarkerName(line)
    disp('Line')
    line
    C = strsplit(strtrim(line), ',');
    tmp1 = strsplit(char(C(2)), '"');
    tmp2 = strsplit(char(tmp1(2)), '_');
    markerName = strtrim(tmp2(length(tmp2)));
end

%
% Input1 - Key: 461861580,0,U,a,n,923723160,23.574,U,a,n
% Input2 - ,2309307900,23.580,U,a,n,2771169480,23.582,U,a,n
% Output1 - [0, 23.574]'
% Output2 - [23.580, 23.582]'
%
function tmpCoords = getCoordsFromLine(line)
    
    %if 'Key' is present in the line
    if ~isempty(strfind(strtrim(line), 'Key'))
        tmp = strsplit(line, ':');
        line = strtrim(tmp(2));
        line = strcat(',', line);
    end
    
    %disp(line);
    C = strsplit(char(line), ',');
	  numberOfCoordsInLine=(length(C)-1)/5;
    
    %disp(numberOfCoordsInLine);
    nextCoordIndex=3;
    tmpCoords = zeros(numberOfCoordsInLine,1);
    
    for i=1:numberOfCoordsInLine
      tmpCoords(i) = str2num(char(C(nextCoordIndex)));
      nextCoordIndex=nextCoordIndex+5;
    end
    
end

