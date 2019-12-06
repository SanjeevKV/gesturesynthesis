%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% audio_file
% corresponding marker_data
% delay
% plot them together
% find the cut location -> store it in text file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=22;
poem=result{n,2};
subject=result{n,1};

% audio_path='/home/prr/my_project/optitrack/Gaurav/Audio/'
% marker_path='/media/prr/PRR/Optitrack/Poems/Gaurav/FBX/'

audio_file=[audio_path result{n,3}];
% out_audio='/home/prr/my_project/optitrack/Sahana/processed/'
marker_file=[marker_path result{n,5}];

[y ,Fs] = audioread(audio_file);
eval(['load ', marker_file]);

disp('Calculating Distance between hands');
tempDist=getDistanceBetweenHands(markerData, '/home/prr/my_project/HeadMotionRelatedCode/HandMarkerNames.txt');
d=(tempDist-min(tempDist))/range(tempDist);
% eval(['save ','/home/prr/my_project/optitrack/Astha/FBX/',poem,'HandMarkerDistance.mat tempDist;']);

delay=finddelay(y(1:Fs*25), Fs, d(1:120*25), 120, 0);
fid=fopen([marker_path,'Extracted/',poem,'_Delay.txt'], 'w');
close all
plot(linspace(0,length(y(delay*Fs:end))/16000,length(y(delay*Fs:end))),y(delay*Fs:end),'r')
hold on
plot(linspace(0,length(tempDist)/120,length(tempDist)),tempDist/100);
cut=input('enter the cut locaton ')

plot(linspace(0,length(y((delay+cut)*Fs:end))/16000,length(y(delay*Fs:end))),y(delay*Fs:end),'r')
hold on
plot(linspace(0,length(tempDist)/120,length(tempDist)),tempDist/100);

fprintf(fid,'time to be added to head_marker data %.4f\n', delay);
fprintf(fid,'audio 1st cut location %.4f\n', delay+cut);
fprintf(fid,'head_marker cut location %.4f\n', cut);
audiowrite([marker_path,'Extracted/',subject,'_',poem,'.wav'],y((delay+cut)*Fs:end),Fs);
% close all
% check=input('do you want to cut 1 or 0');
% if(check)
% cut2=input('enter the second cut locaton ')
% fprintf(fid,'audio 2nd cut location %.4f\n', delay+cut2);
% 
% cut2=cut2+delay;
% audiowrite([audio_path,'nm','gau','l001s',num2str(200+num),'.wav'],y(cut2*Fs:cut3*Fs),Fs);
% check=input('do you want to cut 1 or 0');
% if(check)
% cut3=input('enter the third cut locaton ')
% fprintf(fid,'audio 3rd cut location %.4f\n', delay+cut3);
% cut3=cut3+delay;
% audiowrite([audio_path,'nm','gau','l001s',num2str(300+num),'.wav'],y(cut3*Fs:end),Fs);
% end
% end
% close all

close all
plot(linspace(0,length(y((delay+cut)*Fs:end))/16000,length(y((delay+cut)*Fs:end))),y((delay+cut)*Fs:end))

fclose(fid);

% prepare all data 
prepare_all_data_file(marker_path,marker_file,poem,cut);
close all

