%
%Function to calculate the distance between hands - Used in synchronizeAudioMarkerData
%Input - Files: 1. Extracted Coordinates from FBX file 2. OutputPath 3. txt file containing names of the markers (HandMarkerNames.txt / Old_HandMarkerNames.txt
%Output - Distance between hands for every frame (I guess)
%
function handDist=getDistanceBetweenHands(markerDataPath, handDistancePath, handMarkerNamesPath)

    data = textread(handMarkerNamesPath, '%s', 'delimiter', '\r');
    load(markerDataPath);
    numberOfLines = length(data);
    handData=cell(1, numberOfLines);
    
    for i=1:numberOfLines
        handData{i} = getDataForMarker(markerData, data{i});
    end
    
    hand1mean = (handData{1}+handData{2})./2;
    hand2mean = (handData{3}+handData{4})./2;
    
    handDist = find3dDistance(hand1mean, hand2mean);
    save(handDistancePath, 'handDist');
    
end