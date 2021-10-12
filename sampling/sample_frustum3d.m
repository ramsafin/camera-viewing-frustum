function [pos] = sample_frustum3d(Camera, Pattern, view_dists, density)
%sample_frustum3d Samples a truncated 3D camera viewing frustum (trapezoid).
%
% === Inputs ===
% Camera            a structure with camera parameters
% Pattern           a structure with calibration pattern parameters 
%                   (used to compute a C-space)
% view_dists        an array of view distance samples (size: 1xM)
% density           plane sampling density (samples per meter squared)
% 
% === Outputs ===
% pos               samples of 3D poses inside the frustum (size: Nx3)

    pos = [];

    % sample 3D points at each view distance
    for idx = 1:size(view_dists, 2)
        [~, ref_base] = compute_frustum(Camera, view_dists(1, idx));

        optical_base = transform_points3d(ref_base, ...
                                          Camera.T_inv_cam_optical);

        c_optical_base = c_space(optical_base, Pattern.dim);

        num_samples = round(density * rect_area(c_optical_base));
        optical_samples = inv_norm2d(c_optical_base, num_samples);

        ref_samples = transform_points3d(optical_samples, ...
                                         Camera.T_cam_optical);

        pos = [pos; ref_samples];
    end
end