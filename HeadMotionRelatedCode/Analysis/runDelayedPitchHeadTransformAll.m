function runDelayedPitchHeadTransformAll()

    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    %Languages={'Hindi'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';

    for i=1:length(Languages)
        lang=Languages{i};
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            sub=Subjects(j).name
            getDelayedPitchHeadTransformData(lang,sub,-20);
            getDelayedPitchHeadTransformData(lang,sub,-15);
            getDelayedPitchHeadTransformData(lang,sub,-10);
            for k=-7:2:-3
                getDelayedPitchHeadTransformData(lang,sub,k);
            end
            getDelayedPitchHeadTransformData(lang,sub,0);
            for k=3:2:7
                getDelayedPitchHeadTransformData(lang,sub,k);
            end
            getDelayedPitchHeadTransformData(lang,sub,10);
            getDelayedPitchHeadTransformData(lang,sub,15);
            getDelayedPitchHeadTransformData(lang,sub,20);
        end
    end
    
end