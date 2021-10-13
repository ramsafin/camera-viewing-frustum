function [quad] = quadrant(point, axes)
%quadrant.m Computes the quadrant of a point.
%
% === Inputs ===
% point         coordinates of a 2D/3D point
% axes          axes of a qudrants plane (values: 'XY', 'XZ', 'YZ')
    if ~ismember(axes, ["XY", "XZ", "YZ"])
        disp('Axes are incorrect!');
        return;
    end
    
    axis1 = 1;
    axis2 = 2;
    
    if axes == "XZ"
        axis2 = 3;
    elseif axes == "YZ"
        axis1 = 2;
        axis2 = 3;
    end
    
    if point(axis1) >= 0
        if point(axis2) >= 0
            quad = 1;
        else
            quad = 4;
        end
    else
        if point(axis2) >= 0
            quad = 2;
        else
            quad = 3;
        end
    end
end

