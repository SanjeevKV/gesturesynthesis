function [x,y,z] = decompose_rotation(R)
	x = atan2(R(3,2), R(3,3)) * 57.2958;
	y = atan2(-R(3,1), sqrt(R(3,2)*R(3,2) + R(3,3)*R(3,3))) * 57.2958;
	z = atan2(R(2,1), R(1,1)) * 57.2958;
end