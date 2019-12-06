function handDist=getDistanceBetweenHands(markerData, handMarkerNamesFile)

    data = textread(handMarkerNamesFile, '%s', 'delimiter', '\r');
    numberOfLines = length(data);
    handData=cell(1, numberOfLines);
    
    for i=1:numberOfLines
        handData{i} = getDataForMarker(markerData, data{i});
    end
    
    hand1mean = (handData{1}+handData{2})./2;
    hand2mean = (handData{3}+handData{4})./2;
    
    handDist = find3dDistance(hand1mean, hand2mean);
    
end