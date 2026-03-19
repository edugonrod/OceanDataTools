function linidx = sub2ind3d(size3d, rowidx, colidx, layidx, orientation)
%   linidx = sub2ind3d(size3d, rowidx, colidx, layidx, orientation)
%   Get linear indices for 2D points across 3D layers
%
%   Main use: Extract time series for spatial points
%   Default: layidx = all layers (when not provided)
%
%   Inputs:
%   size3d      - Size of 3D matrix [nRows, nCols, nLayers]
%   rowidx      - Row indices (1 or more points)
%   colidx      - Column indices (same length as rowidx)
%   layidx      - (Optional) Layer indices. Default: all layers (1:nLayers)
%   orientation - (Optional) Output orientation:
%                 'rows'           : [nPoints × nLayers] (DEFAULT)
%                 'columns'        : [nLayers × nPoints]
%                 'vector'         : [nPoints*nLayers × 1] column vector
%
%   Output:
%   linidx      - Linear indices organized as specified
%
%   Typical usage (extract all time series for selected points):
%   % Get ALL time layers for 3 points
%   idx = sub2ind3d([100, 100, 50], [10, 20, 30], [15, 25, 35]);
%   % idx is [3 × 50] matrix: 3 points × 50 time layers
%
%   % Get specific time range for same points
%   idx = sub2ind3d([100, 100, 50], [10, 20, 30], [15, 25, 35], 10:20);
%   % idx is [3 × 11] matrix: 3 points × 11 time layers
%
%   EGR 202207
%   egonzale@cicese.mx

% === Handle layidx (main feature: default to all layers) ===
if nargin < 4 || isempty(layidx)
    if numel(size3d) == 2 % 2D matrix
        layidx = 1;
    elseif numel(size3d) == 3
        layidx = 1:size3d(3);  % ALL layers - MAIN USE CASE
    else
        error('size3d must have 2 or 3 elements');
    end
end

% === Handle orientation (optional) ===
if nargin < 5 || isempty(orientation)
    orientation = 'rows';  % DEFAULT for time series analysis
end

% === Validation ===
if length(rowidx) ~= length(colidx)
    error('rowidx and colidx must have the same length');
end

% Prepare vectors
rowidx = rowidx(:)';   % [1 × nPoints]
colidx = colidx(:)';   % [1 × nPoints]
layidx = layidx(:);    % [nLayers × 1]

% Get dimensions
R = size3d(1);
C = size3d(2);

% === Direct calculation with IMPLICIT EXPANSION (MATLAB R2016b+) ===
% linidx = (layidx-1)*(R*C) + (colidx-1)*R + rowidx
% layidx: [nLayers × 1] → [nLayers × nPoints] via expansion
% colidx: [1 × nPoints] → [nLayers × nPoints] via expansion  
% rowidx: [1 × nPoints] → [nLayers × nPoints] via expansion
linidx = (layidx - 1) * (R * C) + (colidx - 1) * R + rowidx;  % [nLayers × nPoints] (automático!)

% === Organize output based on orientation ===
switch lower(orientation)
    case {'rows', 'r'}
        % DEFAULT: Points in rows, layers in columns
        % Good for: plot(linidx(i,:)) shows time series of point i
        linidx = linidx';  % [nPoints × nLayers]
        
    case {'columns', 'cols', 'c'}
        % Points in columns, layers in rows
        % Good for: plot(linidx(:,i)) shows time series of point i
        % linidx already is [nLayers × nPoints]
        
    case {'vector', 'v'}
        % Single column vector [nPoints*nLayers × 1]
        % Useful for direct indexing: data(linidx)
        linidx = linidx(:);
        
    otherwise
        error(['Invalid orientation. Use: ' '''rows'', ''columns'', or ''vector''']);
end
