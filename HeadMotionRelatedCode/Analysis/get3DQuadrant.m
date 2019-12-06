function q=get3DQuadrant(x,y,z,nr)

%     if((x^2+y^2+z^2)^0.5<0.1*nr)
%         q=1;
%         return
%     end

    if(sign(x) > 0 && sign(y) > 0 && sign(z) > 0)
        q=2;
    elseif(sign(x) < 0 && sign(y) > 0 && sign(z) > 0)
        q=3;
    elseif(sign(x) > 0 && sign(y) < 0 && sign(z) > 0)
        q=4;
    elseif(sign(x) > 0 && sign(y) > 0 && sign(z) < 0)
        q=5;
    elseif(sign(x) < 0 && sign(y) < 0 && sign(z) > 0)
        q=6;
    elseif(sign(x) > 0 && sign(y) < 0 && sign(z) < 0)
        q=7;
    elseif(sign(x) < 0 && sign(y) > 0 && sign(z) < 0)
        q=8;
    elseif(sign(x) < 0 && sign(y) < 0 && sign(z) < 0)
        q=9;
    end
        
end