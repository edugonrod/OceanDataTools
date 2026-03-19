function c = distinctcolors(N,fmt)
%DISTINCTCOLORS Distinct categorical colors for plots.
%
%   C = DISTINCTCOLORS(N) returns N distinct RGB colors (Nx3).
%
%   C = DISTINCTCOLORS(N,'hex') returns hexadecimal color strings.
%
%   Optimized for 3–10 colors, usable up to ~16. If more colors are
%   requested they are interpolated smoothly.
%
% Example
%   c = distinctcolors(6);
%   axes('ColorOrder',c,'NextPlot','replacechildren')
%   plot(rand(100,6),'LineWidth',2)

if nargin<2
    fmt='rgb';
end

assert(N>=1,'N must be >=1')

% reordered so first colors are maximally distinct
base = [
0.1216 0.4667 0.7059
0.8392 0.1529 0.1569
0.1725 0.6275 0.1725
1.0000 0.4980 0.0549
0.5804 0.4039 0.7412
0.0902 0.7451 0.8118
0.8902 0.4667 0.7608
0.7373 0.7412 0.1333
0.5490 0.3373 0.2941
0.4980 0.4980 0.4980
0.6820 0.7800 0.9090
1.0000 0.7330 0.4700
0.5960 0.8740 0.5410
1.0000 0.5960 0.5880
0.7730 0.6900 0.8350
0.7690 0.6110 0.5800
];

nb = size(base,1);

if N<=nb
    rgb = base(1:N,:);
else
    x = linspace(0,1,nb);
    xi = linspace(0,1,N);
    rgb = interp1(x,base,xi,'pchip');
end

rgb = max(min(rgb,1),0);

switch lower(fmt)
    case 'rgb'
        c = rgb;
    case 'hex'
        c = compose("#%02X%02X%02X",round(rgb*255));
    otherwise
        error('Format must be ''rgb'' or ''hex''.')
end

