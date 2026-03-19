% OceanDataTools (ODT)
% Oceanographic Data Analysis Toolbox for MATLAB
%
% A collection of tools for processing, analyzing, and visualizing
% oceanographic and geophysical datasets.
%
% Author: Eduardo Gonzalez Rodriguez
% Institution: CICESE
%
% -------------------------------------------------------------------------
% GEO (Geographic utilities)
%   cropGrid             - Crop gridded datasets using coordinate limits
%   cropShapefile        - Crop shapefile structures to geographic limits
%   geocircle            - Generate geographic circle coordinates
%   geodistance          - Great-circle distance and cumulative distance
%   geogradient          - Gradient on geographic grids
%   gshhgland            - Extract land polygons from GSHHG database
%   kmToDeg              - Convert kilometers to degrees
%   krigingGeo           - Geographic kriging interpolation
%   llToIndex            - Convert lat/lon coordinates to grid indices
%   seasonDates          - Compute astronomical season start dates
%
% -------------------------------------------------------------------------
% GRAPHICS (Visualization utilities)
%   fancyframe           - Stylized axes frame
%   gifWriter            - Create animated GIFs from figures
%   imagescnan           - Image display preserving NaN transparency
%   logbar               - Logarithmic colorbar
%   minorticks           - Enable minor ticks on axes
%   plotband             - Plot shaded confidence bands
%   pltseasons           - Plot seasonal background bands
%   quivercol            - Colored vector field plots
%   shadeanomaly         - Highlight anomalies relative to baseline
%   xticklabel2rows      - Two-row tick labels
%
% -------------------------------------------------------------------------
% MASKS (Polygon and geographic masking)
%   drawgeopolygons      - Interactive polygon drawing
%   inpolygons           - Multi-polygon point inclusion test
%   geomask              - Generate geographic masks
%   optimizePolygons     - Optimize polygon structures for fast plotting
%   polygons2mask        - Convert polygons to raster masks
%
% -------------------------------------------------------------------------
% OCEAN (Oceanographic analysis)
%   bruntVaisala         - Brunt–Väisälä frequency
%   detectMHW            - Marine heatwave detection
%   detectEddies         - Eddy detection from SSH fields
%   maskEddies           - Convert eddy contours to masks
%   eddyStats            - Eddy statistics
%   trackEddies          - Eddy trajectory tracking
%   detectFronts         - Ocean front detection
%   geostrophicVelocity  - Geostrophic velocity from SSH
%   okuboweiss           - Okubo–Weiss parameter
%   relativevorticity    - Relative vorticity
%   rossbyradius         - Rossby deformation radius
%   stratification       - Water column stratification
%   tsDiagram            - Temperature–salinity diagram
%   uvToAngle            - Vector direction and magnitude
%   uvToDir              - Convert velocity components to direction
%   uvToWindDir          - Convert velocity components to wind direction
%   uvExtreme            - Extract velocity vectors at extreme speeds
%   fitProfileIntegral   - Fit and integrate vertical profiles
%   vpzThickness         - Vertical productivity zone thickness
%   windStressCurl       - Wind stress curl and Ekman pumping
%   windDirToDeg         - Convert wind direction strings to degrees
%   windrose             - Wind rose diagram
%
% -------------------------------------------------------------------------
% IO (Data input/output utilities)
%   readOceanNC          - Generic NetCDF ocean reader
%   ncOceanInfo          - Inspect NetCDF ocean metadata
%   readbluemarble       - Read NASA Blue Marble imagery
%   findFiles            - Recursive file search utility
%
% -------------------------------------------------------------------------
% STATS (Statistical analysis)
%   CumStats             - Incremental statistics accumulator
%   findPeriods          - Harmonic period detection in time series
%   getClimatology       - Extract climatology fields
%   groupstats           - Group-based statistical summaries
%   initClimatology      - Initialize climatology datasets
%   initStats            - Initialize incremental statistics
%   jenksbreaks          - Jenks natural breaks classification
%   updateclimatology    - Update climatology datasets
%
% -------------------------------------------------------------------------
% UTILS (General utilities)
%   areaIntegral         - Area integral of gridded data
%   areaMean             - Area-weighted mean
%   areaWeights          - Area weights for latitude grids
%   consecutive          - Identify consecutive sequences
%   dateToYMD            - Convert datetime to year/month/day
%   duplicates           - Identify duplicate elements
%   entire               - Extract integer component
%   extractValues        - Extract values from arrays
%   fraction             - Extract fractional component
%   isentire             - Test if values are integers
%   iseven               - Test even numbers
%   isodd                - Test odd numbers
%   index2Dto3D          - Convert 2D indices to 3D indices
%   indexDates           - Find indices corresponding to dates
%   indexGroups          - Find start/end indices of groups
%   minmax               - Minimum and maximum values with indices
%   toPercent            - Normalize data to percentages
%   rotateCoords         - Rotate coordinate systems
%   sub2ind3d            - Linear indexing for 3D arrays
%   unpackstruct         - Unpack struct fields into variables
%   ymdToDatetime        - Convert year/month/day to datetime
%
% -------------------------------------------------------------------------
% COLORMAPS
%   algae                - Algae color map
%   parcmap              - PAR color map
%   sstcmap              - Sea surface temperature colormap
%   stdcmap              - Standard deviation colormap
%   wyrcmap              - White-yellow-red colormap
%
% -------------------------------------------------------------------------
% OceanDataTools
% MATLAB toolbox for oceanographic data analysis
