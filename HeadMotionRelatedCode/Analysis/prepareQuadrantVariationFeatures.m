function prepareQuadrantVariationFeatures(thresh, order)

Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
%Languages={'Hindi'};
DIR='F:/IIScProjectMain/Optitrack/Analysis/AngleQuadrant/';

train_data=zeros(24,8^order);
train_data_temporal=cell(24,8^order);
test_data=zeros(24,8^order);
test_data_temporal=cell(24,8^order);
%test_count=zeros(24,8^order);

subjCount=0;
for i=1:length(Languages)
    Subjects=dir([DIR Languages{i}]);
    for j=3:length(Subjects)
        lang=Languages{i};
        subj=Subjects(j).name
        subjCount=subjCount+1;
        subjDIR=[DIR '/' lang '/' subj '/'];
        
        %fileList=dir([subjDIR 'Story*En_Q_' num2str(thresh) '_uniq.txt']);
        fileList=dir([subjDIR 'Story*L1_Q_' num2str(thresh) '_uniq.txt']);
        trainFileList=fileList(1:end-1);
        testFileList=fileList(end);
        
        windowCount=0;
        for k=1:length(trainFileList)
            qMat=load([subjDIR trainFileList(k).name]);
            s=qMat(:,1);
            t=qMat(:,2);
            for wi=1:length(s)-order+1
                seq=s(wi:wi+order-1);
                
                %Ignoring last window
                if(wi+order-1==length(s))
                    break;
                end
                
                windowCount=windowCount+1;
                uniqHash=convertToHash(seq); %uniqHash starts from 0
                train_data(subjCount,uniqHash+1)=train_data(subjCount,uniqHash+1)+1;
                
                temp=train_data_temporal{subjCount,uniqHash+1};
                temp=[temp;k,t(wi),t(wi+order)-1];% Since t marks start of sequence, end will be t(wi+order)-1 
                train_data_temporal{subjCount,uniqHash+1}=temp;
            end
        end
        train_data(subjCount,:)=train_data(subjCount,:)/windowCount;
        
        windowCount=0;
        for k=1:length(testFileList)
            qMat=load([subjDIR testFileList(k).name]);
            s=qMat(:,1);
            t=qMat(:,2);
            for wi=1:length(s)-order+1
                seq=s(wi:wi+order-1);
                
                 %Ignoring last window
                if(wi+order-1==length(s))
                    break;
                end
                
                windowCount=windowCount+1;
                uniqHash=convertToHash(seq); %uniqHash starts from 0
                test_data(subjCount,uniqHash+1)=test_data(subjCount,uniqHash+1)+1;
                
                temp=test_data_temporal{subjCount,uniqHash+1};
                % 5th Story is test
                % always---------------------------Change-------------------------
                temp=[temp;5,t(wi),t(wi+order)-1];% Since t marks start of sequence, end will be t(wi+order)-1 
                test_data_temporal{subjCount,uniqHash+1}=temp;
            end
        end
        %test_count=test_data;
        test_data(subjCount,:)=test_data(subjCount,:)/windowCount;
        
    end
end

temp=train_data(:);
epsln=min(temp(find(temp~=0)))*10^(-3);
train_data=train_data+epsln;

temp=test_data(:);
epsln=min(temp(find(temp~=0)))*10^(-3);
test_data=test_data+epsln;
for kk=1:24
    train_data(kk,:)=train_data(kk,:)/sum(train_data(kk,:));
    test_data(kk,:)=test_data(kk,:)/sum(test_data(kk,:));
end

trainStruct=struct();
trainStruct.feat=train_data;
trainStruct.temporal=train_data_temporal;

testStruct=struct();
testStruct.feat=test_data;
testStruct.temporal=test_data_temporal;

save([DIR 'trainData_SeqCount_' num2str(order) 'L1.mat'],'trainStruct');
save([DIR 'testData_SeqCount_' num2str(order) 'L1.mat'],'testStruct');
%save([DIR 'testDataCount_SeqCount_' num2str(order) '.mat'],'test_count');


end