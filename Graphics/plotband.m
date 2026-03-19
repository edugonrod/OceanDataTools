function [hp,hm,hp1,hm1] = plotband(x,meanserie,b1,b2,color,trans,linecolor,showbounds,softedge)
% PLOTBAND  Plot a series with a shaded uncertainty band.
%
%   plotband(x,mean,std)
%   plots the series MEANSERIE with a shaded band defined by MEAN ± STD.
%
%   plotband(x,mean,lower,upper)
%   plots the series MEANSERIE with a shaded band between LOWER and UPPER.
%
%   plotband(...,color)
%   specifies the band color (default [0.5 0.5 0.5]).
%
%   plotband(...,color,trans)
%   specifies band transparency (default 0.5).
%
%   plotband(...,linecolor)
%   specifies the color of the central line (default 'k').
%
%   plotband(...,showbounds)
%   if TRUE, plots the upper and lower bounds as dashed lines (default false).
%
%   plotband(...,softedge)
%   if TRUE, adds a faint outer band to create a soft visual edge
%   (default false).
%
% INPUTS
%   x          : x-coordinates
%   meanserie  : central series
%
%   Mode 1 (standard deviation)
%   b1         : standard deviation
%
%   Mode 2 (explicit bounds)
%   b1         : lower bound
%   b2         : upper bound
%
% OPTIONAL
%   color      : RGB band color
%   trans      : band transparency (0–1)
%   linecolor  : color of the central line
%   showbounds : draw dashed bound lines
%   softedge   : draw outer faint band for smoother appearance
%
% OUTPUTS
%   hp   : patch handle of shaded band
%   hm   : handle of central line
%   hp1  : handle of upper bound line (if plotted)
%   hm1  : handle of lower bound line (if plotted)
%
% EXAMPLES
%   % Standard deviation band
%   plotband(t,mean,std)
%
%   % Percentile band
%   plotband(t,median,p25,p75)
%
%   % Confidence interval
%   plotband(t,mean,CI_low,CI_high)
%
%   % Publication-style plot
%   plotband(t,mean,std,[0.7 0.8 1],0.35,[0 0.2 0.8],false,true)
%
% NOTES
%   Works with numeric or datetime x-coordinates.
%   The function preserves the current HOLD state.
%
% EGR 2026036

if nargin < 5 || isempty(color)
    color = [0.5 0.5 0.5];
end
if nargin < 6 || isempty(trans)
    trans = 0.5;
end
if nargin < 7 || isempty(linecolor)
    linecolor = 'k';
end
if nargin < 8 || isempty(showbounds)
    showbounds = false;
end
if nargin < 9 || isempty(softedge)
    softedge = false;
end
% --- determinar modo ---
if nargin < 4 || isempty(b2)
    stdserie = b1;
    if numel(stdserie)==1
        stdserie = stdserie + zeros(size(x));
    end
    upper = meanserie + stdserie;
    lower = meanserie - stdserie;
else
    lower = b1;
    upper = b2;
end
if numel(meanserie)==1
    meanserie = meanserie + zeros(size(x));
end
% --- plot ---
ish = ishold;
if ~ish
    hold on
end
% --- banda suavizada (externa) ---
if softedge
    spread = (upper - lower)/2;
    center = meanserie;
    upper2 = center + 1.5*spread;
    lower2 = center - 1.5*spread;
    fill([x(:)' fliplr(x(:)')], ...
         [upper2(:)' fliplr(lower2(:)')], ...
         color,'EdgeColor','none','FaceAlpha',trans*0.35);
end
% --- banda principal ---
hp = fill([x(:)' fliplr(x(:)')], ...
          [upper(:)' fliplr(lower(:)')], ...
          color,'EdgeColor','none','FaceAlpha',trans);
% --- línea central ---
hm = plot(x,meanserie,'Color',linecolor,'LineWidth',2);
hp1 = [];
hm1 = [];
% --- límites ---
if showbounds
    hp1 = plot(x,upper,'--','Color',linecolor);
    hm1 = plot(x,lower,'--','Color',linecolor);
end
if ~ish
    hold off
end
