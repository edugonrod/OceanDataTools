function [ima,lonvec,latvec,mask] = readbluemarble(lonlims,latlims,month,domask,tol)
% READBLUEMARBLE Read and crop NASA Blue Marble imagery.
%
%   ima = readbluemarble(lonlims,latlims)
%   ima = readbluemarble(lonlims,latlims,month)
%   ima = readbluemarble(...,month,domask)
%   ima = readbluemarble(...,month,domask,tol)
%
% Reads a Blue Marble global image, crops it to the specified geographic
% region, and optionally generates a land mask using the GSHHG coastline
% database.
%
% INPUTS
%   lonlims
%       Longitude limits of the region to extract [min max].
%
%   latlims
%       Latitude limits of the region to extract [min max].
%
%   month
%       (optional) Month of the Blue Marble dataset (1–12). If omitted,
%       the default global topography Blue Marble image is used.
%
%   domask
%       (optional) Logical flag indicating whether a land mask should be
%       generated using GSHHG coastlines (default false).
%
%   tol
%       (optional) Polygon simplification tolerance in degrees used when
%       generating the land mask. Larger domains automatically use larger
%       tolerances to speed up processing.
%
% OUTPUTS
%   ima
%       Cropped RGB image of the selected geographic region.
%
%   lonvec
%       Longitude vector corresponding to the image columns.
%
%   latvec
%       Latitude vector corresponding to the image rows.
%
%   mask
%       Land mask derived from GSHHG coastlines. Returned only when
%       requested. Land pixels are true and ocean pixels are false.
%
% DESCRIPTION
%   The function reads high-resolution NASA Blue Marble imagery and crops
%   it to the requested geographic limits. If requested, a land mask is
%   generated using the GSHHG shoreline database. The coastline resolution
%   and polygon simplification tolerance are automatically adjusted based
%   on the spatial extent of the domain to balance accuracy and speed.
%
% NOTES
%   • Requires Blue Marble image files available in the MATLAB path.
%   • Land masking uses GSHHG coastlines via GSHHGLAND.
%   • Large domains automatically use lower-resolution coastlines for
%     faster processing.
%
% EXAMPLE
%   lonlims = [-120 -100];
%   latlims = [20 35];
%
%   [img,lon,lat,mask] = readbluemarble(lonlims,latlims,[],true);
%
% SEE ALSO
%   GSHHGLAND, POLYGONS2MASK
%
% EGR

if nargin < 3 || isempty(month)
    img = flip(imread('land_shallow_topo_21600.tif'));
else
    mm = num2str(month,'%02d');
    img = flip(imread(['world.2004' mm '.3x21600x10800.png']));
end

if nargin < 4 || isempty(domask)
    domask = false;
end

if nargin < 5
    tol = [];
end

x = linspace(-180,180,size(img,2))';
y = linspace(-90,90,size(img,1))';

xix = dsearchn(x, lonlims(:));
yix = dsearchn(y, latlims(:));

lonvec = x(xix(1):xix(2));
latvec = y(yix(1):yix(2));
% [lonvec, latvec] = meshgrid(lonvec, latvec);

ima = img(yix(1):yix(2), xix(1):xix(2), :);
mask = [];

%--------- optional land mask ----------
if domask
    span = max(diff(lonlims), diff(latlims));
    % tolerancia automática según tamaño del dominio
    if isempty(tol)
        if span < 10
            tol = 0;
        elseif span < 20
            tol = 0.005;
        elseif span < 40
            tol = 0.01;
        elseif span < 80
            tol = 0.05;
        else
            tol = 0.1;
        end
    end
    % resolución GSHHG según escala
    if span < 40
        res = 'h';
    elseif span < 80
        res = 'i';
    else
        res = 'l';
    end
    land = gshhgland(lonlims, latlims, res);
    mask = polygons2mask([land.X]', [land.Y]', lonvec, latvec, tol);
    ocean = isnan(mask);
    ima = im2double(ima) + ocean;
end
end
