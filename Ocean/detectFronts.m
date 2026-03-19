function fronts = detectFronts(field,lonvec,latvec,varargin)
% detectFronts Detect ocean fronts using several algorithms
%
% fronts = detectFronts(field,lonvec,latvec)
% fronts = detectFronts(...,'method','canny')
% fronts = detectFronts(...,'threshold',T)
%
% METHODS
%   canny           Edge detection (default, robust for SST)
%   gradient        Gradient magnitude threshold
%   gradient_clean  Gradient + morphological cleaning
%   sobel           Sobel edge operator
%   tensor          Structure tensor coherence
%
% NOTES
%   The variable used to detect fronts depends on the application.
%
%   Common choices are:
%
%       SST           Thermal fronts
%       SSH           Dynamic fronts
%       Density       Water mass boundaries
%       Chlorophyll   Biological fronts
%
%   In studies of mesoscale circulation, fronts are often detected from
%   the gradient of geostrophic velocity rather than directly from SSH:
%
%       [ug,vg] = geostrophicvelocity(ssh,lonvec,latvec);
%       speed = hypot(ug,vg);
%       fronts = detectFronts(speed,lonvec,latvec);
%
% CANNY PARAMETERS
%   The Canny detector is sensitive to the amount of smoothing applied
%   before edge detection and to the threshold parameter T. The smoothing
%   scale (sigma) determines the spatial scale of fronts that are detected.
%
%   Typical parameter ranges for SST fields:
%
%       Target structures      Gaussian sigma     Canny threshold (T)
%       --------------------------------------------------------------
%       Small filaments            0.8 – 1.0           0.15 – 0.20
%       Mesoscale fronts           1.5 – 2.0           0.20 – 0.25
%       Strong large fronts        2.5 – 3.0           0.25 – 0.30
%
%   For mesoscale thermal fronts (≈10–100 km), a common configuration is:
%
%       fieldf = imgaussfilt(field,1.5);
%       mask   = edge(fieldf,'Canny',0.225);
%
% APPLICATION-SPECIFIC PARAMETERS
%
%   Recommended methods depend on the variable being analyzed.
%
%       Variable        Recommended method
%       -----------------------------------
%       SST             canny
%       Chlorophyll     sobel
%
%   Thermal fronts in SST are usually smoother and benefit from edge
%   detectors such as Canny applied to a mildly smoothed field.
%
%   Chlorophyll fields often exhibit sharper gradients and filamentary
%   structures associated with biological activity. In these cases the
%   Sobel operator tends to provide clearer front detection, especially
%   when applied to log-transformed chlorophyll:
%
%       chl = log10(chl);
%       F = detectFronts(chl,lonvec,latvec,'method','sobel');
%
%   This transformation stabilizes gradients because chlorophyll
%   distributions are typically log-normal.
%
% EXAMPLES
%   Detect mesoscale thermal fronts from SST:
%
%       F = detectFronts(sst,lonvec,latvec,'method','canny',...
%                        'sigma',1.5,'threshold',0.225);
%
%       sigma     controls the spatial scale of detected fronts
%       threshold controls the sensitivity to weak gradients
%
%   Detect chlorophyll fronts (recommended to work in log space):
%
%       F = detectFronts(log10(chl),lonvec,latvec,'method','sobel');
%
%   Plot detected fronts:
%
%       imagescnan(lonvec,latvec,field)
%       contour(lonvec,latvec,F.mask,[1 1],'k')
%
%   Classical oceanographic algorithms such as CCA (Cayula–Cornillon),
%   BOA (Belkin–O'Reilly), or TFP were tested but are not included here
%   because simplified implementations often produce unstable or overly
%   sensitive detections without careful regional calibration.
%
% SEE ALSO
%   edge, imgaussfilt, geogradient
%
% OceanDataTools
% 20160306 EGR + IA help

method = 'canny';
threshold = [];
sigma = [];
k = 1;
while k <= numel(varargin)
    switch lower(varargin{k})
        case 'method'
            method = lower(varargin{k+1});
        case 'threshold'
            threshold = varargin{k+1};
        case 'sigma'
            sigma = varargin{k+1};
    end
    k = k + 2;
end
method = lower(method);

validmethods = {'canny','gradient','gradient_clean','sobel','tensor'};
if ~any(strcmp(method,validmethods))
    error('detectfronts:UnknownMethod','Unknown method "%s". Available methods: %s',method,strjoin(validmethods,', '))
end

% GRADIENT
if any(strcmp(method,{'gradient','gradient_clean'}))
    [gx,gy] = geogradient(field,lonvec,latvec);
    gradmag = hypot(gx,gy);
    if isempty(threshold)
        g = gradmag(~isnan(gradmag));
        threshold = prctile(g,90);
    end
    mask = gradmag >= threshold;
    if strcmp(method,'gradient_clean')
        if license('test','image_toolbox')
            mask = bwareaopen(mask,4);
            mask = imclose(mask,strel('disk',1));
        else
            mask = conv2(double(mask),ones(3),'same') > 4;
        end
    end
end

% SOBEL
if strcmp(method,'sobel')
    sx = [1 0 -1;2 0 -2;1 0 -1];
    sy = sx';
    gx = conv2(field,sx,'same');
    gy = conv2(field,sy,'same');
    gradmag = hypot(gx,gy);
    if isempty(threshold)
        g = gradmag(~isnan(gradmag));
        threshold = prctile(g,90);
    end
    mask = gradmag >= threshold;
end

% STRUCTURE TENSOR
if strcmp(method,'tensor')
    [gx,gy] = geogradient(field,lonvec,latvec);
    Jxx = gx.^2;
    Jyy = gy.^2;
    Jxy = gx.*gy;
    h = ones(5)/25;
    Jxx = conv2(Jxx,h,'same');
    Jyy = conv2(Jyy,h,'same');
    Jxy = conv2(Jxy,h,'same');
    lambda1 = (Jxx+Jyy)/2 + sqrt(((Jxx-Jyy)/2).^2 + Jxy.^2);
    lambda2 = (Jxx+Jyy)/2 - sqrt(((Jxx-Jyy)/2).^2 + Jxy.^2);
    coherence = (lambda1-lambda2)./(lambda1+lambda2);
    if isempty(threshold)
        g = coherence(~isnan(coherence));
        threshold = prctile(g,90);
    end
    mask = coherence >= threshold;
end

% CANNY
if strcmp(method,'canny')
    if isempty(sigma)
        sigma = 1.5;
    end
    fieldf = imgaussfilt(field,sigma);
    if isempty(threshold)
        threshold = 0.2;
    end
    mask = edge(fieldf,'Canny',threshold);
    if license('test','image_toolbox')
        mask = bwareaopen(mask,5);
    else
        mask = conv2(double(mask),ones(3),'same') > 2;
    end
end

fronts.mask = mask;
fronts.method = method;
fronts.threshold = threshold;
fronts.lon = lonvec;
fronts.lat = latvec;
