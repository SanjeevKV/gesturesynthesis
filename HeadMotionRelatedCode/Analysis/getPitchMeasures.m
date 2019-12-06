function [measuresEn,measuresL1]=getPitchMeasures(Language, Subject)

DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';

allwavsEn=dir([DIR Language '/' Subject '/Audio/*En.wav']);
allwavsL1=dir([DIR Language '/' Subject '/Audio/*Story*' Language(1) '*.wav']);

measuresEn=struct();
measuresEn.mean=[];measuresEn.std=[];measuresEn.median=[];measuresEn.kurt=[];measuresEn.dur=[];
for i=1:length(allwavsEn)
    
    filename=allwavsEn(i).name;
    wavfile=[DIR Language '/' Subject '/Audio/' filename];
    pitchfile=[wavfile(1:end-4) '_pitch.txt'];
    
    pitch=load(pitchfile);
    t_pitch=[1:length(pitch)]/100;
    
    nonZeroPitchInds = find(pitch);
    nonZeroTimes=t_pitch(nonZeroPitchInds);
    
    nonZeroIndIntervals=[];
    tmp=[nonZeroPitchInds(1)];
    % Calculate the intervals of time in between which pitch is non
    % zero
    for j=2:length(nonZeroTimes)
        if((nonZeroTimes(j)-nonZeroTimes(j-1)-0.01)>0.00001)
            tmp=[tmp nonZeroPitchInds(j-1)];
            nonZeroIndIntervals=[nonZeroIndIntervals;tmp];
            tmp=[nonZeroPitchInds(j)];
        end
    end
    clear tmp;
    
    for j=1:size(nonZeroIndIntervals,1)
        pseg=pitch(nonZeroIndIntervals(j,1):nonZeroIndIntervals(j,2));
        measuresEn.dur=[measuresEn.dur length(pseg)];
        measuresEn.mean=[measuresEn.mean mean(pseg)];
        measuresEn.std=[measuresEn.std std(pseg)];
        measuresEn.median=[measuresEn.median median(pseg)];
        measuresEn.kurt=[measuresEn.kurt kurtosis(pseg)];
    end
    
end

measuresL1=struct();
measuresL1.mean=[];measuresL1.std=[];measuresL1.median=[];measuresL1.kurt=[];measuresL1.dur=[];
for i=1:length(allwavsL1)
    
    filename=allwavsL1(i).name;
    wavfile=[DIR Language '/' Subject '/Audio/' filename];
    pitchfile=[wavfile(1:end-4) '_pitch.txt'];
    
    pitch=load(pitchfile);
    t_pitch=[1:length(pitch)]/100;
    
    nonZeroPitchInds = find(pitch);
    nonZeroTimes=t_pitch(nonZeroPitchInds);
    
    nonZeroIndIntervals=[];
    tmp=[nonZeroPitchInds(1)];
    % Calculate the intervals of time in between which pitch is non
    % zero
    for j=2:length(nonZeroTimes)
        if((nonZeroTimes(j)-nonZeroTimes(j-1)-0.01)>0.00001)
            tmp=[tmp nonZeroPitchInds(j-1)];
            nonZeroIndIntervals=[nonZeroIndIntervals;tmp];
            tmp=[nonZeroPitchInds(j)];
        end
    end
    clear tmp;
    for j=1:size(nonZeroIndIntervals,1)
        pseg=pitch(nonZeroIndIntervals(j,1):nonZeroIndIntervals(j,2));
        measuresL1.dur=[measuresL1.dur length(pseg)];
        measuresL1.mean=[measuresL1.mean mean(pseg)];
        measuresL1.std=[measuresL1.std std(pseg)];
        measuresL1.median=[measuresL1.median median(pseg)];
        measuresL1.kurt=[measuresL1.kurt kurtosis(pseg)];
    end
end

end