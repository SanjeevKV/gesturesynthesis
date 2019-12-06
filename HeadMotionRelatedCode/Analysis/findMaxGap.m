function findMaxGap(dirPath)

list = dir([dirPath,'\*ZeroData.mat']);
largest=0;

for i=1:length(list)
    eval(['load ',list(i).name]);

    for j=3:3:18
        m=zeroData{j};
        if m~=0
            large=max(diff(m,1,2));
            if large > largest
                largest=large;
            end
        end
    end
    
end

save 'largestGap.txt' 'largest' -ascii
end