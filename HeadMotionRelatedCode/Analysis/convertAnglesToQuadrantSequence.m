function convertAnglesToQuadrantSequence(Language,Subject)

    DIR=['F:/IISCProjectMain/Optitrack/ExtractedData/' Language '/' Subject '/Marker/'];
    saveDIR=['F:/IISCProjectMain/Optitrack/Analysis/AngleQuadrant/' Language '/' Subject '/'];
    mkdir(saveDIR);
    fileList=dir([DIR '*EnData.mat']);
    %fileList=dir([DIR '*Story*' Language(1) '*Data.mat']);
    
    for i=1:length(fileList)
        load([DIR fileList(i).name]); %data loaded
        angles=data(:,19:21);
        n=sum(angles.^2,2).^0.5;
        nr=range(n);
        
        qseq=[];
        
        % 1st frame is 0
        for j=2:size(angles,1)
            qseq=[qseq;get3DQuadrant(angles(j,1),angles(j,2),angles(j,3),nr)];
        end
        
        [Q1,t]=removeSubsequentDuplicates(qseq);
        Q=[Q1,t];
        save([saveDIR 'Story' num2str(i) 'En_Q_0_uniq.txt'],'Q','-ascii');
        %save([saveDIR 'Story' num2str(i) 'L1_Q_0_uniq.txt'],'Q','-ascii');
%         plot(qseq);pause
    end

end