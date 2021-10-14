function [samples] = inv_norm2d(base, num_samples)
%inv_norm2d.m Generates 3D samples from the inverse normal distribution.
%   
%   Samples are generated on a YZ-plane.
%   For more information see inv_norm1d function.
%
% === Inputs ===
% base           a rectangle that defines the min/max sample values (size: 4x2 or 4x3)
% num_samples    a number of samples to generate
%
% === Outputs ===
% samples       inverse normal distribution samples (size: Nx2 or Nx3)s

    samples = zeros(num_samples, size(base, 2));

    if size(base, 2) == 3
        samples(:, 1) = base(1, 1);
    end

    % min and max values of the 2D region
    y_minmax = unique(minmax(base(:, 2)));
    z_minmax = unique(minmax(base(:, 3)));

    % 3-sigma rule
    stddev_y = norm(y_minmax) / 12;
    stddev_z = norm(z_minmax) / 12;

    samples(:, 2) = inv_norm1d(y_minmax, 0, stddev_y, num_samples);
    samples(:, 3) = inv_norm1d(z_minmax, 0, stddev_z, num_samples);
end