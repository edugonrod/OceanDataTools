function [cfg, info] = ncOceanInfo(file)
%ncOceanInfo Inspect oceanographic NetCDF file and propose read configuration
%
%   [CFG,INFO] = ncOceanInfo(FILE) inspects an oceanographic NetCDF file
%   and identifies coordinate variables, data variables and basic
%   metadata. The function returns a configuration structure that can be
%   used directly by READNCOCEAN to read the dataset.
%
%   The function automatically detects longitude, latitude, time and
%   depth variables using common naming conventions used in oceanographic
%   datasets.
%
%   INPUT
%
%   FILE      Name of the NetCDF file to inspect. It can be provided as a
%             character array, string or cell array. If a cell array is
%             provided, only the first file is inspected.
%
%
%   OUTPUTS
%
%   CFG       Configuration structure used by READNCOCEAN.
%             Fields may include:
%               cfg.index
%               cfg.varnames
%               cfg.lonname
%               cfg.latname
%               cfg.zname
%               cfg.timename
%
%   INFO      Structure containing file inspection information.
%             General information
%               info.filename
%             Coordinate names
%               info.coords.lon
%               info.coords.lat
%             Spatial limits
%               info.lonrange
%               info.latrange
%             Optional depth information
%               info.depth.name
%               info.depth.range
%             Optional time information
%               info.time.name
%               info.time.units
%             Data variables
%               info.vars(k).name
%               info.vars(k).size
%               info.vars(k).units
%             Optional palette
%               info.palette
%
%   VARIABLE DETECTION
%   Longitude and latitude coordinates are detected automatically using
%   common variable names such as:
%       lon, longitude
%       lat, latitude
%   Time and depth variables are detected if variables named:
%       time
%       depth
%   are present in the dataset.
%
%   Data variables are identified as variables that contain both
%   longitude and latitude dimensions.
%
%   EXAMPLE
%       [cfg,info] = ncoceaninfo('adt.nc');
%       cfg.varnames
%       info.lonrange
%       info.latrange
%
%   WORKFLOW EXAMPLE
%       [cfg,info] = ncoceaninfo('adt.nc');
%       lonlims = [-130 -110];
%       latlims = [20 35];
%       out = readncocean('adt.nc',cfg,lonlims,latlims);
%
%   SEE ALSO
%       READNCOCEAN
%       NCINFO
%       NCREAD
%
%   Author: EGR 2026 + IA

if isstring(file) || ischar(file)
    file = cellstr(file);
end

if iscell(file)
    file = file{1};
end

nc = ncinfo(file);
names = {nc.Variables.Name};
low = lower(names);

ilon = find(strcmp(low,'lon') | strcmp(low,'longitude'),1);
if isempty(ilon), ilon = find(contains(low,'lon'),1); end

ilat = find(strcmp(low,'lat') | strcmp(low,'latitude'),1);
if isempty(ilat), ilat = find(contains(low,'lat'),1); end

itim = find(strcmp(low,'time'),1);
iz = find(strcmp(low,'depth'),1);

lon = names{ilon};
lonvec = ncread(file,lon);
info.lonrange = [min(lonvec(:)) max(lonvec(:))];

lat = names{ilat};
latvec = ncread(file,lat);
info.latrange = [min(latvec(:)) max(latvec(:))];

info.filename = file;
info.coords.lon = lon;
info.coords.lat = lat;

tim = [];
if ~isempty(itim)
    tim = names{itim};
    info.time.name = tim;
    try
        info.time.units = ncreadatt(file,tim,'units');
    catch
        info.time.units = '';
    end
end

zname = [];
if ~isempty(iz)
    zname = names{iz};
    zvec = ncread(file,zname);
    info.depth.name = zname;
    info.depth.range = [min(zvec(:)) max(zvec(:))];
end

exclude = {lon,lat};
if ~isempty(tim), exclude{end+1} = tim; end
if ~isempty(zname), exclude{end+1} = zname; end

datavars = names(~ismember(names,exclude));
ipal = find(strcmpi(datavars,'palette'),1);
if ~isempty(ipal)
    info.palette = datavars{ipal};
    datavars(ipal) = [];
end

keep = false(size(datavars));
for k = 1:numel(datavars)
    ix = find(strcmp(names,datavars{k}),1);
    if isempty(ix)
        continue
    end
    dims = nc.Variables(ix).Dimensions;
    if ~isstruct(dims) || isempty(dims)
        continue
    end
    dnames = arrayfun(@(x) x.Name, dims, 'UniformOutput', false);
    keep(k) = any(strcmp(dnames,lon)) && any(strcmp(dnames,lat));
end
datavars = datavars(keep);

for k = 1:numel(datavars)
    v = datavars{k};
    ix = find(strcmp(names,v));
    vi = nc.Variables(ix);
    info.vars(k).name = v;
    info.vars(k).size = vi.Size;
    att = {vi.Attributes.Name};
    iu = find(strcmp(att,'units'),1);
    if ~isempty(iu)
        info.vars(k).units = vi.Attributes(iu).Value;
    else
        info.vars(k).units = '';
    end
end

cfg.index = 1:numel(datavars);
cfg.varnames = datavars;
cfg.lonname = lon;
cfg.latname = lat;

if ~isempty(zname)
    cfg.zname = zname;
end

if ~isempty(tim)
    cfg.timename = tim;
end
