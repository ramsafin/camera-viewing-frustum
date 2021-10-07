%% [Required] MATLAB setup

clear all;

addpath(genpath('plotting'), genpath('sampling'), ...
        genpath('frustum'), genpath('utility'));

%% [Required] Plotting options

Opts.axis_text = {'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k'};

Opts.fig = {'Color', 'white', 'WindowStyle', 'docked'};

Opts.frame = {'thick', 2, 'rgb', 'framelabeloffset', [0.1, 0.1], ...
    'text_opts', {'FontSize', 13, 'FontWeight', 'bold'}};

%% [Required] Camera properties (camera model)

Camera.name = 'Pin-hole camera';

Camera.hfov = deg2rad(60);
Camera.aspect_ratio = 4/3;

Camera.height = 480;
Camera.width = Camera.height * Camera.aspect_ratio;

% camera reference frame
Camera.T_cam_ref = eye(4);

% camera optical frame (REP 103: https://www.ros.org/reps/rep-0103.html)
%   OX - right
%   OY - down
%   OZ - forward (camera viewing direction)
Camera.T_cam_optical = rpy2tr(-90, 0, -90) * Camera.T_cam_ref;

% transform from the reference to optical frame
Camera.T_inv_cam_optical = inv(Camera.T_cam_optical);

%% [Required] Constants

Pattern.name = "Checkerboard";
Pattern.dim = [297, 210] * 1e-3;

%% Camera viewing frustum (3D)

% compute the frustum points in the camera reference frame
view_dist = 10; % meters
[ref_cam_origin, ref_cam_base] = compute_frustum(Camera, view_dist);

figure('Name', 'Camera viewing frustum', Opts.fig{:});

% plot the camera optical frame
trplot(Camera.T_cam_optical, Opts.frame{:}, ...
    'length', view_dist * 0.7, 'frame', 'C_{opt}');

hold on;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
% plot the camera frustum (pyramid)
plot_frustum3d(ref_cam_origin, ref_cam_base);

% plot image plane XY axes
plot_image_axes(ref_cam_base);

% figure settings
grid on;
view([40 30]);
title('Viewing frustum 3D');
axis([-1, 1, -1, 1, -1, 1] .* view_dist);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});
zlabel('Z (m)', Opts.axis_text{:});

hold off;

% cleanup
clear ref_cam_base ref_cam_origin view_dist;

%% Camera viewing frustum (2D)

% compute the frustum points in the camera reference frame
view_dist = 1; % meters
[~, ref_cam_base] = compute_frustum(Camera, view_dist);

% transform frustum plane's base points to camera optical frame
optical_cam_base = transform_points3d(ref_cam_base, ...
                                      Camera.T_inv_cam_optical);

% estimate the calibration pattern's C-space
[c_optical_cam_base, ~] = c_space(optical_cam_base, Pattern.dim);

% generate frustum plane points (inverse Gaussian by rejection sampling)
num_samples = 500;
samples = inv_norm2d(c_optical_cam_base, num_samples);

figure('Name', 'Viewing frustum plane', Opts.fig{:});

% plot the sample points
scatter(samples(:, 1), samples(:, 2), 'Marker', '*');

hold on;

plot_c_space(optical_cam_base, c_optical_cam_base);

% figure settings
grid on;
grid minor;
axis 'equal';
title('Viewing frustum plane (2D)');

legend(' Samples', ' Frustum (plane)', ' C-space', ...
       'Location', 'southeast')

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});

hold off;

% cleanup
clear view_dist pattern_dim num_samples samples ref_cam_base ...
      optical_cam_base c_optical_cam_base optical_samples; 

%% Clustering sample points (2D)

% compute the frustum points in the camera reference frame
view_dist = 5; % meters
[~, ref_cam_base] = compute_frustum(Camera, view_dist);

optical_cam_base = transform_points3d(ref_cam_base, ...
                                      Camera.T_inv_cam_optical);

% estimate the calibration pattern's C-space
c_optical_cam_base = c_space(optical_cam_base, Pattern.dim);

% generate frustum plane point samples
num_samples = 1000;
samples = inv_norm2d(c_optical_cam_base, num_samples);

% compute clusters of 2D points (on the frustum plane)
num_clusters = 200;

