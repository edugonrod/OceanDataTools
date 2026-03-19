function qh = quivercol(x, y, u, v, varargin)
%QUIVERCOL Colored quiver plot with discrete magnitudes
%
% qh = quivercol(x, y, u, v, Name,Value,...)
%
% Name–Value options:
%   'Scale'       : [] (auto, default) | 0 | scalar
%   'Magnitudes'  : bin edges for magnitude coloring (e.g. 0:0.2:1)
%   'Colormap'    : colormap name or Nx3 array (default 'turbo')
%   'LineWidth'   : default 1.2
%   'MaxHeadSize' : default 0.5
%
% Notes:
% - Magnitude is represented ONLY by color
% - Arrow geometry and scale are preserved using full matrices + NaNs
% - Respects hold on/off exactly like quiver
%   EGR egonzale@cicese.edu.mx
%   20230603, updated 20260306 with IA

% Input parser (ONLY Name–Value)
p = inputParser;
p.addParameter('Scale', []);
p.addParameter('Magnitudes', []);
p.addParameter('Colormap', 'turbo');
p.addParameter('LineWidth', 1.2);
p.addParameter('MaxHeadSize', 0.5);
p.parse(varargin{:});
opt = p.Results;

ax = gca;

% Grid handling
if isvector(x) && isvector(y)
    [x, y] = meshgrid(x, y);
end

% Hold logic (MATLAB-consistent)
wasHold = ishold(ax);
if ~wasHold
    cla(ax);        % borrar eje SOLO si no había hold
end
hold(ax, 'on');

% Magnitude and bins
mag = hypot(u, v);
if isempty(opt.Magnitudes)
    mmax = nanmax(mag(:));
    opt.Magnitudes = linspace(0, mmax, 8);
end

mags = opt.Magnitudes(:)';
nc   = numel(mags) - 1;
bin = discretize(mag, mags);
bin(mag < mags(1))    = 1;
bin(mag >= mags(end)) = nc;

% Colormap
if ischar(opt.Colormap) || isstring(opt.Colormap)
    basecmap = feval(opt.Colormap, 256);
else
    basecmap = opt.Colormap;
end

idx  = round(linspace(1, size(basecmap,1), nc));
cmap = basecmap(idx, :);

% Plot (FULL matrices + NaNs → escala consistente)
qh = gobjects(nc,1);

for i = 1:nc
    mask = (bin == i);
    if ~any(mask(:))
        continue
    end

    Uplot = nan(size(u));
    Vplot = nan(size(v));
    Uplot(mask) = u(mask);
    Vplot(mask) = v(mask);

    if isempty(opt.Scale)
        qh(i) = quiver(ax, x, y, Uplot, Vplot, ...
            'Color', cmap(i,:), ...
            'LineWidth', opt.LineWidth);
    else
        qh(i) = quiver(ax, x, y, Uplot, Vplot, opt.Scale, ...
            'Color', cmap(i,:), ...
            'LineWidth', opt.LineWidth, ...
            'MaxHeadSize', opt.MaxHeadSize);
    end
end

% Colorbar
colormap(ax, cmap);
clim(ax, [mags(1) mags(end)]);
cb = colorbar(ax);
cb.Ticks = mags;
cb.TickLabels = string(mags);

% Restore hold state
if ~wasHold
    hold(ax, 'off');
end

if nargout == 0
    clear qh
end

