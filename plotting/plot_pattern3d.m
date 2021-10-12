function [] = plot_pattern3d(Pattern, T, scale)
%plot_pattern3d.m Plots a 3D pattern on the scene.
%
% === Inputs ===
% Pattern       a structure with the following required fields:
%               1. dim - dimensions of the pattern (size: 1x2 or 1x3)
%
% T             4x4 homogeneous matrix representing the pose of the pattern
% scale         scale parameters for the pattern size

    width = Pattern.dim(1) * scale;
    height = Pattern.dim(2) * scale;
    
    % matrix format: X; Y; Z
    % points are in the Cartesian quadrands order
    corners = transp([1 -1 -1 1; 1 1 -1 -1; 0 0 0 0]) ...
                     .* [width/2, height/2, 1];
    
    mid_x_top = (corners(1, :) + corners(2, :)) ./ 2;
    mid_x_bottom = (corners(3, :) + corners(4, :)) ./ 2;
    
    mid_y_left = (corners(2, :) + corners(3, :)) ./ 2;
    mid_y_right = (corners(1, :) + corners(4, :)) ./ 2;
    
    black1 = [corners(1, :); mid_x_top; zeros(1, 3); mid_y_right];
    black3 = [zeros(1, 3); mid_y_left; corners(3, :); mid_x_bottom];
    white2 = [mid_x_top; corners(2, :); mid_y_left; zeros(1, 3)];
    white4 = [mid_y_right; zeros(1, 3); mid_x_bottom; corners(4, :)];
    
    T = T * rpy2tr(-90, 0, 90); % w.r.t. optical frame
    
    black1 = transform_points3d(black1, T);
    black3 = transform_points3d(black3, T);
    white2 = transform_points3d(white2, T);
    white4 = transform_points3d(white4, T);
    
    % plot black-and-white patches on quadrands
    black_opts = {'FaceColor', 'black', 'FaceAlpha', 0.85, ...
        'EdgeColor', 'black', 'EdgeAlpha', 1, 'LineWidth', 1};
    
    patch(black1(:, 1), black1(:, 2), black1(:, 3), 1, black_opts{:});
    patch(black3(:, 1), black3(:, 2), black3(:, 3), 1, black_opts{:});

    white_opts = {'FaceColor', 'white', 'FaceAlpha', 0.95, ...
        'EdgeColor', 'black', 'EdgeAlpha', 1, 'LineWidth', 1};
    
    patch(white2(:, 1), white2(:, 2), white2(:, 3), 1, white_opts{:});
    patch(white4(:, 1), white4(:, 2), white4(:, 3), 1, white_opts{:});
    
    % plot pattern's frame
    trplot(T * Pattern.T_ref_frame, ...
        'length', 0.2 * scale, ...
        'thick', 1.7, ...
        'rgb', 'notext', ...
        'text_opts', {'FontSize', 7});
end

