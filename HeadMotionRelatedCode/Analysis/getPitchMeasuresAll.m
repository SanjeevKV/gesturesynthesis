function getPitchMeasuresAll()

    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    saveDIR='F:/IIScProjectMain/Optitrack/Analysis/Pitch/';
    
    for i=1:length(Languages)
        mkdir([saveDIR Languages{i}]);
    end
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i}
            subject=Subjects(j).name
            [measuresEn,measuresL1]=getPitchMeasures(lang, subject);
            save([saveDIR lang '/' subject '_En.mat'],'measuresEn');
            save([saveDIR lang '/' subject '_L1.mat'],'measuresL1');
        end
    end
end