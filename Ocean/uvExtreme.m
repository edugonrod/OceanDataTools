function [uExt, vExt, speedExt, idxExt] = uvExtreme(u, v, mode)
% uvExtreme Extract velocity vectors associated with extreme speeds.
%
%   [uExt, vExt, speedExt, idxExt] = uvExtreme(u, v)
%   [uExt, vExt, speedExt, idxExt] = uvExtreme(u, v, mode)
%
% Computes, for each spatial pixel of a 3-D velocity field, the time at
% which the velocity magnitude reaches an extreme value (maximum, minimum,
% or percentile) and returns the corresponding velocity components.
%
% INPUT
%   u, v
%       3-D numeric arrays of size (nx, ny, nt) containing the zonal (u)
%       and meridional (v) velocity components. The third dimension
%       represents time.
%
%   mode
%       String specifying the extreme speed to extract (optional).
%
%           'max'  → maximum speed over time (default)
%           'min'  → minimum speed over time
%           'pXX'  → percentile of speed, where XX is in (0,100),
%                    e.g. 'p95', 'p05', 'p99'
%
% OUTPUT
%   uExt
%       u-component corresponding to the time of extreme speed (nx × ny).
%
%   vExt
%       v-component corresponding to the time of extreme speed (nx × ny).
%
%   speedExt
%       Extreme velocity magnitude (nx × ny).
%
%   idxExt
%       Temporal index at which the extreme occurs (nx × ny).
%
% DESCRIPTION
%   The velocity magnitude is computed as:
%
%       speed = hypot(u, v)
%
%   The function identifies the time index at which the magnitude is
%   extreme according to the selected mode and returns the corresponding
%   velocity components.
%
% NOTES
%   • Percentile modes ('pXX') compute the percentile of the speed along
%     the time dimension. The returned index corresponds to the closest
%     available value in time.
%
%   • If multiple time steps match the extreme value, the first occurrence
%     is returned.
%
%   • Grid points where all time steps are NaN return NaN in all outputs.
%
% EXAMPLES
%   % Maximum current speed
%   [uM, vM, sM, iM] = uvExtreme(u, v, 'max');
%
%   % 95th percentile speed and corresponding vectors
%   [u95, v95, s95, i95] = uvExtreme(u, v, 'p95');
%
%   % Minimum speed
%   [uMin, vMin, sMin, iMin] = uvExtreme(u, v, 'min');
%
% SEE ALSO
%   HYPOT, NANMAX, NANMIN, PRCTILE
%
% EGR


if nargin < 3 || isempty(mode)
    mode = 'max';
end

[nx, ny, nt] = size(u);

% Magnitude
speed = hypot(u, v);
mode = lower(mode);

% ----------- Select extreme -----------
if strcmp(mode, 'max')
    [speedExt, idxExt] = nanmax(speed, [], 3);
elseif strcmp(mode, 'min')
    [speedExt, idxExt] = nanmin(speed, [], 3);
elseif startsWith(mode, 'p')
    % Percentile mode
    p = str2double(mode(2:end));
    if isnan(p) || p <= 0 || p >= 100
        error('Percentile mode must be ''pXX'', e.g. ''p95''.');
    end
    % Percentile of the magnitude
    speedExt = prctile(speed, p, 3);
    % Find closest time to percentile
    diffp = abs(speed - speedExt);
    [~, idxExt] = nanmin(diffp, [], 3);
else
    error('Unknown mode. Use ''max'', ''min'', or ''pXX''.');
end

%----------- Linear indexing -----------
[X, Y] = ndgrid(1:nx, 1:ny);
lin_idx = sub2ind([nx, ny, nt], X, Y, idxExt);
uExt = reshape(u(lin_idx), nx, ny);
vExt = reshape(v(lin_idx), nx, ny);

% ----------- Mask all-NaN pixels -----------
mask = all(isnan(speed),3);
uExt(mask)     = NaN;
vExt(mask)     = NaN;
speedExt(mask) = NaN;
idxExt(mask)   = NaN;
