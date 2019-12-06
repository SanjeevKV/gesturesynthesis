function createPitchAngleMeasuresWindowed(Language,Subject)

    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    markerDIR = [DIR Language '/' Subject '/Marker/'];
    saveDIR=['F:/IIScProjectMain/Optitrack/Analysis/PitchAnglesMeasuresWindowed/' Language '/' Subject '/'];
    allWavsEn=dir([DIR Language '/' Subject '/Audio/*En.wav']);
    allWavsL1=dir([DIR Language '/' Subject '/Audio/*Story*' Language(1) '*.wav']);
    
    for i=1:length(allWavsEn)
        
        filename=allWavsEn(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pitchfile=[wavfile(1:end-4) '_pitch.txt'];
        mfccfile=[wavfile(1:end-4) '.mfc'];

        fl=filename(1:end-4)
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];

        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];

        t=load(markerfile);
        tp=load(pitchfile);t_tp=[1:length(tp)]/100;
        mfcc=readhtk(mfccfile);t_mfcc=[1:size(mfcc,1)]/100;
        delay=load(delayfile);
        
        markerdata=t.data;
        angles_120=markerdata(:,19:21);t_angles_120=[1:length(angles_120)]/120;
        angles_120=angles_120+180;
        
        % downsample angles to 100 samples per second 
%         angles=resample(angles_120,100,120);
        angles=interp1(t_angles_120,angles_120,t_tp);
        
        pitch=tp(t_tp>delay);
        mfcc=mfcc(t_mfcc>delay,:);
        nonZeroPitchInds=find(pitch);
        pitch=pitch(1:nonZeroPitchInds(end));
        
        t_marker=[1:size(angles,1)]/100;
        t_pitch=[1:length(pitch)]/100;
        t_mfcc=[1:size(mfcc,1)]/100;
        nZPitchT=t_pitch(nonZeroPitchInds);
        
        windowSize=1*100;
        shift=100;
        segsStart=(1:shift:size(angles,1)-windowSize)/100;
        segsEnd=(windowSize+1:shift:size(angles,1))/100;
        segs=[segsStart' segsEnd'];
        segs=segs';
        segs=segs(:)
        
        measuresEn=struct();
        measuresEn.mean=[];measuresEn.std=[];measuresEn.median=[];measuresEn.kurt=[];measuresEn.dur=[];measuresEn.corr=[];
        for j=1:2:length(segs)-1
            angles_window=angles(t_marker>=segs(j) & t_marker<segs(j+1),:);
            pitch_window=pitch(t_pitch>=segs(j) & t_pitch<segs(j+1));
            mfcc_window=mfcc(t_mfcc>=segs(j) & t_mfcc<segs(j+1),:);
            
