function dist=find3dDistance(A, B)

    temp = (A-B).^2;
    dist = (temp(:,1)+temp(:,2)+temp(:,3)).^0.5;

end