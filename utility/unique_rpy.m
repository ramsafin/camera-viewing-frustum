function [RPY] = unique_rpy(num_samples, limits)
%unique_rpy.m Summary of this function goes here
%   Detailed explanation goes here
    RPY = zeros(num_samples, 3);
    S = limits(1):limits(3):limits(2); % sample space
    
    [R, P, Y] = meshgrid(S, S, S);
    Cartesian = unique([R(:), P(:), Y(:)], 'rows');
    size(Cartesian, 1)
    num_samples
    
    indices = randsample(1:size(Cartesian, 1), num_samples);
    RPY = Cartesian(indices, :);
    RPY = sortrows(RPY, [2 3]);
end

