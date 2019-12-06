DIR='F:/IIScProjectMain/Optitrack/Analysis/PitchAnglesMeasuresWindowed/';
Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};

t=[];
for i=1:length(Languages)
    Subjects=dir([DIR Languages{i}]);
    for j=3:length(Subjects)
        lang=Languages{i};
        subject=Subjects(j).name;
        dataFilesEn=dir([DIR Languages{i} '/' subject '/*En.mat']);
        dataFilesL1=dir([DIR Languages{i} '/' subject '/*L1.mat']);
%         load([DIR Languages{i} '/' subject '/' dataFilesEn(1).name]);
%         load([DIR Languages{i} '/' subject '/' dataFilesL1(1).name]);
%         stdEn=mean(measuresEn.std(:,measuresEn.dur>20)');
%         stdL1=mean(measuresL1.std(:,measuresL1.dur>20)');
%         t=[t ;stdEn-stdL1];
%         for k=1:5
%             load([DIR Languages{i} '/' subject '/' dataFilesEn(k).name]);
%             load([DIR Languages{i} '/' subject '/' dataFilesL1(k).name]);
%             stdEn=mean(measuresEn.std(:,measuresEn.dur>20)');
%             stdL1=mean(measuresL1.std(:,measuresL1.dur>20)');
%             t=[t ;stdEn-stdL1];
%         end
        for k=1:5
            load([DIR Languages{i} '/' subject '/' dataFilesEn(k).name])
            load([DIR Languages{i} '/' subject '/' dataFilesL1(k).name])
            if(size(measuresEn.mean,1)~=43)
                pause
            end
            if(size(measuresEn.std,1)~=43)
                pause
            end
            if(size(measuresEn.median,1)~=43)
                pause
            end
            if(size(measuresEn.kurt,1)~=43)
                pause
            end
            if(size(measuresL1.mean,1)~=43)
                pause
            end
            if(size(measuresL1.std,1)~=43)
                pause
            end
            if(size(measuresL1.median,1)~=43)
                pause
            end
            if(size(measuresEn.kurt,1)~=43)
                pause
            end
        end
    end
end

% res=[];
% for i=4:43
%     t1=corrcoef(t(:,1),t(:,i));
%     t1=t1(2,1);
%     t2=corrcoef(t(:,2),t(:,i));
%     t2=t2(2,1);
%     t3=corrcoef(t(:,3),t(:,i));
%     t3=t3(2,1);
%     res=[res;t1 t2 t3];
% end
% max(res)