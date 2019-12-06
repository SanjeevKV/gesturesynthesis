function reconstructWithLanguageDictAll(interval, k)

    Languages={'Hindi','Kannada','Malayalam','Tamil','Telugu'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i};
            subject=Subjects(j).name;
            reconstructWithLanguageDict(lang,subject,interval,k);
        end
    end
end