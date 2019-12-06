function createPauseNonPauseAngles(Language, Subject)

DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
markerDIR=[DIR Language '/' Subject '/Marker/'];
saveDirPause=[markerDIR '/Pause_Angles/' ];
saveDirNonPause=[markerDIR '/NonPause_Angles/'];

allwavs=dir([DIR Language '/' Subject '/Audio/*.wav']);

mkdir(saveDirPause);
mkdir(saveDirNonPause);

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
    
    % pitch at 100Hz. To get where speaking starts check first pitch
    % non-zero value after delay.
    
    %Code to find where the the pitch is non-zero for the first time after
    %delay
    
    nonZeroPitchInd = find(tp);
    delayFramesBy = delay*100;
    
    tmp = find(nonZeroPitchInd>delayFramesBy);
    speechStartPitchFrame = nonZeroPitchInd(tmp(1));
    speechStartTime = speechStartPitchFrame/100;
    speechStartTime_euler=speechStartTime-delay;
    angles=angles(speechStartTime_euler*120:end,:);
    % To remove -ve angles
    angles=angles+180;

    % Now among the angles we need to separate the pause and non-pause areas
    t_pause_euler=t_pause-delay;
    % Remove the pause before speech started
    tmp2 = find(t_pause_euler(:,1)>speechStartTime_euler);
    t_pause_euler = t_pause_euler(tmp2(1):end,:);
    
    angleDataDuration=size(angles,1)/120;
    tmp2=find(t_pause_euler(:,2)<angleDataDuration);
    t_pause_euler = t_pause_euler(1:tmp2(end),:);
    
    angles_pause=[];
    angles_non_pause=angles;
    lastEnd=0;
    lastStart=0;
    for j=1:length(t_pause_euler)
        t=[floor(t_pause_euler(j,1)*120) floor(t_pause_euler(j,2)*120)];
        skipLoop=false;
        if (t(1,2) > lastEnd)
            if(lastEnd >= t(1,1) || t(1,1) == lastStart)
                t(1,1) = lastEnd+1;
                if(t(1,1)>t(1,2))
                    skipLoop=true;
                end
            end
            if(~skipLoop)
                angles_pause=[angles_pause;angles(t(1,1):t(1,2),:)];
                angles_non_pause(t(1,1):t(1,2),:)=100000;
                lastEnd=t(1,2);
                lastStart=t(1,1);
            end
        end
    end
    
    %reshaping angles_non_pause
    angles_non_pause = angles_non_pause(angles_non_pause ~= 100000);
    angles_non_pause = reshape(angles_non_pause,[],3);
    
    if(size(angles_non_pause,1)+size(angles_pause,1) ~= size(angles,1))
        size(angles)
        size(angles_pause)
        size(angles_non_pause)
        pause;
    end
    disp('Angles pause and non-pause prep ended');
    
    save([saveDirPause fl 'Data.mat'],'angles_pause');
    save([saveDirNonPause fl 'Data.mat'],'angles_non_pause');
    
end

end