function fh = fancyframe(basecolor, oncolor, axs, chlabs)
%FANCYFRAME Add a decorative frame around the current axes.
%
%   FANCYFRAME adds a stylized frame around the current axes using filled
%   patches. The frame consists of alternating boxes along the axes and
%   optional triangular corners, producing a "fancy" border effect useful
%   for maps and figures.
%
%   FANCYFRAME(BASECOLOR, ONCOLOR, AXS, CHLABS) customizes the appearance
%   of the frame.
%
%   Inputs
%       BASECOLOR   Background color of the outer frame area, specified as
%                   an RGB vector. Default: [1 1 1].
%
%       ONCOLOR     Color of the frame elements (boxes and corners),
%                   specified as an RGB vector. Default: [0 0 0].
%
%       AXS         Flag controlling the frame extent:
%                     1  draw frame on all four sides of the axes (default)
%                     0  draw frame only on the left and bottom sides.
%
%       CHLABS      Option to modify tick labels to geographic notation.
%                   Tick labels are converted to E/W and N/S format.
%                   Options: 'yes' or 'no'. Default: 'yes'.
%
%   Output
%       FH          Vector containing handles to the graphical objects
%                   created by FANCYFRAME.
%
%   Notes
%       • The function operates on the current axes (GCA).
%       • Existing HOLD state is preserved.
%       • Legend auto-updates are disabled to prevent frame elements from
%         appearing in legends.
%
%   Example
%       plot(rand(10,1))
%       fancyframe
%
%       % Custom colors
%       fancyframe([0.95 0.95 0.95], [0 0 0], 1, 'no')
%
%   See also FILL, AXIS, GCA
%
%   EGR 201608
%   egonzale@cicese.mx

set(gcf,'defaultLegendAutoUpdate','off');

if nargin == 0
    basecolor = [1, 1, 1];
    oncolor = [0, 0, 0];
    axs = 1;
    chlabs = 'yes';
elseif nargin == 1
    oncolor = [10, 0, 0];
    axs = 1;
    chlabs = 'yes';
elseif nargin == 2
    axs = 1;
    chlabs = 'yes';
elseif nargin == 3
    chlabs = 'yes';
end

if isempty(basecolor)
    basecolor = [1, 1, 1];
end

if isempty(oncolor)
    oncolor = [0, 0, 0];
end
    
if ishold
    ho=1;
else
    hold on
    ho=0;
end

xlims = get(gca, 'Xlim');
ylims = get(gca, 'Ylim');
[xin, yin] = boxfrom2pts(xlims, ylims);
xt = get(gca, 'Xtick');
yt = get(gca, 'Ytick');
dx = median(diff(xt));
dy = median(diff(yt));
xt = xt + dx/2;
yt = yt + dy/2;

Ax = max(max(xin)-min(xin))/250;%Size of frame x
Ay = max(max(yin)-min(yin))/150;%Size of frame y
[xout,yout] = boxfrom2pts(xlims+[-Ax,Ax], ylims+[-Ay,Ay]);

%Background fill
if axs
    xf = [xin; xout];
    yf = [yin; yout];
else
    xf = [min(xout), max(xout), max(xout), min(xin), min(xin), min(xout), min(xout)]';
    yf = [min(yout), min(yout), min(yin), min(yin), max(yout), max(yout), min(yout)]';
end
fk = fill(xf, yf, basecolor, 'EdgeColor', oncolor);
arrayfun(@(h)set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'),fk)

%Boxes fill
%Polygons x
xt = sort([xt, xt(1:end-1)+diff(xt)/2]);
yt = sort([yt, yt(1:end-1)+diff(yt)/2]);
xpts = [xlims(1), xt; xt, xlims(2)];
fw = []; N = 0;
for P = 1:2:size(xpts,2)
    N = N+1;
    [xd, yd] = boxfrom2pts(xpts(:,P), [min(yin(:))-Ay; min(yin(:))]);
    fx1 = fill(xd, yd, oncolor);
    fw = cat(1, fw, fx1);
    [xu, yu] = boxfrom2pts(xpts(:,P+1), [max(yin(:))+Ay; max(yin(:))]);
    if axs
        fx2 = fill(xu, yu, oncolor);
        fw = cat(1, fw, fx2);
    end
    set(get(get(fw(N),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
end

%Polygons y
ypts = [ylims(1), yt; yt, ylims(2)];
fy = []; N = 0;
for P = 2:2:size(ypts,2)
    N = N+1;
    [xl, yl] = boxfrom2pts([min(xin(:))-Ax; min(xin(:))], ypts(:,P));
    fy1 = fill(xl, yl, oncolor);
    fy = cat(1, fy, fy1); 
    [xr, yr] = boxfrom2pts([max(xin(:))+Ax; max(xin(:))], ypts(:,P-1));
    if axs
        fy2= fill(xr, yr, oncolor);
        fy = cat(1, fy, fy2);
    end
    set(get(get(fy(N),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')

end

% Triangles corners and axis
if axs
    fur(1) = fill([xlims(1) xlims(1)-Ax xlims(1)], [ylims(2) ylims(2)+Ay ylims(2)], oncolor);
    fur(2) = fill([xlims(1) xlims(1)-Ax xlims(1)], [ylims(1) ylims(1)    ylims(1)-Ay], oncolor);
    fur(3) = fill([xlims(2) xlims(2)+Ax xlims(2)], [ylims(1) ylims(1)-Ay ylims(1)], oncolor);
    fur(4) = fill([xlims(2) xlims(2)+Ax xlims(2)], [ylims(2) ylims(2)    ylims(2)+Ay], oncolor);
    axis([minmax(xf), minmax(yf)])
else
    fur = [];
    axis([min(xf), max(xlims), min(yf), max(ylims)])
end

for T = 1:size(fur,1)
    set(get(get(fur(T,2),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
end

if strcmpi(chlabs, 'yes')
    %Change x  Tickslabel from negatives to west
xlab = get(gca, 'XtickLabel');
xlab(cellfun(@isempty, (xlab))) = [];
xlabnew = cell(size(xlab));
for T = 1:numel(xlab)
    xtick = char(xlab(T));
    if strcmp(xtick(1), '-') %Negative
        xlabnew(T) = cellstr([xtick(2:end), ' W']);
    elseif strcmp(xtick(1), '0') 
        xlabnew(T) = cellstr('0');
    else
        xlabnew(T) = cellstr([xtick(1:end), ' E']);
    end
end
set(gca, 'XtickLabel', xlabnew)

%Change y Tickslabel from negatives to south
ylab = get(gca, 'YtickLabel');
ylabnew = cell(size(ylab));
for T = 1:numel(ylab)
    ytick = char(ylab(T));
    if strcmp(ytick(1), '-') %Negative
        ylabnew(T) = cellstr([ytick(2:end), ' S']);
    elseif strcmp(ytick(1), '0')
        ylabnew(T) = cellstr('0');
    else
        ylabnew(T) = cellstr([ytick(1:end), ' N']);
    end
end
set(gca, 'YtickLabel', ylabnew)
end

if nargout == 1
    fh = [fk(:); fw(:); fur(:); fy(:)];
end

uistack(fk,'bottom')
uistack([fw(:); fy(:)],'top')
uistack(fur(:),'top')

if ho == 0
    hold off
end
