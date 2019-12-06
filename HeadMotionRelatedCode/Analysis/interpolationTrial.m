zeroSegs
inds=[1:26269 26325:26505 26554:29054];
yy=interp1(inds,noseD(inds),[zeroSegs(1,1):zeroSegs(1,2) ...
zeroSegs(2,1):zeroSegs(2,2)],'spline');
inds=[1:26269 26325:26505 26554:29054];
yy=interp1(inds,noseD(inds,1),[zeroSegs(1,1):zeroSegs(1,2) ...
zeroSegs(2,1):zeroSegs(2,2)],'spline');
inds=[1:26269 26325:26505 26554:29054];
yy=interp1(inds,noseD(inds,1),1:length(noseD),'spline');
figure;plot(noseD(:,1));hold on;plot(yy,'O-');

inds=[1:26269 26325:26505 26554:29054];
yy=interp1(inds,noseD(inds,1),1:length(noseD),'pchip');
figure;plot(noseD(:,1));hold on;plot(yy,'O-');
help interp1
inds=[1:26269 26325:26505 26554:29054];
yy=interp1(inds,noseD(inds,1),1:length(noseD),'nearest');
figure;plot(noseD(:,1));hold on;plot(yy,'O-');
inds=[1:26269 26325:26505 26554:29054];
yy=interp1(inds,noseD(inds,1),1:length(noseD),'cubic');
figure;plot(noseD(:,1));hold on;plot(yy,'O-');
inds=[1:26269 26325:26505 26554:29054];
yy=interp1(inds,noseD(inds,1),1:length(noseD),'v5cubic');
figure;plot(noseD(:,1));hold on;plot(yy,'O-');