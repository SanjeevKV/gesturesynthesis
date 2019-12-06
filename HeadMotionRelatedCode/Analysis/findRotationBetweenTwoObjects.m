function angles = findRotationBetweenTwoObjects(AOrig, BOrig, COrig, DOrig, A, B, C, D)
len = 13835;
mat1=[];
mat2=[];
angles=[];
for i=1:len
    
    mat1=[mat1;AOrig(i,:)];
    mat1=[mat1;BOrig(i,:)];
    mat1=[mat1;COrig(i,:)];
    mat1=[mat1;DOrig(i,:)];
    
    mat2=[mat2;A(i,:)];
    mat2=[mat2;B(i,:)];
    mat2=[mat2;C(i,:)];
    mat2=[mat2;D(i,:)];
    
    [R,t]=rigid_transform_3D(mat2,mat1);
    [x, y, z] = decompose_rotation(R);
    angles=[angles;x, y, z];
    
    mat1=[];
    mat2=[];
end
    