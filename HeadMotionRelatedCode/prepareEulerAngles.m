function markerData=prepareEulerAngles(inputFilePath, outputFilePath, headMarkerCount, headMarkersPath)

    eval(['load ',inputFilePath]);
    headData=getAllHeadMarkerData(markerData,headMarkersPath);
    transform=getTransformForObject(headData, headMarkerCount);
    %temp=strsplit(list(i).name,'.');
    %filename=temp{1};
    data=[];
    for j=1:length(headData)
        data=[data headData{j}];
    end
    data = [data transform];
    eval(['save ', outputFilePath,' data']);
    clear transform temp filename markerData headData data;

end
