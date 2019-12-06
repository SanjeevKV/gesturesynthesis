function createPitchMFCCAngleMatrixAll()

    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    %Languages={'Malayalam','Tamil','Telugu'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    saveDIR='F:/IIScProjectMain/Optitrack/Analysis/PitchMFCCAngles_70/';
    
    for i=1:length(Languages)
        mkdir([saveDIR Languages{i}]);
    end
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i};
            subject=Subjects(j).name
            mkdir([saveDIR Languages{i} '/' subject]);
            createPitchMFCCAngleMatrix(lang, subject);
        end
    end
    
end