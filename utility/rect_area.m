function [area] = rect_area(rect)
%square_rect.m Computes the area of a 2D or 3D rectangle.
%
% === Inputs ===
% rect          XY[Z] coordinates of the rectangle corners
% 
% === Outputs ===
% area          computed area of the rectangle (in squared units)
    area = norm(rect(1, :) - rect(2, :)) * norm(rect(2, :) - rect(3, :));
end

