function ix3dlin = index2Dto3D(idx2dlin, size2d, nlayers)
% index2Dto3D Convert linear indices from a 2D grid to linear indices in a 3D array.
%
%   ix3dlin = index2Dto3D(idx2dlin, size2d, nlayers)
%
% Converts linear indices referring to a 2D matrix into the corresponding
% linear indices of a 3D array where the same 2D grid is repeated across
% multiple layers.
%
% INPUT
%   idx2dlin
%       Vector of linear indices referring to a 2D array.
%       Valid range: 1 to prod(size2d).
%
%   size2d
%       Two-element vector specifying the dimensions of the 2D grid:
%
%           [nrows ncols]
%
%   nlayers
%       Number of layers in the third dimension.
%
% OUTPUT
%   ix3dlin
%       Matrix of size:
%
%           [length(idx2dlin) , nlayers]
%
%       Each column contains the linear indices corresponding to the same
%       2D positions in each layer of the 3D array.
%
% DESCRIPTION
%   The function replicates 2D linear indices across multiple layers of a
%   3D array by adding offsets corresponding to the number of elements in
%   each 2D slice:
%
%       ix3dlin = idx2dlin + (layer-1) * prod(size2d)
%
%   This is particularly useful when working with geophysical or gridded
%   datasets where the spatial grid is constant and the third dimension
%   represents time, depth, or ensemble members.
%
% EXAMPLE
%   size2d = [100 200];
%   idx = [10 20 30];
%
%   ix3d = index2Dto3D(idx, size2d, 12);
%
% SEE ALSO
%   SUB2IND, IND2SUB
%
% EGR 2016

% Total number of elements in one 2D slice
total_2d = prod(size2d);

% Offset for each layer
offsets = (0:nlayers-1) * total_2d;

% Expand indices across layers
ix3dlin = idx2dlin(:) + offsets;
