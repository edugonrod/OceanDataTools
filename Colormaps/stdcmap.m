function cmap = stdcmap(m)
% STDCMAP  Colormap for standard deviation visualization

if nargin == 0
    m = 256;
end

red = [256, 255, 221, 239, 229, 217, 239, 234, 228, 222, 205, 196, 161, 137, 116, 89, 77, 60, 51] / 256;
green = [256, 249, 242, 243, 235, 225, 190, 160, 128, 87, 72, 59, 33, 21, 29, 30, 30, 29, 26] / 256;
blue = [256, 224, 243, 169, 99, 51, 63, 37, 39, 21, 27, 23, 22, 26, 29, 28, 27, 25, 22] / 256;

rgbs = [red', green', blue'];

P = size(rgbs,1);
cmap = interp1(1:size(rgbs,1), rgbs, linspace(1,P,m), 'linear');
