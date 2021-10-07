function [samples] = sample_frustum3d(Camera, view_dist, density, Pattern)
%sample_frustum3d Samples a truncated 3D camera viewing frustum.
%
%   The algorithm dissects the truncated frustum by planes orthogonal
%   to the camera optical axis (and parallel to the image plane).
% 
%   Each frustum slice is sampled individually, and the number of samples 
%   is linearly defined by the density parameters.
%
% === Inputs ===
% Camera            a structure with camera parameters
% view_dist         an array of viewing distances (size: 1xM)
% density           plane sampling density per meter squared
% Pattern           a structure with calibration pattern parameters
%
% === Outputs ===
% samples       samples of 6D poses inside the frustum (size: Nx3)

    samples = [];

    % sample 2D points at each view distance
    for idx = 1:max(size(view_dist))
        [~, ref_base] = compute_frustum(Camera, view_dist(idx));

        optical_base = transform_points3d(ref_base, ...
                                          Camera.T_inv_cam_optical);

        c_optical_base = c_space(optical_base, Pattern.dim);

        num_samples = round(density * rect_area(c_optical_base));
        optical_samples = inv_norm2d(c_optical_base, num_samples);
        
        ref_samples = transform_points3d(optical_samples, ...
                                         Camera.T_cam_optical);

        samples = [samples; ref_samples];
    end
end