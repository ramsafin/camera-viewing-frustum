function [RPY] = unique_rpy(roll, pitch, yaw)
%unique_rpy.m Generate a set of all possible RPY sequences.
%   Angles are limited according to the respective function arguments.
%
% === Inputs ===
% roll          a sequence of roll samples to draw from
% pitch         a sequence of pitch samples to draw from
% yaw           a sequence of yaw samples to draw from
%
% === Output ===
% RPY           a set of all possilbe combinations of roll, pitch, and yaw

    [R, P, Y] = meshgrid(roll, pitch, yaw);
    RPY = sortrows(unique([R(:), P(:), Y(:)], 'rows'), [1 2 3]);
end