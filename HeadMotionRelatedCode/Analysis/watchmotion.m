Language='Kannada';
Subject='Pranav';

DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';
audioDIR=[DIR Language '/' Subject '/Audio/'];
markerDIR=[DIR Language '/' Subject '/Marker/'];

allwavs=dir([DIR Language '/' Subject '/Audio/*.wav']);

for i=8:length(allwavs)
   
    filename=allwavs(i).name;
    wavfile=[DIR Language '/' Subject '/Audio/' filename]
    pausefile=[wavfile(1:end-4) '_pause.txt']
    pitchfile=[wavfile(1:end-4) '_pitch.txt']
    
    fl=filename(1:end-4);
    markerfilelist=dir([DIR Language '/' Subject '/Marker/*' fl 'Data.mat']);
    markerfile=[markerDIR markerfilelist(1).name]
    
    tmp=markerfilelist(1).name;
    delayfile=[markerDIR tmp(1:end-8) '.fbx.matDelay.txt']
    
    [sig fs]=wavread(wavfile);
    t=load(markerfile);
    tp=load(pitchfile);t_tp=[1:length(tp)]/100;
    tpause=load(pausefile);
    delay=load(delayfile);
    
    
    delay_in_samples=round(delay*fs);
    
    %%%% signals
    pauseflag=0*sig;
    for k=1:size(tpause)
        pauseflag(round(tpause(k,1)*fs):1:round(tpause(k,2)*fs))=1;
    end
    sig=sig(delay_in_samples+1:end);
    pauseflag=pauseflag(delay_in_samples+1:end);
    markerdata=t.data;
    pitch=tp(t_tp>delay);
    
    
    %%%% timestampts
    t_sig=[1:length(sig)]/fs;
    t_marker=[1:size(markerdata,1)]/120;
    t_pitch=[1:length(pitch)]/100;
    
    
%     length(sig)/fs
%     size(markerdata,1)/120
    
    angles=markerdata(:,19:21);
    ptch=angles(:,1);roll=angles(:,2);yaw=angles(:,3);
    %ptch=(ptch-min(ptch))/range(ptch)*.1-.4;
    %roll=(roll-min(roll))/range(roll)*.1-.5;
    %yaw=(yaw-min(yaw))/range(yaw)*.1-.6;
    angles_norm=sqrt(sum(angles.^2,2));
    [b1,a1]=cheby2(5,40,20/60);
    T=0:3:size(markerdata,1)/120;
    for j=3:length(T)
        ind=find(t_sig>T(j-2) & t_sig<=T(j));
        ind1=find(t_pitch>T(j-2) & t_pitch<=T(j));
        ind2=find(t_marker>T(j-2) & t_marker<=T(j));
        
       
        figure(1);
        plot(t_sig(ind),sig(ind));hold on;
        plot(t_sig(ind),0.5*pauseflag(ind),'k*-');
        plot(t_pitch(ind1),1/1200*pitch(ind1),'m');
        p1=((ptch(ind2)-min(ptch(ind2)))/range(ptch(ind2)))*0.35;
        fp1=filtfilt(b1,a1,p1);
        pksFp1=findpeaks(fp1);
        r1=((roll(ind2)-min(roll(ind2)))/range(roll(ind2)))*0.35;
        fr1=filtfilt(b1,a1,r1);
        pksFr1=findpeaks(fr1);
        y1=((yaw(ind2)-min(yaw(ind2)))/range(yaw(ind2)))*0.35;
        fy1=filtfilt(b1,a1,y1);
        pksFy1=findpeaks(fy1);

        fAngNorm=filtfilt(b1,a1,angles_norm(ind2));
        pksAngNorm=findpeaks(fAngNorm);
