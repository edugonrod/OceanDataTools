function [mhwave, threshold] = detectMHW(sstvec, datevec, clim)
% detectMHW Detect Marine Heatwave events following Hobday et al. (2016).
%
%   mhwave = detectMHW(sstvec, datevec)
%   mhwave = detectMHW(sstvec, datevec, clim)
%   [mhwave, threshold] = detectMHW(...)
%
% Detects Marine Heatwave (MHW) events from a sea surface temperature (SST)
% time series using a percentile-based threshold following the definition
% proposed by Hobday et al. (2016).
%
% INPUT
%   sstvec
%       Vector containing sea surface temperature values.
%
%   datevec
%       Vector of dates corresponding to sstvec. It can be either
%       datetime or datenum format. Both vectors must have the same length.
%
%   clim
%       Climatology grouping used to compute the threshold:
%
%           'q'  → quarterly climatology (default)
%           'm'  → monthly climatology
%
% OUTPUT
%   mhwave
%       Table describing detected Marine Heatwave events with variables:
%
%           fecha_inicio   start date of the event
%           fecha_fin      end date of the event
%           duracion       event duration in days
%
%       Only events lasting at least 5 consecutive days are retained.
%
%   threshold
%       Table containing the threshold used for each climatological
%       period with variables:
%
%           Periodo
%           Umbral
%
% DESCRIPTION
%   A Marine Heatwave is defined as a period where SST exceeds the
%   90th percentile threshold of a climatological baseline for at
%   least five consecutive days.
%
%   The threshold is computed separately for each climatological period
%   (monthly or quarterly).
%
% REFERENCE
%   Hobday, A. J., et al. (2016).
%   "A hierarchical approach to defining marine heatwaves."
%   Progress in Oceanography, 141, 227–238.
%
% EXAMPLE
%   mhw_events = mhw(sst, time);
%
% SEE ALSO
%   PRCTILE, FINDGROUPS, SPLITAPPLY
%
% EGR
% 20230424 / 2024
if nargin < 3 || isempty(clim) 
	clim = 'q';
end

if ~isdatetime(datevec)
	datevec = datetime(datevec,'ConvertFrom','datenum'); 
end

switch clim
    case 'q'; periodos = quarter(datevec);
    case 'm'; periodos = month(datevec);
end

prc = 90;
[grupos, periodos_unicos] = findgroups(periodos);
threshold = splitapply(@(x) prctile(x, prc), sstvec, grupos);
threshold = table(periodos_unicos, threshold, 'VariableNames', {'Periodo','Umbral'});

excede = false(size(datevec));
for i = 1:length(periodos_unicos)
    idx = grupos == i;
    excede(idx) = sstvec(idx) > threshold.Umbral(i);
end

fechas_evento = datevec(excede);
if isempty(fechas_evento); 
	mhwave = table();
	return; 
end

saltos = find(diff(datenum(fechas_evento)) > 1);
inicios = [1; saltos+1];
fines = [saltos; length(fechas_evento)];

mhwave = table();
mhwave.fecha_inicio = fechas_evento(inicios)';
mhwave.fecha_fin = fechas_evento(fines)';
mhwave.duracion = (fines - inicios + 1)';
mhwave(mhwave.duracion < 5, :) = [];
