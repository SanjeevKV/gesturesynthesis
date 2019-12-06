function reconstructWithLanguageDict(Language, Subject, interval, k)

    interval=str2num(interval);
    k=str2num(k);
    
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    markerDIR=[DIR Language '/' Subject '/Marker/Ctxt/' num2str(interval) '/'];
    dictDIR=[DIR Language '/' Subject '/Marker/LanguageBasesNMF/' num2str(k) '/'];
    
    allwavsEn=dir([DIR Language '/' Subject '/Audio/*Story*En.wav']);
    allwavsL1=dir([DIR Language '/' Subject '/Audio/*Story*' Language(1) '*.wav']);
    
    nmfDictEn=load([dictDIR 'WEn.mat']);
    nmfDictEn=nmfDictEn.W;
    nmfDictL1=load([dictDIR 'WL1.mat']);
    nmfDictL1=nmfDictL1.W;
    
    errEnEn=[];
    errEnL1=[];
    errL1En=[];
    errL1L1=[];
    
    for i=1:length(allwavsEn)
        
        file=allwavsEn(i).name
        filename=file(1:end-4);
        
        t=load([markerDIR filename '.mat']);
        angles=t.ang_ctxt;
        
        [W,H,err] = nmf_kl(angles',k, 'W', nmfDictEn);
        errEnEn=[errEnEn;err(end)];
        [W,H,err] = nmf_kl(angles',k, 'W', nmfDictL1);
        errEnL1=[errEnL1;err(end)];
        
    end
    
    for i=1:length(allwavsL1)
        
        file=allwavsL1(i).name
        filename=file(1:end-4);
        
        t=load([markerDIR filename '.mat']);
        angles=t.ang_ctxt;
        
        [W,H,err] = nmf_kl(angles', k, 'W', nmfDictL1);
        errL1L1=[errL1L1;err(end)];
        [W,H,err] = nmf_kl(angles', k, 'W', nmfDictEn);
        errL1En=[errL1En;err(end)];
        
    end
    
    res=struct('errEnEn',errEnEn,'errEnL1',errEnL1,'errL1L1',errL1L1,'errL1En',errL1En);
    save([dictDIR 'totErr.mat'],'res');

end