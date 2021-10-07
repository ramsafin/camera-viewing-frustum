function [] = plot_frustum3d(origin, base)
%plot_frustum3d.m Plots a camera viewing frustum (pyramid).
%   The base of the frustum is orthogonal to the X axis 
%   of the provided coordinate frame.
%
% === Inputs ===
% origin    XYZ coordinates of the frustum's apex (size: 1x3)
%
% base      XYZ coordinates of the frustum's base (size: 4x3)

    % plot the frustum's base
    patch_opts = {'FaceColor', '#4DBEEE', 'FaceAlpha', 0.05, ...
                  'EdgeColor', '#4DBEEE', 'EdgeAlpha', 0.5, ...
                  'LineWidth', 2};

    patch(base(:, 1), base(:, 2), base(:, 3), 1, patch_opts{:});

    % plot the base's diagonals
    diag_opts = {'Color', '#4DBEEE', 'LineWidth', 0.7};
    plot3(base([1, 3], 1), base([1, 3], 2), base([1, 3], 3), diag_opts{:});
    plot3(base([2, 4], 1), base([2, 4], 2), base([2, 4], 3), diag_opts{:});

    % plot the frustum's sides
    points = [origin; base];

    for idx = transp([1 2 3; 1 3 4; 1 4 5; 1 5 2])
       patch(points(idx, 1), points(idx, 2), points(idx, 3), ...
             1, patch_opts{:});
    end
end