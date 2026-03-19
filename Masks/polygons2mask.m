function [mask, in] = polygons2mask(lonpoly, latpoly, lonvec, latvec, reducetol)
%POLYGONS2MASK Create grid mask from geographic polygons
%
%   mask = POLYGONS2MASK(lonpoly, latpoly, lonvec, latvec)
%   mask = POLYGONS2MASK(lonpoly, latpoly, lonvec, latvec, reducetol)
%
%   [mask, in] = POLYGONS2MASK(...)
%
%   Creates a spatial mask from one or more geographic polygons on a regular
%   grid defined by longitude and latitude coordinates. Polygons must be
%   separated by NaN values.
%
%   Inputs
%   lonpoly, latpoly   Vectors of polygon vertices in geographic
%                        coordinates. Multiple polygons separated by NaN.
%
%   lonvec, latvec     Coordinate vectors defining the target grid.
%
%   reducetol          Optional tolerance for polygon simplification
%                        using REDUCEM. Default = 0 (no simplification).
%
%   Outputs
%   mask               Numeric mask with 0 inside polygons and NaN outside.
%                        Same size as the grid defined by latvec × lonvec.
%                        Useful for masking maps by simple addition.
%
%   in                 Logical array equivalent to INPOLYGON evaluated
%                      on the grid. True values indicate points located
%                      inside the polygon(s). This implementation is 
%                      optimized for regular grids and can be significantly
%                      faster than evaluating INPOLYGON on every grid point.
%
%   Example
%     [mask, in] = polygons2mask(lonpoly, latpoly, lonvec, latvec, 0.1);
%
%     % Apply mask to a map
%     sstmasked = sst + mask;
%
%     % Extract values inside the region
%     vals = sst(in);
%
%   See also: POLY2MASK, REDUCEM, INPOLYGON
%
%   EGR 202601 with IA assistance

if nargin < 5
    reducetol = 0;
end

rows = length(latvec);
cols = length(lonvec);

if reducetol > 0
    [latpoly, lonpoly] = reducem(latpoly(:), lonpoly(:), reducetol);
end

[xsplit, ysplit] = polysplit(lonpoly, latpoly);
npolys = length(xsplit);
in = false(rows, cols);

for i = 1:npolys
    xp = xsplit{i};
    yp = ysplit{i};
    lonlim = [min(xp) max(xp)];
    latlim = [min(yp) max(yp)];
    ic = find(lonvec >= lonlim(1) & lonvec <= lonlim(2));
    ir = find(latvec >= latlim(1) & latvec <= latlim(2));
    if isempty(ir) || isempty(ic)
        continue
    end

    [~, icp] = min(abs(lonvec(ic) - xp(:)'), [], 1);
    [~, irp] = min(abs(latvec(ir) - yp(:)'), [], 1);
    if numel(ic) < 2 || numel(ir) < 2
        continue
    end
    localmask = poly2mask(icp, irp, numel(ir), numel(ic));
    in(ir, ic) = in(ir, ic) | localmask;
end

mask = nan(size(in));
mask(in) = 0;
