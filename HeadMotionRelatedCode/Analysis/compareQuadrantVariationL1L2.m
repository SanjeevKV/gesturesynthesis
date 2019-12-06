function [EnEn,L1L1,EnL1]=compareQuadrantVariationL1L2(Language, Subject, thresh, order)


    baseDIR='F:/IIScProjectMain/Optitrack/Analysis/AngleQuadrant/';
    subjDIR=[baseDIR Language '/' Subject '/'];
    
    fileListEn=dir([subjDIR 'Story*En_Q_' num2str(thresh) '_uniq.txt']);
    fileListL1=dir([subjDIR 'Story*L1_Q_' num2str(thresh) '_uniq.txt']);
    
    histEn=zeros(5,8^order);
    histL1=zeros(5,8^order);
    
    for i=1:length(fileListEn)
        windowCount=0;
        qMat=load([subjDIR fileListEn(i).name]);
        s=qMat(:,1);
        for wi=1:length(s)-order+1
            seq=s(wi:wi+order-1);
            windowCount=windowCount+1;
            uniqHash=convertToHash(seq); %uniqHash starts from 0
            histEn(i,uniqHash+1)=histEn(i,uniqHash+1)+1;
        end
        histEn(i,:)=histEn(i,:)/windowCount;
    end
    
    for i=1:length(fileListL1)
        windowCount=0;
        qMat=load([subjDIR fileListL1(i).name]);
        s=qMat(:,1);
        for wi=1:length(s)-order+1
            seq=s(wi:wi+order-1);
            windowCount=windowCount+1;
            uniqHash=convertToHash(seq); %uniqHash starts from 0
            histL1(i,uniqHash+1)=histL1(i,uniqHash+1)+1;
        end
        histL1(i,:)=histL1(i,:)/windowCount;
    end
    
    EnEn=[];
    L1L1=[];
    EnL1=[];
    
    for i=1:length(fileListEn)
        for j=i+1:length(fileListEn)
            d=pdist([histEn(i,:);histEn(j,:)],'cosine');
            EnEn=[EnEn;d];
        end
    end
    
    for i=1:length(fileListL1)
        for j=i+1:length(fileListEn)
            d=pdist([histL1(i,:);histL1(j,:)],'cosine');
            L1L1=[L1L1;d];
        end
    end
    
    for i=1:length(fileListEn)
        for j=1:length(fileListL1)
            d=pdist([histEn(i,:);histL1(j,:)],'cosine');
            EnL1=[EnL1;d];
        end
    end
    
end