%             zeroPitchInds=find(pitch_window==0);
%             pitch_window(zeroPitchInds)=[];
%             angles_window(zeroPitchInds,:)=[];
%             mfcc_window(zeroPitchInds,:)=[];
            
            angNorm=sum(diff(angles_window).^2,2).^0.5;
            
            if(sum(sum(isnan(angles_window))) == 0 && size(angles_window,1)>20 && size(pitch_window,1)==size(angles_window,1))
                measuresEn.dur=[measuresEn.dur length(pitch_window)];

                meantmp=[mean(angles_window) mean(pitch_window) mean(mfcc_window)];
                stdtmp=[std(angles_window) std(pitch_window) std(mfcc_window)];
                mediantmp=[median(angles_window) median(pitch_window) median(mfcc_window)];
                kurttmp=[kurtosis(angles_window) kurtosis(pitch_window) kurtosis(mfcc_window)];
                
                t1=corrcoef(angles_window(:,1),pitch_window);
                t2=corrcoef(angles_window(:,2),pitch_window);
                t3=corrcoef(angles_window(:,3),pitch_window);
                t4=corrcoef(angNorm,pitch_window(2:end));
                
                corr=[t1(2,1) t2(2,1) t3(2,1) t4(2,1)];

                measuresEn.mean=[measuresEn.mean meantmp'];
                measuresEn.std=[measuresEn.std stdtmp'];
                measuresEn.median=[measuresEn.median mediantmp'];
                measuresEn.kurt=[measuresEn.kurt kurttmp'];
                measuresEn.corr=[measuresEn.corr corr'];
            end
        end
        save([saveDIR 'Story' num2str(i) 'En.mat'],'measuresEn');
    end
    
    for i=1:length(allWavsL1)
        
        filename=allWavsL1(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        pitchfile=[wavfile(1:end-4) '_pitch.txt'];
        mfccfile=[wavfile(1:end-4) '.mfc'];

        fl=filename(1:end-4)
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];

        tmp=markerfilelist(1).name;
        delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt'];
        
        t=load(markerfile);
        tp=load(pitchfile);t_tp=[1:length(tp)]/100;
        mfcc=readhtk(mfccfile);t_mfcc=[1:size(mfcc,1)]/100;
        delay=load(delayfile);
        
        markerdata=t.data;
        angles_120=markerdata(:,19:21);t_angles_120=[1:length(angles_120)]/120;
        angles_120=angles_120+180;
        
        % downsample angles to 100 samples per second
%         angles=resample(angles_120,100,120);
        angles=interp1(t_angles_120,angles_120,t_tp);
        
        pitch=tp(t_tp>delay);
        mfcc=mfcc(t_mfcc>delay,:);
        nonZeroPitchInds=find(pitch);
        pitch=pitch(1:nonZeroPitchInds(end));
        
        t_marker=[1:size(angles,1)]/100;
        t_pitch=[1:length(pitch)]/100;
        t_mfcc=[1:size(mfcc,1)]/100;
        
        windowSize=1*100;
        shift=100;
        segsStart=(1:shift:size(angles,1)-windowSize)/100;
        segsEnd=(windowSize+1:shift:size(angles,1))/100;
        segs=[segsStart' segsEnd'];
        segs=segs';
        segs=segs(:);
        
        measuresL1=struct();
        measuresL1.mean=[];measuresL1.std=[];measuresL1.median=[];measuresL1.kurt=[];measuresL1.dur=[];measuresL1.corr=[];
        for j=1:2:length(segs)-1
            angles_window=angles(t_marker>=segs(j) & t_marker<segs(j+1),:);
            pitch_window=pitch(t_pitch>=segs(j) & t_pitch<segs(j+1));
            mfcc_window=mfcc(t_mfcc>=segs(j) & t_mfcc<segs(j+1),:);
            
%             zeroPitchInds=find(pitch_window==0);
%             pitch_window(zeroPitchInds)=[];
%             angles_window(zeroPitchInds,:)=[];
%             mfcc_window(zeroPitchInds,:)=[];
                            
            angNorm=sum(diff(angles_window).^2,2).^0.5;
            
            if(sum(sum(isnan(angles_window))) == 0 && size(angles_window,1)>20 && size(pitch_window,1)==size(angles_window,1))
                measuresL1.dur=[measuresL1.dur length(pitch_window)];

                meantmp=[mean(angles_window) mean(pitch_window) mean(mfcc_window)];
                stdtmp=[std(angles_window) std(pitch_window) std(mfcc_window)];
                mediantmp=[median(angles_window) median(pitch_window) median(mfcc_window)];
                kurttmp=[kurtosis(angles_window) kurtosis(pitch_window) kurtosis(mfcc_window)];
                
                t1=corrcoef(angles_window(:,1),pitch_window);
                t2=corrcoef(angles_window(:,2),pitch_window);
                t3=corrcoef(angles_window(:,3),pitch_window);
                t4=corrcoef(angNorm,pitch_window(2:end));
                
                corr=[t1(2,1) t2(2,1) t3(2,1) t4(2,1)];

                measuresL1.mean=[measuresL1.mean meantmp'];
                measuresL1.std=[measuresL1.std stdtmp'];
                measuresL1.median=[measuresL1.median mediantmp'];
                measuresL1.kurt=[measuresL1.kurt kurttmp'];
                measuresL1.corr=[measuresL1.corr corr'];
            end
        end
        save([saveDIR 'Story' num2str(i) 'L1.mat'],'measuresL1');
    end

end