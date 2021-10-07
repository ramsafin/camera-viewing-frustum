function [] = plot_image_axes(base)
%plot_image_axes.m Plots XY axes on a 2D rectangle.
%                  Works well in 2D and 3D plots.
%
% === Inputs ===
% base      XYZ coordinates of the 2D rectangle (size: 4x3)

    % compute the middle points of the 2D rectangle sides
    mid_y_top    = (base(1, :) + base(2, :)) ./ 2;
    mid_y_bottom = (base(3, :) + base(4, :)) ./ 2;

    mid_x_left   = (base(2, :) + base(3, :)) ./ 2;
    mid_x_right  = (base(4, :) + base(1, :)) ./ 2;

    v_line = [mid_y_bottom; mid_y_top];
    h_line = [mid_x_left; mid_x_right];

    % compute the gradients
    [~, grad_x] = gradient(h_line);
    [~, grad_y] = gradient(v_line);

    U_x = [grad_x(1, 1); 0];
    V_x = [grad_x(1, 2); 0];

    U_y = [grad_y(1, 1); 0];
    V_y = [grad_y(1, 2); 0];

    v_line_opts = {'LineWidth', 2, 'Autoscale', 'off', ...
                'MaxHeadSize', 0.2, 'Color', 'green'};

    h_line_opts = {'LineWidth', 2, 'Autoscale', 'off', ...
                'MaxHeadSize', 0.2, 'Color', 'red'};

    if size(base, 2) == 2
        quiver(v_line(:, 1), v_line(:, 2), U_y, V_y, v_line_opts{:});
        quiver(h_line(:, 1), h_line(:, 2), U_x, V_x, h_line_opts{:});
    else
        W_x = [grad_x(1, 3); 0];
        W_y = [grad_y(1, 3); 0];

        quiver3(v_line(:, 1), v_line(:, 2), v_line(:, 3), ...
                U_y, V_y, W_y, v_line_opts{:});

        quiver3(h_line(:, 1), h_line(:, 2), h_line(:, 3), ...
                U_x, V_x, W_x, h_line_opts{:});
    end
end