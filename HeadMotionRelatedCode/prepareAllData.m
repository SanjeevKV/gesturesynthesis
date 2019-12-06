list = dir('*.fbx.mat');
for i=1:length(list)
    
    eval(['load ',list(i).name]);
    headData=getAllHeadMarkerData(markerData,'/home/prr/my_project/HeadMotionRelatedCode/HeadMarkerNames.txt');
    transform=getTransformForObject(headData, 6);
    temp=strsplit(list(i).name,'.');
    filename=temp{1};
    data=[];
    for j=1:length(headData)
        data=[data headData{j}];
    end
    data = [data transform];
    eval(['save ', filename, 'Data.mat ','data']);
    clear transform temp filename markerData headData data;

end
