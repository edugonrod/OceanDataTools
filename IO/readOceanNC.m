function datanc = readOceanNC(ncfiles,cfg,lonlims,latlims)
%readOceanNC Read and subset oceanographic NetCDF datasets
%
%   out = readOceanNC(ncfiles,cfg,lonlims,latlims)
%
%   Reads gridded variables from one or more NetCDF files and extracts a
%   geographic subset defined by longitude and latitude limits.
%
%   The function is designed for common oceanographic datasets such as
%   satellite products, reanalysis and numerical model outputs. Variables
%   are automatically reordered to LAT × LON × ... × FILE and concatenated
%   along the last dimension when multiple files are provided.
%
%   INPUTS
%
%   ncfiles   String, character array or cell array containing the names
%             of the NetCDF files to read. If multiple files are provided,
%             they are appended along the last dimension.
%
%   cfg       Configuration structure returned by NCOCEANINFO. This
%             structure contains the variable names and coordinate names
%             detected in the dataset.
%
%   lonlims   Two-element vector specifying longitude limits:
%                 [lonmin lonmax]
%
%   latlims   Two-element vector specifying latitude limits:
%                 [latmin latmax]
%
%   LONGITUDE REFERENCE SYSTEM
%   The behaviour of longitude subsetting depends on cfg.lonref, which is
%   automatically defined by NCOCEANINFO and can be modified manually if
%   needed.
%
%   Possible values:
%       'greenwich'
%           Dataset uses longitudes in the range −180 to 180.
%           Longitude limits must be provided in the same system.
%       'equivalent360'
%           Dataset uses longitudes in the range 0 to 360 but equivalent to
%           a −180 to 180 representation. Longitude limits given in either
%           system are accepted and internally adjusted.
%       'native360'
%           Dataset uses a 0 to 360 convention that should not be wrapped to
%           −180 to 180 (e.g. ERSST). Longitude limits given in −180 to 180
%           are internally converted only for indexing, while output
%           coordinates remain unchanged.
%
%   If longitude subsetting returns incorrect regions when using
%   'equivalent360', set:
%       cfg.lonref = 'native360'
%   before calling READNCOCEAN.
%
%   OUTPUT
%   out       Structure containing the extracted data and metadata.
%             Coordinates
%               out.lonvec
%               out.latvec
%
%             Optional coordinate
%               out.depth
%
%             Time vector
%               out.timevec
%
%             Metadata
%               out.varnames
%               out.units
%               out.longname
%
%             Optional palette
%               out.palette
%
%             Data variables
%               out.<varname>
%
%             out.nt_per_file   Number of time steps per file
%             out.nfiles        Number of input files
%
%   DIMENSIONS OF OUTPUT VARIABLES
%
%   Variables are always returned with dimensions ordered as:
%       LAT × LON × ... × FILE
%   Examples:
%       lat × lon
%       lat × lon × file
%       lat × lon × depth
%       lat × lon × depth × file
%       lat × lon × time
%       lat × lon × time × file
%       lat × lon × depth × time
%       lat × lon × depth × time × file
%
%   TIME HANDLING
%
%   If the dataset contains a time variable, its units attribute
%   (e.g. "days since YYYY-MM-DD") is used to construct the time vector.
%
%   If no time variable exists, the function attempts to read the
%   attribute "time_coverage_start" from each file. This is common
%   in satellite datasets such as OceanColor.
%   out.timevec is always returned as a column vector of length nt × nfiles
%
%   MISSING VALUES
%   Values defined by the attributes
%       _FillValue
%       missing_value
%   are converted to NaN.
%
%   SCALE FACTOR AND OFFSET
%   Attributes "scale_factor" and "add_offset" are ignored because
%   most modern oceanographic datasets already store physical values.
%
%   DATASETS SUPPORTED
%   The function has been tested with datasets such as:
%       OceanColor
%       CMEMS / Copernicus Marine
%       CCMP winds
%       Satellite altimetry products
%       Gridded ocean model outputs
%       GHRSST-MUR data
%
%   EXAMPLE 1: Single file
%       [cfg,info] = ncoceaninfo('adt.nc');
%       lonlims = [-130 -110];
%       latlims = [20 35];
%       out = readncocean('adt.nc',cfg,lonlims,latlims);
%       imagesc(out.lonvec,out.latvec,out.adt)
%       axis xy
%
%   EXAMPLE 2: Multiple files
%       files = {'adt_20200101.nc'
%           'adt_20200102.nc'
%           'adt_20200103.nc'};
%       [cfg,info] = ncoceaninfo(files{1});
%       out = readncocean(files,cfg,[-130 -110],[20 35]);
%       size(out.adt)
%
%   EXAMPLE 3: Satellite SST
%       files = dir('*.L3m*.nc');
%       files = {files.name};
%       [cfg,info] = ncoceaninfo(files{1});
%       out = readncocean(files,cfg,[-120 -100],[15 30]);
%       imagesc(out.lonvec,out.latvec,out.sst(:,:,1))
%       axis xy
%
%   SEE ALSO
%       NCOCEANINFO
%       NCREAD
%       NCINFO
%
%   Author: EGR + IA help

