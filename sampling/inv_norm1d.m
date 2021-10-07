function [samples] = inv_norm1d(range, mean, stddev, num_samples)
%inv_norm1d.m Sample scalar values from inverse normal distribution.
%   Inverse normal distributed samples form an inverse bell curve, mostly
%   concentraiting on the edges of the specified range.
%
%   Refer to https://en.wikipedia.org/wiki/Rejection_sampling for more info.
%
% === Inputs ===
% range         a min and max values to sample from (size: 1x2)
% mean          normal distribution mean
% stddev        normal distribution standard deviation
% num_samples   a number of samples to generate
%
% === Outputs ===
% samples       generated inverse normal distribution samples

    num_remained = num_samples;
    samples = zeros(1, num_samples);
    
    coeff = -1 / (2 * power(stddev, 2));
    
    while num_remained > 0
        x = unifrnd(range(1), range(2));
        
        if exp(coeff * power(x - mean, 2)) < unifrnd(0, 1)
            samples(num_remained) = x;
            num_remained = num_remained - 1;
        end
    end
end

