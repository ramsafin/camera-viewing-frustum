%% [Required] MATLAB setup

clear all;

addpath(genpath('plotting'), genpath('sampling'), ...
        genpath('frustum'), genpath('utility'));

%% [Required] Options

Opts.axis_text = {'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k'};

Opts.fig = {'Color', 'white', 'WindowStyle', 'docked'};

Opts.frame = {'thick', 2, 'rgb', 'framelabeloffset', [0.1, 0.1], ...
    'text_opts', {'FontSize', 13, 'FontWeight', 'bold'}};

Opts.kmeans = {'Distance',  'sqeuclidean', 'Display', 'off', ...
    'Replicates', 50, 'MaxIter', 300, 'OnlinePhase', 'off'};

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

%% [Required] Pattern properties

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
view_dist = 1; % meters
[~, ref_cam_base] = compute_frustum(Camera, view_dist);

optical_cam_base = transform_points3d(ref_cam_base, ...
                                      Camera.T_inv_cam_optical);

% estimate the calibration pattern's C-space
c_optical_cam_base = c_space(optical_cam_base, Pattern.dim);

% generate frustum plane point samples
num_samples = 1200;
samples = inv_norm2d(c_optical_cam_base, num_samples);

% compute clusters of 2D points (on the frustum plane)
num_clusters = 50;

[cluster_ids, clusters] = kmeans(samples, num_clusters, Opts.kmeans{:});

avg_dist(clusters, zeros(1, 3), [0 0 1])

% (optional) display the distributed clusters error
% [silh, ~] = silhouette(samples, cluster_ids, 'sqeuclidean');

% factor = mean(silh);
% disp(['Clustering factor (the closer to 1 the better): ', ...
%      num2str(factor)]);

% cleanup
clear view_dist ref_cam_base optical_cam_base c_optical_cam_base ...
      num_samples samples num_clusters clusters cluster_ids ...
      factor silh;

%% Plot the sample points' clusters 

view_dist = 5; % meters
[ref_cam_origin, ref_cam_base] = compute_frustum(Camera, view_dist);

optical_cam_base = transform_points3d(ref_cam_base, ...
                                      Camera.T_inv_cam_optical);

c_optical_cam_base = c_space(optical_cam_base, Pattern.dim);

num_samples = 1000;
optical_samples = inv_norm2d(c_optical_cam_base, num_samples);

num_clusters = 50;

[~, clusters] = kmeans(optical_samples, num_clusters, Opts.kmeans{:});

% plot the centroids of the clusters
ref_clusters = transform_points3d(clusters, Camera.T_cam_optical);

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
      num_clusters clusters ref_clusters ...
      num_samples optical_samples;

%% Plot a calibration template and camera poses (3D)

figure('Name', 'Clustered frustum samples', Opts.fig{:});

trplot(Camera.T_cam_ref, 'frame', 'C_{ref}', Opts.frame{:});

hold on;

% plot a calibration pattern
% Note: pattern plane is orthogonal to the Z-axis of the optical frame
T_pattern = rt2tr(rpy2r(0, 0, 0), [0.75 0 1]);
plot_pattern3d(Pattern, T_pattern, 2);

% plot camera poses (as pyramids with axes)
num_cameras = 1;

for idx = 1:num_cameras
    R = rotz(180);
    T = rt2tr(R, [3, 0, 1]);
    plot_camera3d(idx, Camera, 0.5, T);
end

clear idx R T;

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
clear num_cameras T_pattern;

%% Sampling 6D poses in the viewing frustum

% === How does it work? ===
% Viewing frustum is a trapezoid with 2 bases located 
% at different distances from the camera's optical center.
% 
% Sampling in the trapezoid volume involves:
% 1. unifrom samplig the distance h of points from the optical center (Z-axis)
% 2. 2D inverse Gaussian sampling by rejection on the trapezoid's base 
%    located at distance h from the optical center

SAMPLING_DENSITY = 100; % samples per meter squared

% camera view distances: from, to, number of samples
dist_samples = unifrnd(0.5, 0.75, [1, 250]);

