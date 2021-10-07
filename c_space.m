function [c_base, c_offset] = c_space(base, object_dim)
%c_space.m Estimates a 2D rectangle C-space for the given object dimensions.
%
%   The object is defined by 2 dimensions in meters. 
%
%   The rectangle can be specified by 2D and 3D coordinates, 
%   but only the first 2 dimensions will be considered in computations.
%
%   Additional check is executed trying to fit an object in the rectangle
%   leaving some room in 2 dimensions specified by the threshold.
%
% === Inputs ===
% base          coordinates of the 2D/3D rectangle points (size 4x2 or 4x3)
% object_dim    C-space object dimensions in meters (size: 1x2 or 2x1)
%
% === Outputs ===
% c_base        estimated C-space base coordinates
% c_offset      computed offset applied to form the C-space

    if size(base, 2) == 3 && ~all(base(:, 3) == base(1, 3))
        disp('Not all Z values are the same.');
        c_base = [];
        return;
    end

    max_obj_length = unique(max(object_dim));
    c_offset = max_obj_length / 2;

    base_width = norm(base(1, :) - base(2, :));
    base_height = norm(base(2, :) - base(3, :));

    thresh = 5e-2; % meters

    if base_width - max_obj_length < thresh || ...
       base_height - max_obj_length < thresh
        c_base = [];
    else
        c_base = zeros(size(base));
        c_base(1, :) = base(1, :) + [-c_offset, -c_offset, 0];
        c_base(2, :) = base(2, :) + [ c_offset, -c_offset, 0];
        c_base(3, :) = base(3, :) + [ c_offset,  c_offset, 0];
        c_base(4, :) = base(4, :) + [-c_offset,  c_offset, 0];
    end
end