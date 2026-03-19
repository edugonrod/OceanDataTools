function initClimatology(varname, lista, reader, force)
% INITCLIMATOLOGY Initialize an incremental monthly climatology dataset.
%
%   INITCLIMATOLOGY(varname, lista, reader)
%   INITCLIMATOLOGY(varname, lista, reader, force)
%
% Creates a MAT file containing a monthly climatology and the associated
% incremental statistics required for future updates.
%
% The output file contains:
%   climatology     - monthly climatology (mean values)
%   stats           - 1x12 array of CumStats objects (one per month)
%   tablameses      - table describing the months included
%   meses_omitidos  - table listing skipped months (incomplete coverage)
%   lonvec          - longitude vector
%   latvec          - latitude vector
%
% INPUTS
%   varname
%       Prefix of the output MAT file. The resulting file will be saved as:
%
%           varname_climatology.mat
%
%   lista
%       List of files to process.
%
%   reader
%       Function handle used to read the data files. It must return:
%
%           [data, lonvec, latvec, timevec]
%
%       where DATA is typically a 3-D array (lat × lon × time).
%
%   force
%       Logical flag controlling the inclusion of incomplete months.
%
%           false (default)  incomplete months are ignored
%           true             allows inclusion after manual confirmation
%
% DESCRIPTION
%   The function builds a monthly climatology by processing data month by
%   month. Each month's data are accumulated using CumStats objects, which
%   allow incremental updates without reprocessing all previous data.
%
%   The routine:
%
%       • Processes data month by month (memory efficient)
%       • Supports multiple years of data
%       • Verifies that each month is complete using the actual time vector
%       • Initializes CumStats accumulators for each calendar month
%       • Produces a MAT file ready for incremental climatology updates
%
% OUTPUT FILE CONTENTS
%   climatology
%       3-D array (lat × lon × 12) containing the monthly mean climatology.
%
%   stats
%       1×12 array of CumStats objects used to accumulate statistics for
%       each month of the year.
%
%   tablameses
%       Table listing the months included in the climatology with their
%       temporal coverage.
%
%   meses_omitidos
%       Table listing months excluded due to incomplete data coverage.
%
%   lonvec, latvec
%       Spatial coordinate vectors associated with the data grid.
%
% NOTES
%   The generated MAT file is intended to be used later for incremental
%   updates as new data become available, without recomputing the entire
%   climatology.
%
% EGR 20260306

if nargin < 4
    force = false;
end
fechas = getDatesFromfiles(lista);
yy = year(fechas);
mm = month(fechas);
pares = unique([yy mm], 'rows');

tablameses = table([], [], [], [], 'VariableNames', {'year','month','ndays','mdays'});
meses_omitidos = table([], [], [], [], [], 'VariableNames', {'year','month','ndays','days_in_month','coverage'});

stats(12) = CumStats;

for k = 1:size(pares, 1)
    y = pares(k, 1);
    m = pares(k, 2);
    ixfiles = yy == y & mm == m;
    lista_mes = lista(ixfiles);
    dias_mes = eomday(y, m);

    [data, lonvec, latvec, timevec] = reader(lista_mes);
    nd = numel(unique(timevec));
    cobertura = nd / dias_mes;
    if nd < dias_mes && ~force
        disp(['Mes incompleto ignorado: ', num2str(y), '-', sprintf('%02d', m), ...
            ' (', num2str(nd), '/', num2str(dias_mes), ')'])
        meses_omitidos = [meses_omitidos; {y, m, nd, dias_mes, cobertura}];
        clear data timevec
        continue
    end

    if force && cobertura < 0.0
        warning(['Cobertura baja detectada: ', num2str(y), '-', sprintf('%02d', m), ...
            ' (', sprintf('%.1f%%', cobertura*100), ')'])
        resp = input('¿Incluir este mes de todas formas? [y/N]: ','s');
        if ~strcmpi(resp,'y')
            disp('Mes omitido por cobertura baja.')
            clear data timevec
            continue
        end
    end

    if isempty(stats(m).count)
        stats(m) = CumStats(data);
    else
        stats(m) = stats(m).update(data);
    end

    tablameses = [tablameses; {y, m, nd, dias_mes}];
    if nd < dias_mes
        disp(['Mes agregado (INCOMPLETO): ', num2str(y), '-', sprintf('%02d', m)])
    else
        disp(['Mes agregado: ', num2str(y), '-', sprintf('%02d', m)])
    end

    clear data timevec
end

tablameses = sortrows(tablameses, {'year','month'});
meses_omitidos = sortrows(meses_omitidos, {'year','month'});

nx = length(latvec);
ny = length(lonvec);
climatology = nan(nx, ny, 12);

for m = 1:12
    if ~isempty(stats(m).count)
        climatology(:, :, m) = stats(m).cmean;
    end
end

outfile = [varname, '_climatology.mat'];
save(outfile, 'climatology', 'stats', 'tablameses', 'meses_omitidos', 'lonvec', 'latvec', '-v7.3')