%         plot(t_marker(ind2),p1,'r');plot(t_marker(ind2),fp1,'r-.');
%         plot(t_marker(ind2),r1,'g');plot(t_marker(ind2),fr1,'g-.');
%         plot(t_marker(ind2),y1,'b');plot(t_marker(ind2),fy1,'b-.');

        plot(t_marker(ind2),fp1,'r');
        plot(t_marker(ind2),fr1,'g');
        plot(t_marker(ind2),fy1,'b');
        
        %plot(t_marker(ind2),0.01*angles_norm(ind2),'r');
        title(['\color{red}',num2str(length(pksFp1)),' \color{green}',num2str(length(pksFr1)),' \color{blue}',num2str(length(pksFy1)),' \color{black}',num2str(length(pksAngNorm))],'interpreter','tex');
        nonZeroPitchInd=find(pitch(ind1)~=0);
        nonZeroPitchInd=nonZeroPitchInd+min(ind1)-1;
        
        if(~isempty(nonZeroPitchInd))
        
            beginInds=[];
            endInds=[];
            tval1=t_pitch(nonZeroPitchInd(1));
            beginInds=[beginInds;nonZeroPitchInd(1)];

            for k=2:length(nonZeroPitchInd)
                tval2=t_pitch(nonZeroPitchInd(k));
                if(tval2-tval1-0.01 < 0.0001)
                    tval1=tval2;
                    if(k==length(nonZeroPitchInd))
                        endInds=[endInds;nonZeroPitchInd(k)];
                    end
                    continue;
                else
                    if(k<length(nonZeroPitchInd))
                        endInds=[endInds;nonZeroPitchInd(k-1)];
                        beginInds=[beginInds;nonZeroPitchInd(k)];
                    else
                        endInds=[endInds;nonZeroPitchInd(k-1)];
                    end
                end
                tval1=tval2;
            end
            intervals=[beginInds endInds];
            tpInterval=[];
            for k=1:size(intervals,1)
                t1=t_pitch(intervals(k,1));
                t2=t_pitch(intervals(k,2));
                tpInterval=[tpInterval;t1 t2];
            end
            
            markerInterval=[];
            mtInterval=[];
            for k=1:size(tpInterval,1)
                b=tpInterval(k,1);
                e=tpInterval(k,2);
                tmInd=find(t_marker(ind2)>=b & t_marker(ind2)<=e);
                tmInd=tmInd+min(ind2)-1;
                mtInterval=[mtInterval;t_marker(tmInd(1)) t_marker(tmInd(end))];
                markerInterval=[markerInterval;tmInd(1) tmInd(end)];
            end
              
        end
        
        %plot(t_marker(ind2),ptch(ind2),'k');plot(t_marker(ind2),roll(ind2),'k');plot(t_marker(ind2),yaw(ind2),'k');
        %axis([t_sig(ind(1)) t_sig(ind(end)) -.65 .65]);
        xlim([t_sig(ind(1)) t_sig(ind(end))]);
        hold off;
        
%         figure(2);
%         if(exist('markerInterval','var'))
%             plotWithlabelledInterval(t_marker(ind2),ptch(ind2),markerInterval(:,1)-min(ind2)+1,markerInterval(:,2)-min(ind2)+1,'r');
%             plotWithlabelledInterval(t_marker(ind2),roll(ind2),markerInterval(:,1)-min(ind2)+1,markerInterval(:,2)-min(ind2)+1,'g');
%             plotWithlabelledInterval(t_marker(ind2),yaw(ind2),markerInterval(:,1)-min(ind2)+1,markerInterval(:,2)-min(ind2)+1,'b');
%         else
%             hold on;
%             plot(t_marker(ind2),ptch(ind2),'r');
%             plot(t_marker(ind2),roll(ind2),'g');
%             plot(t_marker(ind2),yaw(ind2),'b');
%         end
%         
%         xlim([t_sig(ind(1)) t_sig(ind(end))]);
%         hold off;
        clear markerInterval
        
        
        soundsc(sig(ind),fs)
        pause
        
    end
    
end