if ischar(ncfiles) || isstring(ncfiles)
    ncfiles = cellstr(ncfiles);
end
nfiles = numel(ncfiles);
file0 = ncfiles{1};
info0 = ncinfo(file0);
allvars = {info0.Variables.Name};

Lat = ncread(file0,cfg.latname);
Lon = ncread(file0,cfg.lonname);
if nargin < 3 || isempty(lonlims)
    lonlims = [min(Lon(:)) max(Lon(:))];
end

if nargin < 4 || isempty(latlims)
    latlims = [min(Lat(:)) max(Lat(:))];
end

if isfield(cfg,'lonref')
    switch lower(cfg.lonref)
        case 'equivalent360'
            w360 = true;
        case {'greenwich','native360'}
            w360 = false;
        otherwise
            w360 = min(Lon(:)) >= 0;
    end
else
    try
        lonmin = ncreadatt(file0,cfg.lonname,'valid_min');
        w360 = lonmin >= 0;
    catch
        w360 = min(Lon(:)) >= 0;
    end
end

if w360
    if abs(diff(lonlims)) < 360
        lonlims = mod(lonlims,360);
    else
        lonlims = [min(Lon(:)) max(Lon(:))];
    end
elseif isfield(cfg,'lonref') && strcmpi(cfg.lonref,'native360')
    if abs(diff(lonlims)) < 360
        lonlims = mod(lonlims,360);
    else
        lonlims = [min(Lon(:)) max(Lon(:))];
    end
else
    if abs(diff(lonlims)) >= 360
        lonlims = [min(Lon(:)) max(Lon(:))];
    end
end

ixlon = sort(dsearchn(Lon(:),lonlims(:)));
ixlat = sort(dsearchn(Lat(:),latlims(:)));
lonvec = double(Lon(ixlon(1):ixlon(2)));
latvec = double(Lat(ixlat(1):ixlat(2)));
Nx = numel(lonvec);
Ny = numel(latvec);

if w360
    lonvec = wrapTo180(lonvec);
end
datanc.lonvec = lonvec;
datanc.latvec = latvec;

if isfield(cfg,'zname')
    z = ncread(file0,cfg.zname);
    datanc.depth = double(z(:));
end

nvars = numel(cfg.index);
datanc.varnames = cfg.varnames(cfg.index);
if isfield(cfg,'timename')
    tunits = ncreadatt(file0,cfg.timename,'units');
    parts = regexp(tunits,'(\w+)\s+since\s+([0-9\-:\s]+)','tokens','once');
    tunit = lower(parts{1});
    tref = strtrim(parts{2});
    if contains(tref,':')
        t0 = datetime(tref,'InputFormat','yyyy-MM-dd HH:mm:ss');
    else
        t0 = datetime(tref,'InputFormat','yyyy-MM-dd');
    end
    t = ncread(file0,cfg.timename);
    nt = numel(t);
    Nt = nt*nfiles;
    datanc.timevec = NaT(Nt,1);
else
    nt = 1;
    Nt = nfiles;
end

datanc.nt_per_file = nt;
datanc.nfiles = nfiles;

