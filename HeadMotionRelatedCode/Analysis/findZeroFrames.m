function zeroData=findZeroFrames(dirPath)

list=dir([dirPath,'\*.fbx.mat']);

for i=1:length(list)
    eval(['load ',dirPath,'\',list(i).name]);
    temp = strsplit(list(i).name, '.');
    name=temp{1};
    
    [headData, markerNames]=getAllHeadMarkerData(markerData,'F:\IIScProjectMain\Optitrack\Code\HeadMarkerNames.txt');
    zeroData=cell(1, 20);
    maxFrames = length(headData{1});
    for j=1:length(headData)
        data=headData{j};
        dataSum = sum((data).^2,2);
        zeroIndices=find(dataSum==0);
        if(length(zeroIndices) > 1)
            interpolationInd = getInterpolationIndices(zeroIndices);
			if isempty(interpolationInd)
				interpolationInd=0;
			end
        else
            interpolationInd = 0;
        end
        zeroData{j*3-2}=markerNames{j};
        zeroData{j*3-1}=zeroIndices;
		zeroData{j*3}=interpolationInd;
    end
    zeroData{19} = 'MaxFrames';
    zeroData{20} = maxFrames;
    eval(['save ', dirPath, '\', name,'ZeroData.mat zeroData']);
    clear zeroData zeroIndices zeroCount headData markerNames markerData name temp;
end
end