function updateclimatology(matfile, lista, reader, force)
% UPDATECLIMATOLOGY Update an incremental monthly climatology dataset.
%
%   updateclimatology(matfile, lista, reader)
%   updateclimatology(matfile, lista, reader, force)
%
% Updates an existing climatology file created with INITCLIMATOLOGY by
% incorporating new data files. The function processes only the months
% that require updating, avoiding unnecessary recomputation.
%
% INPUTS
%   matfile
%       MAT file previously created by INITCLIMATOLOGY.
%
%   lista
%       List of data files to incorporate into the climatology.
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
%   The function updates an existing climatology by:
%
%       • Identifying which months require processing
%       • Processing only missing or incomplete months
%       • Avoiding reprocessing months already completed
%       • Allowing previously incomplete months to be completed
%       • Updating CumStats accumulators
%       • Updating the coverage table (tablameses)
%       • Recomputing omitted months automatically
%       • Preserving temporal traceability of processed data
%
% OUTPUT FILE CONTENTS
%   The MAT file is updated with:
%
%       climatology
%           Monthly mean climatology (lat × lon × 12).
%
%       stats
%           1×12 array of CumStats objects used for incremental updates.
%
%       tablameses
%           Table describing temporal coverage of processed months.
%
%       mesesomitidos
%           Table listing months with incomplete data coverage.
%
%       lonvec, latvec
%           Spatial grid vectors associated with the climatology.
%
% NOTES
%   • The spatial grid of new data must match the existing climatology.
%   • Only months not yet processed are evaluated.
%   • CumStats allows incremental updates without recomputing all data.
%
% SEE ALSO
%   INITCLIMATOLOGY, CUMSTATS
%
% EGR

if nargin < 4
    force = false;
end

load(matfile, 'stats', 'tablameses', 'lonvec', 'latvec')

fechas = getDatesFromfiles(lista);
yy = year(fechas);
mm = month(fechas);
pares = unique([yy mm], 'rows');

% ===== determinar meses a procesar =====
pares_a_procesar = [];

for k = 1:size(pares,1)
    y = pares(k,1);
    m = pares(k,2);
    dias_mes = eomday(y,m);

    fila = tablameses.year == y & tablameses.month == m;

    if any(fila)
        continue
    end

    pares_a_procesar(end+1,:) = [y m];
end

if isempty(pares_a_procesar)
    disp('No hay meses que requieran actualización.')
    return
end

meses_completados = table([], [], [], [], ...
    'VariableNames', {'year','month','antes','despues'});

% ===== procesar solo los necesarios =====
for k = 1:size(pares_a_procesar,1)

    y = pares_a_procesar(k,1);
    m = pares_a_procesar(k,2);

    ixfiles = yy == y & mm == m;
    lista_mes = lista(ixfiles);
    dias_mes = eomday(y,m);

    fila = tablameses.year == y & tablameses.month == m;
    nd_prev = 0;

    if any(fila)
        nd_prev = tablameses.ndays(fila);
    end

    [data, lon_new, lat_new, timevec] = reader(lista_mes);

    if ~isequal(lon_new, lonvec) || ~isequal(lat_new, latvec)
        error('La grilla espacial no coincide con la climatología existente.')
    end

    nd = numel(unique(timevec));
    cobertura = nd / dias_mes;

    if nd < dias_mes && ~force
        disp(['Mes incompleto ignorado: ', num2str(y), '-', sprintf('%02d', m), ...
            ' (', num2str(nd), '/', num2str(dias_mes), ')'])
        clear data timevec
        continue
    end

    if force && cobertura < 0.8
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

    if any(fila)
        tablameses.ndays(fila) = tablameses.ndays(fila) + nd;
        tablameses.mdays(fila) = dias_mes;
        nd_new = tablameses.ndays(fila);
    else
        tablameses = [tablameses; {y, m, nd, dias_mes}];
        nd_new = nd;
    end

    if nd_prev < dias_mes && nd_new >= dias_mes
        meses_completados = [meses_completados; {y, m, nd_prev, nd_new}];
    end

    if nd < dias_mes
        disp(['Mes agregado (INCOMPLETO): ', num2str(y), '-', sprintf('%02d', m)])
    else
        disp(['Mes agregado: ', num2str(y), '-', sprintf('%02d', m)])
    end

    clear data timevec
end

tablameses = sortrows(tablameses, {'year','month'});

dias_mes = tablameses.mdays;
faltantes = tablameses.ndays < dias_mes;

mesesomitidos = tablameses(faltantes, :);
mesesomitidos.days_in_month = dias_mes(faltantes);
mesesomitidos.coverage = mesesomitidos.ndays ./ mesesomitidos.days_in_month;

nx = length(latvec);
ny = length(lonvec);
climatology = nan(nx, ny, 12);

for m = 1:12
    if ~isempty(stats(m).count)
        climatology(:, :, m) = stats(m).cmean;
    end
end

save(matfile, 'climatology', 'stats', 'tablameses', 'mesesomitidos', 'lonvec', 'latvec', '-v7.3')

disp('Actualización completada')
