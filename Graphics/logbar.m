function cbh = logbar(cbh, cblimits)
%LOGBAR Applies a log-scale colorbar with linear tick labels.
%
%   cbh = LOGBAR() creates a colorbar for an existing log10-scaled plot
%   and applies a set of linear tick labels to it.
%
%   cbh = LOGBAR(cblimits) creates or updates a colorbar assuming the plot
%   data was scaled with log10, and cblimits is a 2-element vector [min max]
%   in linear scale.
%
%   cbh = LOGBAR(cbh, cblimits) applies limits and ticks to the provided
%   colorbar handle.
%
%   Inputs:
%       cbh       - (optional) colorbar handle or cblimits vector
%       cblimits  - (optional) 2-element vector specifying the color axis 
%                   limits in **linear scale** (e.g., [1 1000])
%
%   Output:
%       cbh       - Handle to the updated colorbar
%
%   Notes:
%       - Best used when plotting log10-scaled data, e.g., pcolor(log10(data))
%       - Automatically adjusts for values ≤ 0
%       - Uses ticks closest to the log-limits without toolboxes
%
%   Author: Eduardo Gonzalez Rodriguez
%   Email: egonzale@cicese.mx
%   Date: 2016-05-18 (updated 2025-06-30)

    if nargin == 0
        colorbar('off'); % avoid duplicates
        cbh = colorbar;
        loglimits = cbh.Limits;

    elseif nargin == 1
        if isgraphics(cbh, 'colorbar')
            loglimits = cbh.YLim;
        else
            cblimits = cbh;
            cbh = colorbar;
            cblimits(cblimits <= 0) = min(cblimits(cblimits > 0)) * 0.1;
            loglimits = log10(cblimits);
            cbh.YLim = loglimits;
        end

    else % nargin == 2
        cblimits(cblimits <= 0) = min(cblimits(cblimits > 0)) * 0.1;
        loglimits = log10(cblimits);
        cbh.YLim = loglimits;
    end

    % Apply limits to plot
    caxis(loglimits)

    % Define full log10 scale
    linscale = [1e-10, .001, .01, .025, .05, .1, .5, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192]';
    logscale = log10(linscale);

    % Find closest indices to loglimits using min(abs(...))
    [~, idx] = min(abs(logscale(:) - loglimits(:)'));
    idx = idx(1):idx(2);

    % Assign ticks and labels
    cbh.YTick = logscale(idx);
    cbh.YTickLabel = linscale(idx);

    if nargout == 0
        clear cbh
    end
end
