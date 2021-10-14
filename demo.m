% create required objects and set default parameters
setup;

%% Camera viewing frustum (3D)

% compute frustum points in the camera reference frame
dist = 1;
[ref_cam_origin, ref_cam_base] = frustum3d(Camera, dist);

% === Plotting ===
figure('Name', 'Camera viewing frustum', Graphics.figure{:});

% plot camera optical frame
trplot(Camera.T_cam_ref, Graphics.frame{:}, 'frame', 'C', 'length', dist * 0.7);

hold on;

% shift optical frame for visual purposes
T_optical_offset = transl(-0.5, -0.5, 0.5);

trplot(T_optical_offset * Camera.T_cam_optical, Graphics.frame{:}, ...
    'frame', 'O', 'length', dist * 0.3, 'thick', 2, 'framelabeloffset', [1, 0]);

% plot camera viewing frustum
plot_frustum3d(ref_cam_origin, ref_cam_base, Graphics.frustum.patch);

title('3D viewing frustum', 'FontSize', 14, 'FontWeight', 'bold');

% axes labels
xlabel('X (m)', Graphics.axis.text{:});
ylabel('Y (m)', Graphics.axis.text{:});
zlabel('Z (m)', Graphics.axis.text{:});

% axes size and shape
axis 'square';
axis([-1, 1, -1, 1, -1, 1] .* dist);

% enable axes grid lines ('on', 'off', 'minor')
grid on;

% disable current axes minor ticks
set(gca, 'XMinorTick', 'off', 'YMinorTick', 'off', 'ZMinorTick', 'off');

% setup minor and major ticks of the axes
Axes = gca;
Axes.XAxis.TickValues = -dist:0.5:dist;
Axes.YAxis.TickValues = -dist:0.5:dist;
Axes.ZAxis.TickValues = -dist:0.5:dist;

% set viewing angle
view([47 18]); 

hold off;

% cleanup variables
clear ref_cam_base ref_cam_origin dist T_optical_offset Axes;

%% Camera viewing frustum (2D)

% compute viewing frustum points (in the camera reference frame)
dist = 1;
[~, ref_cam_base] = frustum3d(Camera, dist);

% estimate calibration pattern's C-space
[c_ref_cam_base, ~] = c_space(ref_cam_base, Pattern.dim, 5e-2);

% generate frustum plane points
num_samples = 500;
samples = inv_norm2d(c_ref_cam_base, num_samples);

% === Plotting ===
figure('Name', 'Viewing frustum plane', Graphics.figure{:});

% plot sample points
scatter(samples(:, 2), samples(:, 3), 21, Graphics.scatter{:});

hold on;

% plot C-space boundaries
plot_c_space(ref_cam_base, c_ref_cam_base, Graphics.c_space);

% enable grid lines
grid on;
grid minor;

% axes size
axis 'equal';

% meta information
title('Viewing frustum plane (2D)');
legend(' Samples', ' Frustum (plane)', ' C-space', 'Location', 'southeast')

% axes labels
xlabel('X (m)', Graphics.axis.text{:});
ylabel('Y (m)', Graphics.axis.text{:});

hold off;

% cleanup variables
clear dist pattern_dim num_samples samples ref_cam_base c_ref_cam_base; 

%% Plot clusters (sub-samples) of sample points

% compute frustum points in the camera reference frame
dist = 3;
[ref_cam_origin, ref_cam_base] = frustum3d(Camera, dist);

% estimate calibration pattern's C-space
c_ref_cam_base = c_space(ref_cam_base, Pattern.dim, 5e-2);

% generate frustum plane samples
num_samples = 1000;
samples = inv_norm2d(c_ref_cam_base, num_samples);

num_clusters = 100;
% clusters = datasample(samples, num_clusters, 'Replace', false);

[~, clusters] = kmeans(samples, num_clusters, Samples.kmeans{:});

% === Plotting ===
figure('Name', '3D viewing frustum clusters', Graphics.figure{:});

view([45 30]);

% plot camera optical frame
trplot(Camera.T_cam_optical, Graphics.frame{:}, 'frame', 'O', 'length', dist * 0.7);

hold on;

% plot camera frustum and image plane axes
plot_frustum3d(ref_cam_origin, ref_cam_base, Graphics.frustum.patch);

% plot cluster centroids
scatter3(clusters(:, 1), clusters(:, 2), clusters(:, 3), 24, Graphics.scatter{:});
 
