function [poses] = sample_poses6d(Camera, Pattern, Samples)
%sample_poses6d.m Samples 6D poses in the frustum, i.e. position and orientation.
% Poses are represented in the form [X, Y, Z, Roll, Pitch, Yaw].
% 
% A camera viewing frustum is a trapezoid with 2 bases located at different 
% distances from the camera's optical center.
% 
% Sampling in the viewing frustum includes:
%   1. Unifrom samplig of points distances from the optical center.
%   2. Computing a calibration template's C-space (configuration space).
%   3. C-space frustum base 2D inverse Gaussian sampling by rejection 
%      (frustum bases that are located at diferrent distances).
%
% The viewing distance range is chosen empirically, such as that:
%   1. Calibration template is visible (located inside the viewing frustum).
%   2. The distance to the image plane is miminal.
%
% The next step is sub-sampling (to reduce the dimensionality of samples by
% computing a representative subset). 
% 
% There are multiple choices for sub-sampling:
%   1. Clustering (K-means)
%   2. Uniform sampling
%   3. Unique tolerance (see: uniquetol)
%   4. Clustering + uniform sampling
% 
% Sampling calibration template orientation includes:
%   1. Generating all unique RPY combinations (given the limits).
%   2. Partitioning RPY samples into groups with positive/negative pitch/yaw.
%   3. Partitioning 3D positions into quadrants (YZ axes in the reference frame).
%   4. Sampling RPY for a 3D position:
%    a. 1st/2nd quadrants - negative pitch, 3rd/4th - positive pitch
%    b. 1st/4th quadrants - positive yaw, 2nd/3rd - negative yaw
%    c. roll - anything
% 
% Combination of positions and orientations are formed based 
% on the Cartesian quadrants, i.e. the angle of rotation is determined
% according to the pose 3D location.
%
% === Inputs ===
% Camera        a structure describing camera parameters
% Pattern       a structure describing pattern parameters
% Samples       a structure describing a sampling parameters
% 
% === Outputs ===
% poses             generated 6D poses
    
    % TODO: add user output messages
    
    % 1. Generate camera view distances (uniform distribution)    
    dist_num = (Samples.dist_max - Samples.dist_min) * 1000;
    dist = unifrnd(Samples.dist_min, Samples.dist_max, [1, dist_num]);
    
    fprintf('Generated %d distance samples in range %.2f to %.2f m\n', ...
             dist_num, Samples.dist_min, Samples.dist_max);
    
    % 2. Sample 3D positions in the camera viewing frustum
    XYZ = sample_frustum3d(Camera, Pattern, dist, Samples.density);
    
    fprintf('Sampled %d frustum points (density = %d samples/m^2)\n', ...
             size(XYZ, 1), Samples.density);
    
    % 3. Clustering 3D position samples (i.e. representative sub-sampling)
    %stream = RandStream('mlfg6331_64');
    %options = statset('UseParallel', 1, 'UseSubstreams', 1, 'Streams', stream);
    
    tic
    disp('Starting K-means clustering ...');
    [~, XYZ] = kmeans(XYZ, Samples.num_clusters, Samples.cluster_opts{:});
    
    fprintf('Created %d clusters\n', size(XYZ, 1));
    toc
    
    % 4. Uniform sub-sampling over a frustum's volume
    XYZ = datasample(XYZ, Samples.num_sub_samples, 'Replace', false);
                       
    fprintf('Sub-sampled %d positions\n', size(XYZ, 1));
    
    % 5. Generate unique RPY combinations
    RPY = unique_rpy(Samples.roll_range, Samples.pitch_range, Samples.yaw_range);
    
    fprintf('Generated %d unique RPY combinations\n', size(RPY, 1));
    
    % 6. Randomly pick signs (negative ~ 50%, positive ~ 50%)
    RPY = rand_sign(RPY, [1 2 3], 0.5);
    
    % 7. Partition RPYs and XYZs into quadrants
    [Q1, Q2, Q3, Q4] = partition_rpy(RPY);
    [P1, P2, P3, P4] = partition_xyz(XYZ);
    
    % 8. Join 3D positions and 3D orientations into 6D poses
    poses = [P1 datasample(Q1, size(P1, 1), 'Replace', false); ...
             P2 datasample(Q2, size(P2, 1), 'Replace', false); ...
             P3 datasample(Q3, size(P3, 1), 'Replace', false); ...
             P4 datasample(Q4, size(P4, 1), 'Replace', false)];
    
    % 9. Shuffle poses
    poses = poses(randperm(size(poses, 1)), :);
end