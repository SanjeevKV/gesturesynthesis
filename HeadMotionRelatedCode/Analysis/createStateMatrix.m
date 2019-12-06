function createStateMatrix(Language,Subject)

    DIR=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/' Subject '/Marker/'];
    
    fileList=dir([DIR '*_Q.mat']);
    
    stateMatrix=zeros(9,9);
    count=0;
    for i=1:length(fileList)
        load([DIR fileList(i).name]); % qseq
        for j=1:length(qseq)-1
            stateMatrix(qseq(j),qseq(j+1))=stateMatrix(qseq(j),qseq(j+1))+1;
        end
        count=count+length(qseq);
        clear qseq
    end
    
    stateMatrix=stateMatrix/count
end