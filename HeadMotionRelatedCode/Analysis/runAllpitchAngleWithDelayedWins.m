function runAllpitchAngleWithDelayedWins()

    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
%     Languages={'Hindi'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i}
            subj=Subjects(j).name
            pitchAngleWithDelayedWins(lang,subj);
%             window_corr_greater_30(lang,subj);
        end
    end
end