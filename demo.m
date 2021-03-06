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

view([-165 20]);

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
set(gcf, 'Color', 'none'); % transparent background
set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning

export_fig('images/3d_camera_viewing_frustum.pdf', '-q101', '-painters', '-transparent');
% export_fig('images/example.png', '-r300', '-painters', '-transparent');

disp('Done.');

% close;
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
% subsample points - from unifrom distribution
samples = datasample(samples, round(num_samples * 0.7), 'Replace', false);
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

%% Plot clusters (sub-samples) of sample points (3D)

setup;

% compute frustum points in the camera reference frame
dist = 0.7;
[ref_cam_origin, ref_cam_base] = frustum3d(Camera, dist);

% estimate calibration pattern's C-space
c_ref_cam_base = c_space(ref_cam_base, Pattern.dim, 5e-2);

% generate frustum plane samples
num_samples = 2000;
samples = inv_norm2d(c_ref_cam_base, num_samples);

% num_clusters = 500;
% [~, clusters] = kmeans(samples, num_clusters, Samples.kmeans{:});

num_samples = 150;
clusters = datasample(samples, num_samples, 'Replace', false);

% === Plotting ===
figure('Name', '3D viewing frustum clusters', Graphics.figure{:});

view([-160 6]);

% plot camera optical frame
trplot(Camera.T_cam_optical, Graphics.frame{:}, ...
       'framelabel', 'O', 'length', dist * 0.7);

hold on;

% plot camera frustum and image plane axes
plot_frustum3d(ref_cam_origin, ref_cam_base, Graphics.frustum);

% plot cluster centroids
scatter3(clusters(:, 1), clusters(:, 2), clusters(:, 3), 24, Graphics.scatter{:});
 
hold off;

% enable grid lines
grid on;
% TODO: disable minor grid

axis([-1, 1, -1, 1, -1, 1] .* dist);

% title('Clustered frustum points');

xlabel('{\it X} [m]', Graphics.axis.labels{:});
ylabel('{\it Y} [m]', Graphics.axis.labels{:});
zlabel('{\it Z} [m]', Graphics.axis.labels{:});

set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning
export_fig('images/frustum_c_space_3d.pdf', '-q101', '-painters', '-transparent');

disp('Done');

% close;
clear variables;

%% Plot a calibration template and camera poses (3D)

setup;

figure('Name', 'Camera and template setup', Graphics.figure{:});

view([149 24]);

% plot camera reference frame
trplot(Camera.T_cam_ref, Graphics.frame{:}, 'framelabel', 'C');

hold on;

% T_pattern = rt2tr(rpy2r(0, 0, 0), [0.5 0 1]);

plot_pattern3d(Pattern, rt2tr(rpy2r(10, 15, 30), [0.5 -0.3 1]), 1.5, Graphics.pattern);
plot_pattern3d(Pattern, rt2tr(rpy2r(-10, -15, -5), [-0.4 0.1 1]), 1.5, Graphics.pattern);
plot_pattern3d(Pattern, rt2tr(rpy2r(0, 15, 0), [0.1 0.1 1.5]), 1.5, Graphics.pattern);

% plot camera poses (as pyramids with axes)
plot_camera3d(1, Camera, 0.5, rt2tr(rotz(180), [1.75, 0, 1]), Graphics.frustum);

axis([-1, 2, -1, 2, 0, 2]);

grid on;

% title('Camera - pattern setting');

xlabel('{\it X} [m]', Graphics.axis.labels{:});
ylabel('{\it Y} [m]', Graphics.axis.labels{:});
zlabel('{\it Z} [m]', Graphics.axis.labels{:});

hold off;

set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning
export_fig('images/camera_pattern_setup3d.pdf', '-q101', '-painters', '-transparent');

disp('Done');

% close;
clear variables;

%% Generate 6D poses of the calibration template

setup;

Samples.dist_min = 0.5;
Samples.dist_max = 0.9;

poses = sample_poses6d(Camera, Pattern, Samples);

% === Plotting ===
figure('Name', 'Clusters', Graphics.figure{:});

view([200 10]);

% plot camera optical frame
trplot(Camera.T_cam_optical, Graphics.frame{:}, 'frame', 'O', 'length', 1.5);

hold on;

[ref_cam_origin, ref_cam_base] = frustum3d(Camera, 1);
plot_frustum3d(ref_cam_origin, ref_cam_base, Graphics.frustum);

% plot cluster centroids
scatter3(poses(:, 1), poses(:, 2), poses(:, 3), 21, Graphics.scatter{:});

% enable grid lines
grid on;

% axes size
axis([-1, 1, -1, 1, -1, 1] .* 1.2);

% meta information
% title('Clustered frustum points');

xlabel('{\it X} [m]', Graphics.axis.labels{:});
ylabel('{\it Y} [m]', Graphics.axis.labels{:});
zlabel('{\it Z} [m]', Graphics.axis.labels{:});

