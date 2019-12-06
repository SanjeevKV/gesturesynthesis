function checkMarkerData(dirPath)

list = dir([dirPath,'\*.fbx.mat']);
for i=1:length(list)
eval(['load ',dirPath,'\',list(i).name]);
[headData, markerNames]=getAllHeadMarkerData(markerData,'F:\IIScProjectMain\Optitrack\Code\HeadMarkerNames.txt');
for j=1:length(headData)
    plot((1:length(headData{j}))/120,headData{j});title([list(i).name,' ',markerNames(j)]);pause;
end
clear markerData headData
end
end