function m = areaMean(field, latvec, mask, dim)
% AREAMEAN Area-weighted mean for geophysical fields
%
%   m = areaMean(field, latvec)
%   m = areaMean(field, latvec, mask)
%   m = areaMean(field, latvec, mask, dim)
%
% Computes an area-weighted mean assuming a regular latitude–longitude grid.
% The weighting accounts for the convergence of meridians toward the poles
% using cos(latitude).
%
% INPUT
%   field
%       Data array of size:
%           [ny nx]
%           [ny nx nt]
%
%   latvec
%       Latitude vector (ny).
%
%   mask
%       Optional logical mask (same size as first two dimensions of field).
%
%   dim
%       Dimension along which to average (default = spatial mean).
%
% OUTPUT
%   m
%       Area-weighted mean.
%
% DESCRIPTION
%   For regular lat–lon grids the area of grid cells decreases with latitude.
%   This function applies cosine latitude weighting:
%
%       w = cosd(lat)
%
%   ensuring correct spatial averages.
%
% EXAMPLES
%
%   % mean SST
%   m = areaMean(sst, lat);
%
%   % time series mean
%   m = areaMean(sst, lat);
%
%   % masked mean
%   m = areaMean(sst, lat, mask);
%
% SEE ALSO
%   mean, cosd
%
% OceanDataTools
% 20160306 EGR + IA help

if nargin < 3
    mask = [];
end

if nargin < 4
    dim = [];
end

latvec = latvec(:);
w = cosd(latvec);
w = w ./ nansum(w);

% expand weights
w = reshape(w,[],1);

% apply mask
if ~isempty(mask)
    field(~mask) = NaN;
end

if isempty(dim)
    % spatial mean
    W = repmat(w,1,size(field,2));
    W = W ./ nansum(W(:));
    if ndims(field) == 2
        m = nansum(field .* W,'all');
    else
        W = repmat(W,1,1,size(field,3));
        m = squeeze(nansum(field .* W,[1 2]));
    end
else
    m = mean(field,dim,'omitnan');
end
