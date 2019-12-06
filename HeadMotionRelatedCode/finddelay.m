function est_delay = finddelay(v1,fs1,v2,fs2, initdelay)

delay=initdelay;

subplot(2,1,1);
plot([1:length(v1)]/fs1,v1,'LineWidth',1.7);ylim([-1.2, 1.2]);
subplot(2,1,2);
plot(delay+[1:length(v2)]/fs2,v2,'r','LineWidth',1.7);ylim([-0.2,1.2])
%plot([1:length(v1)]/fs1,v1);hold on;plot(delay+[1:length(v2)]/fs2,v2,'r');hold off;
%title(delay);

ans='y';
while strcmp(ans,'y')==0
    
    ans=input('Is the delay ok (y/n)','s');
    if ans=='n'
        inputdelay=input('Enter delay','s');
        delayval=str2double(inputdelay);
        delay=delay+delayval;
        plot([1:length(v1)]/fs1,v1);hold on;plot(delay+[1:length(v2)]/fs2,v2,'r');hold off;
        title(delay);
    end
end
est_delay=delay;
