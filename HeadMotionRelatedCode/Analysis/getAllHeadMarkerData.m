function [headData, markerNames]=getAllHeadMarkerData(markerData, headMarkerNamesFile)

    data = textread(headMarkerNamesFile, '%s', 'delimiter', '\r');
    numberOfLines = length(data);
    headData=cell(1, numberOfLines);
    
    for i=1:numberOfLines
		data{i}
        headData{i} = getDataForMarker(markerData, data{i});
    end
    
    markerNames=data;
    
end