% Right now only supports En, just to make it easy. Adding more is no big
% deal.
function compareWithIntraFaceAngles(Language,Subject,story,intrafaceFile)

    dataDIR=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/' Subject '/Marker/'];
    
    % Different Languages if you want should be handled starting from here
    fileList=dir([dataDIR '*Story' num2str(story) 'EnData.mat']);
    load([dataDIR fileList(1).name]); % data loaded
    
    markerData=data(:,1:18); % x,y,z coords for 6 markers
    
    % Bad way of doing it but oh well no internet right now
    filedata = textread(intrafaceFile, '%s', 'delimiter', '\r');
    totalRows=size(filedata,1);
    clear filedata
    
    intraFaceData=importIntrafaceData(intrafaceFile,3,totalRows);
    
    % Calculate the delay between intraface data and optitrack data
    fileList=dir([dataDIR '*Story' num2str(story) 'En*Delay.txt']);
    opti_audio_delay=load([dataDIR fileList(1).name]);
    
    intrapath=fileparts(intrafaceFile);
    video_audio_delay=load([intrapath '/Delay.txt']); % In frames
    
    % Assuming 25 fps
    video_audio_delay=video_audio_delay/25;
    
    % there's some trickiness here about the sign. With current values this
    % equation is right. Meaning intraface is delayed by these seconds
    % w.r.t optitrack data
    intraface_delay=abs(opti_audio_delay+video_audio_delay); 
    
    % For comparison, we can remove the optitrack data corresponding to the
    % delay
    markerData(1:intraface_delay*120,:)=[];
    
    % Optitrack data is at 120fps and intraface at 25fps.
    t_opti=[1:size(markerData,1)]/120;
    t_intraface=[1:size(intraFaceData,1)]/25;
    
    markerDataDown=interp1(t_opti,markerData,t_intraface);
    
    % Since we don't know reference position used for intraface, we will
    % find it by rotating back the first frame by the angles given by
    % intraface. Also we will have to rotate around the middle point of
    % eyes to be consistent with intraface.* sighs*
    
    % Making the upper nose marker origin. Marker columns : 13,14,15
    markerDataFinal=zeros(size(markerDataDown));
    markerDataFinal(:,1:3:end)=markerDataDown(:,1:3:end)-repmat(markerDataDown(:,13),1,size(markerDataDown(:,1:3:end),2));
    markerDataFinal(:,2:3:end)=markerDataDown(:,2:3:end)-repmat(markerDataDown(:,14),1,size(markerDataDown(:,2:3:end),2));
    markerDataFinal(:,3:3:end)=markerDataDown(:,3:3:end)-repmat(markerDataDown(:,15),1,size(markerDataDown(:,3:3:end),2));
    
    R=compose_rotation(-1*intraFaceData(1,1),-1*intraFaceData(1,2),-1*intraFaceData(1,3));
    
    % 1st frame from optitrack is all zeros. Starting from 2nd.
    
    refPos=R*[markerDataFinal(2,1:3);markerDataFinal(2,4:6);markerDataFinal(2,7:9);markerDataFinal(2,10:12);markerDataFinal(2,13:15);markerDataFinal(2,16:18)]';
    refPos=refPos';
    
    for i=2:size(markerDataFinal,1)
        currPos=zeros(6,3);
        for j=1:6
            currPos(j,:)=markerDataFinal(i,j*3-2:j*3);
        end
        % Index of the marker in middle of the eyes
        t = refPos(5,:)-currPos(5, :);
    end

end