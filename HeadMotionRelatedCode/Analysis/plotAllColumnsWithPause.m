function plotAllColumnsWithPause(m)

figure;
for i=1:size(m,2)
    plot(m(:,i));title(i);pause;
end

end