samples = sample_frustum3d(Camera, dist_samples, ...
                           SAMPLING_DENSITY, Pattern);

disp(['Number of samples: ', num2str(size(samples, 1))]);

% =====================================
% There are 3 choices for sub-sampling:
% 1. Clustering + uniform sampling
% 2. Clustering
% 3. Uniform sampling

% clusterting
NUM_CLUSTERS = 500;

disp('Starting K-means ...');

tic
[~, samples] = kmeans(samples, NUM_CLUSTERS, Opts.kmeans{:}, ...
    'Replicates', 100, 'MaxIter', 300);
toc

disp('K-means finished!');

avg_d = avg_dist(samples, zeros(1, 3), [1 0 0]);
disp(['Avg. distance of points to the X-axis: ', num2str(avg_d)]);

% cleanup
clear SAMPLING_DENSITY NUM_CLUSTERS dist_samples avg_d;

%% Uniform sampling over a frustum's volume
NUM_SUB_SAMPLES = 50;

% generate random sub-sample indices
indices = randsample(1:size(samples, 1), NUM_SUB_SAMPLES);

sub_samples = samples(indices, :);

avg_d = avg_dist(sub_samples, zeros(1, 3), [1 0 0]);
disp(['Avg. distance of points to the X-axis: ', num2str(avg_d)]);

% cleanup
clear NUM_SUB_SAMPLES indices avg_d;

%% [Experimental] Sample 3D orientation
rpy = zeros(size(sub_samples, 1), 3);

%% [Experimental] Plotting 
figure('Name', 'Clustered frustum samples', Opts.fig{:});

% camera optical frame
trplot(Camera.T_cam_optical, Opts.frame{:}, 'frame', 'C_{opt}');

hold on;

% plot the near and far planes of the trapezoid
[~, near_base] = compute_frustum(Camera, 0.5);
[far_origin, far_base] = compute_frustum(Camera, 1);

plot_frustum3d(far_origin, far_base);
plot_image_axes(far_base);

patch(near_base(:, 1), near_base(:, 2), near_base(:, 3), 1, ...
    'FaceColor', '#A2142F', 'FaceAlpha', 0.5, ...
    'EdgeColor', '#A2142F', 'EdgeAlpha', 0.5, ...
    'LineWidth', 1);

% plot poses as dots

scatter3(sub_samples(:, 1), sub_samples(:, 2), sub_samples(:, 3), ...
         10, 'filled', ...
         'Marker', 'o', ...
         'MarkerEdgeColor', 'k', ...
         'MarkerFaceColor', [0 .75 .75]);
 
% plot poses as trapezoids
cam_height = 0.12;

for idx = 1:size(samples, 1)
    % Note: pose correction of the camera w.r.t. reference frame
    % location = samples(idx, :);
    % T = rt2tr(rpy2r(samples(idx, :)), location) * T_cam_optical;
    % plot_camera_pose(cam_origin, cam_base, idx, cam_height, T);
end

% figure settings
grid on;
view([-90 90]);
title('Pattern poses 3D');
axis([-1, 1, -1, 1, -1, 1] .* 1.2);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});

hold off;

clear near_base far_origin far_base cam_height idx rpy;

%% [Draft] Sample orientation

% sample RPY (w.r.t. the camera reference frame)
rpy_clusters = ... 
    sample_optical_rpy(transform_points3d(sub_clusters, inv(T_cam_optical)), ...
                                          [5, 45], [5, 45], [0, 0]);

%% [Draft] Output sampled calibration template poses

% File name structure:
% 1. poses
% 2. view distance range
% 3. number of samples
% 4. index
% Ex.: poses_0.5_to_0.75cm_200_1.csv

% save as CSV
csv_samples = zeros(num_sub_samples, 6);
csv_samples(:, 1:3) = round(sub_clusters, 3);
csv_samples(:, 4:6) = round(deg2rad(rpy_clusters), 3);

writematrix(csv_samples, 'data/poses6D_0.5_1.5m_50_5.csv', ...
    'FileType', 'text', ...
    'Encoding', 'UTF-8');
