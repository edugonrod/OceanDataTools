function [vals, ixlin] = extractValues(array, xvec, yvec, xq, yq, layer, mode, stat)
% extractValues Extract values or regional statistics from arrays.
%
%   [VALS, IXLIN] = extractValues(ARRAY, XVEC, YVEC, XQ, YQ)
%   extracts values from a vector, matrix, or 3-D array using real-world
%   coordinates instead of explicit indices. Extraction is performed using
%   nearest-neighbor selection.
%
%   [VALS, IXLIN] = extractValues(..., LAYER)
%   specifies the layer(s) to extract when ARRAY is three-dimensional. If
%   omitted or empty, all layers are extracted.
%
%   [VALS, IXLIN] = extractValues(..., LAYER, MODE)
%   defines the extraction mode:
%       'points'    extract point values (default)
%       'polygons'  compute statistics inside one or more polygons
%
%   [VALS, IXLIN] = extractValues(..., MODE, STAT)
%   defines the statistic computed when MODE is 'polygons':
%       'mean' (default), 'min', 'max', 'std', 'median', 'sum'
%
% INPUTS
%   ARRAY
%       Data array (vector, matrix, or 3-D tensor).
%
%   XVEC
%       Reference vector associated with columns (e.g., longitude or time).
%
%   YVEC
%       Reference vector associated with rows (e.g., latitude).
%       Ignored if ARRAY is a vector.
%
%   XQ, YQ
%       Query coordinates. In 'polygons' mode they represent the vertices
%       of one or more polygons separated by NaNs.
%
%   LAYER
%       Layers to extract if ARRAY is 3-D.
%
%   MODE
%       Extraction mode:
%           'points'    extract point values (default)
%           'polygons'  compute statistics within one or more polygons
%           'all'       compute statistics using all valid pixels in each
%                       layer (XQ and YQ are ignored)
%
%   STAT
%       Statistic to compute in 'polygons' mode:
%           'mean', 'min', 'max', 'std', 'median', 'sum'
%
% OUTPUTS
%   VALS
%       Extracted values or computed statistics.
%
%       • 'points' mode   → point values
%       • 'polygons' mode → [layers × polygons]
%
%   IXLIN
%       Linear indices used during extraction.
%
%       • 'points' mode   → vector of indices
%       • 'polygons' mode → cell array with indices per polygon
%
% NOTES
%   • Extraction uses nearest-neighbor selection (no interpolation).
%   • Multiple polygons are supported and must be separated by NaNs.
%   • If query coordinates do not exactly match the grid, the closest
%     grid point is selected.
%   • Supports datetime vectors.
%   • Requires SUB2IND3D for indexing in 3-D arrays.
%
% EGR 20160603 | unified & extended 2026

% --- 1D extraction ---
if nargin == 3
    xq = yvec;
    if isdatetime(xvec)
        xvec = datenum(xvec);
    end
    if isdatetime(xq)
        xq = datenum(xq);
    end
    ixlin = dsearchn(xvec(:), xq(:));
    vals  = array(ixlin);
    return
end

% --- defaults ---
if nargin < 6 || isempty(layer)
    layer = 1:max(1,size(array,3));
end
if nargin < 7 || isempty(mode)
    mode = 'points';
end
if nargin < 8 || isempty(stat)
    stat = 'mean';
end

if isdatetime(xvec)
    xvec = datenum(xvec);
end
if isdatetime(xq)
    xq  = datenum(xq);
end

mode = lower(mode);
validModes = {'points','polygon','polygons','all'};
if ~ismember(mode,validModes)
    error('extractValues: mode must be ''points'', ''polygons'' or ''all''')
end

% --- main switch ---
switch lower(mode)
case 'points'
    if isvector(array)
        ixlin = dsearchn(xvec(:),xq(:));
        vals  = array(ixlin);
        return
    end
    ixrow = dsearchn(yvec(:),yq(:));
    ixcol = dsearchn(xvec(:),xq(:));
    ixlin = sub2ind3d(size(array),ixrow,ixcol,layer);
    vals  = array(ixlin);
    if isrow(vals)
        vals = vals';
    end
    return
case {'polys', 'polygon','polygons'}
    mask3D = inpolygons(xvec,yvec,xq(:),yq(:));
    nreg = size(mask3D,3);
    nl = numel(layer);
    data = reshape(array(:,:,layer),[],nl);
    ixlin = cell(nreg,1);
    npix_max = max(sum(reshape(mask3D,[],nreg),1));
    V = nan(npix_max,nl,nreg);
    for p = 1:nreg
        mask = mask3D(:,:,p);
        maskvec = mask(:);
        if any(maskvec)
            vp = data(maskvec,:);
            npix = size(vp,1);
            V(1:npix,:,p) = vp;
            ixlin{p} = find(maskvec);
        end
    end
case 'all'
    nl = numel(layer);
    v = reshape(array(:,:,layer),[],nl);
    V = reshape(v,size(v,1),nl,1);
    ixlin = [];
end

switch lower(stat)
case 'mean'
    vals = squeeze(mean(V,1,'omitnan'));
case 'min'
    vals = squeeze(min(V,[],1));
case 'max'
    vals = squeeze(max(V,[],1));
case 'std'
    vals = squeeze(std(V,0,1,'omitnan'));
case 'median'
    vals = squeeze(median(V,1,'omitnan'));
case 'sum'
    vals = squeeze(sum(V,1,'omitnan'));
end
