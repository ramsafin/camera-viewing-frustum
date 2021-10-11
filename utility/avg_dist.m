function [dist] = avg_dist(points, v1, v2)
%mean_dist.m Computes the average Euclidean distance of all the points 
%            to the line.
% 
% === Inputs ===
% points        an array of 2D or 3D points (size: Nx2 or Nx3)
% v1, v2        vector start and end coordinates
%
% === Outputs ===
% dist     computed average distance

    dist_num = size(points, 1);
    dist_sum = 0;
    
    v = v1 - v2;
    
    for idx=1:dist_num
        dist_sum = dist_sum + norm(cross(v, points(idx, :))) / norm(v);
    end

    dist = dist_sum / dist_num;
end