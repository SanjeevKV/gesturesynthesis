% 
% This file expects N matrices as input, where N is the number of markers
% on the 3D object you want to find Rotation of. 
% Each matrix should be of size Mx3, where M is the number of
% frames/time-instants and each row contains x,y,z coordinates. Each matrix
% should contain data about one marker only.
% Sizes of all matrices given as input should be same i.e Mx3

% LIMITATION : This code will not work if all markers lie on the same
% plane.

function transform=getTransformForObject(cellArray, transMarkerIndex)

    markerCount=length(cellArray);
    
    % 1st frame from optitrack is always 0
    refIndex=2;
    % Get reference position of Object. 
    refPos=zeros(markerCount,3);
    for i=1:markerCount
        refPos(i,:)=mean(cellArray{i});
    end
    
    numberOfFrames=size(cellArray{1},1);
    transform=zeros(numberOfFrames-1, 6);
    
    for i=refIndex:numberOfFrames
        currPos=zeros(markerCount,3);
        for j=1:markerCount
            currPos(j,:)=cellArray{j}(i,:);
        end
        t = refPos(transMarkerIndex,:)-currPos(transMarkerIndex, :);
        currPos = currPos - repmat(t, markerCount, 1);
        R=rigid_transform_3D(refPos,currPos);
        [x, y, z] = decompose_rotation(R);
        transform(i,:)= [x y z t];
        disp(['Frame number ' num2str(i) ' done']);
    end
end

function [x,y,z] = decompose_rotation(R)
	x = atan2(R(3,2), R(3,3)) * 57.2958;
	y = atan2(-R(3,1), sqrt(R(3,2)*R(3,2) + R(3,3)*R(3,3))) * 57.2958;
	z = atan2(R(2,1), R(1,1)) * 57.2958;
end

