Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
%Languages={'Hindi'};
DIR='F:/IIScProjectMain/Optitrack/Analysis/AngleQuadrant/';

th=0;
train_data=[];
target=[];
test_data=[];
test_target=[];
subjCount=0;
for i=1:length(Languages)
Subjects=dir([DIR Languages{i}]);
for j=3:length(Subjects)
    lang=Languages{i};
    subject=Subjects(j).name
    subjCount=subjCount+1;
    count=0;
    for st=1:4
        q=load([DIR lang '/' subject '/Story' num2str(st) 'En_Q_' num2str(th) '.txt']);
        for kk=1:120:length(q)-120*60
%             unigram
%             [n x]=hist(q(kk:kk+120*60),2:9);
%             train_data=[train_data; n/sum(n)];

%             bigram
            stateMat=zeros(8,8);
            qseq=q(kk:kk+120*60);
            transitionCount=0;
            for ii=1:length(qseq)-1
                if(qseq(ii)~=qseq(ii+1))
                    stateMat(qseq(ii)-1,qseq(ii+1)-1)=stateMat(qseq(ii)-1,qseq(ii+1)-1)+1;
                    transitionCount=transitionCount+1;
                end
            end
%             stateMat=zeros(8,8,8);
%             qseq=q(kk:kk+120*60);
%             transitionCount=0;
%             for ii=1:length(qseq)-2
%                 if(~(qseq(ii)==qseq(ii+1) && qseq(ii)==qseq(ii+2)))
%                     if(qseq(ii)~=1 && qseq(ii+1)~=1 && qseq(ii+2)~=1)
%                         stateMat(qseq(ii)-1,qseq(ii+1)-1,qseq(ii+2)-1)=stateMat(qseq(ii)-1,qseq(ii+1)-1,qseq(ii+2)-1)+1;
%                         transitionCount=transitionCount+1;
%                     end
%                 end
%             end
            %Ignoring transitions from 1
%             stateMat(:,1)=[];
%             stateMat(1,:)=[];
            stateMat=stateMat/transitionCount;
            train_data=[train_data;stateMat(:)'];

            count=count+1;
        end
    end
    t_template=zeros(1,24);t_template(subjCount)=1;target=[target;repmat(t_template,[count,1])];
    % Story 5 test

    count=0;
    q=load([DIR lang '/' subject '/Story5En_Q_' num2str(th) '.txt']);
    for kk=1:120:length(q)-120*60
%         unigram
%         [n x]=hist(q(kk:kk+120*60),2:9);
%         test_data=[test_data; n/sum(n)];
%         bigram
        stateMat=zeros(8,8);
        qseq=q(kk:kk+120*60);
        transitionCount=0;
        for ii=1:length(qseq)-1
            if(qseq(ii)~=qseq(ii+1))
                stateMat(qseq(ii)-1,qseq(ii+1)-1)=stateMat(qseq(ii)-1,qseq(ii+1)-1)+1;
                transitionCount=transitionCount+1;
            end
        end
%         %Ignoring transitions from 1
%         stateMat(:,1)=[];
%         stateMat(1,:)=[];
%         stateMat=zeros(8,8,8);
%         qseq=q(kk:kk+120*60);
%         transitionCount=0;
%         for ii=1:length(qseq)-2
%             if(~(qseq(ii)==qseq(ii+1) && qseq(ii)==qseq(ii+2)))
%                 if(qseq(ii)~=1 && qseq(ii+1)~=1 && qseq(ii+2)~=1)
%                     stateMat(qseq(ii)-1,qseq(ii+1)-1,qseq(ii+2)-1)=stateMat(qseq(ii)-1,qseq(ii+1)-1,qseq(ii+2)-1)+1;
%                     transitionCount=transitionCount+1;
%                 end
%             end
%         end
        stateMat=stateMat/transitionCount;
        test_data=[test_data;stateMat(:)'];
        
        count=count+1;
    end
    t_template=zeros(1,24);t_template(subjCount)=1;test_target=[test_target;repmat(t_template,[count,1])];
end
end

% bigram
% After removing 1 state stateMat becomes 8x8...diagnals are every +9th
% otherwise every +10th

train_data(:,1:9:end)=[];
test_data(:,1:9:end)=[];

% trigram
% ind=[];
% for i=1:8
%     ind=[ind;sub2ind([8,8,8],i,i,i)];
% end
% 
% train_data(:,ind)=[];
% test_data(:,ind)=[];

save([DIR '/nntrain_0_22.mat'],'train_data');
save([DIR '/nntarget.mat'],'target');
save([DIR '/nntest_0_22.mat'],'test_data');
save([DIR '/nntest_target.mat'],'test_target');
