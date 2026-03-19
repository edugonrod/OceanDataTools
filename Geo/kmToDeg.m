function deg = kmToDeg(km, sphere)
%kmToDeg  Convert kilometers to degrees on Earth's surface
%   DEG = KM2DEG(KM) converts kilometers to degrees
%   DEG = KM2DEG(KM, 'earth') uses Earth's radius (6371 km)
%   DEG = KM2DEG(KM, 'moon') uses Moon's radius (1737 km)
%   DEG = KM2DEG(KM, R) uses custom radius R (in km)

if nargin < 2
    sphere = 'earth';
end

if ischar(sphere)
    switch lower(sphere)
        case 'earth'
            R = 6371;  % Earth mean radius (km)
        case 'moon'
            R = 1737;  % Moon mean radius (km)
        case 'mars'
            R = 3389;  % Mars mean radius (km)
        otherwise
            error('Unknown sphere: %s', sphere);
    end
else
    R = sphere;  % Custom radius
end

% Circumference = 2*pi*R
% One degree = (2*pi*R)/360
deg_per_km = 360 / (2 * pi * R);
deg = km * deg_per_km;

