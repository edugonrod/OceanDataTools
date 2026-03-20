function [integral, profile] = fitProfileIntegral(z,x,method,npts)
%fitProfileIntegral  Fit/smooth a vertical profile and compute its integral.
%   [integral, profile] = fitProfileIntegral(z,x) fits or smooths the profile x(z),
%   then computes the vertical integral and returns a modeled profile
%   suitable for analysis and visualization.
%
%   method:
%     'pchip'  (default) shape-preserving interpolation
%     'smooth' Savitzky–Golay smoothing
%     'spline' smoothing spline
%     'trapz'  raw profile (no smoothing)
%     'gauss'  Gaussian fit with offset (ideal SCM profiles)
%
%   out contains:
%     z,x      processed profile
%     zmax     depth of maximum
%     xmax     maximum value
%     imax     index of maximum in processed profile
%     rmse     root mean square error vs observations
%     r2       coefficient of determination
%     bias     mean bias
%     nobs     number of observations
%     method   method used
%     mu, sigma, amp, offset, fwhm (only for 'gauss')
%
%   Eduardo Gonzalez Rodriguez + IA
%   2026

if nargin<3||isempty(method)
    method='pchip';
end
if nargin<4||isempty(npts)
    npts=200;
end

z=z(:);x=x(:);
ok=~isnan(z)&~isnan(x);
z=z(ok);x=x(ok);
profile.nobs=numel(z);

if profile.nobs<2
    integral=NaN;profile=[];
    return
end

[z,ix]=sort(z);x=x(ix);

switch lower(method)
case 'trapz'
    zi = z;
    xi = x;
case 'smooth'
    zi = z;
    xi = smoothdata(x,'sgolay',5);
case 'pchip'
    zi = linspace(z(1), z(end), npts);
    xi = interp1(z, x, zi, 'pchip');
    case 'spline'
        zi = linspace(z(1), z(end), npts);
        pp = csaps(z, x, 0.85);
        xi = fnval(pp, zi);
    case 'gauss'
        gaussfun = @(b,z) b(1) + b(2)*exp(-(z-b(3)).^2/(2*b(4)^2));
        offset = min(x);
        amp = max(x)-offset;
        [~,im] = max(x);
        mu = z(im);
        if numel(mu)>1
            mu = mu(1);
        end
        sigma = (max(z) - min(z))/4;
        beta0 = [offset amp mu sigma];
        try
            beta = nlinfit(z,x,gaussfun,beta0);
        catch
            integral = NaN;
            profile = [];
            return
        end
        zi = linspace(min(z), max(z), npts);
        xi = gaussfun(beta,zi);
        profile.mu    = beta(3);
        profile.sigma = abs(beta(4));
        profile.amp   = beta(2);
    profile.offset= beta(1);
    profile.fwhm  = 2.355*profile.sigma;
otherwise
    error('Unknown method')
end

integral = trapz(zi,xi);
[xmax,im] = max(xi);
zmax = zi(im);
xModel = interp1(zi,xi,z,'linear','extrap');
res = x - xModel;

profile.z = zi;
profile.x = xi;
profile.zmax = zmax;
profile.xmax = xmax;
profile.imax = im;
profile.rmse = sqrt(mean(res.^2));
profile.bias = mean(res);
den = sum((x-mean(x)).^2);
if den==0
    profile.r2 = NaN;
else
    profile.r2 = 1 - sum(res.^2)/den;
end
profile.method = method;
profile.npts = npts;
end
