function minorticks(mintk, eje, ax)
%MINORTICKS  Set minor tick marks at specified positions
%   MINORTICKS(mintk) sets minor ticks on x-axis at positions mintk
%   MINORTICKS(mintk, eje) sets minor ticks on specified axis
%   MINORTICKS(mintk, eje, ax) uses specified axes handle
%
%   INPUTS:
%       mintk : Vector of tick positions
%       eje   : Axis to modify ('x' or 'y'). Default: 'x'
%       ax    : Axes handle. Default: gca
%
%   EXAMPLES:
%       % Minor ticks every 0.5 on x-axis
%       minorticks(0:0.5:10)
%
%       % Minor ticks on y-axis at specific depths
%       minorticks([5 15 25 35], 'y')
%
%       % On specific subplot
%       ax = subplot(2,1,1);
%       minorticks(0:0.2:1, 'x', ax)
%
%   NOTE: Requires MATLAB R2016b or later (uses new graphics system)
%
%   See also: GCA, AXESPROPERTIES

% EGR 20220308 (original)
% Updated: 20260311 - Input validation, better documentation

% Parse inputs
narginchk(1,3);

% Default values
if nargin < 2 || isempty(eje)
    eje = 'x';
end

if nargin < 3 || isempty(ax)
    ax = gca;
end

% Validate inputs
if ~(isnumeric(mintk) || isdatetime(mintk) || isduration(mintk))
    error('mintk must be numeric, datetime, or duration.')
end

if ~isvector(mintk)
    error('mintk must be a vector.')
end
validateattributes(eje, {'char', 'string'}, {'scalartext'}, 'minorticks', 'eje');
validateattributes(ax, {'matlab.graphics.axis.Axes'}, {'scalar'}, 'minorticks', 'ax');

% Normalize axis specification
eje = lower(char(eje));
if ~ismember(eje(1), {'x', 'y'})
    error('Axis must be ''x'' or ''y'', got: %s', eje);
end

% Set minor ticks
switch eje(1)
    case 'x'
        ax.XAxis.MinorTickValues = mintk;
        ax.XAxis.MinorTick = 'on';
    case 'y'
        ax.YAxis.MinorTickValues = mintk;
        ax.YAxis.MinorTick = 'on';
end

% Turn off box (keeps ticks but removes top/right spines)
box off
end
