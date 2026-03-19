function wm = watermasses(wms)
%WATERMASSES Water mass dictionary (T–S ranges)
%
%   wm = watermasses()
%   wm = watermasses(wms)
%
% Returns a struct array containing approximate temperature–salinity (T–S)
% ranges for common ocean water masses. The dictionary includes both
% generic (global) categories and region-specific water masses for the
% Pacific Mexico / Gulf of California region.
%
% INPUT
%   wms
%       Water mass identifier(s) used to select specific water masses
%       Can be:
%           'ccw'         → California Current Water
%           'gcw'         → Gulf of California Water
%           'tsw'         → Tropical Water
%           cell array    → e.g. {'ccw','gcw','tw'}
%
% OUTPUT
%   wm   struct array with fields:
%
%        .name    Name of the water mass
%        .id      Water mass identifier
%        .S       Salinity range [Smin Smax]
%        .T       Temperature range [Tmin Tmax]
%        .color   RGB color used for plotting
%        .alpha   Transparency (0–1)
%        .line    Line style for boundaries
%
% DESCRIPTION
%   This function provides a reference dictionary of water masses for use
%   in Temperature–Salinity (T–S) diagrams. The ranges are approximate and
%   intended for visualization and exploratory analysis, not strict
%   classification.
%
% EXAMPLE
%   wm = watermasses();
%   wm = watermasses('ccw');
%   wm = watermasses({'ccw','gcw','tsw'});
%
% REFERENCES
%   Lavín, M. F., & Marinone, S. G. (2006).
%   Progress in Oceanography, 69(2–4), 114–137.
%
% SEE ALSO
%   tsdiag
%
% EGR 2026 + IA

if nargin < 1 || isempty(wms)
    error('watermasses:InputRequired', ...
          'watermasses requires at least one water mass ID.');
end

wm = struct([]);
k = 0;

% GLOBAL (GENERIC)
k = k+1;
wm(k).name  = 'Global Surface Water';
wm(k).S     = [30 36];
wm(k).T     = [15 30];
wm(k).color = [1 0.7 0.7];
wm(k).alpha = 0.10;
wm(k).line  = '-';
wm(k).id    = 'gsw';

k = k+1;
wm(k).name  = 'Global Subtropical Subsurface';
wm(k).S     = [34.5 36];
wm(k).T     = [10 20];
wm(k).color = [0.7 1 0.7];
wm(k).alpha = 0.10;
wm(k).line  = '-';
wm(k).id    = 'gss';

k = k+1;
wm(k).name  = 'Global Intermediate Water';
wm(k).S     = [34.0 35];
wm(k).T     = [4 10];
wm(k).color = [0.7 0.7 1];
wm(k).alpha = 0.10;
wm(k).line  = '-';
wm(k).id    = 'giw';

k = k+1;
wm(k).name  = 'Global Deep Water';
wm(k).S     = [34.5 35];
wm(k).T     = [0 5];
wm(k).color = [0.6 0.6 0.8];
wm(k).alpha = 0.08;
wm(k).line  = ':';
wm(k).id    = 'gdw';

% PACIFIC MEXICO / GOC
k = k+1;
wm(k).name  = 'Tropical Surface Water';
wm(k).S     = [33.5 34.5];
wm(k).T     = [18 32];
wm(k).color = [1 0.4 0.4];
wm(k).alpha = 0.20;
wm(k).line  = '--';
wm(k).id    = 'tsw';

k = k+1;
wm(k).name  = 'Gulf of California Water';
wm(k).S     = [35 36.5];
wm(k).T     = [12.5 32];
wm(k).color = [1 0.7 0.3];
wm(k).alpha = 0.20;
wm(k).line  = '--';
wm(k).id    = 'gcw';

k = k+1;
wm(k).name  = 'California Current Water';
wm(k).S     = [32.5 34.5];
wm(k).T     = [9 26];
wm(k).color = [1 0.7 0.3];
wm(k).alpha = 0.20;
wm(k).line  = '--';
wm(k).id    = 'ccw';

k = k+1;
wm(k).name  = 'Subtropical Surface Water';
wm(k).S     = [34.5 35];
wm(k).T     = [12 18];
wm(k).color = [0.4 0.9 0.4];
wm(k).alpha = 0.20;
wm(k).line  = '--';
wm(k).id    = 'ssw';

k = k+1;
wm(k).name  = 'Subtropical Subsurface Water';
wm(k).S     = [34.6 35];
wm(k).T     = [12 18];
wm(k).color = [0.3 0.8 0.8];
wm(k).alpha = 0.20;
wm(k).line  = '--';
wm(k).id    = 'stssw';

k = k+1;
wm(k).name  = 'Pacific Intermediate Water';
wm(k).S     = [34.2 34.6];
wm(k).T     = [5 12];
wm(k).color = [0.4 0.4 1];
wm(k).alpha = 0.20;
wm(k).line  = '--';
wm(k).id    = 'piw';

k = k+1;
wm(k).name  = 'Pacific Deep Water';
wm(k).S     = [34.6 34.7];
wm(k).T     = [2 4];
wm(k).color = [0.4 0.4 0.7];
wm(k).alpha = 0.15;
wm(k).line  = '--';
wm(k).id    = 'pdw';

% FILTER BY REQUESTED IDS
% ensure cell array of char
if ischar(wms) || isstring(wms)
    wms = cellstr(wms);
end

% available IDs
ids = {wm.id};

% mask
mask = false(size(wm));
for i = 1:numel(wms)
    found = strcmpi(ids, wms{i});
    
    if ~any(found)
        warning('watermasses:UnknownID', ...
            'Unknown water mass ID: %s', wms{i});
    end
    mask = mask | found;
end

% apply filter
wm = wm(mask);
