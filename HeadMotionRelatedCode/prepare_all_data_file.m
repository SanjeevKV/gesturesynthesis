function prepare_all_data_file(direct,file_name,Key_word,timing)

% list = dir([direct ,'/*.fbx.mat']);

    
    eval(['load ',file_name]);
    headData=getAllHeadMarkerData(markerData,'/home/prr/my_project/HeadMotionRelatedCode/HeadMarkerNames.txt');
    transform=getTransformForObject(headData, 6);
    
    data=[];
    for j=1:length(headData)
        data=[data headData{j}];
    end
    data = [data transform];
    s=floor(timing*120);
    final_data=data(s:end,:);
    eval(['save ', [direct ,'Extracted/',Key_word], '_Data.mat ','data',' timing',' final_data']);
    


end