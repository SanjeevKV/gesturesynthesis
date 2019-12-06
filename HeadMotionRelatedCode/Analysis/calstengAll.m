function calstengAll()

    Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
    DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
    
    for i=1:length(Languages)
        Subjects=dir([DIR Languages{i}]);
        for j=3:length(Subjects)
            lang=Languages{i}
            subj=Subjects(j).name
            audioList=dir([DIR lang '/' subj '/Audio/*.wav']);
            for k=1:length(audioList)
                [y,fs]=wavread([DIR lang '/' subj '/Audio/' audioList(k).name]);
                steng=calsteng(y,160,160);
                steng=steng';
                save([DIR lang '/' subj '/Audio/' audioList(k).name(1:end-4) '_steng.txt'],'steng','-ascii');
            end
        end
    end

end