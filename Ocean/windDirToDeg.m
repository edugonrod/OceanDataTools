function windeg = windDirToDeg(windir)
% windDirToDeg Convert compass wind directions to degrees.
%
%   windeg = windDirToDeg(windir)
%
% Converts wind direction labels expressed as compass points into their
% equivalent angles in degrees.
%
% INPUT
%   windir
%       Wind direction(s) expressed as cardinal or intercardinal compass
%       points. Accepted values are:
%
%           N, NNE, NE, ENE, E, ESE, SE, SSE,
%           S, SSW, SW, WSW, W, WNW, NW, NNW
%
%       Input must be a cell array of character vectors or a string array.
%
% OUTPUT
%   windeg
%       Wind direction in degrees following the meteorological convention:
%
%           0°    → N
%           90°   → E
%           180°  → S
%           270°  → W
%
%       Intermediate directions are spaced every 22.5°.
%
% DESCRIPTION
%   The function maps the 16-point compass rose to its corresponding
%   angular representation in degrees. Unknown directions are returned
%   as NaN.
%
% EXAMPLE
%   windeg = windDirToDeg({'N','SW','ENE'});
%
%   % result
%   % [0 225 67.5]
%
% SEE ALSO
%   UV2WINDIR
%
% EGR

% Define the lookup table mapping wind directions to degrees
directions = {'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', ...
              'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'};
degrees = 0:22.5:337.5;

% Create a map for quick lookup
directionMap = containers.Map(directions, degrees);

% Convert wind directions to degrees
ixnan = find(ismember(windir, directions));
windeg = nan(size(windir));
for i = 1:numel(ixnan)
    windeg(ixnan(i)) = directionMap(windir{ixnan(i)});
end

