function createTransitionMatrix(Language,Subject)

    DIR=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/' Subject '/Marker/'];
    
    fileList=dir([DIR '*EnData_Q.mat']);
    
    stateMatrix=zeros(9,9);
    count=0;
    for i=1:length(fileList)
        load([DIR fileList(i).name]); % qseq
        c=0;
        for j=1:length(qseq)-1
            if(qseq(j)==qseq(j+1))
                continue;
            else
                stateMatrix(qseq(j),qseq(j+1))=stateMatrix(qseq(j),qseq(j+1))+1;
                c=c+1;
            end
        end
        count=count+c;
        clear qseq
    end
    
    stateMatrix=stateMatrix/count
end