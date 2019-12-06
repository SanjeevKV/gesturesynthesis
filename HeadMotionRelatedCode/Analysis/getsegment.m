function segments=getsegment(angles)

d1=sqrt(mean(angles.^2,2));
[b a]=cheby2(5,40,5/60);
f_d1=filtfilt(b,a,d1);

plot([1:length(d1)]/120,d1);hold on;plot([1:length(d1)]/120,f_d1,'r');

[pks loc]=findpeaks(f_d1);
s_pks=sort(pks);
th=s_pks(round(.7*length(s_pks)))

inds=find(d1>th);
active_sign=0*d1;
active_sign(inds)=1;

upinds=find(diff(active_sign)==1)+1;
downinds=find(diff(active_sign)==-1);

if downinds(1)<upinds(1)
    downinds=downinds(2:end);
end
if upinds(end)>downinds(end)
    upinds=upinds(1:end-1);
end

active_lengths=downinds-upinds;
remove_inds=find(active_lengths<=60); %0.5second
upinds(remove_inds)=[];
downinds(remove_inds)=[];

grid on;
stem(upinds/120,5*ones(1,length(upinds)),'r');
stem(downinds/120,5*ones(1,length(downinds)),'k');

segments=[];