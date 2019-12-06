function interpolationInd = getInterpolationIndices(zeroIndices)

	interpolationInd=[];
    m=[];
    init=zeroIndices(2);
    v=[zeroIndices(2)];
    for i=2:length(zeroIndices)
        if init == zeroIndices(i)
            init=init+1;
        else
            v=[v zeroIndices(i-1)];
            if (v(2)-v(1))/120 <=3
                m = [m ; v];
            end
            init = zeroIndices(i);
            v = [zeroIndices(i)];
            init = init+1;
        end
    end

    v=[v zeroIndices(i-1)];
    if (v(2)-v(1))/120 <=3
        interpolationInd=[m;v];
    end

end
