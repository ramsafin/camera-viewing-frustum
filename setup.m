clear all;
close all;
clc;

%% Add local paths

addpath(genpath('plotting'), ...
        genpath('sampling'), ...
        genpath('frustum'), ...
        genpath('utility'));

%% Set default plotting options

reset(groot); % reset all graphic setting made previously

DEFAULT_FONT_SIZE = 18;
DEFAULT_FONT_NAME = 'Helvetica'; % see listfonts

set(groot, 'defaultAxesLineWidth', 1);
set(groot, 'defaultLineLineWidth', 2.0);

set(groot, 'defaultAxesUnits', 'normalized');
set(groot, 'defaultAxesFontUnits', 'points');

set(groot, 'defaultAxesFontWeight', 'bold');
set(groot, 'defaultAxesFontSize', DEFAULT_FONT_SIZE);
set(groot, 'defaultAxesFontName', DEFAULT_FONT_NAME);

set(groot, 'defaultAxesXColor', [0.9, 0, 0]);
set(groot, 'defaultAxesYColor', [0, 0.6, 0]);
set(groot, 'defaultAxesZColor', [0, 0, 0.8]);

set(groot, 'defaultAxesGridAlpha', 0.15);
set(groot, 'defaultAxesGridLineStyle', '-');
set(groot, 'defaultAxesGridColor', [0.15, 0.15, 0.15]);

set(groot, 'defaultAxesMinorGridAlpha', 0.25);
set(groot, 'defaultAxesMinorGridLineStyle', ':');
set(groot, 'defaultAxesMinorGridColor', [0.1, 0.1, 0.1]);

set(groot, 'defaultAxesXMinorTick', 'on');
set(groot, 'defaultAxesYMinorTick', 'on');
set(groot, 'defaultAxesZMinorTick', 'on');

set(groot, 'defaultAxesXMinorGrid', 'off');
set(groot, 'defaultAxesYMinorGrid', 'off');
set(groot, 'defaultAxesZMinorGrid', 'off');

set(groot, 'defaultAxesTickLength', [0.01, 0.05]);

set(groot, 'defaultTextFontSize', DEFAULT_FONT_SIZE);
set(groot, 'defaultTextFontName', DEFAULT_FONT_NAME);
set(groot, 'defaultTextFontUnits', 'points');

set(groot, 'defaultFigureRenderer', 'painters');

set(groot, 'defaultFigureColor', 'white');
set(groot, 'defaultFigureWindowStyle', 'normal');
set(groot, 'defaultFigurePaperPositionMode', 'auto');

set(groot, 'defaultAxesSortMethod', 'ChildOrder');

clear DEFAULT_FONT_NAME DEFAULT_FONT_SIZE;

%% Other graphics options

Graphics.figure = {};
Graphics.axis.labels = {};

Graphics.frame = {'rgb', 'thick', 4, 'text_opts', {'FontWeight', 'bold'}, ...
                  'framelabeloffset', [0.05, 0.05], 'perspective'};
                
Graphics.frustum.patch = {'FaceColor', '#4DBEEE', 'FaceAlpha', 0.1, ...
                          'EdgeColor', '#4DBEEE', 'EdgeAlpha', 0.7, ...
                          'LineWidth', 1.75};
                      
Graphics.frustum.frame = {'thick', 1.75, 'rgb', 'notext', 'text_opts', {'FontSize', 7}};

Graphics.frustum.near_plane = {'FaceColor', '#A2142F', 'FaceAlpha', 0.1, ...
                               'EdgeColor', '#A2142F', 'EdgeAlpha', 0.75, ...
                               'LineWidth', 1.2};
                           
Graphics.scatter = {'filled', 'Marker', 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerEdgeAlpha', 0.6, ...
                    'MarkerFaceColor', [0 .75 .75], 'MarkerFaceAlpha', 0.5};

Graphics.c_space.opts = {'FaceColor', 'cyan', 'FaceAlpha', 0.01, 'EdgeColor', 'red', ...
                         'EdgeAlpha', 0.7, 'LineWidth', 3};
    
Graphics.c_space.c_opts = {'FaceColor', 'cyan', 'FaceAlpha', 0.05, ...
                           'EdgeColor', 'green', 'EdgeAlpha', 0.7, 'LineWidth', 3};

Graphics.pattern.patch.black = {'FaceColor', 'black', 'FaceAlpha', 0.85, ...
                                'EdgeColor', 'black', 'EdgeAlpha', 1, 'LineWidth', 1};

Graphics.pattern.patch.white = {'FaceColor', 'white', 'FaceAlpha', 0.95, ...
                                'EdgeColor', 'black', 'EdgeAlpha', 1, 'LineWidth', 1};

Graphics.pattern.frame = {'thick', 1.75, 'rgb', 'notext', 'text_opts', {'FontSize', 7}};

%% Create a camera structure

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
Camera.T_inv_cam_optical = inv(rpy2tr(-90, 0, -90));

%% Create a pattern structure

% size of the pattern (in mm) - A4 paper
Pattern.dim = [297, 210] * 1e-3;

% pattern reference frame transform
Pattern.T_ref_frame = rpy2tr(90, 0, 90);

%% Sampling options

Samples.kmeans = {'Distance', 'sqeuclidean', 'Display', 'off', ...
                  'Replicates', 50, 'MaxIter', 100, 'OnlinePhase', 'off'};
              
Samples.density = 100;
Samples.dist_min = 0.45;
Samples.dist_max = 0.75;

Samples.roll_range = 0:3:15;
Samples.pitch_range = 5:3:45;
Samples.yaw_range = 5:3:45;

Samples.cluster_enabled = false;
Samples.num_clusters = 800;
Samples.num_sub_samples = 200;

%% Cheat Sheet

% Removing unnecessary white spaces
% set(gca,'LooseInset', max(get(gca,'TightInset'), 0.02));

% Exporting
% print('img/example', '-dpng', '-r300');
% print('img/example', '-deps2');
% print -depsc2 img/example.eps

% Show factory graphics settings
% get(groot,'factory')

% set minor ticks
% Axes = gca; % workaround to set minor ticks
% Axes.XAxis.MinorTickValues = [...];

% set major ticks
% set(gca, 'XTick', [...]);

% transparent background
% set(gcf, 'Color', 'none');

%% Display message
disp('Parameters have been set! Ready to create a masterpiece!!!');