%% [Required] MATLAB setup

clear all;
close all;

addpath(genpath('plotting'), genpath('sampling'), ...
        genpath('frustum'), genpath('utility'));

%% [Required] Options

Opts.axis_text = {'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k'};

Opts.fig = {'Color', 'white', 'WindowStyle', 'docked'};

Opts.frame = {'thick', 2, 'rgb', 'framelabeloffset', [0.1, 0.1], ...
    'text_opts', {'FontSize', 13, 'FontWeight', 'bold'}};

Opts.scatter = {'filled', 'Marker', 'o', 'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', [0 .75 .75]};

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

% transform from the reference to the optical frame
Camera.T_inv_cam_optical = inv(Camera.T_cam_optical);

%% [Required] Pattern properties

Pattern.name = "Checkerboard";
Pattern.dim = [297, 210] * 1e-3;
Pattern.T_ref_frame = rpy2tr(90, 0, 90);

%% Camera viewing frustum (3D)

% compute frustum points in the camera reference frame
view_dist = 10; % meters
[ref_cam_origin, ref_cam_base] = frustum3d(Camera, view_dist);

figure('Name', 'Camera viewing frustum', Opts.fig{:});

% plot camera optical frame
trplot(Camera.T_cam_optical, Opts.frame{:}, ...
    'length', view_dist * 0.7, 'frame', 'C_{opt}');

hold on;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
% plot camera frustum (3D pyramid)
plot_frustum3d(ref_cam_origin, ref_cam_base);

% plot image plane XY axes
plot_image_axes(ref_cam_base);

% setup graphics
grid on;
view([40 30]);
title('Viewing frustum 3D');
axis([-1, 1, -1, 1, -1, 1] .* view_dist);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});
zlabel('Z (m)', Opts.axis_text{:});

hold off;

% cleanup variables
clear ref_cam_base ref_cam_origin view_dist;

%% Camera viewing frustum (2D)

% compute frustum points in the camera reference frame
view_dist = 1; % meters
[~, ref_cam_base] = frustum3d(Camera, view_dist);

% transform frustum plane's base points to camera optical frame
optical_cam_base = tf_points3d(ref_cam_base, Camera.T_inv_cam_optical);

% estimate calibration pattern's C-space
[c_optical_cam_base, ~] = c_space(optical_cam_base, Pattern.dim);

% generate frustum plane points (inverse Gaussian by rejection sampling)
num_samples = 500;
samples = inv_norm2d(c_optical_cam_base, num_samples);

figure('Name', 'Viewing frustum plane', Opts.fig{:});

% plot sample points
scatter(samples(:, 1), samples(:, 2), 21, Opts.scatter{:});

hold on;

% plot C-space boundaries
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

% cleanup variables
clear view_dist pattern_dim num_samples samples ref_cam_base ...
      optical_cam_base c_optical_cam_base optical_samples; 

%% Clustering sample points (2D)

% compute frustum points in the camera reference frame
view_dist = 1; % meters
[~, ref_cam_base] = frustum3d(Camera, view_dist);

% transform frustum base points into the camera optical frame
optical_cam_base = tf_points3d(ref_cam_base, Camera.T_inv_cam_optical);

% estimate calibration pattern's C-space
c_optical_cam_base = c_space(optical_cam_base, Pattern.dim);

% generate frustum plane samples
num_samples = 1200;
samples = inv_norm2d(c_optical_cam_base, num_samples);

% create clusters of 3D points (in the optical frame)
disp('Starting K-means ...');
tic
num_clusters = 50;
[~, clusters] = kmeans(samples, num_clusters, Opts.kmeans{:});
toc

% compute average distance of samples to the optical axis
avg_d = avg_dist(clusters, zeros(1, 3), [0 0 1]);
disp(['Avg. distance to the optical axis: ', num2str(avg_d, 3), ' m']);

% cleanup variables
clear view_dist ref_cam_base optical_cam_base c_optical_cam_base ...
      num_samples samples num_clusters clusters avg_d;

%% Plot clusters of sample points

