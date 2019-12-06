

Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
%Languages={'Hindi'};
DIR='F:/IIScProjectMain/Optitrack/Analysis/AngleQuadrant/';

th=5;
clrs='rkbmc';
count=1;
for i=1:length(Languages)
Subjects=dir([DIR Languages{i}]);
for j=3:length(Subjects)
    lang=Languages{i};
    subject=Subjects(j).name
    for st=1:5
        n0=[];
        q=load([DIR lang '/' subject '/Story' num2str(st) 'En_Q_' num2str(th) '.txt']);
        for kk=1:120:length(q)-120*60
        [n x]=hist(q(kk:kk+120*60),2:9);
        n0=[n0; n/sum(n)];
        
        end
        subplot(4,6,count);stem(x,mean(n0),clrs(st));hold on;axis([0 10 0 .64])
    end
    count=count+1;
end
end

