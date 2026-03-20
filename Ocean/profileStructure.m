function [out, class] = profileStructure(P, T, S, X, z, varargin)
%profileStructure  Compare MLD, pycnocline and vertical maxima
%
%   OUT = profileStructure(P,T,S,X,Z)
%   OUT = profileStructure(...,'Name',Value)
%
% Computes key physical and biogeochemical structure metrics from vertical
% profiles, including mixed layer depth (MLD), pycnocline depth, and the
% vertical maximum of a biogeochemical variable (e.g. chlorophyll).
%
% INPUTS
%   P,T,S
%       Pressure (dbar), temperature, and salinity arrays of size [Nz × Np],
%       where Nz is the number of depth levels and Np the number of profiles.
%
%   X
%       Biogeochemical variable (e.g. chlorophyll) [Nz × Np].
%
%   Z
%       Depth vector [Nz × 1], positive downward (m).
%
% SCIENTIFIC SCOPE:
% Pressure (P) is used for TEOS-10 density calculations,
% while depth (z) is used for vertical structure diagnostics.
%
% NAME–VALUE OPTIONS
%   'DeltaSigma'
%       Density threshold for MLD detection (default = 0.03 kg m^-3).
%
%   'Method'
%       Method used to model/smooth the vertical profile X(z) via
%       FITPROFILEINTEGRAL. Options include:
%           'pchip'   (default) shape-preserving interpolation
%           'smooth'  Savitzky–Golay smoothing
%           'spline'  smoothing spline
%           'trapz'   raw profile (no smoothing)
%           'gauss'   Gaussian fit with offset
%
% OUTPUT
%   OUT is a struct with fields:
%
%       mld, pyc
%           Mixed layer depth and pycnocline depth [1 × Np].
%
%       zm
%           Depth of maximum of X(z) [1 × Np].
%
%       sigma
%           Characteristic vertical width of the profile
%           Only available when Method = 'gauss'
%
%       area
%           Vertical integral of X(z).
%
%       r2, rmse
%           Goodness-of-fit metrics of the modeled profile.
%
%       dz.mld, dz.pyc
%           Relative position of the maximum with respect to MLD and
%           pycnocline:
%               dz.mld = zm − mld
%               dz.pyc = zm − pyc
%
%       class
%           Profile classification:
%               "mixed"       → maximum within mixed layer
%               "pycnocline"  → maximum near the pycnocline depth
%               "deep"        → maximum below pycnocline
%               "bad"         → insufficient or invalid data
%
%       method
%           Structure describing methods used:
%               .mld     method for MLD detection
%               .pyc     method for pycnocline detection
%               .profile method used for X(z) modeling
%
%       z
%           Depth vector used in the analysis.
%
% DESCRIPTION
%   The function combines physical diagnostics (MLD and pycnocline depth)
%   with biogeochemical structure (vertical maxima and profile shape) to
%   characterize vertical organization of the water column.
%
%   The vertical structure of X(z) is obtained using FITPROFILEINTEGRAL,
%   which provides a smoothed or fitted representation of the profile and
%   associated metrics such as maximum depth, width, and integral.
%
% NOTE:
% This function is intended for joint analysis of physical structure
% (MLD, pycnocline) and a biogeochemical variable X(z), such as
% chlorophyll, oxygen, or nitrate.
%
% EXAMPLE
%   out = profileStructure(P,T,S,chl,z);
%
%   out = profileStructure(P,T,S,chl,z, ...
%          'DeltaSigma',0.02,'Method','pchip');
%
% SEE ALSO
%   SEE ALSO mldPyc, fitProfileIntegral, tsDiagram
%
% EGR 2026

% Allow single physical profile with multiple biogeochemical profiles
NpX = size(X,2);
if size(P,2)==1 && NpX>1
    P = repmat(P,1,NpX);
end

if size(T,2)==1 && NpX>1
    T = repmat(T,1,NpX);
end

if size(S,2)==1 && NpX>1
    S = repmat(S,1,NpX);
end

assert(all(size(T)==size(S)) && all(size(T)==size(P)) && all(size(T)==size(X)), ...
    'P, T, S, X must have same dimensions')
assert(numel(z)==size(T,1), ...
    'z must match vertical dimension of T')

% Options
p = inputParser;
p.addParameter('DeltaSigma',0.03,@(x)x>0)
p.addParameter('Method','pchip',@ischar)
p.addParameter('RefDepth',10,@(x)x>=0)
p.addParameter('TEOS10',true,@islogical)
p.parse(varargin{:})
DeltaSigma = p.Results.DeltaSigma;
Method     = p.Results.Method;
RefDepth   = p.Results.RefDepth;
TEOS10     = p.Results.TEOS10;

% Dimensions
z = z(:);
Np = size(T,2);

% MLD & Pycnocline
phys = mldPyc(P, T, S, z, 'DeltaSigma', DeltaSigma, ...
    'RefDepth', RefDepth, 'TEOS10', TEOS10);
out.mld = phys.mld;
out.pyc = phys.pyc;

% Prealloc
area = NaN(1,Np);
out.zm    = NaN(1,Np);
out.sigma = NaN(1,Np);
out.r2   = NaN(1,Np);
out.rmse = NaN(1,Np);

% Profile analysis
for k = 1:Np
    [area(k), prof] = fitProfileIntegral(z, X(:,k), Method);
    if isempty(prof)
        continue
    end
    out.zm(k)    = prof.zmax;
    if isfield(prof,'sigma')
        out.sigma(k) = prof.sigma;
    end
    out.r2(k)    = prof.r2;
    out.rmse(k)  = prof.rmse;
end
out.area = area;

% Relative depths
out.dz.mld = out.zm - out.mld;
out.dz.pyc = out.zm - out.pyc;

% Classification
class = strings(1,Np);
for k = 1:Np
    if any(isnan([out.zm(k),out.mld(k),out.pyc(k)]))
        class(k) = "bad";
    elseif out.zm(k) <= out.mld(k)
        class(k) = "mixed";
    elseif abs(out.zm(k) - out.pyc(k)) <= 0.15*out.pyc(k)
        class(k) = "pycnocline";
    else
        class(k) = "deep";
    end
end

out.class = categorical(class, ...
    ["mixed","pycnocline","deep","bad"]);

% Metadata
out.method.mld = phys.method.mld;
out.method.pyc = phys.method.pyc;
out.method.profile = Method;
out.z = z;

if nargout == 1
    class = out.class;
end
