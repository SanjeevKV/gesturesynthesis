function calcPausePercent(Language, Subject)
    
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    markerDIR = [DIR Language '/' Subject '/Marker/'];
    allWavsEn=dir([DIR Language '/' Subject '/Audio/*En.wav']);
    allWavsL1=dir([DIR Language '/' Subject '/Audio/*Story*' Language(1) '*.wav']);
    
    pEn=[];
    for i=1:length(allWavsEn)
        filename=allWavsEn(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pausefile=[wavfile(1:end-4) '_pause.txt'];
        fl=filename(1:end-4)
        
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];
        t=load(markerfile);
        markerdata=t.data;
        angles_120=markerdata(:,19:21);
        
        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];
        delay=load(delayfile);
        
        totalTime=size(angles_120,1)/120;
        
        tpause=load(pausefile);
        inds=find(tpause(:,2)>delay);
        tpause=tpause(inds,:);
        totalPause=sum(tpause(:,2)-tpause(:,1));
        
        pPercent = totalPause/totalTime;
        pEn=[pEn pPercent];
    end
    
    pL1=[];
    for i=1:length(allWavsL1)
        filename=allWavsL1(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pausefile=[wavfile(1:end-4) '_pause.txt'];
        fl=filename(1:end-4)
        
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];
        t=load(markerfile);
        markerdata=t.data;
        angles_120=markerdata(:,19:21);
        
        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];
        delay=load(delayfile);
        
        totalTime=size(angles_120,1)/120;
        
        tpause=load(pausefile);
        inds=find(tpause(:,2)>delay);
        tpause=tpause(inds,:);
        totalPause=sum(tpause(:,2)-tpause(:,1));
        
        totalPause=sum(tpause(:,2)-tpause(:,1));
        pPercent = totalPause/totalTime;
        pL1=[pL1 pPercent];
    end
    
    pEn
    mean(pEn)
    std(pEn)
    
    pL1
    mean(pL1)
    std(pL1)
    
end