% compute frustum points in the camera reference frame
view_dist = 3; % meters
[ref_cam_origin, ref_cam_base] = frustum3d(Camera, view_dist);

% transform frustum base points into the camera optical frame
optical_cam_base = tf_points3d(ref_cam_base, Camera.T_inv_cam_optical);

% estimate calibration pattern's C-space
c_optical_cam_base = c_space(optical_cam_base, Pattern.dim);

% generate frustum plane samples (inverse Gaussian by rejection sampling)
num_samples = 1000;
optical_samples = inv_norm2d(c_optical_cam_base, num_samples);

% clusters = datasample(optical_samples, 100, 'Replace', false);
% clusters = uniquetol(optical_samples, 1e-1, 'ByRows', true);

% create clusters of samples (in the optical frame)
num_clusters = 100;
[~, clusters] = kmeans(optical_samples, num_clusters, Opts.kmeans{:});

% transform cluster centroids to the reference frame
ref_clusters = tf_points3d(clusters, Camera.T_cam_optical);

figure('Name', 'Clustered frustum samples', Opts.fig{:});

% plot camera optical frame
trplot(Camera.T_cam_optical, Opts.frame{:}, ...
       'length', view_dist * 0.7, 'frame', 'C_{opt}');

hold on;

%{
plot_c_space(transform_points3d(optical_cam_base, Camera.T_cam_optical), ...
             transform_points3d(c_optical_cam_base, Camera.T_cam_optical));
%}

% plot camera frustum and image plane axes
plot_frustum3d(ref_cam_origin, ref_cam_base);
plot_image_axes(ref_cam_base);

% plot cluster centroids
scatter3(ref_clusters(:, 1), ...
         ref_clusters(:, 2), ...
         ref_clusters(:, 3), ...
         24, Opts.scatter{:});
 
% figure settings
grid on;
view([45 30]);
title('Clustered frustum points');
axis([-1, 1, -1, 1, -1, 1] .* view_dist);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});

hold off;

% cleanup variables
clear view_dist ref_cam_origin ref_cam_base ...
      optical_cam_base c_optical_cam_base ...
      num_clusters clusters ref_clusters ...
      num_samples optical_samples;

%% Plot a calibration template and camera poses (3D)

figure('Name', 'Clustered frustum samples', Opts.fig{:});

% camera reference frame
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

% figure setiings
view([45 30]);
title('Camera poses');
axis([-1, 4, -3, 3, -3, 3]);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});
zlabel('Z (m)', Opts.axis_text{:});

hold off;

% cleanup variables
clear idx R T num_cameras T_pattern;

%% Sampling 3D poses in the viewing frustum

% === How does it work? ===
% Viewing frustum is a trapezoid with 2 bases located 
% at different distances from the camera's optical center.
% 
% Sampling in the trapezoid volume involves:
% 1. unifrom samplig the distance h of points from the optical center (Z-axis)
% 2. 2D inverse Gaussian sampling by rejection on the trapezoid's base 
%    located at distance h from the optical center
%
% The viewing distance is chosen empirically, such that all the calibration
% template points are observable and the distance to the camera is minimal.

SAMPLING_DENSITY = 50; % samples per meter squared

% camera view distances: from, to, number of samples
dist = unifrnd(0.5, 0.75, [1, 250]);
positions = sample_frustum3d(Camera, Pattern, dist, SAMPLING_DENSITY);

disp(['Number of poses: ', num2str(size(positions, 1))]);

% =====================================
% There are multiple choices for sub-sampling:
% 1. Clustering + uniform sampling
% 2. Clustering
% 3. Uniform sampling
% 4. Unique tolerance: uniquetol(samples, tolerance, 'ByRows', true)

% clusterting
NUM_CLUSTERS = 500;

tic
disp('Starting K-means ...');
[~, positions] = kmeans(positions, NUM_CLUSTERS, Opts.kmeans{:}, ...
    'Replicates', 50, 'MaxIter', 100);
toc

avg_d = avg_dist(positions, zeros(1, 3), [1 0 0]);
disp(['Avg. distance of points to the X-axis: ', num2str(avg_d, 3), ' m']);

