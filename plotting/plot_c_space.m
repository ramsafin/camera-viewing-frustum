function [] = plot_c_space(base, c_base)
%plot_c_space.m Plots a viewing frustum base and its C-space (YZ-plane).
% 
% === Inputs ===
% base          coordinates of the base (size: 4x3 or 4x2)
% c_base        coordinates of the C-space (size: 4x3 or 4x2)

    opts = {'FaceColor', 'cyan', 'FaceAlpha', 0.01, 'EdgeColor', 'red', ...
            'EdgeAlpha', 0.7, 'LineWidth', 3};
    
    c_opts = {'FaceColor', 'cyan', 'FaceAlpha', 0.125, ...
              'EdgeColor', 'green', 'EdgeAlpha', 0.7, 'LineWidth', 3};
    
    if size(base, 2) == 3
        patch(base(:, 2), base(:, 3), base(:, 1), 1, opts{:});
        patch(c_base(:, 2), c_base(:, 3), c_base(:, 1), 1, c_opts{:});
    else
        patch(base(:, 1), base(:, 2), 1, opts{:});
        patch(c_base(:, 1), c_base(:, 2), 1, c_opts{:});
    end
    
end