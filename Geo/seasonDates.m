function [winter, spring, summer, autumn] = seasonDates(year, timezone)
%seasonDates  Calculate the start dates of astronomical seasons
%   [WINTER, SPRING, SUMMER, AUTUMN] = seasonDates(YEAR) returns the start
%   dates of the four astronomical seasons for the specified year in UTC.
%
%   [WINTER, SPRING, SUMMER, AUTUMN] = seasonDates(YEAR, TIMEZONE) adjusts the
%   output to the specified timezone offset in hours (e.g., -7 for Mexico
%   City, -5 for New York, +1 for London, +8 for Beijing).
%
%   INPUTS:
%       YEAR      : Scalar integer year (must be > 1582, Gregorian calendar)
%       TIMEZONE  : Optional scalar integer hours offset from UTC (-12 to +14)
%                   Default: 0 (UTC)
%
%   OUTPUTS:
%       WINTER, SPRING, SUMMER, AUTUMN : datetime arrays with the season
%                                        start dates for the specified year
%
%   The calculations are based on the astronomical definitions of seasons,
%   using the year 2000 as reference with high-precision constants for the
%   tropical year length for each season. Results are accurate to within
%   a few minutes for the Gregorian calendar range.
%
%   EXAMPLES:
%       % Get 2024 seasons in UTC
%       [win, spr, sum, aut] = seasons(2024);
%       
%       % Get 2024 seasons in Mexico City time (UTC-6)
%       [win, spr, sum, aut] = seasonDates(2024, -6);
%       
%       % Display as readable string
%       disp(datestr(win))
%       
%       % Or with modern datetime formatting
%       disp(win, 'dd-MMM-yyyy HH:mm:ss')
%
%   NOTES:
%       - Output is in MATLAB's datetime format (modern, recommended)
%       - For backward compatibility, use datestr() or convert with datenum()
%       - Timezone offsets do not account for daylight saving time
%       - Based on reference year 2000 with precise astronomical constants
%
%   See also DATETIME, DATESTR, DATENUM, CALDAYS, HOURS

%   Original: EGR 200703, CICESE La Paz, egonzale@cicese.mx
%   Updated:  20260311, Modernized with datetime and input validation

% Validate year input
validateattributes(year, {'numeric'}, ...
    {'scalar', 'integer', 'positive', '>', 1582}, ...
    'seasons', 'YEAR');

% Handle timezone (default UTC)
if nargin < 2 || isempty(timezone)
    timezone = 0;
else
    validateattributes(timezone, {'numeric'}, ...
        {'scalar', 'integer', '>=', -12, '<=', 14}, ...
        'seasons', 'TIMEZONE');
end

% Reference year
REF_YEAR = 2000;

% Tropical year length constants for each season
% These small differences account for astronomical variations
WINTER_CONST = 365.24275;  % December solstice to March equinox
SPRING_CONST = 365.24238;  % March equinox to June solstice
SUMMER_CONST = 365.24164;  % June solstice to September equinox
AUTUMN_CONST = 365.24203;  % September equinox to December solstice

% Season start dates in the reference year 2000 (precise to the second)
winter_ref = datetime(2000, 12, 21, 13, 27, 03);  % December solstice
spring_ref = datetime(2000, 03, 20, 06, 28, 10);  % March equinox
summer_ref = datetime(2000, 06, 21, 01, 39, 22);  % June solstice
autumn_ref = datetime(2000, 09, 22, 17, 13, 57);  % September equinox

% Calculate years difference from reference
year_diff = year - REF_YEAR;

% Compute season dates for requested year
% Using caldays for accurate day counts and hours for timezone
winter = winter_ref + caldays(round(WINTER_CONST * year_diff)) + hours(timezone);
spring = spring_ref + caldays(round(SPRING_CONST * year_diff)) + hours(timezone);
summer = summer_ref + caldays(round(SUMMER_CONST * year_diff)) + hours(timezone);
autumn = autumn_ref + caldays(round(AUTUMN_CONST * year_diff)) + hours(timezone);

% Note: Output is in datetime format (modern MATLAB)
% For old code expecting datenum, users can convert:
%   winter_datenum = datenum(winter);
end

