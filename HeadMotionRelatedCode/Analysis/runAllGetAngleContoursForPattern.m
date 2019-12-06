function runAllGetAngleContoursForPattern(order)
    
    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    %Languages={'Hindi'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            subject=Subjects(j).name
            getAllAngleContoursForPattern(subject,order);
        end
    end

end