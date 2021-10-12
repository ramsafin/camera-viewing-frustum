function [poses] = sample_frustum3d(Camera, Pattern, ...
    view_dists, density, rpy_lims)
%sample_frustum3d Samples a truncated 3D camera viewing frustum (trapezoid).
%
% === Inputs ===
% Camera            a structure with camera parameters
% Pattern           a structure with calibration pattern parameters 
%                   (used to compute a C-space)
% view_dists        an array of view distance samples (size: 1xM)
% density           plane sampling density (samples per meter squared)
% rpy_lims           roll, pitch, yaw angle limits in degrees
% 
% === Outputs ===
% poses             samples of 6D poses inside the frustum (size: Nx3)

    positions = [];

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

        positions = [positions; ref_samples];
    end

    num_samples = size(positions, 1);

    poses = zeros(num_samples, 6);
    poses(:, 1:3) = positions;
    poses(:, 4:6) = unique_rpy(num_samples, rpy_lims);
    
    poses = sortrows(poses, 1:6);
end