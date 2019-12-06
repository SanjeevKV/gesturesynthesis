function createDictForLanguage(Language, Subject, interval)

interval=str2num(interval);
    
DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
markerDIR=[DIR Language '/' Subject '/Marker/'];

dataDIR=[markerDIR 'Ctxt/' num2str(interval) '/'];

allwavsEn=dir([DIR Language '/' Subject '/Audio/*En.wav']);
% allwavsL1=dir([DIR Language '/' Subject '/Audio/*Story*' Language(1) '*.wav']);

saveDir = [markerDIR '/LanguageBasesNMF/' num2str(interval)];
mkdir([saveDir])
% for i=10:10:100
%     mkdir([saveDir num2str(i)]);
% end

anglesEn=[];
for i=1:length(allwavsEn)-1
    
    file=allwavsEn(i).name
    filename=file(1:end-4);
    
    t=load([dataDIR filename '.mat']);
    angles=t.ang_ctxt;
    anglesEn=[anglesEn; angles];
    
    clear t
    
end

% anglesL1=[];
% for i=1:length(allwavsL1)
%     
%     file=allwavsL1(i).name
%     filename=file(1:end-4);
%     
%     t=load([dataDIR filename '.mat']);
%     angles=t.ang_ctxt;
%     anglesL1=[anglesL1; angles];
%     
% end

% [W,H,err] = nmf_kl(anglesEn',k);
%  
% save([saveDir num2str(k) '\WEn.mat'],'W');
% save([saveDir num2str(k) '\HEn.mat'],'H');
% save([saveDir num2str(k) '\errEn.mat'],'err');

% [W,H,err] = nmf_kl(anglesL1',k);
%  
% save([saveDir num2str(k) '\WL1.mat'],'W');
% save([saveDir num2str(k) '\HL1.mat'],'H');
% save([saveDir num2str(k) '\errL1.mat'],'err');

for j=10:60:100
    [W,H,err] = nmf_kl(anglesEn',j);

    save([saveDir '\WEn_' num2str(j) '.mat'],'W');
    save([saveDir '\HEn_' num2str(j) '.mat'],'H');
    save([saveDir '\errEn_' num2str(j) '.mat'],'err');
end

clear anglesEn W H err
% 
% for j=10:30:100
%     [W,H,err] = nmf_kl(anglesL1',j);
% 
%     save([saveDir num2str(j) '\WL1.mat'],'W');
%     save([saveDir num2str(j) '\HL1.mat'],'H');
%     save([saveDir num2str(j) '\errL1.mat'],'err');
% end

end