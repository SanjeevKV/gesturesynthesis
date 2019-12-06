function interpolateAllAndRecreate(dir)

list=dir([dir,'\*.fbx.mat']);

for i=1:length(list)
    name=strsplit(list(i).name,'.');
    zeroDataFile=[name{1},'ZeroData.mat'];
    eval(['load ',zeroDataFile]);
    eval(['load ',list(i).name]);
    allMarkerDataFixed=markerData;
    
    for j=3:3:18
        InterpolateIndices=zeroData{j};
        markerName=zeroData{j-2};
        [singleMarkerData,ind]=getDataForMarker(markerData,markerName);
        fixedData=interpolate(singleMarkerData,InterpolateIndices);
        allMarkerDataFixed{ind}=fixedData;
    end
    
    eval(['save ',name,'Fixed.mat fixedData']);
end
end