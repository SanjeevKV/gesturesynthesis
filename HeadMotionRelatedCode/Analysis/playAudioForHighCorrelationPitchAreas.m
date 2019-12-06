audioDIR='F:/IIScProjectMain/Optitrack/ExtractedData/Bengali/Prasanta/Audio/';
markerDIR='F:/IIScProjectMain/Optitrack/ExtractedData/Bengali/Prasanta/Marker/';

fileList=dir([audioDIR '*En_pitch.txt']);
corrAll=[];
for i=1:5
    
    pitch_file=[audioDIR fileList(i).name]
    markerFileList=dir([markerDIR '*' fileList(i).name(1:end-10) '*Data.mat']);
    markerFile=[markerDIR markerFileList(1).name];
    delayFileList=dir([markerDIR '*' fileList(i).name(1:end-10) '*Delay.txt']);
    delayFile=[markerDIR delayFileList(1).name];
    audioFile=[audioDIR fileList(i).name(1:end-10) '.wav'];
    
    p=load(pitch_file);
    load(markerFile) %data
    angles=data(:,19:21);
    delay=load(delayFile);
    [y,fs]=wavread(audioFile);
    
    clear data pitch_file markerFileList delayFileList markerFile delayFile audioFile
    
    p(1:floor(delay*100))=[];
    y(1:floor(delay*fs))=[];
    
    tDelayEnd=length(p)/100-size(angles,1)/120;
    p(end-floor(tDelayEnd*100):end)=[];
    y(end-floor(tDelayEnd*fs):end)=[];
    
    tang=(1:size(angles,1))/120;
    tp=(1:length(p))/100;
    
    angles100=interp1(tang,angles,tp);
    
    angles100_v=diff(angles100);
    angles100_v=[angles100_v(1,:);angles100_v];
    
    angles100_a=diff(diff(angles100));
    angles100_a=[angles100_a(1,:);angles100_a(2,:);angles100_a];
    
    clear delay tDelayEnd angles tp tang 
    
    nzIntervals=[];
    nzInds=find(p~=0);
    temp=nzInds(1);
    for j=1:length(nzInds)-1
        if nzInds(j+1)~=nzInds(j)+1
            temp=[temp,nzInds(j)];
            nzIntervals=[nzIntervals;temp];
            temp=nzInds(j+1);
        end
    end
    
    smallInds=find((nzIntervals(:,2)-nzIntervals(:,1))<50);
    nzIntervals(smallInds,:)=[];
    
    clear nzInds temp smallInds
    
    corr=zeros(size(nzIntervals,1),9);
    for j=1:size(nzIntervals,1)
        ax=angles100(nzIntervals(j,1):nzIntervals(j,2),1);
        ay=angles100(nzIntervals(j,1):nzIntervals(j,2),2);
        az=angles100(nzIntervals(j,1):nzIntervals(j,2),3);
        
        avx=angles100_v(nzIntervals(j,1):nzIntervals(j,2),1);
        avy=angles100_v(nzIntervals(j,1):nzIntervals(j,2),2);
        avz=angles100_v(nzIntervals(j,1):nzIntervals(j,2),3);
        
        aax=angles100_v(nzIntervals(j,1):nzIntervals(j,2),1);
        aay=angles100_v(nzIntervals(j,1):nzIntervals(j,2),2);
        aaz=angles100_v(nzIntervals(j,1):nzIntervals(j,2),3);
        
        ptch=p(nzIntervals(j,1):nzIntervals(j,2));
        
        c=corrcoef(ax,ptch);
        corr(j,1)=c(2,1);
        c=corrcoef(ay,ptch);
        corr(j,2)=c(2,1);
        c=corrcoef(az,ptch);
        corr(j,3)=c(2,1);
        
        c=corrcoef(avx,ptch);
        corr(j,4)=c(2,1);
        c=corrcoef(avy,ptch);
        corr(j,5)=c(2,1);
        c=corrcoef(avz,ptch);
        corr(j,6)=c(2,1);

        c=corrcoef(aax,ptch);
        corr(j,7)=c(2,1);
        c=corrcoef(aay,ptch);
        corr(j,8)=c(2,1);
        c=corrcoef(aaz,ptch);
        corr(j,9)=c(2,1);
    end
    
    nanInds=find(isnan(sum(corr,2)));
    corr(nanInds,:)=[];
    nzIntervals(nanInds,:)=[];
    
    clear c ax ay az ptch nanInds
    
    corrAll=[corrAll;mean(abs(corr))];
    
    %inds=find(max(abs(corr),[],2)>0.7);
%     inds=find(mean(abs(corr),2)>0.6);
%     for j=1:length(inds)
%         startF=nzIntervals(inds(j),1)
%         endF=nzIntervals(inds(j),2)
%         y1=y(floor(startF/100*fs):floor(endF/100*fs));
%         soundsc(y1,fs);pause
%     end

end

mean(corrAll)