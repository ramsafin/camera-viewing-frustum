function [Q1, Q2, Q3, Q4] = partition_rpy(RPY)
%partition_rpy.m Partitions RPY into groups of negative 
%                 and/or positive pitch and yaw angles.
%                                 
% === Inputs ===
% RPY           a matrix of roll, pitch, yaw angles (size: Nx3)
%
% === Outputs ===
% Q1            a matrix of RPYs (pitch - negative, yaw - positive)
% Q2            a matrix of RPYs (pitch - negative, yaw - negative)
% Q3            a matrix of RPYs (pitch - positive, yaw - negative)
% Q4            a matrix of RPYs (pitch - positive, yaw - positive)
    Q1 = RPY(RPY(:, 2) < 0 & RPY(:, 3) > 0, :);
    Q2 = RPY(RPY(:, 2) < 0 & RPY(:, 3) < 0, :);
    Q3 = RPY(RPY(:, 2) > 0 & RPY(:, 3) < 0, :);
    Q4 = RPY(RPY(:, 2) > 0 & RPY(:, 3) > 0, :);
end

