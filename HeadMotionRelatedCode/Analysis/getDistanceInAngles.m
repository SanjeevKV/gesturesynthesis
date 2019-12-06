function getDistanceInAngles(Language, Subject)

    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    audioDIR=[DIR Language '/' Subject '/Audio/'];
    markerDIR=[DIR Language '/' Subject '/Marker/'];
    
    allwavs=dir([DIR Language '/' Subject '/Audio/*.wav']);
    
    for i=1:length(allwavs)
    
        filename=allwavs(i).name
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pausefile=[wavfile(1:end-4) '_pause.txt'];
        pitchfile=[wavfile(1:end-4) '_pitch.txt'];

        fl=filename(1:end-4);
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];
        t=load(markerfile);
        angles=t.data(:,19:21);
        
        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];

        tp=load(pitchfile);
        delay=load(delayfile);
        t_pause=load(pausefile);
        
        nonZeroPitchInd = find(tp);
        delayFramesBy = delay*100;

        tmp = find(nonZeroPitchInd>delayFramesBy);
        speechStartPitchFrame = nonZeroPitchInd(tmp(1));
        speechStartTime = speechStartPitchFrame/100;
        speechStartTime_euler=speechStartTime-delay;
        angles=angles(speechStartTime_euler*120:end,:);
        % To remove -ve angles
        angles=angles+180;
        
        dist=(sum(abs(diff(angles))))/size(angles,1)
end