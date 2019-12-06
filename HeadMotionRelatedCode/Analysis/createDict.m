function createDict(Language, Subject, interval)
    
DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
markerDIR=[DIR Language '/' Subject '/Marker/'];

saveDirPause=[DIR Language '/' Subject '/Ctxt_NMF_pause/' num2str(interval) '/'];
saveDirNonPause=[DIR Language '/' Subject '/Ctxt_NMF_Non_pause/' num2str(interval) '/'];
saveDir=[DIR Language '/' Subject '/Ctxt_NMF/' num2str(interval) '/'];

allwavs=dir([DIR Language '/' Subject '/Audio/*.wav']);

anglesCtxtDir = [markerDIR '/Ctxt/' num2str(interval) '/'];
anglesPauseCtxtDir = [markerDIR '/Ctxt_pause/' num2str(interval) '/'];
anglesNonPauseCtxtDir = [markerDIR '/Ctxt_Non_pause/' num2str(interval) '/'];

for i=10:10:100
    mkdir([saveDirPause num2str(i)]);
    mkdir([saveDirNonPause num2str(i)]);
    mkdir([saveDir num2str(i)]);
end

for i=1:length(allwavs)
    
    file=allwavs(i).name
    filename=file(1:end-4);
    
    t=load([anglesCtxtDir filename '.mat']);
    angles=t.ang_ctxt;
    
    t=load([anglesPauseCtxtDir filename '.mat']);
    ang_p_ctxt=t.ang_p_ctxt;
    
    t=load([anglesNonPauseCtxtDir filename '.mat']);
    ang_np_ctxt=t.ang_np_ctxt;
    
    for j=10:10:100
        [W,H,err] = nmf_kl(angles',j);

        save([saveDir num2str(j) '\' filename '_W.mat'],'W');
        save([saveDir num2str(j) '\' filename '_H.mat'],'H');
        save([saveDir num2str(j) '\' filename '_err.mat'],'err');
    end
    
    for j=10:10:100
        [W,H,err] = nmf_kl(ang_p_ctxt',j);

        save([saveDirPause num2str(j) '\' filename '_W.mat'],'W');
        save([saveDirPause num2str(j) '\' filename '_H.mat'],'H');
        save([saveDirPause num2str(j) '\' filename '_err.mat'],'err');
    end
    
    for j=10:10:100
        [W,H,err] = nmf_kl(ang_np_ctxt',j);

        save([saveDirNonPause num2str(j) '\' filename '_W.mat'],'W');
        save([saveDirNonPause num2str(j) '\' filename '_H.mat'],'H');
        save([saveDirNonPause num2str(j) '\' filename '_err.mat'],'err');
    end
    
end
end