function [origin, base] = frustum3d(camera, view_dist)
%compute_frustum.m Computes a camera viewing frustum (trapezoid).
%    The frustum is computed at a given viewing distance and transformed
%    into camera's reference frame.
%
% === Inputs ===
% camera        A structure with camera parameters. 
%               Required fields:
%                   - hfov           horizontal field of view in radians
%                   - aspect_ratio   width / height, type: double
%                   - T_cam_optical  4x4 homogeneous transformation matrix 
%                                    which converts points from the optical 
%                                    frame (REP 103) to the reference frame
%
% view_dist     Viewing distance from the camera's origin to the frustum's 
%               base in meters (type: double)
%
% == Outputs ==
% origin        frustum origin XYZ coordinates (size: 1x3)
%
% base          frustum base XYZ coordinates in the Cartesian 
%               quadrands order (size: 4x3).

    % compute XY offsets of the frustum's base points
    x_len = 2 * tan(camera.hfov / 2) * view_dist;
    y_len = x_len / camera.aspect_ratio;

    x_offset = x_len / 2;
    y_offset = y_len / 2;

    % Note: base = transp([X; Y; Z])
    base = transpose([1 -1 -1 1; 1 1 -1 -1; 1 1 1 1]);
    base = base .* [x_offset, y_offset, view_dist];

    % transform origin and base points into the camera reference frame
    origin = transp(camera.T_cam_ref(1:3, 4));
    base = tf_points3d(base, camera.T_cam_optical);
end