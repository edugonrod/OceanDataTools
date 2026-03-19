function mask = maskEddies(eddies,lonvec,latvec)
% maskEddies Create masks for detected eddies.
%
% mask = maskEddies(eddies,lonvec,latvec)
%
% INPUT
%   eddies   structure array returned by eddydetect
%   lonvec   longitude vector
%   latvec   latitude vector
%
% OUTPUT
%   mask     logical array (ny × nx × nEddies) where each layer contains
%            the spatial mask of one eddy.
%
% DESCRIPTION
%   Each eddy contour is converted to a spatial mask using polygons2mask.
%
% REQUIREMENTS
%   polygons2mask
%
% OceanDataTools

ny = numel(latvec);
nx = numel(lonvec);
nE = numel(eddies);
mask = false(ny,nx,nE);

for k = 1:nE
    x = eddies(k).contour(:,1);
    y = eddies(k).contour(:,2);
    [~,in] = polygons2mask(x,y,lonvec,latvec);
    if isempty(in)
        continue
    end
    m = false(ny,nx);
    m(in) = true;
    mask(:,:,k) = m;
end
