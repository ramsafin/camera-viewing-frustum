%% Camera viewing frustum (3D)

setup;

% compute frustum points in the camera reference frame
dist = 1;
[ref_cam_origin, ref_cam_base] = frustum3d(Camera, dist);

% === Plotting ===
figure('Name', 'Camera viewing frustum', Graphics.figure{:});

% plot camera optical frame
trplot(Camera.T_cam_ref, Graphics.frame{:}, 'frame', 'C', 'length', dist * 0.75);

hold on;

% plot optical frame (shifted for visual purposes)
T_optical_offset = transl(-0.5, -0.5, 0.5);

trplot(T_optical_offset * Camera.T_cam_optical, Graphics.frame{:}, ...
    'length', dist * 0.5, 'notext');

% plot camera viewing frustum
plot_frustum3d(ref_cam_origin, ref_cam_base, Graphics.frustum);

hold off;

view([50 10]);

% title('3D viewing frustum');

xlabel('{\it X} [m]', Graphics.axis.labels{:});
ylabel('{\it Y} [m]', Graphics.axis.labels{:});
zlabel('{\it Z} [m]', Graphics.axis.labels{:});

% enable axes grid lines ('on', 'off', 'minor')
grid on;

% axes range
axis([-1, 1, -1, 1, -1, 1] .* dist);

% axes minor and major ticks
set(gca, 'XTick', -dist:1:dist);
set(gca, 'YTick', -dist:1:dist);
set(gca, 'ZTick', -dist:1:dist);

% workaround to set axes minor ticks
Axes = gca;
minor_ticks = -dist:0.25:dist;
Axes.XAxis.MinorTickValues = minor_ticks;
Axes.YAxis.MinorTickValues = minor_ticks;
Axes.ZAxis.MinorTickValues = minor_ticks;

% export figure
% set(gcf, 'Color', 'none'); % transparent background
set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning

export_fig('images/3d_camera_viewing_frustum.pdf', '-q101', '-painters', '-transparent');
% export_fig('images/example.png', '-r300', '-painters', '-transparent');

disp('Done.');

close;
clear variables;

%% Camera viewing frustum (2D)

setup;

% compute viewing frustum points (in the camera reference frame)
dist = 1;
[~, ref_cam_base] = frustum3d(Camera, dist);

% estimate calibration pattern's C-space
[c_ref_cam_base, ~] = c_space(ref_cam_base, Pattern.dim, 5e-2);

% generate frustum plane points
num_samples = 500;
samples = inv_norm2d(c_ref_cam_base, num_samples);

% === Plotting ===
figure('Name', 'Viewing frustum C-space', Graphics.figure{:});

% plot sample points
scatter(samples(:, 2), samples(:, 3), 24, Graphics.scatter{:});

hold on;

% plot C-space boundaries
plot_c_space(ref_cam_base, c_ref_cam_base, Graphics.c_space);

hold off;

axis([-0.7 0.7 -0.5 0.5]);
axis 'equal'

% enable grid lines
grid on;
grid minor;

set(gca, 'YTick', [-0.5, 0, 0.5]);

Axes = gca; % workaround to set minor ticks
Axes.YAxis.MinorTickValues = -0.5:0.1:0.5;

% meta information
% title('Viewing frustum plane (2D)');
legend(' Samples', ' Frustum (base)', ' C-space', ...
       'Location', 'bestoutside', 'EdgeColor', 'black', 'FontSize', 12);

% axes labels
xlabel('{\it X} [m]', Graphics.axis.labels{:});
ylabel('{\it Y} [m]', Graphics.axis.labels{:});

set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning
export_fig('images/frustum_base_c_space_2d.pdf', '-q101', '-painters', '-transparent');

disp('Done.');

% close;
clear variables;

%% Plot clusters (sub-samples) of sample points

setup;

% compute frustum points in the camera reference frame
dist = 1;
[ref_cam_origin, ref_cam_base] = frustum3d(Camera, dist);

% estimate calibration pattern's C-space
c_ref_cam_base = c_space(ref_cam_base, Pattern.dim, 5e-2);

% generate frustum plane samples
num_samples = 2000;
samples = inv_norm2d(c_ref_cam_base, num_samples);

num_clusters = 500;
[~, clusters] = kmeans(samples, num_clusters, Samples.kmeans{:});

num_samples = 100;
clusters = datasample(clusters, num_samples, 'Replace', false);

% === Plotting ===
figure('Name', '3D viewing frustum clusters', Graphics.figure{:});

view([45 30]);

% plot camera optical frame
trplot(Camera.T_cam_optical, Graphics.frame{:}, ...
       'framelabel', 'O', 'length', dist * 0.7);

hold on;

