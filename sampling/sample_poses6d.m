function [poses] = sample_poses6d(Camera, Pattern, opts)
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
% opts          a structure describing a sampling parameters
% 
% === Outputs ===
% poses             generated 6D poses
    
    % 1. Generate camera view distances (uniform distribution)    
    dist_num = floor((opts.dist_max - opts.dist_min) * 1000); % cm precision
    dist = unifrnd(opts.dist_min, opts.dist_max, [1, dist_num]);
    dist = uniquetol(dist, 5e-4, 'DataScale', 1); % remove "duplicates" (<= 0.5 mm)
    
    fprintf('Generated %d distance samples in range %.2f to %.2f m\n', ...
             size(dist, 2), opts.dist_min, opts.dist_max);
    
    % 2. Sample 3D positions in the camera viewing frustum
    XYZ = sample_frustum3d(Camera, Pattern, dist, opts.density);
    
    fprintf('Sampled %d frustum points (density = %d samples/m^2)\n', ...
             size(XYZ, 1), opts.density);
    
    % 3. Clustering 3D position samples (i.e. representative sub-sampling)
    if opts.cluster_enabled
        tic
        disp('Starting K-means clustering ...');
        [~, XYZ] = kmeans(XYZ, opts.num_clusters, opts.kmeans{:});

        fprintf('Created %d clusters\n', size(XYZ, 1));
        toc
    end
    
    % 4. Uniform sub-sampling over a frustum's volume
    XYZ = datasample(XYZ, opts.num_sub_samples, 'Replace', false);
                       
    fprintf('Sub-sampled %d positions\n', size(XYZ, 1));
    
    % 5. Generate unique RPY combinations
    RPY = unique_rpy(opts.roll_range, opts.pitch_range, opts.yaw_range);
    
    fprintf('Generated %d unique RPY combinations\n', size(RPY, 1));
    
    % 6. Randomly pick signs (negative ~ 50%, positive ~ 50%)
    RPY = rand_sign(RPY, [1 2 3], 0.5);
    
    % 7. Partition RPYs and XYZs into quadrants
    [Q1, Q2, Q3, Q4] = partition_rpy(RPY);
    [P1, P2, P3, P4] = partition_xyz(XYZ);
    
    fprintf('Q1: %d, Q2: %d, Q3: %d, Q4: %d\n', ...
        size(Q1, 1), size(Q2, 1), size(Q3, 1), size(Q4, 1));
    
    fprintf('P1: %d, P2: %d, P3: %d, P4: %d\n', ...
        size(P1, 1), size(P2, 1), size(P3, 1), size(P4, 1));
    
    % 8. Join 3D positions and 3D orientations into 6D poses
    poses = [P1 datasample(Q1, size(P1, 1), 'Replace', false); ...
             P2 datasample(Q2, size(P2, 1), 'Replace', false); ...
             P3 datasample(Q3, size(P3, 1), 'Replace', false); ...
             P4 datasample(Q4, size(P4, 1), 'Replace', false)];
    
    fprintf('Combined positions and orientations by quadrants\n');
    fprintf('Number of poses generated: %d\n', size(poses, 1));
    
    % 9. Shuffle poses
    poses = poses(randperm(size(poses, 1)), :);
end