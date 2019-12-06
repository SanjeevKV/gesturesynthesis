function playVideoWithRating(Language, Subject, Story, rating)

%% Import data from text file.
% Script for importing data from the following text file:
%
%    F:\IIScProjectMain\Phani\story1extractedwithrating.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2016/11/11 19:34:26

%% Initialize variables.
filename = ['F:\IIScProjectMain\Phani\story' num2str(Story) 'extractedwithrating.txt'];
delimiter = '\t';
vidFile=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/' Subject '/Video/' Subject '_Story' num2str(Story) 'En.mp4']

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
fileData = cell2mat(raw);
ratingData=fileData(1:2:end,:);
inds=find(ratingData(:,3)==rating);
ratingData=ratingData(inds,:);
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;
%% Video Process

vid=VideoReader(vidFile);
fr=vid.FrameRate;
[fpath,fname]=fileparts(vidFile);

vidDelay=load([fpath '/' fname '_Videodelay.txt']);
vidDelay=vidDelay/fr;

for i=1:size(ratingData,1)
    startFr=floor((ratingData(i,1)+vidDelay)*fr);
    endFr=floor((ratingData(i,2)+vidDelay)*fr);
    for j=startFr:endFr
        imshow(read(vid,j));title([num2str(ratingData(i,1)) ' to ' num2str(ratingData(i,2))]);
        pause(0.01);
    end
end
end
    