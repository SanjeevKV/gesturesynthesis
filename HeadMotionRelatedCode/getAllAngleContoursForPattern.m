function getAllAngleContoursForPattern(subject, order)

baseDIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
quadrantDIR='F:/IIScProjectMain/Optitrack/Analysis/AngleQuadrant/';

load([quadrantDIR 'SubjectMapping.mat']); % mapping loaded

subjInd=0;
for i=1:24
    if(strcmp(mapping(i,2),subject)==1)
        subjInd=i;
        break;
    end
end

% Looking at only trainData so 1st 4 stories
lang=mapping{subjInd,1};

dataDIR=[baseDIR lang '/' subject '/Marker/']
fileList=dir([dataDIR '*EnData.mat'])

ang=cell(1,4);

for i=1:length(fileList)-1
    load([dataDIR fileList(i).name]);
    ang{i}=data(:,19:21);
end

% Only En for now
load([quadrantDIR 'trainData_SeqCount_' num2str(order) 'En.mat']); %trainStruct

% histAll=testStruct.feat(subjInd,:);
% tAll=testStruct.temporal(subjInd,:);

histAll=trainStruct.feat(subjInd,:);
tAll=trainStruct.temporal(subjInd,:);

nzInds=find(histAll~=min(histAll));

histFinal=histAll;
t=tAll;

[Y,I]=sort(histFinal,2,'descend');

% plot(histFinal);
% I(1:10)
% t{I(1)}
% patternDurs=struct();

for i=1:length(I)
    pattInd=I(i)
    t_patt=t{pattInd};
%     patt=num2str(convertFromHash(pattInd-1));
% 
%     patt= patt(~isspace(patt))
%     patternDurs.(['x' patt])=[];
    size(t_patt,1)
    for j=1:size(t_patt,1)
        storyNo=t_patt(j,1)
        startFrame=t_patt(j,2);
        endFrame=t_patt(j,3);
        
        angles=ang{storyNo};
%         dur=endFrame-startFrame;
%         temp=patternDurs.(['x' patt]);
%         temp=[temp;dur];
%         patternDurs.(['x' patt])=temp;
        
        subplot(2,2,1);plot(angles(startFrame:endFrame,1),'b');title(num2str(convertFromHash(pattInd-1)));
        subplot(2,2,2);plot(angles(startFrame:endFrame,2),'g');subplot(2,2,3);
        plot(angles(startFrame:endFrame,3),'r');
    end
%     pause
%     close all;
end

% save([quadrantDIR '/Durations5/' subject '_' num2str(order) 'dur.mat'],'patternDurs')
save([quadrantDIR '/Durations5/' subject '_' num2str(order) '_contours.mat'],'patternDurs')

end