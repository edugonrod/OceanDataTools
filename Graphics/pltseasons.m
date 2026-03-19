function xt = pltseasons(fi, ff, zonah, c)
%PLTSEASONS  Add colored bars to plot showing astronomical seasons
%   XT = PLTSEASONS(FI, FF) adds season bars between dates FI and FF
%   using UTC time and default gray colors.
%
%   XT = PLTSEASONS(FI, FF, ZONAH) adjusts to specified timezone.
%   XT = PLTSEASONS(FI, FF, ZONAH, C) uses custom colors for seasons.
%
%   INPUTS:
%       FI, FF : Date limits. Can be:
%                - [yyyy mm dd] vector
%                - datenum scalar
%                - datetime scalar
%       ZONAH  : Timezone offset in hours (e.g., -7 for La Paz, -5 for Bogotá)
%                Default: 0 (UTC)
%       C      : 4x3 matrix with RGB colors for [Winter, Spring, Summer, Autumn]
%                Default: grayscale gradient
%
%   OUTPUT:
%       XT     : (Optional) Vector of season boundaries (datenum)
%
%   DESCRIPTION:
%       This function adds semi-transparent colored bars to the current plot
%       indicating the astronomical seasons between two dates. The seasons are
%       calculated using the seasons() function and are displayed as vertical
%       bands spanning the full y-axis limits.
%
%       The figure must already exist with y-limits set. The function works
%       with any time series plot (temperature, salinity, etc.) to visually
%       separate seasonal patterns.
%
%   EXAMPLES:
%       % Example 1: Basic usage
%       t = datetime(2020,1,1):days(30):datetime(2021,1,1);
%       y = sin(2*pi*(day(t,'dayofyear')/365.25)) + 0.1*randn(size(t));
%       
%       figure
%       plot(t, y)
%       ylabel('Temperature anomaly')
%       
%       % Add seasons (UTC)
%       pltseasons([2020,1,1], [2021,1,1])
%
%       % Example 2: With timezone and custom colors
%       figure
%       plot(t, y)
%       
%       % La Paz time (UTC-7) with custom colors
%       mycolors = [0.8 0.2 0.2;  % Winter (redish)
%                   0.2 0.8 0.2;  % Spring (green)
%                   0.2 0.2 0.8;  % Summer (blue)
%                   0.8 0.8 0.2]; % Autumn (yellow)
%       
%       pltseasons([2020,1,1], [2021,1,1], -7, mycolors)
%
%   SEE ALSO:
%       seasons, datenum, datetime, datetick, fill

% Handle input arguments
if nargin < 3
    zonah = 0;  % UTC default
end

if nargin < 4
    % Default grayscale colors (light to dark alternating)
    c = [0.3, 0.3, 0.3;   % Winter
         0.5, 0.5, 0.5;   % Spring
         0.7, 0.7, 0.7;   % Summer
         0.9, 0.9, 0.9];  % Autumn
end

% Convert input dates to datenum for consistent handling
if isdatetime(fi)
    fi = datenum(fi);
elseif numel(fi) ~= 1
    fi = datenum(fi);
end

if isdatetime(ff)
    ff = datenum(ff);
elseif numel(ff) ~= 1
    ff = datenum(ff);
end

% Validate date order
if fi >= ff
    warning('PLTSEASONS:dateOrder', 'Start date must be before end date. No seasons plotted.');
    if nargout > 0
        xt = [];
    end
    return
end

% Get years between start and end
years = str2double(datestr(fi, 10)):str2double(datestr(ff, 10));

% Build vector of season boundaries (as datenum for consistency)
tt = [];
for L = 1:length(years)
    % Calculate seasons for current year (convert datetime to datenum)
    [spring, summer, autumn, winter] = seasons(years(L), zonah);
    spring = datenum(spring);
    summer = datenum(summer);
    autumn = datenum(autumn);
    winter = datenum(winter);
    
    if L == 1
        % First year: handle partial year from fi
        if fi <= spring
            tt = [fi; spring; summer; autumn; winter];
        elseif fi > spring && fi <= summer
            tt = [fi; summer; autumn; winter];
        elseif fi > summer && fi <= autumn
            tt = [fi; autumn; winter];
        elseif fi > autumn && fi <= winter
            tt = [fi; winter];
        else
            tt = fi;
        end
    elseif L > 1 && L < length(years)
        % Middle years: add all seasons
        tt = [tt; spring; summer; autumn; winter];
    elseif L == length(years) && L ~= 1
        % Last year: handle partial year to ff
        if ff <= spring
            tt = [tt; ff];
        elseif ff > spring && ff <= summer
            tt = [tt; spring; ff];
        elseif ff > summer && ff <= autumn
            tt = [tt; spring; summer; ff];
        elseif ff > autumn && ff <= winter
            tt = [tt; spring; summer; autumn; ff];
        elseif ff > winter
            tt = [tt; spring; summer; autumn; winter; ff];
        end
    end
end

% Plot season bars
hold on
ylims = get(gca, 'Ylim');
LL = 0;  % Counter for color cycling

for L = 1:length(tt)-1
    LL = LL + 1;
    
    % Create rectangle coordinates
    x = [tt(L), tt(L), tt(L+1), tt(L+1)];
    y = [ylims(1), ylims(2), ylims(2), ylims(1)];
    
    % Cycle through colors (4 seasons)
    if LL == 1
        col = c(1, :);
    elseif LL == 2
        col = c(2, :);
    elseif LL == 3
        col = c(3, :);
    elseif LL == 4
        col = c(4, :);
        LL = 0;  % Reset counter after 4 seasons
    end
    
    % Draw filled rectangle
    fill(x, y, col, 'EdgeColor', 'none', 'FaceAlpha', 0.3)
end

% Adjust x-axis limits and labels
set(gca, 'xlim', [fi ff])
set(gca, 'xticklabel', [])
datetick('x', 12, 'keeplimits', 'keepticks')

% Return season boundaries if requested
if nargout > 0
    xt = tt;
end