for v = 1:nvars
    varname = cfg.varnames{cfg.index(v)};
    iv = find(strcmp(allvars,varname));
    vinfo = info0.Variables(iv);
    dims = arrayfun(@(x) x.Name, vinfo.Dimensions, 'UniformOutput', false);
    itim = find(strcmp(dims,cfg.timename));
    nd = numel(dims);
    start = ones(1,nd);
    count = vinfo.Size;
    ilon = find(strcmp(dims,cfg.lonname));
    ilat = find(strcmp(dims,cfg.latname));
    start(ilon) = ixlon(1);
    count(ilon) = Nx;
    start(ilat) = ixlat(1);
    count(ilat) = Ny;
    perm = [ilat ilon setdiff(1:nd,[ilat ilon])];
    units = getattr(file0,varname,'units','');
    if ~isempty(units)
        datanc.units.(varname) = units;
    end
    lname = getattr(file0,varname,'long_name','');
    if ~isempty(lname)
        datanc.longname.(varname) = lname;
    end

    sf = double(getattr(file0,varname,'scale_factor',1));
    ao = double(getattr(file0,varname,'add_offset',0));
    fillv = getattr(file0,varname,'_FillValue',[]);
    missv = getattr(file0,varname,'missing_value',[]);
    isKelvin = false;
    if ~isempty(units)
        u = lower(units);
        if contains(u,'kelvin') || strcmp(u,'k')
            isKelvin = true;
            datanc.units.(varname) = 'Celsius';
        end
    end

    sz = vinfo.Size;
    sz(ilon) = Nx;
    sz(ilat) = Ny;
    sz = sz(perm);
    if isempty(itim)
        dat = nan([sz Nt]);
    else
        dat = nan(sz);
    end
    it = 1;
    for k = 1:nfiles
        raw = double(ncread(ncfiles{k},varname,start,count));
        bad = [fillv(:);missv(:)];
        if ~isempty(bad)
            raw(ismember(raw,bad)) = NaN;
        end
        % raw = raw*sf + ao; %scale factor, not needed
        if isKelvin
            raw = raw-273.15;
        end

        raw = permute(raw,perm);
        idx = repmat({':'},1,ndims(raw));
        idx{end+1} = k;
        dat(idx{:}) = raw;

        if isfield(cfg,'timename')
            t = double(ncread(ncfiles{k},cfg.timename));
            if contains(tunit,'second')
                datanc.timevec(it:it+nt-1) = t0 + seconds(t(:));
            elseif contains(tunit,'hour')
                datanc.timevec(it:it+nt-1) = t0 + hours(t(:));
            elseif contains(tunit,'day')
                datanc.timevec(it:it+nt-1) = t0 + days(t(:));
            elseif contains(tunit,'month')
                if all(abs(t(:)-round(t(:))) < 1e-6)
                    datanc.timevec(it:it+nt-1) = t0 + calmonths(round(t(:)));
                else
                    datanc.timevec(it:it+nt-1) = t0 + days(30.4375*t(:));
                end
            end
        else
            try
                t1 = ncreadatt(ncfiles{k},'/','time_coverage_start');
                datanc.timevec(it) = datetime(t1(1:19),'InputFormat','yyyy-MM-dd''T''HH:mm:ss');
            catch
            end
        end
        it = it + nt;
    end

    dat = squeeze(dat);
    if datanc.latvec(1) > datanc.latvec(end)
        datanc.latvec = flip(datanc.latvec);
        dat = flip(dat,1);
    end
    if datanc.lonvec(1) > datanc.lonvec(end)
        datanc.lonvec = flip(datanc.lonvec);
        dat = flip(dat,2);
    end
    if isfield(datanc,'depth')
        if datanc.depth(1) > datanc.depth(end)
            datanc.depth = flip(datanc.depth);
            dat = flip(dat,3);
        end
    end
    datanc.(varname) = dat;
end
vars = {info0.Variables.Name};
ipal = find(strcmpi(vars,'palette'),1);
if ~isempty(ipal)
    datanc.palette = ncread(file0,'palette');
end
end

function val = getattr(file,var,att,default)
try
    val = ncreadatt(file,var,att);
catch
    val = default;
end
end