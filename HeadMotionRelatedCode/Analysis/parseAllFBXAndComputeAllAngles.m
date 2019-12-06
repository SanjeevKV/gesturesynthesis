list = dir('*.fbx');
if ~exist('../extractedData');
mkdir ../extractedData;
end
for i=1:length(list)
    markerData=parseFBX(list(i).name,10);
    headData=getAllHeadMarkerData(markerData,'F:\IIScProjectMain\Optitrack\Code\HeadMarkerNames.txt');
    transform=getTransformForObject(headData, 6);
    temp=strsplit(list(i).name,'.');
    filename=temp{1};
    data=[];
    for j=1:length(headData)
        data=[data headData{j}];
    end
    data = [data transform];
    eval(['save ../extractedData/', filename, 'Data.mat ','data']);
    clear transform temp filename markerData headData data;
end
