function calcFPPercent(Language, Subject)

    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    markerDIR = [DIR Language '/' Subject '/Marker/'];
    allWavs=dir([DIR Language '/' Subject '/Audio/*.wav']);
    fpDir = ['F:/IIScProjectMain/Optitrack/Annotation/' Subject '/FP/' ];

    for i=1:length(allWavs)
        filename=allWavs(i).name;
        wavfile=[DIR Language '/' Subject '/Audio/' filename];
        fl=filename(1:end-4)
        markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
        markerfile=[markerDIR markerfilelist(1).name];
        fpFile = [fpDir fl '.txt'];

        t=load(markerfile);
        markerdata=t.data;
        angles_120=markerdata(:,19:21);
        
        fid = fopen(fpFile);
        fpDatatmp = textscan(fid, '%f\t%f\t%*s');
        fclose(fid);
        fpData=cell2mat(fpDatatmp);
        clear fid fpDatatmp
        
        tot_length=size(angles_120,1)/120;
        fp_length=sum(fpData(:,2)-fpData(:,1));
        
        fpPercent=fp_length/tot_length
    end
end