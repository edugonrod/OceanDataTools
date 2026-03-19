function eddies = detectEddies(ssh, lonvec, latvec, varargin)
% detectEddies Detect mesoscale eddies from SSH (Chelton method)
%
%   eddies = detectEddies(ssh, lonvec, latvec)
%   eddies = detectEddies(...,'dssh',0.01,'ampmin',0.02,'rmin',10,'rmax',300)
%
% Detects mesoscale eddies from a 2D sea surface height (SSH/ADT) field
% using a contour-based method following Chelton et al. (2011).
%
% INPUT
%   ssh      : sea surface height [ny nx] (m)
%   lonvec   : longitude vector (degrees)
%   latvec   : latitude vector (degrees)
%
% OPTIONS
%   dssh     : contour interval (m)      default = 0.01
%   ampmin   : minimum amplitude (m)     default = 0.02
%   rmin     : minimum radius (km)       default = 10
%   rmax     : maximum radius (km)       default = 300
%
% OUTPUT
%   eddies structure:
%
%       center_lon   Eddy center longitude
%       center_lat   Eddy center latitude
%       radius_km    Equivalent radius (km)
%       area_km2     Eddy area (km²)
%       amplitude    SSH amplitude (m)
%       polarity     'cyclonic' or 'anticyclonic'
%       contour      [lon lat] coordinates of outer contour
%       npixels      Number of grid cells inside the eddy
%
% METHOD
%   The algorithm follows the SSH contour method described in:
%
%   Chelton, M. G., Schlax, M. G., & Samelson, R. M. (2011)
%   Global observations of nonlinear mesoscale eddies.
%   Progress in Oceanography, 91(2), 167–216.
%
%   Steps:
%       1) Detect local extrema in SSH (land masked)
%       2) Search contour levels outward from each extremum
%       3) Identify the first closed contour enclosing the extremum
%       4) Compute amplitude relative to contour level
%       5) Compute eddy area using spherical cell areas
%       6) Derive equivalent radius
%       7) Apply amplitude and radius thresholds
%       8) Remove duplicate detections based on distance
%
% NOTES
%   - Input SSH should be Absolute Dynamic Topography (ADT).
%   - NaN values (land) are automatically masked.
%   - Area is computed using latitude-dependent grid cell size.
%   - A final distance-based filter removes multiple detections
%     of the same eddy.
%
% EXAMPLE
%   eddies = detectEddies(adt,lonvec,latvec);
%
%   imagescnan(lonvec,latvec,adt)
%   hold on
%   for i = 1:numel(eddies)
%       plot(eddies(i).contour(:,1),eddies(i).contour(:,2),'k')
%   end
%
% SEE ALSO
%   contourc, inpolygon, areaweights
%
% OceanDataTools
% 20160306 EGR + IA help

% ---------------- parameters ----------------
dssh   = 0.01;
ampmin = 0.02;
rmin   = 10;
rmax   = 300;
k = 1;
while k <= numel(varargin)
    switch lower(varargin{k})
        case 'dssh'
            dssh = varargin{k+1};
        case 'ampmin'
            ampmin = varargin{k+1};
        case 'rmin'
            rmin = varargin{k+1};
        case 'rmax'
            rmax = varargin{k+1};
    end
    k = k + 2;
end

[Lon,Lat] = meshgrid(lonvec,latvec);
% ---------- extrema detection ----------
mask = isfinite(ssh);
ssh2 = ssh;
ssh2(~isfinite(ssh2)) = mean(ssh(mask));
maxima = imregionalmax(ssh2);
minima = imregionalmin(ssh2);
maxima = maxima & mask;
minima = minima & mask;
extrema = maxima | minima;
% ---------- contour levels ----------
vmin = min(ssh(:));
vmax = max(ssh(:));

% ---------- grid cell area ----------
W = areaweights(lonvec,latvec);

% ---------- find extrema coordinates ----------
ext_idx = find(extrema);
ext_idx = ext_idx(isfinite(ssh(ext_idx)));
eddies = struct([]);
e = 0;

% LOOP OVER EXTREMA INSTEAD OF ALL CONTOURS
for k = 1:length(ext_idx)
    ind = ext_idx(k);
    ssh0 = ssh(ind);
    if isnan(ssh0)
        continue
    end

    % determine polarity
    if maxima(ind)
        polarity = 'anticyclonic';
        test_levels = ssh0:-dssh:vmin;
    else
        polarity = 'cyclonic';
        test_levels = ssh0:dssh:vmax;
    end

    lon0 = Lon(ind);
    lat0 = Lat(ind);
    best = [];
    best_amp = -Inf;
    for lev = test_levels
        C = contourc(lonvec,latvec,ssh,[lev lev]);
        i = 1;
        while i < size(C,2)
            npts = C(2,i);
            x = C(1,i+1:i+npts);
            y = C(2,i+1:i+npts);
            i = i + npts + 1;
            if hypot(x(1)-x(end),y(1)-y(end)) > 1e-6
                continue
            end
            if numel(x) < 10
                continue
            end
            if ~inpolygon(lon0,lat0,x,y)
                continue
            end
            [~, in] = polygons2mask(x,y,lonvec,latvec);
            if isempty(in)
                continue
            end
            if strcmp(polarity,'anticyclonic')
                amp = ssh0 - lev;
            else
                amp = lev - ssh0;
            end
            if amp < ampmin
                continue
            end
            npix = sum(in(:));
            area = sum(W(in))/1e6;
            radius = sqrt(area/pi);
            if radius < rmin || radius > rmax
                continue
            end
            if amp > best_amp
                best_amp = amp;
                best.x = x;
                best.y = y;
                best.radius = radius;
                best.area = area;
                best.amp = amp;
                best.npix = npix;
            end
        end
    end

    if ~isempty(best)
        e = e + 1;
        eddies(e).center_lon = lon0;
        eddies(e).center_lat = lat0;
        eddies(e).radius_km  = best.radius;
        eddies(e).area_km2   = best.area;
        eddies(e).amplitude  = best.amp;
        eddies(e).polarity   = polarity;
        eddies(e).contour    = [best.x(:) best.y(:)];
        eddies(e).npixels    = best.npix;
    end

end

% Remove duplicates
fac = 0.5;
if ~isempty(eddies)
    keep = true(1,numel(eddies));
    for i = 1:numel(eddies)
        for j = i+1:numel(eddies)
            d = hypot(eddies(i).center_lon-eddies(j).center_lon,...
                eddies(i).center_lat-eddies(j).center_lat)*111;
            if d < fac * (eddies(i).radius_km + eddies(j).radius_km)
                keep(j) = false;
            end
        end
    end
    eddies = eddies(keep);
end
eddies = eddies(:);
