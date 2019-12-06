function runAllpitchAngleDelayVerify()

    Languages={'Bengali','Malayalam','Tamil','Telugu'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i}
            subj=Subjects(j).name
            pitchAngleDelayVerify(lang,subj);
        end
    end
end