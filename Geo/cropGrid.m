function [trmat, trlon, trlat] = cropGrid(array, xvector, yvector, xpoints, ypoints, layers)
%CROPGRID Crop 1D, 2D or 3D gridded data using coordinate limits.
%
%   [Z, X] = cropGrid(A, Xvec, Xlims)
%   [Z, X, Y] = cropGrid(A, Xvec, Yvec, Xlims, Ylims)
%   [Z, X, Y] = cropGrid(..., layers)
%
% Extracts a spatial subset of a vector, matrix, or 3-D array using
% coordinate limits rather than indices.
%
% INPUT
%   array
%       Data array. Supported formats:
%           vector (Nx)
%           matrix (Ny,Nx)
%           array  (Ny,Nx,Nz)
%
%   xvector
%       X-coordinate vector (length Nx). Typically longitude or time.
%
%   yvector
%       Y-coordinate vector (length Ny). Typically latitude.
%       Not required for 1-D inputs.
%
%   xpoints
%       Two-element vector specifying X limits:
%
%           [xmin xmax]
%
%   ypoints
%       Two-element vector specifying Y limits:
%
%           [ymin ymax]
%
%   layers
%       Optional indices of the third dimension when ARRAY is 3-D.
%
% OUTPUT
%   trmat
%       Cropped data array.
%
%   trlon
%       Cropped X coordinate vector.
%
%   trlat
%       Cropped Y coordinate vector.
%
% NOTES
%   - Xvector and Xpoints must use the same longitude convention
%     (either [-180 180] or [0 360]).
%   - Extraction uses nearest-neighbor indexing.
%   - The function supports vectors, matrices and 3-D arrays.
%
% EXAMPLE
%   [Z,lon,lat] = cropGrid(sst, lonvec, latvec, [-120 -100], [20 35]);
%
% SEE ALSO
%   SUB2IND, DSEARCHN
%
% EGR

nd = ndims(array);

% --- 1D CASE -----------------------------------------------------------
if nargin == 3
    xpoints = yvector;
    yvector = [];
    ypoints = [];
end

if nargin == 3 && nd == 2 && any(size(array) == 1)
    if isempty(xpoints)
        xpoints = minmax(xvector);
    end

    ix = dsearchn(xvector(:), xpoints(:));
    trlon = xvector(ix(1):ix(end));
    trmat = array(ix(1):ix(end));
    trmat = trmat(:);
    trlat = [];

    return
end

% --- DEFAULTS FOR 2D / 3D ----------------------------------------------
if nargin < 6 || isempty(layers)
    if nd == 3
        layers = 1:size(array,3);
    else
        layers = [];
    end
end

if isempty(xpoints)
    xpoints = minmax(xvector);
end

if isempty(ypoints)
    ypoints = minmax(yvector);
end

% --- INDEXING ----------------------------------------------------------
ix = dsearchn(xvector(:), xpoints(:));
iy = dsearchn(yvector(:), ypoints(:));

trlon = xvector(ix(1):ix(end));
trlat = yvector(iy(1):iy(end));

if nd == 2
    trmat = array(iy(1):iy(end), ix(1):ix(end));
else
    trmat = array(iy(1):iy(end), ix(1):ix(end), layers);
    trmat = squeeze(trmat);
end
