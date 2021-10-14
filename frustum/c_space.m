function [c_base, c_offset] = c_space(base, object_dim, thresh)
%c_space.m Estimates a rectangular C-space for the given object dimensions.
%
%   The object is defined by 2 dimensions in meters in the camera reference frame.
%
%   The rectangle can be specified by 2D and 3D coordinates, 
%   but only the 2 dimensions will be considered (i.e. YZ coordinates).
%  
%   C-space is estimated with a tolerance in mind. Object is fitted into the rectangle
%   and the remaining space is compared against the tolerance.
%
% === Inputs ===
% base              coordinates of a rectangle points (size 4x2 or 4x3)
% object_dim        C-space object dimensions in meters (size: 1x2 or 2x1)
% thresh            object fitting tolerance parameter
%
% === Outputs ===
% c_base            estimated C-space base coordinates
% c_offset          computed C-space (in meters)

    if size(base, 2) == 3 && ~all(base(:, 1) == base(1, 1))
        error('[C-space] X coordinates are not the same.');
    else
        max_obj_length = unique(max(object_dim));
        c_offset = max_obj_length / 2;
        
        base_width = norm(base(1, :) - base(2, :));
        base_height = norm(base(2, :) - base(3, :));
        
        % fprintf('[C-space] base width: %.3f height: %.3f\n', base_width, base_height);
        
        if base_width - max_obj_length < thresh || base_height - max_obj_length < thresh
            error('[C-space] Tolerance %.3f has been reached.', thresh);
        else
            c_base = zeros(size(base));
            c_base(1, :) = base(1, :) + [0, -1, -1] .* c_offset;
            c_base(2, :) = base(2, :) + [0,  1, -1] .* c_offset;
            c_base(3, :) = base(3, :) + [0,  1,  1] .* c_offset;
            c_base(4, :) = base(4, :) + [0, -1,  1] .* c_offset;
        end
    end
end