function [] = plot_frustum3d(origin, base, opts)
%plot_frustum3d.m Plots a camera viewing frustum (pyramid).
%   The base of the frustum is orthogonal to the X axis of the camera reference frame.
%
% === Inputs ===
% origin            coordinates of the frustum's apex (size: 1x3)
% base              coordinates of the frustum's base (size: 4x3)
    
    patch(base(:, 1), base(:, 2), base(:, 3), 1, opts.patch{:});
    points = [origin; base];
    
    for idx = transp([1 2 3; 1 3 4; 1 4 5; 1 5 2])
       patch(points(idx, 1), points(idx, 2), points(idx, 3), 1, opts.patch{:});
    end
end