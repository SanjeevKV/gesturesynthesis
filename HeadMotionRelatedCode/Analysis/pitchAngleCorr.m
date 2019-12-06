function pitchAngleCorr(Language, Subject)
    
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    markerDIR = [DIR Language '/' Subject '/Marker/'];
    allWavsEn=dir([DIR Language '/' Subject '/Audio/*En.wav']);
    allWavsL1=dir([DIR Language '/' Subject '/Audio/*Story*' Language(1) '*.wav']);
    
    corrMeanEn=[];
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
        angles_120=markerdata(:,19:21);
        % downsample angles to 100 samples per second : ignore every 7th
        % sample
        
        angles=resample(angles_120,100,120);
        
        pitch=tp(t_tp>delay);
        nonZeroPitchInds=find(pitch ~= 0);
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
        
        % Now we have to map the non zero pitch intervals to the angles
        % time axis
        corr=[];
        for j=1:size(nonZeroTIntervals,1)
            startT=nonZeroTIntervals(j,1);
            endT=nonZeroTIntervals(j,2);
            m_inds=find(t_marker>=startT & t_marker<=endT);
            p_inds=find(t_pitch>=startT & t_pitch<=endT);
            
            m_data=angles(m_inds,:);
            p_data=pitch(p_inds);
            
            if(length(p_data) > 35 && size(m_data,1) ~= 0)
                t1=corrcoef(m_data(:,1),p_data);
                t2=corrcoef(m_data(:,2),p_data);
                t3=corrcoef(m_data(:,3),p_data);
                t=[t1(2,1) t2(2,1) t3(2,1)];

                corr=[corr;t];
            end
        end
        size(corr)
        corrMeanEn=[corrMeanEn;mean(abs(corr))];
        %corrMeanEn=[corrMeanEn;corr];
    end
    %corrMeanEn=mean(abs(corrMeanEn));
    
    corrMeanL1=[];
    for i=1:length(allWavsL1)
        filename=allWavsL1(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pitchfile=[wavfile(1:end-4) '_pitch.txt'];

        fl=filename(1:end-4)
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];

        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];
        fpFile = [fpDir fl '.txt'];
        
        t=load(markerfile);
        tp=load(pitchfile);t_tp=[1:length(tp)]/100;
        delay=load(delayfile);
        
        fid = fopen(fpFile);
        fpDatatmp = textscan(fid, '%f\t%f\t%*s');
        fclose(fid);
        fpData=cell2mat(fpDatatmp);
        clear fid fpDatatmp
        
        markerdata=t.data;
        angles_120=markerdata(:,19:21);
        % downsample angles to 100 samples per second : ignore every 7th
        % sample
        
        angles=[];
        for j=1:size(angles_120,1)
            if(mod(j,6) ~= 1)
                angles=[angles;angles_120(j,:)];
            end
        end
        
        fpData=fpData-delay;
        pitch=tp(t_tp>delay);
        nonZeroPitchInds=find(pitch ~= 0);
        pitch=pitch(1:nonZeroPitchInds(end));
        t_marker=[1:size(angles,1)]/100;
        t_pitch=[1:length(pitch)]/100;
        
        pitch_nZ=pitch(nonZeroPitchInds);
      
        nonZeroTimes=t_pitch(nonZeroPitchInds);
        
        % Remove the inds where it's a filled pause
%         finalInds=[];
%         oldendT=0;
%         for j=1:size(fpData,1)
%             startT=fpData(j,1);
%             endT=fpData(j,2);
%             if(j==size(fpData,1))
%                 nextstartT=nonZeroTimes(end);
%             else
%                 nextstartT=fpData(j+1,1);
%             end
%             tmpInds1=find(nonZeroTimes<startT & nonZeroTimes>oldendT);
%             tmpInds2=find(nonZeroTimes>endT & nonZeroTimes<nextstartT);
%             finalInds=[finalInds tmpInds1 tmpInds2];
%             oldendT=endT;
%         end
        
        %finalTimes=nonZeroTimes(finalInds);
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
        
        % Now we have to map the non zero pitch intervals to the angles
        % time axis
        corr=[];
        for j=1:size(nonZeroTIntervals,1)
            startT=nonZeroTIntervals(j,1);
            endT=nonZeroTIntervals(j,2);
            m_inds=find(t_marker>=startT & t_marker<=endT);
            p_inds=find(t_pitch>=startT & t_pitch<=endT);
            
            m_data=angles(m_inds,:);
            p_data=pitch(p_inds);
            
            if(length(p_data) > 35 && size(m_data,1) ~= 0)
                t1=corrcoef(m_data(:,1),p_data);
                t2=corrcoef(m_data(:,2),p_data);
                t3=corrcoef(m_data(:,3),p_data);
                t=[t1(2,1) t2(2,1) t3(2,1)];

                corr=[corr;t];
            end
        end
        size(corr)
        corrMeanL1=[corrMeanL1;mean(abs(corr))];
        %corrMeanL1=[corrMeanL1;corr];
    end
    %corrMeanL1=mean(abs(corrMeanL1));
    
    corrMeanEn
    %mean(corrMeanEn)
    %std(corrMeanEn)
    
    corrMeanL1
    %mean(corrMeanL1)
    %std(corrMeanL1)
    
%     [n1E,x1E]=hist(corrMeanEn(:,1));
%     [n1L,x1L]=hist(corrMeanL1(:,1));
%     figure;plot(x1E,n1E/sum(n1E));hold on;plot(x1L,n1L/sum(n1L),'r');
%     
%     [n2E,x2E]=hist(corrMeanEn(:,2));
%     [n2L,x2L]=hist(corrMeanL1(:,2));
%     figure;plot(x2E,n2E/sum(n2E));hold on;plot(x2L,n2L/sum(n2L),'r');
%     
%     [n3E,x3E]=hist(corrMeanEn(:,3));
%     [n3L,x3L]=hist(corrMeanL1(:,3));
%     figure;plot(x3E,n3E/sum(n3E));hold on;plot(x3L,n3L/sum(n3L),'r');
    
end