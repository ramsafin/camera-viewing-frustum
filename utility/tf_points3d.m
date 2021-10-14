function [points_tf] = tf_points3d(points, T)
%transform_points.m Transforms 3D points multiplying to a homogeneous matrix.
% 
% === Inputs ===
% points        coordinates of points (size: Nx3)
% T             4x4 homogeneous transformation matrix
%
% === Outputs ===
% points_tf     coordinates of the transformted points (size: Nx3)

    points_tf = zeros(size(points));

    for idx = 1:size(points, 1)
        point = T * transp([points(idx, :) 1]);
        points_tf(idx, :) = transp(point(1:3));
    end
end

