
DUR=20;
subplot(421);plot(measuresEn.mean(measuresEn.dur>DUR));...
subplot(423);plot(measuresEn.std(measuresEn.dur>DUR));...
subplot(425);plot(measuresEn.kurt(measuresEn.dur>DUR));...
subplot(427);plot(measuresEn.median(measuresEn.dur>DUR));...
subplot(422);plot(measuresL1.mean(measuresL1.dur>DUR));...
subplot(424);plot(measuresL1.std(measuresL1.dur>DUR));...
subplot(426);plot(measuresL1.kurt(measuresL1.dur>DUR));...
subplot(428);plot(measuresL1.median(measuresL1.dur>DUR));

disp([mean(measuresEn.dur(measuresEn.dur>DUR)) mean(measuresL1.dur(measuresL1.dur>DUR))])
% disp([std(measuresEn.mean(measuresEn.dur>DUR)) std(measuresL1.mean(measuresL1.dur>DUR))])
disp([mean(measuresEn.std(measuresEn.dur>DUR)) mean(measuresL1.std(measuresL1.dur>DUR))])
% disp([std(measuresEn.kurt(measuresEn.dur>DUR)) std(measuresL1.kurt(measuresL1.dur>DUR))])
% disp([std(measuresEn.median(measuresEn.dur>DUR)) std(measuresL1.median(measuresL1.dur>DUR))])
