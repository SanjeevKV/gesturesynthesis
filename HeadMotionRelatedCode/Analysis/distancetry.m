Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    means1=[];
    for i1=1:length(Languages)
        Subjects=dir([DIR Languages{i1}]);
        for j=3:length(Subjects)
            Subjects(j).name
            
means=[];
for i=1:5
file=dir([DIR Languages{i1} '/' Subjects(j).name '/Marker/*Story' num2str(i) 'En*.mat']);
% file(1).name
load([DIR Languages{i1} '/' Subjects(j).name '/Marker/' file(1).name]);
angles=data(:,19:21);
a1=angles(1:end-1,:);
a2=angles(2:end,:);
ds=sqrt(sum((a1-a2).^2,2));ds_en=ds(2:end);
ds_en_1=filter(1/60*ones(1,60),1,ds_en);


file=dir([DIR Languages{i1} '/' Subjects(j).name '/Marker/*Story' num2str(i) Languages{i1}(1) '*.mat']);
% file(1).name
load([DIR Languages{i1} '/' Subjects(j).name '/Marker/' file(1).name]);
angles=data(:,19:21);
a1=angles(1:end-1,:);
a2=angles(2:end,:);
ds=sqrt(sum((a1-a2).^2,2));ds_kn=ds(2:end);
ds_kn_1=filter(1/60*ones(1,60),1,ds_kn);
figure(10);plot(ds_en_1);hold on;plot(ds_kn_1,'r');hold off;
title(file(1).name);
pause

means=[means; [mean(ds_en_1) mean(ds_kn_1)]];


end
% means
% pause
means1=[means1;mean(means)];
        end
        means1
        pause
    end

% [n1,x1]=hist(ds_en_1(1:60:end));
% [n2,x2]=hist(ds_kn_1(1:60:end));
% 
% figure;plot(x1,n1/sum(n1));hold on;plot(x2,n2/sum(n2),'r');