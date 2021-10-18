function [] = plot_camera3d(id, Camera, view_dist, T, opts)
%plot_camera3d.m Plots a camera's viewing frustum at a pose.
%
% === Inputs ===
% id            camera pose identifier (used as the frame's name)
% Camera        the structure representing a camera parameters 
%               (see compute_frustum.m for more details)
% view_dist     the frustum's heigth in meters
% T             4x4 homogeneous matrix representing the camera's 6D pose
    
    % compute camera viewing frustum
    [origin, base] = frustum3d(Camera, view_dist);
    
    % transform the frustum to the posture
    origin = tf_points3d(origin, T);
    base = tf_points3d(base, T);
    
    % plot the frustum in the posture
    plot_frustum3d(origin, base, opts);
    
    % plot the frustum's optical frame
    trplot(T * Camera.T_cam_optical, opts.frame{:}, ...
        'frame', num2str(id), 'thick', 3, 'length', view_dist * 0.75);
end