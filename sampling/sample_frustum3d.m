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
% pos               samples of 3D positions inside the frustum (size: Nx3)

    pos = [];

    % sample 3D points at each view distance
    for idx = 1:size(view_dists, 2)
        % compute 3D frustum
        [~, ref_base] = frustum3d(Camera, view_dists(1, idx));

        % working in the camera optical frame
        optical_base = tf_points3d(ref_base, Camera.T_inv_cam_optical);

        % compute pattern's C-space
        c_optical_base = c_space(optical_base, Pattern.dim);
        
        % sample the C-space (number of samples ~ area in squared meters)
        num_samples = floor(density * rect_area(c_optical_base));
        optical_samples = inv_norm2d(c_optical_base, num_samples);
        
        % convert back to the camera reference frame
        ref_samples = tf_points3d(optical_samples, Camera.T_cam_optical);

        pos = [pos; ref_samples];
    end
end