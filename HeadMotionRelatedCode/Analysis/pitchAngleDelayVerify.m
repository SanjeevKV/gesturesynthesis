function pitchAngleDelayVerify(Language,Subject)

DIR=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/' Subject '/Marker/' ];
audioDIR=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/' Subject '/Audio/' ];
fileList=dir([audioDIR '*En.wav'])
for q=1:length(fileList)
    audioFile=[audioDIR fileList(q).name];
    [y,fs]=wavread(audioFile);
    
    markerFileList=dir([DIR '*_Story' num2str(q) 'EnData.mat']);
    markerFile=markerFileList(1).name;
    load([DIR markerFile]); %data
    delayFileList=dir([DIR '*_Story' num2str(q) 'En*Delay.txt']);
    delay=load([DIR delayFileList(1).name]);
    delay=floor(delay*100);
    
    %[~,~,~,~,nzIntervals5]=corr_coefff_window3(Language,Subject,number);
    nzIntervals5=[6000 7000;8000 9000];
    markerData=data(:,1:18);
    saveDIR='F:/IIScProjectMain/Optitrack/Analysis/DelayVerifyVids/';
    for i=1:size(nzIntervals5,1)
        startF=nzIntervals5(i,1);
        endF=nzIntervals5(i,2);
        
        startA=floor((startF+delay)/100*fs);
        endA=floor((endF+delay)/100*fs);
        audiowrite([saveDIR Subject '_s' num2str(q) '_In' num2str(i) '.wav'],y(startA:endA),fs);
        
        startV=floor(startF/100*120);
        endV=floor(endF/100*120);
        
        min_x=min(min(data(startV:endV,1:3:16)));
        max_x=max(max(data(startV:endV,1:3:16)));
        r_x=max_x-min_x;
        min_y=min(min(data(startV:endV,2:3:17)));
        max_y=max(max(data(startV:endV,2:3:17)));
        r_y=max_y-min_y;
        min_z=min(min(data(startV:endV,3:3:18)));
        max_z=max(max(data(startV:endV,3:3:18)));
        r_z=max_z-min_z;
        
        thresh=0.5;
        
        ax=[min_x-thresh*r_x max_x+thresh*r_x min_y-thresh*r_y max_y+thresh*r_y min_z-thresh*r_z max_z+thresh*r_z];
        
        myVideo=VideoWriter([saveDIR Subject '_s' num2str(q) '_In' num2str(i)],'MPEG-4');
        myVideo.FrameRate=120;
        open(myVideo);
        for j=startV:endV
            plot3(data(j,1:3:16),data(j,2:3:17),data(j,3:3:18),'*');hold on;
            view(0,90);
            axis(ax);
            hold off;
            writeVideo(myVideo,getframe);
        end
        close(myVideo);
    end
end

end