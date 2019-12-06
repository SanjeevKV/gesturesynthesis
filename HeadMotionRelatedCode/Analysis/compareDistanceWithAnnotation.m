pDIR='F:/IIScProjectMain/YoutubeLikesProject/predicted/';
tDIR='F:/IIScProjectMain/YoutubeLikesProject/truth/';

plist=dir(pDIR);
for i=3:length(plist)
    pname=plist(i).name
    res=load([pDIR pname]);
    csvname=[pname(1:end-4) '.csv'];
    csvfullpath=[tDIR csvname]
    fid=fopen(csvfullpath,'r');
    t=textscan(fid,'%n%*s','delimiter',',')
    %t=load(['truth\' tname]);
    fclose(fid);
    clear fid;
    t=cell2mat(t);
    t=t+1;
    
    tmp=zeros(1,length(res));
    tmp(t)=50;
    plot(res);hold on;plot(tmp,'r*');hold off;pause;
end