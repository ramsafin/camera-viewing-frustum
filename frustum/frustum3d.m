function [origin, base] = frustum3d(Camera, view_dist)
%compute_frustum.m Computes a 3D camera viewing frustum at a particular distance.
%   
%   The viewing frustum is computed at a given distance along the optical axis (X-axis).
%   It represents a pyramid with a base plane parallel to the image plane (YZ-plane).
%
% === Inputs ===
% camera            a structure with camera parameters
%
% view_dist         viewing distance from the camera's origin 
%                   to the frustum's base (in meters)
%
% === Outputs ===
% origin        origin coordinates (size: 1x3)
% base          base coordinates in the Cartesian quadrants order (size: 4x3).

    % compute the pyramid's base size
    y_len = 2 * tan(Camera.hfov / 2) * view_dist;
    z_len = y_len / Camera.aspect_ratio;

    y_offset = y_len / 2;
    z_offset = z_len / 2;
    
    % fprintf('[Frustum 3D] Offsets y: %.3f z: %.3f\n', y_offset, z_offset);

    % compute the pyramid's base points in the Cartesian quadrants order (YZ-plane)
    base = transp([1 1 1 1; 1 -1 -1 1; 1 1 -1 -1]);
    base = base .* [view_dist, y_offset, z_offset];
    
    % transform into the camera reference frame
    base = tf_points3d(base, Camera.T_cam_ref);
    origin = transp(transl(Camera.T_cam_ref));
end