clear all;
close all;
clc;

disp('Setting up parameters ...');

%% Add paths

addpath(genpath('plotting'), genpath('sampling'), genpath('frustum'), genpath('utility'));

%% Set default plotting options

DEFAULT_FONT_SIZE = 13;
DEFAULT_FONT_NAME = 'Helvetica'; % see listfonts

set(groot, 'defaultAxesFontWeight', 'bold');
set(groot, 'defaultAxesFontSize', DEFAULT_FONT_SIZE);
set(groot, 'defaultAxesFontName', DEFAULT_FONT_NAME);

set(groot, 'defaultAxesXColor', [0.9, 0, 0]);
set(groot, 'defaultAxesYColor', [0, 0.6, 0]);
set(groot, 'defaultAxesZColor', [0, 0, 0.8]);

set(groot, 'defaultAxesGridAlpha', 0.15);
set(groot, 'defaultAxesGridColor', [0.15, 0.15, 0.15]);
set(groot, 'defaultAxesGridLineStyle', '-');

set(groot, 'defaultAxesLineWidth', 1);

set(groot, 'defaultAxesMinorGridAlpha', 0.25);
set(groot, 'defaultAxesMinorGridLineStyle', ':');
set(groot, 'defaultAxesMinorGridColor', [0.1, 0.1, 0.1]);

set(groot, 'defaultAxesTickLength', [0.01, 0.025]);

set(groot, 'defaultTextFontSize', DEFAULT_FONT_SIZE);
set(groot, 'defaultTextFontName', DEFAULT_FONT_NAME);

set(groot, 'defaultFigureRenderer', 'painters');

set(groot, 'defaultLineLineWidth', 2.0);

set(groot, 'defaultFigureColor', 'white');
set(groot, 'defaultFigureWindowStyle', 'docked');

clear DEFAULT_FONT_NAME DEFAULT_FONT_SIZE;

%% Other graphics options

Graphics.figure = {};
Graphics.axis.text = {};

Graphics.frame = {'thick', 3, 'rgb', 'framelabeloffset', [0.05, 0.05], ...
                  'text_opts', {'FontWeight', 'bold'}};

Graphics.scatter = {'filled', 'Marker', 'o', ...
                    'MarkerEdgeColor', 'k', 'MarkerEdgeAlpha', 0.9, ...
                    'MarkerFaceColor', [0 .75 .75], 'MarkerFaceAlpha', 0.3};
                
Graphics.frustum.patch = {'FaceColor', '#4DBEEE', 'FaceAlpha', 0.1, ...
                          'EdgeColor', '#4DBEEE', 'EdgeAlpha', 0.7, ...
                          'LineWidth', 1.75};
                      
Graphics.c_space.opts = {'FaceColor', 'cyan', 'FaceAlpha', 0.01, 'EdgeColor', 'red', ...
                         'EdgeAlpha', 0.7, 'LineWidth', 3};
    
Graphics.c_space.c_opts = {'FaceColor', 'cyan', 'FaceAlpha', 0.125, ...
                           'EdgeColor', 'green', 'EdgeAlpha', 0.7, 'LineWidth', 3};

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
                  'Replicates', 100, 'MaxIter', 100, 'OnlinePhase', 'off'};

%% Cheat Sheet

% Removing unnecessary white spaces
% set(gca,'LooseInset', max(get(gca,'TightInset'), 0.02));

% Exporting
% print('img/example', '-dpng', '-r300');
% print('img/example', '-deps2');

% Show factory graphics settings
% get(groot,'factory')