[cluster_ids, ~] = kmeans(samples, num_clusters, ...
    'Distance',  'sqeuclidean', ...
    'Display', 'final', ...
    'Replicates', 100, ...
    'MaxIter', 500);

% (optional) display the distributed clusters error
[silh, ~] = silhouette(samples, cluster_ids, 'sqeuclidean');
clustering_factor = mean(silh);

disp(['Clustering factor (the closer to 1 the better): ', ...
      num2str(clustering_factor)]);

% cleanup
clear view_dist ref_cam_base optical_cam_base c_optical_cam_base ...
      num_samples samples num_clusters cluster_ids clustering_factor silh

%% Plot the sample points' clusters 

view_dist = 5; % meters
[ref_cam_origin, ref_cam_base] = compute_frustum(Camera, view_dist);

optical_cam_base = transform_points3d(ref_cam_base, ...
                                      Camera.T_inv_cam_optical);

c_optical_cam_base = c_space(optical_cam_base, Pattern.dim);

num_samples = 1000;
optical_samples = inv_norm2d(c_optical_cam_base, num_samples);

num_clusters = 50;
[~, optical_clusters] = kmeans(optical_samples, ...
    num_clusters, ...
    'Distance',  'sqeuclidean', ...
    'Display', 'final', ...
    'Replicates', 100, ...
    'MaxIter', 500);

% plot the centroids of the clusters
ref_clusters = transform_points3d(optical_clusters, Camera.T_cam_optical);

figure('Name', 'Clustered frustum samples', Opts.fig{:});

% plot the camera optical frame
trplot(Camera.T_cam_optical, Opts.frame{:}, ...
       'length', view_dist * 0.7, 'frame', 'C_{opt}');

hold on;

% plot viewing frustum and image plane axes
plot_frustum3d(ref_cam_origin, ref_cam_base);
plot_image_axes(ref_cam_base);

% plot cluster centers
scatter3(ref_clusters(:, 1), ref_clusters(:, 2), ref_clusters(:, 3), ...
         10, 'filled', 'Marker', 'o', ...
         'MarkerEdgeColor', 'k', 'MarkerFaceColor', [0 .75 .75]);
 
% figure settings
grid on;
view([45 30]);
title('Clustered frustum points');

axis([-1, 1, -1, 1, -1, 1] .* view_dist);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});

hold off;

clear view_dist ref_cam_origin ref_cam_base ...
      optical_cam_base c_optical_cam_base ...
      num_clusters optical_clusters ref_clusters ...
      num_samples optical_samples;

%% Plot a calibration template and camera poses (3D)

figure('Name', 'Clustered frustum samples', Opts.fig{:});

trplot(Camera.T_cam_ref, 'frame', 'C_{ref}', Opts.frame{:});

hold on;

% plot a calibration pattern
% Note: pattern plane is orthogonal to the Z-axis of the optical frame
T_pattern_ref = rt2tr(rpy2r(0, 0, 0), [0 0 0.1]);
plot_pattern3d(Pattern, T_pattern_ref, 2);

% plot camera poses (as pyramids with axes)
num_cameras = 1;

for idx = 1:num_cameras
    R = roty(0);
    T = rt2tr(R, [1, 0.5, 1]);
    plot_camera3d(idx, Camera, 0.3, T);
end

% view setiings
view([45 30]);
title('Camera poses');
axis([-1, 4, -3, 3, -3, 3]);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});
zlabel('Z (m)', Opts.axis_text{:});

hold off;

% cleanup
clear num_cameras idx R T_pattern_ref T;

%% Sample 6D poses (in trapezoid)

% a) generate view distances of trapezoid (in meters)
h_start = 0.5;
h_delta = 1.0;
h_step = 0.1;

view_distances = h_start:h_step:(h_start + h_delta); % meters
clear h_start h_delta h_step;

% b) sample 3D position points at each view distance
PATTERN_DIM = [297, 210] * 1e-3;

% number of samples per distance (per trapezoid slice)
num_samples = 1000; % Note: can be computed based on view distance

samples = zeros(size(view_distances, 2) * num_samples, 3);

