function [limits, index] = minmax(matrix, dim)
% MINMAX Return minimum and maximum values of an array and their indices.
%
%   [LIMITS, INDEX] = MINMAX(MATRIX)
%   returns the global minimum and maximum values of MATRIX along with
%   their linear indices.
%
%   [LIMITS, INDEX] = MINMAX(MATRIX, DIM)
%   computes the minimum and maximum values along dimension DIM.
%
% INPUTS
%   MATRIX
%       Input array of any dimension.
%
%   DIM
%       Dimension along which the operation is performed.
%
%           1  operate along columns
%           2  operate along rows
%           3+ higher dimensions
%
%       If DIM = 0 or omitted, the function returns the global minimum
%       and maximum across all elements of MATRIX.
%
% OUTPUTS
%   LIMITS
%       Minimum and maximum values.
%
%       • Global mode (DIM = 0):
%             [min max]
%
%       • Dimension mode:
%             2 × size(MATRIX,DIM)
%             row 1 → minimum values
%             row 2 → maximum values
%
%   INDEX
%       Indices corresponding to the minimum and maximum values.
%
%       • Global mode:
%             linear indices of min and max
%
%       • Dimension mode:
%             indices along dimension DIM
%
% DESCRIPTION
%   This function is a compact utility that simultaneously returns both
%   the minimum and maximum values of an array together with their indices.
%   It simplifies workflows where both extrema are required.
%
% EXAMPLE
%   A = rand(5,4);
%
%   % Global extrema
%   [limits,ix] = minmax(A);
%
%   % Extrema along columns
%   [limits,ix] = minmax(A,1);
%
% SEE ALSO
%   MIN, MAX
%
% EGR 20160714
% CICESE Unidad La Paz


if nargin < 2
    dim = 0;
end

if dim == 0
    % Todos los elementos
    [mini, ixmin] = min(matrix(:));
    [maxi, ixmax] = max(matrix(:));
    limits = [mini, maxi];
    index = [ixmin, ixmax];  % Índices lineales
    
elseif dim <= ndims(matrix)
    % Por dimensión específica
    [mini, ixmin] = min(matrix, [], dim);
    [maxi, ixmax] = max(matrix, [], dim);
    
    limits = cat(1, mini, maxi);  % [2 x size(matrix,dim)]
    
    % Índices a lo largo de esa dimensión
    index = cat(1, ixmin, ixmax);
    
else
    error('DIM excede las dimensiones de la matriz');
end
