function [angles1001,angles1002,angles1003,p,nzIntervals5]=corr_coefff_window3_old(Language, Subject, storynumber)

%% Open the text file.
DIR=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/'];
filelist=dir([DIR Subject '/Audio/*' Subject '_Story' num2str(storynumber) 'En_pitch.txt']);
filename=filelist(1).name
p=load([DIR Subject '/Audio/' filename]);

% threshold=[num2str(threshold)];

filelist=dir([DIR Subject '/Marker/*' Subject '_Story' num2str(storynumber) 'En*Delay.txt']);
delayFile=filelist(1).name

delay=load([DIR '/' Subject '/Marker/' delayFile]);

delay=floor(delay*100);
p(1:delay)=[];
Tp=length(p)/100;

filelist=dir([DIR Subject '/Marker/*' Subject '_Story' num2str(storynumber) 'EnData.mat']);
filename1=filelist(1).name;
load([DIR Subject '/Marker/' filename1]);

angles120=data(:,19:21);
Ta=size(angles120,1)/120;
T=floor((Tp-Ta)*100);
p(end-T+1:end)=[];

q=find(p~=0);
r1=q(1,1);
p(1:r1-1)=[];

q=find(p~=0);
q=q(end);
r2=length(p)-q;
p(q+1:end)=[];

r1_ang=floor((r1/100)*120);
r2_ang=floor((r2/100)*120);

angles120(1:r1_ang,:)=[];
angles120(end-r2_ang+1:end,:)=[];


t120=(1:size(angles120,1))/120;
tp=(1:length(p))/100;
angles100=interp1(t120,angles120,tp);



X=find(p~=0);
nzIntervals=[];

temp=X(1);
for i=1:length(X)-1
    
if (X(i+1)-X(i)~=1);
    temp=[temp,X(i)];
    nzIntervals=[nzIntervals;temp];
    temp=X(i+1);
end

end


 
angles1001=angles100(:,1);
angles1002=angles100(:,2);
angles1003=angles100(:,3);

% r3=length(find(isnan(angles1001)));
% p(end-r3:end,:)=[];
r3=find(isnan(angles1001));
p(r3)=[];

angles1001(isnan(angles1001))=[];
angles1002(isnan(angles1002))=[];
angles1003(isnan(angles1003))=[];
 
l1=find((nzIntervals(:,2)-nzIntervals(:,1))>=30 & (nzIntervals(:,2)-nzIntervals(:,1))<50);
l2=find((nzIntervals(:,2)-nzIntervals(:,1))>=50 & (nzIntervals(:,2)-nzIntervals(:,1))<70);
l3=find((nzIntervals(:,2)-nzIntervals(:,1))>=70);
l4=find((nzIntervals(:,2)-nzIntervals(:,1))>=10 & (nzIntervals(:,2)-nzIntervals(:,1))<30);
l5=find((nzIntervals(:,2)-nzIntervals(:,1))>=30);

nzIntervals1=[];
nzIntervals2=[];
nzIntervals3=[];
nzIntervals4=[];
nzIntervals5=[];

for i=1:length(l1)
    nzIntervals1_=[nzIntervals(l1(i),1),nzIntervals(l1(i),2)];
    nzIntervals1=[nzIntervals1;nzIntervals1_];
end

for i=1:length(l2)
    nzIntervals2_=[nzIntervals(l2(i),1),nzIntervals(l2(i),2)];
        nzIntervals2=[nzIntervals2;nzIntervals2_];

end

for i=1:length(l3)
    nzIntervals3_=[nzIntervals(l3(i),1),nzIntervals(l3(i),2)];
        nzIntervals3=[nzIntervals3;nzIntervals3_];

end

for i=1:length(l4)
    nzIntervals4_=[nzIntervals(l4(i),1),nzIntervals(l4(i),2)];
        nzIntervals4=[nzIntervals4;nzIntervals4_];

end


for i=1:length(l5)
    nzIntervals5_=[nzIntervals(l5(i),1),nzIntervals(l5(i),2)];
        nzIntervals5=[nzIntervals5;nzIntervals5_];

end

  end