for i = 1:size(view_distances, 2)
    h = view_distances(i);
    
    [~, ref_cam_base] = ...
        compute_frustum(hfov_deg, h, aspect_ratio, T_cam_optical);
    
    opt_cam_base = transform_points3d(ref_cam_base, inv(T_cam_optical));
    
    opt_cam_base = c_space(opt_cam_base, PATTERN_DIM);
    
    h_samples = sample_frustum_plane(opt_cam_base, num_samples);
    
    samples(((i - 1) * num_samples + 1):(i * num_samples), :) = ...
        transform_points3d(h_samples, T_cam_optical);
end

clear i h h_samples;

num_clusters = 200;

[cluster_ids, cluster_centroids] = kmeans(samples, ...
    num_clusters, ...
    'Distance',  'sqeuclidean', ...
    'Display', 'final', ...
    'Replicates', 50, ...
    'MaxIter', 500);

%% choose N random samples (uniform probability)
num_sub_samples = 50;

sub_clusters = cluster_centroids(randsample(size(cluster_centroids, 1), num_sub_samples), :);

% sample RPY (w.r.t. the camera reference frame)
rpy_clusters = ... 
    sample_optical_rpy(transform_points3d(sub_clusters, inv(T_cam_optical)), ...
                                          [0, 45], [0, 45], [0, 0]);
                                      
% Save as CSV
csv_samples = zeros(num_sub_samples, 6);
csv_samples(:, 1:3) = round(sub_clusters, 3);
csv_samples(:, 4:6) = round(deg2rad(rpy_clusters), 3);

writematrix(csv_samples, 'data/poses6D_0.5_1.5m_50_5.csv', ...
    'FileType', 'text', ...
    'Encoding', 'UTF-8');

%% plot
figure('Name', 'Clustered frustum samples', ...
       'Color', 'white', ...
       'WindowStyle', 'docked');

% plot the camera optical frame
trplot(T_cam_optical, ...
    'length', view_distances(1) * 0.8, ...
    'thick', 2, ...
    'rgb', ...
    'frame', 'C_{opt}', ...
    'text_opts', {'FontSize', 13, 'FontWeight', 'bold'}, ...
    'framelabeloffset', [0.1, 0.1]);

hold on;

% plot the near and far planes of the trapezoid
[near_origin, near_base] = ...
        compute_frustum(hfov_deg, view_distances(1), ...
        aspect_ratio, T_cam_optical);
    
[far_origin, far_base] = ...
        compute_frustum(hfov_deg, ...
        unique(max(view_distances)), ...
        aspect_ratio, T_cam_optical);

%plot_frustum(near_origin, near_base);
plot_frustum(far_origin, far_base);

% plot frustum plane's XY axes
plot_image_axes(far_base);

% plot the near plane in red color
patch(near_base(:, 1), near_base(:, 2), near_base(:, 3), 1, ...
    'FaceColor', '#A2142F', ...
    'FaceAlpha', 0.5, ...
    'EdgeColor', '#A2142F', ...
    'EdgeAlpha', 0.5, ...
    'LineWidth', 1);

% plot poses as dots
scatter3(sub_clusters(:, 1), ...
         sub_clusters(:, 2), ...
         sub_clusters(:, 3), ...
         10, 'filled', ...
         'Marker', 'o', ...
         'MarkerEdgeColor', 'k', ...
         'MarkerFaceColor', [0 .75 .75]);
 
% plot poses as trapezoids
cam_height = 0.12;

[cam_origin, cam_base] = ... 
    compute_frustum(hfov_deg, cam_height, aspect_ratio, T_cam_ref);

for idx = 1:size(sub_clusters, 1)
    % Note: pose correction of the camera w.r.t. reference frame
    location = sub_clusters(idx, :);
    T = rt2tr(rpy2r(rpy_clusters(idx, :)), location) * T_cam_optical;
    % plot_camera_pose(cam_origin, cam_base, idx, cam_height, T);
end

% trplot(rt2tr(rpy2r(rpy_clusters(1, :)), sub_clusters(1, :)), 'frame', 'Loc');

% figure settings
grid on;
view([-30 20]);
title('Clustered frustum points');

axis([-1, 1, -1, 1, -1, 1] .* unique(max(view_distances)) * 1.2);

set(gca, 'FontSize', 13);
xlabel('X (m)', axis_text_opts{:});
ylabel('Y (m)', axis_text_opts{:});

hold off;
