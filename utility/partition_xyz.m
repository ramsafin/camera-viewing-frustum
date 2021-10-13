function [Q1, Q2, Q3, Q4] = partition_xyz(XYZ)
%partition_xyz.m Partitions 3D position into quadrands (YZ axis).
%
% === Inputs ===
% XYZ           a matrix of 3D positions
%
% === Outputs ===
% Q1            1st quadrant positions
% Q2            2nd quadrant positions
% Q3            3rd quadrant positions
% Q4            4th quadrant positions
    
    Q1 = XYZ(XYZ(:, 2) > 0 & XYZ(:, 3) > 0, :);
    Q2 = XYZ(XYZ(:, 2) < 0 & XYZ(:, 3) > 0, :);
    Q3 = XYZ(XYZ(:, 2) < 0 & XYZ(:, 3) < 0, :);
    Q4 = XYZ(XYZ(:, 2) > 0 & XYZ(:, 3) < 0, :);
end

