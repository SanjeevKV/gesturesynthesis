%    
% Get everyone's dict and check input subject's story5 reconstruction
% error.

function reconstructWithSpeakerDict(Language, Subject, interval, k)

    addpath('F:\IIScProjectMain\Code\NNMF\nmflib');
    
    interval=str2double(interval);
    k=str2double(k);
    
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    markerDIR=[DIR Language '/' Subject '/Marker/Ctxt/' num2str(interval) '/'];
    load([markerDIR Subject '_Story5En.mat']); %ang_ctxt
    
    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    %Languages={'Malayalam','Tamil'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    errAll=[];count=0;ind=0;
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i};
            sub=Subjects(j).name;
            
            dictDIR=[DIR lang '/' sub '/Marker/LanguageBasesNMF/' num2str(interval) '/'];
            nmfDictEn=load([dictDIR 'WEn_' num2str(k) '.mat']);
            nmfDictEn=nmfDictEn.W;

            [~,~,err] = nmf_kl(ang_ctxt', k, 'W', nmfDictEn);
            errAll=[errAll;err(end)];
            count=count+1
            if(strcmp(sub,Subject)==1)
                ind=count;
            end
            clear err lang sub markerDIR nmfDictEn
        end
    end
    
    plot(errAll);title(num2str(ind));
    
end