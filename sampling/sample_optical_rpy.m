function [rpy] = sample_optical_rpy(xyz, r, p, y)
%SAMPLE_RPY Summary of this function goes here
%   Detailed explanation goes here

    num_poses = size(xyz, 1);

    rpy = zeros(num_poses, 3);

    % yaw (optical axis)
    rpy(:, 1) = 0;
    
    % pitch (optical axis)
    rpy(:, 3) = -180;
    
    % roll (optical axis)
    rpy(:, 2) = 0;
    
    for idx = 1:num_poses
        loc = xyz(idx, :);  % in optical frame
        
        roll = unifrnd(r(1), r(2));
        pitch = unifrnd(p(1), p(2));
        
        if loc(1) >= 0
            if loc(2) >= 0  % 1st quarter
                rpy(idx, 2) = - roll;
                rpy(idx, 3) = rpy(idx, 3) - pitch;
            else            % 4th quarter
                rpy(idx, 2) = roll;
                rpy(idx, 3) = rpy(idx, 3) - pitch;
            end
        else
            if loc(2) >= 0  % 2nd quarter
                rpy(idx, 2) = - roll;
                rpy(idx, 3) = rpy(idx, 3) + pitch;
            else            % 3rd quarter
                rpy(idx, 2) = roll;
                rpy(idx, 3) = rpy(idx, 3) + pitch;
            end
        end
    end
end

