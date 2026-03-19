function [vpzThickness, nitraclineDepth] = vpzThickness(EZD,no3,z,umbral)
% vpzThickness  Vertical Productivity Zone thickness
%
% Computes the thickness of the Vertical Productivity Zone (VPZ),
% defined as the vertical overlap between the euphotic zone depth
% (EZD) and the nitracline depth.
%
% INPUT
%   EZD     : [lat x lon] euphotic zone depth (m)
%   no3     : [lat x lon x z] nitrate (mmol m^-3)
%   z       : [z x 1] depth vector (m, positive downward)
%   umbral  : nitrate threshold (default = 1 mmol m^-3)
%
% OUTPUT
%   vpzThickness       : VPZ thickness (m)
%   nitracline_depth   : nitracline depth (m)
%
% INTERPRETATION
%   vpzThickness > 0   → coexistence of light and nutrients
%   vpzThickness = 0   → nitracline intersects the euphotic depth
%   vpzThickness < 0   → nitracline below EZD (nutrient limitation)
%
% METHOD
%   1) Detect nitracline using NO3 threshold
%   2) If threshold is not reached:
%        → detect initial nutrient increase from smoothed gradient
%   3) Linear interpolation used for depth precision
%
% NOTE
%   Negative VPZ values indicate vertical decoupling between light
%   availability and nutrient supply.
%
% EGR + IA

if ~isequal(size(EZD), size(no3(:,:,1)))
    error('EZD and NO3 grid sizes do not match.')
end

if nargin<4
    umbral = 1;
end

z = abs(z(:));
[nlat,nlon] = size(no3, [1,2]);
nitraclineDepth = nan(nlat,nlon);
mask = ~isnan(no3(:,:,1));
[idx_i, idx_j] = find(mask);

for k = 1:numel(idx_i)
    i = idx_i(k);
    j = idx_j(k);prof = no3(i,j,:);
    prof = prof(:);
    valid = ~isnan(prof);
    if ~any(valid)
        continue
    end

    last = find(valid,1,'last');
    prof = prof(1:last);
    zloc = z(1:last);
    prof = max(prof,0);
    % ---- threshold detection ----
    idx = find(prof >= umbral,1,'first');
    if ~isempty(idx) && idx>1
        z1 = zloc(idx-1); z2 = zloc(idx);
        n1 = prof(idx-1); n2 = prof(idx);
        nitraclineDepth(i,j) = z1 + (umbral-n1)*(z2-z1)/(n2-n1);
        continue
    elseif ~isempty(idx)
        nitraclineDepth(i,j) = z(idx);
        continue
    end

    % ---- gradient fallback ----
    p = movmean(prof,3,'omitnan');
    dz = diff(zloc);
    dNO3 = diff(p)./dz;

    if all(isnan(dNO3))
        continue
    end

    gmax = max(dNO3);
    if gmax > 0
        kk = find(dNO3 >= 0.3*gmax,1,'first');
    else
        kk = [];
    end

    if ~isempty(kk)
        nitraclineDepth(i,j) = zloc(kk);
    else
        nitraclineDepth(i,j) = zloc(end);
    end

end

vpzThickness = EZD - nitraclineDepth;
