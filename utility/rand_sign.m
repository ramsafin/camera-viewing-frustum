function [B] = rand_sign(A, columns, fraction)
%rand_sign.m Randomly change sign of elements in the matrix columns.
%
% === Inputs ===
% A             a matrix of elements
% columns       indices of columns that are changed
% fraction      % of elements in the column to the change the sign of
%               (less than or equal to 1)
%
% === Outputs ===
% B             a matrix of elements with changed signs in the columns
    
    num_rows = size(A, 1);
    
    for col_idx=columns
        indices = randsample(1:num_rows, floor(num_rows * fraction));
        A = A(randperm(num_rows), :);
        A(indices, col_idx) = -A(indices, col_idx);
    end
    
    B = sortrows(A, [1 2 3]);
end