% plot camera frustum and image plane axes
plot_frustum3d(ref_cam_origin, ref_cam_base, Graphics.frustum);

% plot cluster centroids
scatter3(clusters(:, 1), clusters(:, 2), clusters(:, 3), 24, Graphics.scatter{:});
 
hold off;

% enalbe grid lines
grid on;

% axes size
axis([-1, 1, -1, 1, -1, 1] .* dist);

% meta information
title('Clustered frustum points');

xlabel('{\it X} [m]', Graphics.axis.labels{:});
ylabel('{\it Y} [m]', Graphics.axis.labels{:});
ylabel('{\it Z} [m]', Graphics.axis.labels{:});

set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning
export_fig('images/frustum_c_space_3d.pdf', '-q101', '-painters', '-transparent');

clear variables;

%% Plot a calibration template and camera poses (3D)

figure('Name', 'Clustered frustum samples', Graphics.figure{:});

view([45 30]);

% plot camera reference frame
trplot(Camera.T_cam_ref, Graphics.frame{:}, 'frame', 'C');

hold on;

T_pattern = rt2tr(rpy2r(0, 0, 0), [0.75 0 1]);
plot_pattern3d(Pattern, T_pattern, 2, Graphics.pattern);

% plot camera poses (as pyramids with axes)
num_cameras = 1;

for idx = 1:num_cameras
    R = rotz(180);
    T = rt2tr(R, [3, 0, 1]);
    plot_camera3d(idx, Camera, 0.5, T, Graphics.frustum);
end

% axes size
axis([-1, 4, -3, 3, -3, 3]);

% meta information
title('Camera - pattern setting');

xlabel('X (m)', Graphics.axis.text{:});
ylabel('Y (m)', Graphics.axis.text{:});
zlabel('Z (m)', Graphics.axis.text{:});

hold off;

% cleanup variables
clear idx R T num_cameras T_pattern;

%% Generate 6D poses of the calibration template

poses = sample_poses6d(Camera, Pattern, Samples);

% === Plotting ===
figure('Name', 'Clusters', Graphics.figure{:});

view([45 30]);

% plot camera optical frame
trplot(Camera.T_cam_optical, Graphics.frame{:}, 'frame', 'O', 'length', 0.7);

hold on;

% plot cluster centroids
scatter3(poses(:, 1), poses(:, 2), poses(:, 3), 24, Graphics.scatter{:});

% enable grid lines
grid on;

% axes size
axis([-1, 1, -1, 1, -1, 1] .* 0.9);

% meta information
title('Clustered frustum points');

xlabel('X (m)', Graphics.axis.text{:});
ylabel('Y (m)', Graphics.axis.text{:});

hold off;

%% Plot 6D calibration template poses

[~, near_base] = frustum3d(Camera, 0.5);
[far_origin, far_base] = frustum3d(Camera, 1.5);

% === Plotting ===
figure('Name', 'Clustered frustum samples', Graphics.figure{:});

view([-100 5]);

title('Pattern poses 3D');

xlabel('X (m)', Graphics.axis.text{:});
ylabel('Y (m)', Graphics.axis.text{:});

grid on;

% animate template poses in the frustum view
for idx = 1:size(poses, 1)
    
    % plot the reference frame
    trplot(Camera.T_cam_optical, Graphics.frame{:}, 'frame', 'O');
    
    hold on;
    
    % frustum and image axes
    plot_frustum3d(far_origin, far_base, Graphics.frustum.patch);
    
    % near plane
    patch(near_base(:, 1), near_base(:, 2), near_base(:, 3), ...
          1, Graphics.frustum.near_plane{:});
    
    % pattern pose
    T = rt2tr(rpy2r(poses(idx, 4:6)), poses(idx, 1:3));
    
    % plot_camera3d(idx, Camera, 0.12, T);
    plot_pattern3d(Pattern, T, 1, Graphics.pattern);

    axis([-1, 1, -1, 1, -1, 1] .* 1.6);
    
    drawnow;
    hold off;
    pause(.3);
end

clear T near_base far_origin far_base cam_height idx;

%% Output calibration template poses to a file

% File name structure:
% 1. poses
% 2. view distance range
% 3. number of samples
% 4. index
% Ex.: poses_0.5_to_0.75cm_200_1.csv

fmt_filename = "data/%d/poses_%.2f_to_%.2fm_%d_%d.csv";

% == Overried pose generation params ===
Samples.density = 100;
Samples.dist_min = 0.45;
Samples.dist_max = 0.75;

Samples.yaw_range = 5:3:45;
Samples.roll_range = 0:3:15;
Samples.pitch_range = 5:3:45;

Samples.num_sub_samples = 200;

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
