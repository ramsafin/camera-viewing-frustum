function [dist] = avg_dist_plane(points, A, B, C, D)
%avg_dist_plane.m Computes the average distance of all the points to a 3D plane.
%
% === Inputs ===
% points        an array of 3D points (size: Nx3)
% A, B, C, D    plane coefficients (Ax + By + Cz + D = 0)
    dist_num = size(points, 1);
    dist = 0;
    
    for idx=1:dist_num
        dist = dist + abs(A*points(idx, 1) + B*points(idx, 2) + C*points(idx, 3) + D) ...
                      / sqrt(A*A + B*B + C*C);
    end
    
    dist = dist / dist_num;
end
