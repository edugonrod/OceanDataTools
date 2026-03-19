function [ixrow, ixcol, ixlin] = llToIndex(latvec, lonvec, lats, lons)
% llToIndex Convert geographic coordinates to grid indices.
%
%   [IXROW, IXCOL, IXLIN] = llToIndex(LATVEC, LONVEC, LATS, LONS) finds the
%   nearest grid indices in a regular latitude–longitude grid defined by
%   LATVEC and LONVEC for the coordinates specified in LATS and LONS.
%
% INPUTS
%   LATVEC
%       Latitude vector defining the grid rows (1-D).
%
%   LONVEC
%       Longitude vector defining the grid columns (1-D).
%
%   LATS
%       Latitude coordinates to locate (scalar or vector).
%
%   LONS
%       Longitude coordinates to locate (scalar or vector).
%
% OUTPUTS
%   IXROW
%       Row indices in the grid corresponding to LATS.
%
%   IXCOL
%       Column indices in the grid corresponding to LONS.
%
%   IXLIN
%       Linear indices for direct access to 2-D matrices using SUB2IND.
%
% DESCRIPTION
%   The function performs nearest-neighbor search using DSEARCHN to map
%   geographic coordinates onto the closest grid points of a regular
%   latitude–longitude grid (meshgrid-style).
%
% NOTES
%   • The grid is assumed to be regular.
%   • Uses nearest-neighbor matching (no interpolation).
%   • Useful for extracting values from gridded datasets after selecting
%     locations interactively (e.g., with GINPUT).
%
% SEE ALSO
%   DSEARCHN, SUB2IND
%
% EGR [egonzale@cicese.mx](mailto:egonzale@cicese.mx) 20251124

ixrow = dsearchn(latvec(:), lats(:));
ixcol = dsearchn(lonvec(:), lons(:));
ixlin = sub2ind([numel(latvec), numel(lonvec)], ixrow, ixcol);
