function seq=convertFromHash(hash)

    r=mod(hash,8);
    n=floor(hash/8);
    
    seq=[r];
    while(n~=0)
        r=mod(n,8);
        n=floor(n/8);
        seq=[r,seq];
    end
    
    seq=seq+2;
    
    if(length(seq)<3)
        num=3-length(seq);
        for i=1:num
            seq=[2,seq];
        end
    end
end