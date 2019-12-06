function avgTrans=calcAverageTranslationAll()

    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    avgTrans=zeros(24,3);
    count=0;
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i}
            subj=Subjects(j).name
            count=count+1;
            fileList=dir([DIR lang '/' subj '/Marker/*EnData.mat']);
            tempTrans=zeros(length(fileList),3);
            for k=1:length(fileList)
                load([DIR lang '/' subj '/Marker/' fileList(k).name]); %data
                tempTrans(k,:)=mean(abs(data(:,22:24)));
            end
            avgTrans(count,:)=mean(abs(tempTrans));
        end
    end

end