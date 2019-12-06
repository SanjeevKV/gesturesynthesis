Languages={'Bengali','Hindi','Kannada','Malayalam','Tamil','Telugu'};
DIR='F:/IIScProjectMain/Optitrack/ExtractedData/';

allEn=[];
allL1=[];
res_m=[];
res_std=[];
for i=1:length(Languages)
    Subjects=dir([DIR Languages{i}]);
    for j=3:length(Subjects)
        lang=Languages{i};
        subject=Subjects(j).name;
        dataDIR=([DIR lang '/' subject '/Marker/']);
        fileListEn=dir([DIR lang '/' subject '/Marker/*EnData.mat']);
        fileListL1=dir([DIR lang '/' subject '/Marker/*Story*' lang(1) '*Data.mat']);
        for k=1:length(fileListEn)
            load([dataDIR fileListEn(k).name]); % data
            allEn=[allEn;size(data,1)/120];
            clear data
        end
        for k=1:length(fileListL1)
            load([dataDIR fileListL1(k).name]); % data
            allL1=[allL1;size(data,1)/120];
            clear data
        end
    end
    res_m=[res_m;mean(allEn),mean(allL1)];
    res_std=[res_std;std(allEn),std(allL1)];
    allEn=[];
    allL1=[];
end
size(res_m)
colormap([0.6,0.6,0.6;0.5,0.5,0.5;0.1,0.1,0.1]);
% subplot(1,2,1);imshow(i2);
subplot(2,1,1);
bar(res_m, 'LineWidth', 2);
set(gca,'XTickLabel','','fontsize',36,'LineWidth',1.5);
%xlabel('Languages','FontSize',36,'FontWeight','bold');
text(3, -220, 'Languages','fontsize',36,'FontWeight','bold');
ylabel('Seconds','FontSize',36,'FontWeight','bold');
leg=legend('English','Native');set(leg,'Position',[.1,.3,.3,.3],'LineWidth',2);
hold on;
for i=1:length(Languages)
    h=text(i-length(Languages{i})/15, -110, Languages{i},'fontsize',36);
    set(h,'rotation',15)
end
for i=1:size(res_std,1)
    plot([i-0.14,i-0.14],[res_m(i,1)-res_std(i,1),res_m(i,1)+res_std(i,1)],'LineWidth',2);
    plot([i-0.14-0.06,i-0.14+0.06],[res_m(i,1)+res_std(i,1),res_m(i,1)+res_std(i,1)],'LineWidth',2);
    plot([i-0.14-0.06,i-0.14+0.06],[res_m(i,1)-res_std(i,1),res_m(i,1)-res_std(i,1)],'LineWidth',2);
    plot([i+0.14,i+0.14],[res_m(i,2)-res_std(i,2),res_m(i,2)+res_std(i,2)],'LineWidth',2);
    plot([i+0.14-0.06,i+0.14+0.06],[res_m(i,2)+res_std(i,2),res_m(i,2)+res_std(i,2)],'LineWidth',2);
    plot([i+0.14-0.06,i+0.14+0.06],[res_m(i,2)-res_std(i,2),res_m(i,2)-res_std(i,2)],'LineWidth',2);
end
hold off;