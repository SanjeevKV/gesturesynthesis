function createPitchAngleMeasures(Language,Subject)

    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    markerDIR = [DIR Language '/' Subject '/Marker/'];
    saveDIR=['F:/IIScProjectMain/Optitrack/Analysis/PitchAngles_100/' Language '/' Subject '/'];
    allWavsEn=dir([DIR Language '/' Subject '/Audio/*En.wav']);
    allWavsL1=dir([DIR Language '/' Subject '/Audio/*Story*' Language(1) '*.wav']);
    
    for i=1:length(allWavsEn)
        filename=allWavsEn(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pitchfile=[wavfile(1:end-4) '_pitch.txt'];

        fl=filename(1:end-4)
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];

        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];

        t=load(markerfile);
        tp=load(pitchfile);t_tp=[1:length(tp)]/100;
        delay=load(delayfile);
        
        markerdata=t.data;
        angles_120=markerdata(:,19:21);t_angles_120=[1:length(angles_120)]/120;
        angles_120=angles_120+180;
        
        % downsample angles to 100 samples per second 
%         angles=resample(angles_120,100,120);
        angles=interp1(t_angles_120,angles_120,t_tp);
        
        
        pitch=tp(t_tp>delay);
        nonZeroPitchInds=find(pitch);
        pitch=pitch(1:nonZeroPitchInds(end));
        t_marker=[1:size(angles,1)]/100;
        t_pitch=[1:length(pitch)]/100;
        pitch_nZ=pitch(nonZeroPitchInds);
      
        nonZeroTimes=t_pitch(nonZeroPitchInds);
        finalTimes=nonZeroTimes;
        
        nonZeroTIntervals=[];
        tmp=[finalTimes(1)];
        % Calculate the intervals of time in between which pitch is non
        % zero
        for j=2:length(finalTimes)
            if((finalTimes(j)-finalTimes(j-1)-0.01)>0.00001)
                tmp=[tmp finalTimes(j-1)];
                nonZeroTIntervals=[nonZeroTIntervals;tmp];
                tmp=[finalTimes(j)];
            end
        end
        
%         measuresEn=struct();
%         measuresEn.mean=[];measuresEn.std=[];measuresEn.median=[];measuresEn.kurt=[];measuresEn.dur=[];
        
        dataEn=[];
        % Now we have to map the non zero pitch intervals to the angles
        % time axis
        for j=1:size(nonZeroTIntervals,1)
            startT=nonZeroTIntervals(j,1);
            endT=nonZeroTIntervals(j,2);
            
            m_inds=t_marker>=startT & t_marker<=endT;
            p_inds=t_pitch>=startT & t_pitch<=endT;
            
            m_data=angles(m_inds,:);
            p_data=pitch(p_inds);
            
            if(sum(sum(isnan(m_data)))>0)
                break;
            end
            if(size(m_data,1) > 10)
%                 measuresEn.dur=[measuresEn.dur length(p_data)];
% 
%                 meantmp=[mean(m_data) mean(p_data)];
%                 stdtmp=[std(m_data) std(p_data)];
%                 mediantmp=[median(m_data) median(p_data)];
%                 kurttmp=[kurtosis(m_data) kurtosis(p_data)];
%                 
% 
%                 measuresEn.mean=[measuresEn.mean meantmp'];
%                 measuresEn.std=[measuresEn.std stdtmp'];
%                 measuresEn.median=[measuresEn.median mediantmp'];
%                 measuresEn.kurt=[measuresEn.kurt kurttmp'];
                tmp=[m_data' ;p_data'];
                dataEn=[dataEn tmp];
            end
            
        end
        size(dataEn,2)
        if(sum(sum(isnan(dataEn))) > 0)
            dataEn
            pause
        end
        save([saveDIR 'Story' num2str(i) 'En.mat'],'dataEn');
    end
    
    for i=1:length(allWavsL1)
        filename=allWavsL1(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pitchfile=[wavfile(1:end-4) '_pitch.txt'];

        fl=filename(1:end-4)
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];

        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];
        
        t=load(markerfile);
        tp=load(pitchfile);t_tp=[1:length(tp)]/100;
        delay=load(delayfile);
        
        markerdata=t.data;
        angles_120=markerdata(:,19:21);t_angles_120=[1:length(angles_120)]/120;
        angles_120=angles_120+180;
        
        % downsample angles to 100 samples per second
%         angles=resample(angles_120,100,120);
        angles=interp1(t_angles_120,angles_120,t_tp);
        
        pitch=tp(t_tp>delay);
        nonZeroPitchInds=find(pitch);
        pitch=pitch(1:nonZeroPitchInds(end));
        t_marker=[1:size(angles,1)]/100;
        t_pitch=[1:length(pitch)]/100;
        
        pitch_nZ=pitch(nonZeroPitchInds);
      
        nonZeroTimes=t_pitch(nonZeroPitchInds);
        finalTimes=nonZeroTimes;
        
        nonZeroTIntervals=[];
        tmp=[finalTimes(1)];
        % Calculate the intervals of time in between which pitch is non
        % zero
        for j=2:length(finalTimes)
            if((finalTimes(j)-finalTimes(j-1)-0.01)>0.00001)
                tmp=[tmp finalTimes(j-1)];
                nonZeroTIntervals=[nonZeroTIntervals;tmp];
                tmp=[finalTimes(j)];
            end
        end
        
%         measuresL1=struct();
%         measuresL1.mean=[];measuresL1.std=[];measuresL1.median=[];measuresL1.kurt=[];measuresL1.dur=[];
        dataL1=[];
        % Now we have to map the non zero pitch intervals to the angles
        % time axis
        for j=1:size(nonZeroTIntervals,1)
            startT=nonZeroTIntervals(j,1);
            endT=nonZeroTIntervals(j,2);
            
            m_inds=t_marker>=startT & t_marker<=endT;
            p_inds=t_pitch>=startT & t_pitch<=endT;
            
            m_data=angles(m_inds,:);
            p_data=pitch(p_inds);
            
            dur=length(p_data);
            if(sum(sum(isnan(m_data)))>0)
                break;
            end
            if(size(m_data,1) > 10)
%                 measuresL1.dur=[measuresL1.dur length(p_data)];
% 
%                 meantmp=[mean(m_data) mean(p_data)];
%                 stdtmp = [std(m_data) std(p_data)];
%                 mediantmp=[median(m_data) median(p_data)];
%                 kurttmp=[kurtosis(m_data) kurtosis(p_data)];
% 
%                 measuresL1.mean=[measuresL1.mean meantmp'];
%                 measuresL1.std=[measuresL1.std stdtmp'];
%                 measuresL1.median=[measuresL1.median mediantmp'];
%                 measuresL1.kurt=[measuresL1.kurt kurttmp'];

                tmp=[m_data';p_data'];
                dataL1=[dataL1 tmp];
            end
            
        end
        size(dataL1,2)
        if(sum(sum(isnan(dataL1))) > 0)
            dataL1
            pause
        end
        save([saveDIR 'Story' num2str(i) 'L1.mat'],'dataL1');
    end

end