function [samples] = inv_norm2d(region, num_samples)
%inv_norm2d.m Sample 2D samples from the inverse normal distribution.
%   For more information see inv_norm1d function.
%   In case a 3D region is provided with the same 3rd dimension values,
%   then they are just copied into the output.
%
% === Inputs ===
% region         defines the min and max sample values (size: 4x2 or 4x3)
% num_samples    a number of samples to generate
%
% === Outputs ===
% samples       inverse normal distribution samples (size: Nx2 or Nx3)s

    samples = zeros(num_samples, size(region, 2));

    if size(region, 2) == 3
        samples(:, 3) = region(1, 3);
    end

    % min and max values of the 2D region
    x_minmax = unique(minmax(region(:, 1)));
    y_minmax = unique(minmax(region(:, 2)));

    % 3-sigma rule
    stddev_x = norm(x_minmax) / 12;
    stddev_y = norm(y_minmax) / 12;

    samples(:, 1) = inv_norm1d(x_minmax, 0, stddev_x, num_samples);
    samples(:, 2) = inv_norm1d(y_minmax, 0, stddev_y, num_samples);
end