% enalbe grid lines
grid on;

% axes size
axis([-1, 1, -1, 1, -1, 1] .* dist);

% meta information
title('Clustered frustum points');

xlabel('X (m)', Graphics.axis.text{:});
ylabel('Y (m)', Graphics.axis.text{:});

hold off;

% cleanup variables
clear dist ref_cam_origin ref_cam_base num_clusters clusters ...
      num_samples optical_samples c_ref_cam_base samples;

%% Plot a calibration template and camera poses (3D)

figure('Name', 'Clustered frustum samples', Opts.fig{:});

% camera reference frame
trplot(Camera.T_cam_ref, 'frame', 'C', Opts.frame{:});

hold on;

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
title('Camera - pattern setting');
axis([-1, 4, -3, 3, -3, 3]);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});
zlabel('Z (m)', Opts.axis_text{:});

hold off;

% cleanup variables
clear idx R T num_cameras T_pattern;

%% Generate 6D poses of the calibration template

clc;

Samples.density = 100;
Samples.dist_min = 0.45;
Samples.dist_max = 0.75;

Samples.roll_range = 0:5:15;
Samples.pitch_range = 5:3:70;
Samples.yaw_range = 5:3:70;

Samples.cluster_enabled = false;
Samples.num_clusters = 800;
Samples.num_sub_samples = 200;
Samples.cluster_opts = {'Distance',  'sqeuclidean', ...
                        'Display', 'off', ...
                        'Replicates', 50, ...
                        'MaxIter', 150, ...
                        'OnlinePhase', 'off'};

poses = sample_poses6d(Camera, Pattern, Samples);

figure('Name', 'Clusters', Opts.fig{:});

% plot camera optical frame
trplot(Camera.T_cam_optical, Opts.frame{:}, ...
       'length', 0.7, 'frame', 'O');

hold on;

% plot cluster centroids
scatter3(poses(:, 1), poses(:, 2), poses(:, 3), 24, Opts.scatter{:});
 
% figure settings
grid on;
view([45 30]);
title('Clustered frustum points');
axis([-1, 1, -1, 1, -1, 1] .* 0.9);

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});

hold off;

clear poses;

%% Plot 6D calibration template poses

figure('Name', 'Clustered frustum samples', Opts.fig{:});

title('Pattern poses 3D');

set(gca, 'FontSize', 13);
xlabel('X (m)', Opts.axis_text{:});
ylabel('Y (m)', Opts.axis_text{:});

view([-100 5]);
grid on;

[~, near_base] = frustum3d(Camera, 0.5);
[far_origin, far_base] = frustum3d(Camera, 1.5);

% animate template poses in the frustum view
for idx = 1:size(poses, 1)
    % reference frame
    trplot(Camera.T_cam_optical, Opts.frame{:}, 'frame', 'O');
    
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
    pause(.5);
end

clear T near_base far_origin far_base cam_height idx;

%% Output calibration template poses to a file
clc;

% File name structure:
% 1. poses
% 2. view distance range
% 3. number of samples
% 4. index
% Ex.: poses_0.5_to_0.75cm_200_1.csv

fmt_filename = "data/%d/poses_%.2f_to_%.2fm_%d_%d.csv";

% === Position sampling params ===
Samples.density = 100;
Samples.dist_min = 0.45;
Samples.dist_max = 0.75;

% === Orientation sampling params ===
Samples.roll_range = 0:3:15;

Samples.yaw_range = 5:3:45;
Samples.pitch_range = 5:3:45;

% === Clustering params ===
Samples.cluster_enabled = false;
Samples.num_clusters = 800;
Samples.cluster_opts = {'Distance',  'sqeuclidean', 'Display', 'off', ...
                        'Replicates', 10, 'MaxIter', 50, 'OnlinePhase', 'off'};

% === Uniform sub-sampling params ===
Samples.num_sub_samples = 200; % the actual number of poses to be generated

for idx=1:50
    fprintf('===> Iteration %d\n', idx);
    poses = sample_poses6d(Camera, Pattern, Samples);
    num_samples = size(poses, 1);
    
    filename = sprintf(fmt_filename, Samples.num_sub_samples, ...
        Samples.dist_min, Samples.dist_max, num_samples, idx);
    
    writematrix(poses, filename, 'FileType', 'text', 'Encoding', 'UTF-8');
    disp('<=== Finished');
end

clear idx fmt_filename filename num_samples poses;

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
