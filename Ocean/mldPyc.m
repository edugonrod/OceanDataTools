function out = mldPyc(P, T, S, z, varargin)
%MLDPYC  Mixed layer depth and pycnocline depth from vertical profiles
%
%   OUT = MLDPYC(P,T,S,Z)
%   OUT = MLDPYC(...,'Name',Value)
%
% Computes mixed layer depth (MLD) and pycnocline depth from density.
%
% INPUTS
%   P,T,S : [Nz x Np] pressure (dbar), temperature, salinity
%   z     : [Nz x 1] depth (m, positive downward)
%
% NAME–VALUE OPTIONS
%   'DeltaSigma' : density threshold (default = 0.03 kg/m^3)
%   'RefDepth'   : reference depth (default = 10 m)
%   'TEOS10'     : use TEOS-10 if available (default = true)
%
% OUTPUT
%   out.mld
%   out.pyc
%   out.method
%
% EXAMPLES
% Basic usage with default options
% out = mldPyc(P, T, S, z);
%
% Use a different density threshold for MLD detection
% out = mldPyc(P, T, S, z, 'DeltaSigma', 0.02);
%
% Change reference depth for density anomaly calculation
% out = mldPyc(P, T, S, z, 'RefDepth', 5);
% 
% Disable TEOS-10 and use fallback equation of state
% out = mldPyc(P, T, S, z, 'UseTEOS', false);
% 
% Plot density profile with MLD and pycnocline depth
% out = mldPyc(P, T, S, z);
%
% k = 1; % profile index
%
% rho = gsw_rho(gsw_SA_from_SP(S(:,k),P(:,k),0,0), ...
%              gsw_CT_from_t(gsw_SA_from_SP(S(:,k),P(:,k),0,0),T(:,k),P(:,k)), ...
%              P(:,k));
% plot(rho, z)
% set(gca,'YDir','reverse')
% hold on
% yline(out.mld(k),'b','MLD')
% yline(out.pyc(k),'r','Pycnocline')
% xlabel('Density')
% ylabel('Depth (m)')
%
% EGR 2026

% -------------------- Validations --------------------
assert(isequal(size(P),size(T),size(S)), ...
    'P, T, S must have same size')

assert(numel(z) == size(T,1), ...
    'z must match vertical dimension')

% -------------------- Options --------------------
p = inputParser;
p.addParameter('DeltaSigma',0.03,@(x)isnumeric(x)&&x>0)
p.addParameter('RefDepth',10,@(x)isnumeric(x)&&x>=0)
p.addParameter('TEOS10',true,@islogical)
p.parse(varargin{:})

DeltaSigma = p.Results.DeltaSigma;
RefDepth   = p.Results.RefDepth;
TEOS10     = p.Results.TEOS10;

% -------------------- Setup --------------------
z = z(:);
[Nz,Np] = size(T);

% -------------------- Detect TEOS --------------------
useGSW = false;
if TEOS10 && exist('gsw_rho','file') == 2
    useGSW = true;
end

% -------------------- Density --------------------
rho = NaN(Nz,Np);
for k = 1:Np
    Tk = T(:,k);
    Sk = S(:,k);
    Pk = P(:,k);
    valid = ~(isnan(Tk) | isnan(Sk) | isnan(Pk));
    if nnz(valid) < 3
        continue
    end
    if useGSW
        % TEOS-10
        SA = NaN(Nz,1);
        CT = NaN(Nz,1);
        SA(valid) = gsw_SA_from_SP(Sk(valid),Pk(valid),0,0);
        CT(valid) = gsw_CT_from_t(SA(valid),Tk(valid),Pk(valid));
        rho(valid,k) = gsw_rho(SA(valid),CT(valid),Pk(valid));
    else
        % Simple linear EOS
        rho(valid,k) = 1000 + 0.8*(Sk(valid)-35) - 0.2*(Tk(valid)-10);
    end
end

% -------------------- MLD --------------------
mld = NaN(1,Np);
for k = 1:Np
    rhok = rho(:,k);
    valid = ~isnan(rhok) & ~isnan(z);
    if nnz(valid) < 3
        continue
    end
    zk   = z(valid);
    rhok = rhok(valid);

    % índice de referencia
    [~, iz] = min(abs(zk - RefDepth));
    if isnan(rhok(iz))
        continue
    end
    drho = rhok - rhok(iz);
    idx = find(drho > DeltaSigma & zk > zk(iz),1,'first');
    if ~isempty(idx)
        mld(k) = zk(idx);
    end
end

% -------------------- Pycnocline --------------------
pyc = NaN(1,Np);
for k = 1:Np
    rhok = rho(:,k);
    valid = ~isnan(rhok) & ~isnan(z);
    if nnz(valid) < 5
        continue
    end
    zk   = z(valid);
    rhok = rhok(valid);
    % gradiente
    drhodz = gradient(rhok,zk);
    % evitar ruido superficial
    mask = zk > 5;
    if nnz(mask) < 3
        continue
    end
    drhodz_masked = drhodz(mask);
    zk_masked     = zk(mask);
    [~,imax] = max(drhodz_masked);
    pyc(k) = zk_masked(imax);
end

% -------------------- Output --------------------
out.mld = mld;
out.pyc = pyc;
out.method.mld = 'density threshold (RefDepth)';
out.method.pyc = 'max density gradient';

if useGSW
    out.method.eos = 'TEOS-10 (GSW)';
else
    out.method.eos = 'linear EOS (fallback)';
end

