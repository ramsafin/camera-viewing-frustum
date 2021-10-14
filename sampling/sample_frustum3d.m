function [pos] = sample_frustum3d(Camera, Pattern, view_dists, density)
%sample_frustum3d Samples a truncated 3D camera viewing frustum (trapezoid).
%
% === Inputs ===
% Camera            a structure with camera parameters
% Pattern           a structure with calibration pattern parameters
% view_dists        an array of view distance samples (size: 1xM)
% density           plane sampling density (samples per meter squared)
% 
% === Outputs ===
% pos               samples of 3D positions inside the frustum (size: Nx3)

    pos = [];

    % sample 3D points at each view distance
    for idx = 1:size(view_dists, 2)
        % compute 3D frustum
        [~, ref_base] = frustum3d(Camera, view_dists(1, idx));

        % compute pattern's C-space
        c_ref_base = c_space(ref_base, Pattern.dim, 5e-2);
        
        % sample the C-space (number of samples ~ area in squared meters)
        num_samples = floor(density * rect_area(c_ref_base));
        samples = inv_norm2d(c_ref_base, num_samples);

        pos = [pos; samples];
    end
end