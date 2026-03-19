function prc = toPercent(data, dim)
%toPercent  Calculate percentage along specified dimension
%   PRC = toPercent(DATA) calculates percentage along first dimension
%   PRC = toPercent(DATA, DIM) calculates percentage along dimension DIM
%
%   INPUTS:
%       data : Numeric array
%       dim  : Dimension to sum over (default: 1)
%
%   OUTPUT:
%       prc : Percentage array (same size as data)
%
%   EXAMPLES:
%       % Percentages of each element in vector
%       x = [10 20 30 40];
%       p = toPercent(x)  % Returns [10 20 30 40]
%
%       % Row percentages in matrix (each row sums to 100)
%       X = rand(5,3);
%       p_rows = toPercent(X, 2)
%
%       % Column percentages (each column sums to 100)
%       p_cols = toPercent(X, 1)
%
%       % Handles NaNs automatically
%       x = [10 NaN 30 40];
%       p = toPercent(x)  % Returns [12.5 0 37.5 50]
%
%   NOTE: NaN values are treated as zero in the total sum
%         and result in 0% in the output
%
%   See also SUM, MEAN, STD

% EGR 20220614 (original)
% Updated: 20260311 - Input validation, better documentation

% Validate inputs
narginchk(1,2);
validateattributes(data, {'numeric'}, {}, 'toPercent', 'data');

% Set default dimension
if nargin < 2 || isempty(dim)
    dim = find(size(data) > 1, 1, 'first');
    if isempty(dim)
        dim = 1;  % Scalar case
    end
else
    validateattributes(dim, {'numeric'}, {'scalar', 'integer', 'positive'}, 'toPercent', 'dim');
end

% Calculate total along dimension (omit NaNs)
tot = sum(data, dim, 'omitnan');

% Handle case where total is zero (avoid division by zero)
if any(tot == 0, 'all')
    warning('toPercent:zeroTotal', 'Some totals are zero. Results will be Inf or NaN.');
end

% Calculate percentages
prc = (data ./ tot) * 100;

% Replace NaNs (from division by zero or original NaNs) with 0
prc(isnan(prc)) = 0;

% Also handle Infs (from 0/0 or nonzero/0)
prc(isinf(prc)) = 0;

end
