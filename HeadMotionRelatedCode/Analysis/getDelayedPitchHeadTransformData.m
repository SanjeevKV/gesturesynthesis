function getDelayedPitchHeadTransformData(Language, Subject, lag)

DIR=['F:/IIScProjectMain/Optitrack/ExtractedData/' Language '/'];
stLang=Language(1);
%stLang='En';
saveDIR='F:/IIScProjectMain/Optitrack/Analysis/LSTMFeatures/PitchStL150/';
%saveDIR='F:/IIScProjectMain/Optitrack/Analysis/LSTMFeatures/PitchStEn50/';
minLengthPitchSegment=50;

%audioFtrs={};audioFtrsCount=0;
%headFtrs={};headFtrsCount=0;

audioAll={};
headAll={};
nzIntervalsAll={};
ml=0;totalPitchSegs=0;

for sn=1:5
    sn
    filelist=dir([DIR Subject '/Audio/*' Subject '_Story' num2str(sn) stLang '*_pitch.txt']);
    filename=filelist(1).name
    p=load([DIR Subject '/Audio/' filename]);
    lp=length(p)

    mfccfilename=[filename(1:end-10) '.mfc'];
    mfAll=readhtk([DIR Subject '/Audio/' mfccfilename]);
    mfAll(1,:)=[];mfAll(end,:)=[];

    StEngFilename=[mfccfilename(1:end-4) '_steng.txt'];
    steng=load([DIR Subject '/Audio/' StEngFilename]);
    lsteng=length(steng)
    
    if(lsteng-lp==3)
        steng(1:2)=[];steng(end)=[];
    elseif(lsteng-lp==2)
        steng(1)=[];steng(end)=[];
    end

    filelist=dir([DIR Subject '/Marker/*' Subject '_Story' num2str(sn) stLang '*Delay.txt']);
    delayFile=filelist(1).name

    delay=load([DIR '/' Subject '/Marker/' delayFile]);

    delay=floor(delay*100);
    p(1:delay)=[];
    mfAll(1:delay,:)=[];
    steng(1:delay)=[];
    Tp=length(p)/100;

    filelist=dir([DIR Subject '/Marker/*' Subject '_Story' num2str(sn) stLang '*Data.mat']);
    filename1=filelist(1).name
    load([DIR Subject '/Marker/' filename1]); %data loaded

    transform120=data(:,19:24);
    
    Ta=size(transform120,1)/120;
    T=floor((Tp-Ta)*100);
    p(end-T+1:end)=[];
    mfAll(end-T+1:end,:)=[];
    steng(end-T+1:end)=[];
    
    t120=(1:size(transform120,1))/120;
    tp=(1:length(p))/100;
    transform100=interp1(t120,transform120,tp);
    
    a1=transform100(:,1);
    a2=transform100(:,2);
    a3=transform100(:,3);
    t1=transform100(:,4);
    t2=transform100(:,5);
    t3=transform100(:,6);

    r3=find(isnan(a1));
    p(r3)=[];
    mfAll(r3,:)=[];
    steng(r3)=[];
    a1(isnan(a1))=[];
    a2(isnan(a2))=[];
    a3(isnan(a3))=[];
    t1(isnan(t1))=[];
    t2(isnan(t2))=[];
    t3(isnan(t3))=[];

    transform=[a1,a2,a3,t1,t2,t3];
    
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
    
    nzIntervals=nzIntervals((nzIntervals(:,2)-nzIntervals(:,1))>=minLengthPitchSegment,:);
    ml_curr=max(nzIntervals(:,2)-nzIntervals(:,1));
    if(ml_curr>ml)
        ml=ml_curr
    end
    totalPitchSegs=totalPitchSegs+size(nzIntervals,1);
    
    audioAll{sn}=[p,steng];
    headAll{sn}=transform;
    nzIntervalsAll{sn}=nzIntervals;
end

audioFtrs=zeros(totalPitchSegs,ml+1,2);
headFtrs=zeros(totalPitchSegs,ml+1,6);
pitchSegCount=0;

for sn=1:5
    
    nzIntervals=nzIntervalsAll{sn};
    audioCurr=audioAll{sn};
    headCurr=headAll{sn};
    
    for n=1:size(nzIntervals,1)
        
        pitchSegCount=pitchSegCount+1;
        aud_temp=audioCurr(nzIntervals(n,1):nzIntervals(n,2),:);
        sz=size(aud_temp,1);
        t_temp=1:sz;

        t_target=1:(sz-1)/ml:sz;
        aud_new=interp1(t_temp, aud_temp, t_target);
        head_temp=headCurr(nzIntervals(n,1)+lag:nzIntervals(n,2)+lag,:);
        head_new=interp1(t_temp, head_temp, t_target);

        audioFtrs(pitchSegCount,:,:)=aud_new;
        headFtrs(pitchSegCount,:,:)=head_new;

        %audioFtrsCount=audioFtrsCount+1;
        %audioFtrs{audioFtrsCount}=[p(nzIntervals(n,1):nzIntervals(n,2)),steng(nzIntervals(n,1):nzIntervals(n,2))];
        %headFtrsCount=headFtrsCount+1;
        %headFtrs{headFtrsCount}=transform(nzIntervals(n,1)+lag:nzIntervals(n,2)+lag,:);
    end
end

%save([saveDIR Subject '_' num2str(lag) '_headftrs.mat'],'headFtrs');
%save([saveDIR Subject '_' num2str(lag) '_audioftrs.mat'],'audioFtrs');

save([saveDIR Subject '_' num2str(lag) '_headftrs3D.mat'],'headFtrs');
save([saveDIR Subject '_' num2str(lag) '_audioftrs3D.mat'],'audioFtrs');

end