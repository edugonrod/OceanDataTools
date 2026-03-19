function [eofMaps, pctimesers, expVar] = eof(data3D, nModes, lat)
%EOF Empirical Orthogonal Functions for 3D spatiotemporal fields.
%
%   eofMaps = EOF(data3D)
%   computes EOF spatial modes from a 3-D dataset.
%
%   eofMaps = EOF(data3D, nModes)
%   returns the first nModes of variability.
%
%   eofMaps = EOF(data3D, nModes, lat)
%   applies area weighting using cos(latitude). Recommended for
%   latitude–longitude grids to avoid polar amplification.
%
%   [eofMaps, pctimesers, expVar] = EOF(...)
%   also returns:
%       pctimesers  → principal component time series (mode × time)
%       expVar      → percent variance explained by each mode
%
% INPUT
%   data3D   : spatial field (lat × lon × time)
%   nModes   : number of modes to retain (default = all)
%   lat      : latitude vector (optional)
%              • length(lat) must equal size(data3D,1)
%              • used for area weighting in lat–lon grids
%
% OUTPUT
%   eofMaps     : spatial modes (lat × lon × mode)
%   pctimesers  : temporal evolution of each mode
%   expVar      : percentage of variance explained
%
% NOTES
%   • Data are internally converted to anomalies (mean removed in time).
%   • Grid cells containing NaNs at any time step are excluded.
%   • Mode signs are adjusted for consistency (positive first value).
%   • EOFs are computed via SVD (stable and memory efficient).
%   • lat must be a vector matching the first dimension of data3D.
%   • If LAT is a 2-D grid, use lat = LAT(:,1).
%
% EXAMPLE
%   [eofMaps, pctimesers, expVar] = eof(sla,3,lat);
%
%   plot(pctimesers(1,:))        % time evolution of dominant mode
%   imagesc(eofMaps(:,:,1))      % dominant spatial pattern
%
% EGR adapted & modernized 2026

nt = size(data3D,3);

if nargin < 2 || isempty(nModes)
    nModes = nt;
end

% valid spatial mask
mask = ~any(isnan(data3D),3);

% reshape to time × space
anom = reshape(data3D,[],nt)';
anom = anom(:,mask(:));

% remove temporal mean
anom = anom - mean(anom,1);

% optional area weighting (lat-lon grids)
if nargin == 3 && ~isempty(lat)
    weights = cosd(lat(:));
    weights = weights / mean(weights);
    weights = repmat(weights,1,size(data3D,2));
    weights = weights(mask);
    anom = anom .* sqrt(weights');
end

% SVD decomposition
[U,S,V] = svds(anom,nModes);

[vals,order] = sort(diag(S),'descend');
S = diag(vals);
U = U(:,order);
V = V(:,order);

pctimesers = (U*S)';
expVar = 100 * diag(S).^2 / sum(diag(S).^2);

% rebuild spatial EOF maps
eofMaps = nan([size(mask) nModes]);

for k = 1:nModes
    modeMap = nan(size(mask));
    modeMap(mask) = V(:,k);
    eofMaps(:,:,k) = modeMap;
end

% consistent sign convention
signFlip = pctimesers(:,1) < 0;
eofMaps(:,:,signFlip) = -eofMaps(:,:,signFlip);
pctimesers(signFlip,:) = -pctimesers(signFlip,:);
