% Poems={'Twinkle','BaaBaa','LondonBridge'};
Poems={'LondonBridge'};
DIR='F:/IIScProjectMain/Poems/Kausthubha_test/Processed/';

videoFs=29.97;
clrs={'k','b','r','g'};

for p=1:length(Poems)
    recFolders=dir([DIR Poems{p}]);
    count=0;
    for r=3:length(recFolders)
        currDIR=[DIR Poems{p} '/' recFolders(r).name ];
        labelFileList=dir([currDIR '/*_labels.txt']);
        intrafaceFileList=dir([currDIR '/*.csv']);
        for file=1:length(labelFileList)
            count=count+1;
            l{count}=importPoemLabelFile([currDIR '/' labelFileList(file).name]);
            angles{count}=importIntrafaceData([currDIR '/' intrafaceFileList(file).name]);
            dist{count}=(sum((angles{count}).^2,2)).^0.5;
            delayfile=[currDIR '/' labelFileList(file).name(1:end-10) '_delay.txt'];
            %delay is in terms of number of video frames
            if exist(delayfile) == 2
                delay{count} = load(delayfile);
            else
                delay{count} = 0;
            end
        end
    end
    numWords=2;
    close all;
%     figure(1);figure(2);figure(3);
    figure(4);
    for word=1:numWords:30
        str='';
%         figure(1);hold off;figure(2);hold off;figure(3);hold off;
        figure(4);hold off;
        for file=1:length(l)
            tStart=round(l{file}{word,1}*videoFs)+delay{file};
            tEnd=round(l{file}{word+numWords,2}*videoFs)+delay{file};
%             figure(1);plot(angles{file}(tStart:tEnd,1),clrs{file});title(str);hold on;
%             figure(2);plot(angles{file}(tStart:tEnd,2),clrs{file});title(str);hold on;
%             figure(3);plot(angles{file}(tStart:tEnd,3),clrs{file});title(str);hold on;
            figure(4);plot(dist{file}(tStart:tEnd),clrs{file});hold on;
            
            str='';
            for num=0:numWords
                tWordS=round(l{file}{word+num,1}*videoFs)+delay{file};
                tWordE=round(l{file}{word+num,2}*videoFs)+delay{file};
                str=[str ' ' l{file}{word+num,3}];
                figure(4);plot(tWordS-tStart+1,dist{file}(tWordS),[ '*' clrs{file}]);
                figure(4);plot(tWordE-tStart+1,dist{file}(tWordE),[ '+' clrs{file}]);
            end
        end
        title(str);
        pause;
    end
%     end
end