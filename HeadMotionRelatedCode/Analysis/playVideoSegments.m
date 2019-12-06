function indicesS=playVideoSegments(vid, segHaca)

g=segHaca(end).G;
s=segHaca(end).s;
k=8;

indicesS = cell(1,k);

iden = eye(k);
for i=1:k
    pat = iden(:,i);
    indicesG = find(ismember(g',pat','rows'));
    indicesPat = [];
    for j=1:length(indicesG)
        indicesPat = [indicesPat;indicesG(j) indicesG(j)+1];
    end
    indicesS{i} = indicesPat;
end

for i=1:k
    frameIntervals = indicesS{i};
    for j=1:size(frameIntervals,1)
        startFrame=s(frameIntervals(j,1))
        endFrame=s(frameIntervals(j,2))-1
        disp('Reading frames');
        frames=read(vid,[startFrame endFrame]);
        disp(['Playing pattern ', num2str(i), ' ', num2str(j),'th occurence']);
        for x=1:size(frames,4)
            imshow(frames(:,:,:,x));
            pause(1/60);
        end
        pause;
    end
    pause;
end

end