% cleanup
clear SAMPLING_DENSITY NUM_CLUSTERS dist avg_d;

%% Uniform sampling over a frustum's volume
NUM_SUB_SAMPLES = 50;

% Note: sub-sampled elements could be weighted
positions = datasample(positions, NUM_SUB_SAMPLES, 'Replace', false);

avg_d = avg_dist(positions, zeros(1, 3), [1 0 0]);
disp(['Avg. distance of points to the X-axis: ', num2str(avg_d, 3), ' m']);

% cleanup variables
clear NUM_SUB_SAMPLES avg_d;

%% Sampling pattern 3D orientation

% ================================
% 1. Generate all unique RPY combinations (given the limits).
% 2. Partition 3D orientation angles into groups with positive/negative:
%   2.1. Pitch
%   2.2. Yaw
% 3. Partition 3D positions into quadrants (YZ axes in the reference frame).
% 4. Sample RPY for a 3D position:
%   4.1. 1st/2nd quadrants - negative pitch, 3rd/4th - positive pitch
%   4.2. 1st/4th quadrants - positive yaw, 2nd/3rd - negative yaw
%   4.3. roll - any

% TODO: RPYs are not sampled based on the number of position samples.

RPYs = rand_sign(unique_rpy(0, 5:3:70, 5:3:70), [1 2 3], 0.5);

[Q1, Q2, Q3, Q4] = partition_rpy(RPYs);
[P1, P2, P3, P4] = partition_xyz(positions);

% join positions + RPYs
poses = [P1 datasample(Q1, size(P1, 1), 'Replace', false); ...
         P2 datasample(Q2, size(P2, 1), 'Replace', false); ...
         P3 datasample(Q3, size(P3, 1), 'Replace', false); ...
         P4 datasample(Q4, size(P4, 1), 'Replace', false)];
     
poses = sortrows(poses, [1 2 3]);

clear RPYs P1 P2 P3 P4 Q1 Q2 Q3 Q4 positions;

%% [Experimental] Plotting 
figure('Name', 'Clustered frustum samples', Opts.fig{:});

title('Pattern poses 3D');

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});

view([-100 5]);
grid on;

[~, near_base] = frustum3d(Camera, 0.5);
[far_origin, far_base] = frustum3d(Camera, 1.5);

%{
scatter3(sub_samples(:, 1), ...
         sub_samples(:, 2), ...
         sub_samples(:, 3), ...
         8, Opts.scatter{:});
%}

% animate template poses in the frustum view
for idx = 1:size(poses, 1)
    % reference frame
    trplot(Camera.T_cam_optical, Opts.frame{:}, 'frame', 'C_{opt}');
    
    hold on;
    
    % frustum and image axes
    plot_frustum3d(far_origin, far_base);
    % plot_image_axes(far_base);
    
    % near plane
    patch(near_base(:, 1), near_base(:, 2), near_base(:, 3), 1, ...
        'FaceColor', '#A2142F', 'FaceAlpha', 0.1, ...
        'EdgeColor', '#A2142F', 'EdgeAlpha', 0.3, ...
        'LineWidth', 1.2);
    
    % pattern pose
    T = rt2tr(rpy2r(poses(idx, 4:6)), poses(idx, 1:3));
    
    %plot_camera3d(idx, Camera, 0.12, T);
    plot_pattern3d(Pattern, T, 1);

    axis([-1, 1, -1, 1, -1, 1] .* 1.6);
    
    drawnow;
    hold off;
    pause(.1);
end

clear T near_base far_origin far_base cam_height idx;

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

%% Q: cannot understand how this sequence helps to spread the angles
N = 16; % number of samples
S = zeros(1, 16);
p = 0;  % power coefficient

for i=1:2:size(S, 2)
    S(i) = 1/4 * (1 / power(2, p));
    
    if i + 1 <= N
        S(i + 1) = 3/4 * (1 / power(2, p));
    end

    p = p + 1;
end

S = flip(S);  % max ... min => min ... max
disp(S);

clear i p offset S N;
