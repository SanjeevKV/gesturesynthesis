delays=[-50:10:-30 -25:5:-10 -7:2:-3 0 3:2:7 10:5:25 30:10:50];
plot(delays,m_val,'*','MarkerSize',11);
xlabel('Delay in ms','FontSize',24);ylabel('Mutual Information','FontSize',24);
xlim([-60 60]);
ylim([0.15 0.32]);
hold on;
for i=1:length(m_val)
    line([delays(i),delays(i)],[m_val(i)-sd_val(i),m_val(i)+sd_val(i)],'Color','r','LineWidth',2);
end
set(gca,'FontSize',24)
line([0,0],[0.15,m_val(11)],'LineStyle','--','Color','k');
line([3,3],[0.15,m_val(12)],'LineStyle','--','Color','b');
hold off;text(1.5,m_val(12)+sd_val(12)+0.005,'3ms','FontSize',23);