function [] = plot_camera3d(id, Camera, view_dist, T)
%plot_camera3d.m Plots a camera's viewing frustum at a pose.
%
% === Inputs ===
% id            camera pose identifier (used as the frame's name)
% Camera        the structure representing a camera parameters 
%               (see compute_frustum.m for more details)
% view_dist     the frustum's heigth in meters
% T             4x4 homogeneous matrix representing the camera's 6D pose

    % compute camera viewing frustum
    [origin, base] = compute_frustum(Camera, view_dist);

    % transform the frustum to the posture
    origin = transform_points3d(origin, T);
    base = transform_points3d(base, T);

    % plot the frustum in the posture
    plot_frustum3d(origin, base);

    % plot the frustum's optical frame
    trplot(T * rpy2tr([-90 0 -90]), ...
        'length', view_dist * 0.75, ...
        'thick', 1.7, ...
        'rgb', 'notext', ...
        'frame', num2str(id), ...
        'text_opts', {'FontSize', 7});
end