hold off;

set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning
export_fig('images/frustum_pattern_poses3d.pdf', '-q101', '-painters', '-transparent');

disp('Done');

% close;
clear variables;

%% Plot 6D calibration template poses

[~, near_base] = frustum3d(Camera, 0.5);
[far_origin, far_base] = frustum3d(Camera, 1.5);

% === Plotting ===
figure('Name', 'Clustered frustum samples', Graphics.figure{:});

view([-135 20]);

xlabel('X (m)', Graphics.axis.labels{:});
ylabel('Y (m)', Graphics.axis.labels{:});

grid on;

% animate template poses in the frustum view
for idx = 1:size(poses, 1)
    
    % plot the reference frame
    trplot(Camera.T_cam_optical, Graphics.frame{:}, 'frame', 'O');
    
    hold on;
    
    % frustum and image axes
    plot_frustum3d(far_origin, far_base, Graphics.frustum);
    
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
    pause(.2);
end

clear variables;

%% Output calibration template poses to a file

setup;

% File name structure:
% 1. poses
% 2. view distance range
% 3. number of samples
% 4. index
% File name template: poses_{index}_{samples}_{near}_{close}_{mean dist}.csv
% Ex.: poses_1_100_0.45_0.75_0.65.csv

% FMT_FILENAME = "data/%d/poses_%d_%d_%.2f_%.2f_%.4f.csv";
FMT_FILENAME = "data/%d/poses_%d_%d.csv";

% == Override pose generation params ===
Samples.density = 200;
Samples.dist_min = 0.45;
Samples.dist_max = 0.7;

Samples.yaw_range = 5:3:45;
Samples.roll_range = 0:3:15;
Samples.pitch_range = 5:3:45;

num_samples = [25, 50:50:500];

for k=num_samples
    Samples.num_sub_samples = k;

    % pre cleanup
    delete(sprintf('data/%d/*.csv', Samples.num_sub_samples));

    NUM_ITERATIONS = 100; % i.e. number of datasets to generate

    for idx=1:NUM_ITERATIONS
        fprintf('===> Iteration %d\n', idx);
        poses = sample_poses6d(Camera, Pattern, Samples);
        num_samples = size(poses, 1);

        mean_dist = avg_dist_plane(poses, 1, 0, 0, 0);

        filename = sprintf(FMT_FILENAME, Samples.num_sub_samples, idx, num_samples);

        output = [{'X','Y','Z','Roll','Pitch','Yaw'}; num2cell(poses)];
        writecell(output, filename);

        disp('<=== Finished');
    end 
end

clear variables;

%% TODO

% 1. 2D plot with shadowed pattern location on the image (sort of heatmap)

%% Error box plot of the mean pattern-to-camera distance
setup;

DATASET_SIZE = 500;
FMT_FOLDER = 'data/%d';

filenames = {dir(sprintf(FMT_FOLDER, DATASET_SIZE)).name};
num_files = size(filenames, 2);

dist_stats = zeros(1, num_files);

% see: https://stackoverflow.com/questions/12643009/regular-expression-for-floating-point-numbers
expr = '(\d*[.])?\d+';

% collect statistics
for idx=1:num_files
    matches = regexp(filenames{idx}, expr, 'match');
    
    if size(matches, 2) == 5 % we have 5 parameters in the filename
       dist_stats(idx) = str2double(matches(5));
    end
end

% remove zero elements
dist_stats = nonzeros(dist_stats);

% compute stats
dist_mean = mean(dist_stats);
dist_stddev = std(dist_stats);

% plotting
figure('Name', 'Mean distances', Graphics.figure{:});

fig = gcf;
fig.Position(3:4) = [600, 400];

grid on;

set(gca, 'XColor', 'k');
set(gca, 'YColor', 'k');
% set(gca, 'TickLength', [0.02, 0.07]);

ylabel('Pattern-to-camera distance [m]', Graphics.axis.labels{:});

hold on;

boxplot(dist_stats, 'Notch', 'on', 'Labels', ...
        [sprintf('mean: %.4f [m], stddev: %.4f [m]', dist_mean, dist_stddev)]);

clear variables;

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


%% Demo: reporjection error distribution
setup;

M = 50;
N = 35;

% means = 0.1 * randc(1, M);
means = zeros(1, M);
means(1) = 0.25;

fig = figure();
hold on;

for idx=1:M
    s = scatter(normrnd(means(idx), 0.1, 1, N), normrnd(means(idx), 0.1, 1, N), ...
            '+', 'LineWidth', 0.9);
    s.SizeData = 64;
end

grid on;

hold off;

% axes labels
xlabel('{\it X} [px]', Graphics.axis.labels{:});
ylabel('{\it Y} [px]', Graphics.axis.labels{:});

set(gca, 'SortMethod', 'ChildOrder'); % suppress export warning
export_fig('images/reprojection_error_dist.png', '-q100', '-r600', '-painters');

clear variables;
close;

