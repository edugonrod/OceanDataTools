function hc = tsDiagram(S,T,varargin)
% tsDiagram Plot a Temperature–Salinity (T–S) diagram with density isolines.
%
%   hc = tsDiagram(S,T)
%   hc = tsDiagram(S,T,'color',C)
%   hc = tsDiagram(S,T,'watermasses',WMS)
%   hc = tsDiagram(S,T,'add',true)
%
% Creates a T–S diagram and overlays density contours computed using the
% TEOS-10 GSW toolbox. The function can optionally color the data points
% using a third variable and overlay multiple datasets.
%
% INPUTS
%   S
%       Salinity vector. Can be Practical Salinity (SP) or Absolute
%       Salinity (SA).
%
%   T
%       Temperature vector. Can be potential temperature (θ) or
%       Conservative Temperature (CT).
%
% NAME–VALUE OPTIONS
%   'srange'
%       Salinity plotting range [Smin Smax].
%
%   'trange'
%       Temperature plotting range [Tmin Tmax].
%
%   'ds'
%       Salinity grid spacing used to compute density contours
%       (default 0.1).
%
%   'dt'
%       Temperature grid spacing used to compute density contours
%       (default 0.5).
%
%   'markersize'
%       Marker size used in the scatter plot (default 20).
%
%   'color'
%       Variable used to color the data points (same length as S and T).
%       Typically used for depth, time, or any third variable.
%       This must be a vector, not a colormap.
%
%   'caxis'
%       Color axis limits applied when using colored scatter points.
%
%   'watermasses'
%       Water mass identifiers used to overlay T–S regions.
%       Must match IDs defined in WATERMASSES.
%       Can be a string or cell array of strings, e.g.:
%           'ccw'
%           {'ccw','gcw','tsw'}
%
%   'sigma'
%       Reference pressure level for potential density:
%
%           0  → σ₀ (default)
%           2  → σ₂
%           4  → σ₄
%
%   'add'
%       Logical flag to overlay data on an existing T–S diagram.
%       If false (default), the axes are cleared and a new diagram is drawn.
%       If true, only the scatter plot is added to the current axes.
%
% OUTPUT
%   hc
%       Handle to the scatter plot object.
%
% DESCRIPTION
%   The function computes potential density isolines using the TEOS-10
%   Gibbs SeaWater (GSW) toolbox and overlays them on a Temperature–
%   Salinity diagram. Data points are plotted as a scatter diagram and can
%   optionally be colored using an additional variable.
%
% NOTES
%   • Requires the TEOS-10 GSW toolbox.
%   • NaN values in S, T, and color variables are automatically removed.
%   • Density contours and water masses are drawn only when 'add' is false.
%
%   NOTE
%       The 'color' option expects a data vector. Colormaps must be applied
%       separately using the MATLAB function COLORMAP.
%
% EXAMPLE
%   % Basic diagram
%   tsDiagram(S,T)
%
%   % Color by depth
%   tsDiagram(S,T,'color',depth,'caxis',[0 500])
%   colormap(cmocean('deep'))
%
%   % Add water masses
%   tsDiagram(S,T,'watermasses',{'ccw','gcw','tsw'})
%
%   % Overlay two datasets
%   tsDiagram(S1,T1,'color',depth1)
%   tsDiagram(S2,T2,'color',depth2,'add',true)
%
% SEE ALSO
%   WATERMASSES, GSW_SIGMA0, GSW_SIGMA2, GSW_SIGMA4
%
% EGR 2026 + IA

% parser
ds = 0.1;
dt = 0.5;
ms = 20;
colorvar = [];
crange = [];
sigma = 0;
wms = [];
add = false;

k = 1;
while k <= numel(varargin)
    switch lower(varargin{k})
        case 'srange'
            srange = varargin{k+1};
        case 'trange'
            trange = varargin{k+1};
        case 'ds'
            ds = varargin{k+1};
        case 'dt'
            dt = varargin{k+1};
        case 'markersize'
            ms = varargin{k+1};
        case 'color'
            colorvar = varargin{k+1};
        case 'caxis'
            crange = varargin{k+1};
        case 'sigma'
            sigma = varargin{k+1};
        case 'watermasses'
            wms = varargin{k+1};
        case 'add'
            add = varargin{k+1};
    end
    k = k + 2;
end

% vectorizar
S = S(:);
T = T(:);
ix = ~isnan(S) & ~isnan(T);
if ~isempty(colorvar)
    ix = ix & ~isnan(colorvar);
end
S = S(ix);
T = T(ix);
if ~isempty(colorvar)
    colorvar = colorvar(ix);
end

% rangos
if ~exist('srange','var')
    srange = [min(S) max(S)];
end
if ~exist('trange','var')
    trange = [min(T) max(T)];
end
xlim(srange)
ylim(trange)

% grid de densidad
svec = srange(1):ds:srange(2);
tvec = trange(1):dt:trange(2);
[SG,TG] = meshgrid(svec,tvec);

% sigma
switch sigma
    case 0
        sig = gsw_sigma0(SG,TG);
    case 2
        sig = gsw_sigma2(SG,TG);
    case 4
        sig = gsw_sigma4(SG,TG);
    otherwise
        error('sigma must be 0, 2, or 4')
end

% axes control
if ~add
    cla
end
hold on

% water masses
if ~isempty(wms)
    wm = watermasses(wms);
end

if ~add && ~isempty(wms)
    xl = xlim; yl = ylim;
    for k = 1:numel(wm)
        Smin = max(wm(k).S(1),xl(1));
        Smax = min(wm(k).S(2),xl(2));
        Tmin = max(wm(k).T(1),yl(1));
        Tmax = min(wm(k).T(2),yl(2));
        if Smin>=Smax || Tmin>=Tmax
            continue
        end
        x = [Smin Smax Smax Smin]; y = [Tmin Tmin Tmax Tmax];
        c = wm(k).color; c_soft = 0.7+0.3*c;
        patch(x,y,c_soft,'FaceAlpha',wm(k).alpha,'EdgeColor',c,...
            'LineStyle',wm(k).line,'LineWidth',0.8);
        if (Smax-Smin)>0.2 && (Tmax-Tmin)>0.5
            text(mean([Smin Smax]),mean([Tmin Tmax]),wm(k).id,...
                'HorizontalAlignment','center','FontSize',8,'Color',c);
        end
    end
end

% scatter
if isempty(colorvar)
    hc = scatter(S,T,ms,'.');
else
    if numel(colorvar) ~= numel(S)
        error('tsDiagram:ColorSizeMismatch', ...
            'color variable must match S and T size')
    end
    hc = scatter(S,T,ms,colorvar,'filled');
    if ~isempty(crange)
        clim(crange)
    end
    if ~add
        colorbar
    end
    cb = colorbar;
    set(cb,'ydir','reverse')
end

% contours
if ~add
    levels = floor(min(sig(:))):0.5:ceil(max(sig(:)));
    [c,h] = contour(SG,TG,sig,levels,'k');
    clabel(c,h,'fontsize',8,'LabelSpacing',400)
    xlabel('Salinity')
    ylabel('\theta (°C)')
end
