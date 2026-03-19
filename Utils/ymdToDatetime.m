function dtdate = ymdToDatetime(ymd)
%ymdToDatetime  Convert compact YYYYMMDD format to MATLAB datetime
%   DT = ymdToDatetime(ymd) converts date in YYYYMMDD format to datetime
%
%   INPUT:
%       ymd : Date(s) in compact format. Can be:
%             - Numeric: 20200306
%             - String:  '20200306'
%             - Cell array of strings: {'20200306', '20200307'}
%             - String array: ["20200306", "20200307"]
%
%   OUTPUT:
%       dtdate : MATLAB datetime array
%
%   AUTO-COMPLETION:
%       - YYYY     -> YYYY0101 (January 1st)
%       - YYYYMM   -> YYYYMM01 (1st of month)
%       - YYYYMMDD -> as provided
%
%   EXAMPLES:
%       % Single date
%       dt = ymdToDatetime(20200306)
%
%       % Multiple dates (cell array)
%       dt = ymdToDatetime({'20200306', '20200307'})
%
%       % Year only
%       dt = ymdToDatetime(2020)  % Returns 2020-01-01
%
%       % Year-month only
%       dt = ymdToDatetime(202003)  % Returns 2020-03-01
%
%   See also DATETIME, NUM2STR, CHAR
% EGR (original)
% Updated: 20260311 - Support for cell/string arrays, vectorization


% Convert to string array
if isnumeric(ymd)
    ymdstr = string(ymd);
end

% Get lengths of each string
len = strlength(ymdstr);

% Pad based on length
ymd_padded = ymdstr;
ymd_padded(len == 4) = ymdstr(len == 4) + "0101";
ymd_padded(len == 6) = ymdstr(len == 6) + "01";

% Convert all at once
dtdate = datetime(ymd_padded, 'InputFormat', 'yyyyMMdd');

