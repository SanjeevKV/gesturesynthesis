function createCtxtAnglesAll(interval)

    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    %Languages={'Hindi'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i};
            subject=Subjects(j).name;
            createCtxtAnglesForSubject(lang,subject,interval);
        end
    end
end