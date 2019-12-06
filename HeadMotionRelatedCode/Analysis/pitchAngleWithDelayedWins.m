function pitchAngleWithDelayedWins(Language,Subject)

for q=1:5

    number=q;

    [angles1001,angles1002,angles1003,t,p,mfAll,steng,nzIntervals5]=corr_coefff_window3(Language,Subject,number);

    col_1=cell(1,21);

    for i=1:length(nzIntervals5)

%         mf=mfAll(nzIntervals5(i,1):nzIntervals5(i,2),:);
%         b1=p(nzIntervals5(i,1):nzIntervals5(i,2));
        b1=[p(nzIntervals5(i,1):nzIntervals5(i,2)),steng(nzIntervals5(i,1):nzIntervals5(i,2))];

        if ((nzIntervals5(i,1)>101) && nzIntervals5(i,2)<(length(angles1001)-101))
            win=nzIntervals5(i,2)-nzIntervals5(i,1);
            k=0;
            for j=nzIntervals5(i,1)-50:10:nzIntervals5(i,1)-30

                k=k+1;
                a1=angles1001(j:j+win);
                a2=angles1002(j:j+win);
                a3=angles1003(j:j+win);
                a4=t(j:j+win,:);

                col=[a1';a2';a3';a4';b1';];
%                 col=[a1';a2';a3';a4';mf'];
                
            col_1{k}=[col_1{k},col];

            end

            for j=nzIntervals5(i,1)-25:5:nzIntervals5(i,1)-10

                k=k+1;
                a1=angles1001(j:j+win);
                a2=angles1002(j:j+win);
                a3=angles1003(j:j+win);
                a4=t(j:j+win,:);

                col=[a1';a2';a3';a4';b1'];
%                 col=[a1';a2';a3';a4';mf'];

                col_1{k}=[col_1{k},col];

            end
            for j=nzIntervals5(i,1)-7:2:nzIntervals5(i,1)-3

                k=k+1;
                a1=angles1001(j:j+win);
                a2=angles1002(j:j+win);
                a3=angles1003(j:j+win);
                a4=t(j:j+win,:);

                col=[a1';a2';a3';a4';b1'];
%                 col=[a1';a2';a3';a4';mf'];

                col_1{k}=[col_1{k},col];

            end
            for j=nzIntervals5(i,1)

                k=k+1;
                a1=angles1001(j:j+win);
                a2=angles1002(j:j+win);
                a3=angles1003(j:j+win);
                a4=t(j:j+win,:);

                col=[a1';a2';a3';a4';b1'];
%                 col=[a1';a2';a3';a4';mf'];

                col_1{k}=[col_1{k},col];

            end

            for j=nzIntervals5(i,1)+3:2:nzIntervals5(i,1)+7

                k=k+1;
                a1=angles1001(j:j+win);
                a2=angles1002(j:j+win);
                a3=angles1003(j:j+win);
                a4=t(j:j+win,:);

                col=[a1';a2';a3';a4';b1'];
%                 col=[a1';a2';a3';a4';mf'];

                col_1{k}=[col_1{k},col];

            end

            for j=nzIntervals5(i,1)+10:5:nzIntervals5(i,1)+25

                k=k+1;
                a1=angles1001(j:j+win);
                a2=angles1002(j:j+win);
                a3=angles1003(j:j+win);
                a4=t(j:j+win,:);

                col=[a1';a2';a3';a4';b1'];
%                 col=[a1';a2';a3';a4';mf'];

                col_1{k}=[col_1{k},col];

            end

            for j=nzIntervals5(i,1)+30:10:nzIntervals5(i,1)+50

                k=k+1;
                a1=angles1001(j:j+win);
                a2=angles1002(j:j+win);
                a3=angles1003(j:j+win);
                a4=t(j:j+win,:);

                col=[a1';a2';a3';a4';b1'];
%                 col=[a1';a2';a3';a4';mf'];

                col_1{k}=[col_1{k},col];

            end

        end

    end

    l{q}=col_1;
end

col=cell(1,21);
c=[];

for i=1:21
    for j=1:5
        c_=l{j}{i};
        c=[c,c_];
    end
    col{i}=c;
    c=[];
end
col_1=col;

DIR='F:/IIScProjectMain/Optitrack/Analysis/ForLSTM/En50/';
save([DIR Language '_' Subject '_stories.mat'],'col_1')

end