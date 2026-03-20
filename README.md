# OceanDataTools (ODT)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.19115529.svg)](https://doi.org/10.5281/zenodo.19115529)

**OceanDataTools (ODT)** is a MATLAB toolbox for processing, analyzing, and visualizing oceanographic datasets.

The toolbox provides tools commonly required in physical and biogeochemical oceanography, including:

- geographic computations
- eddy detection and tracking
- ocean front detection
- stratification diagnostics
- mixed layer and pycnocline depth estimation
- vertical structure classification of water-column profiles
- climatology generation
- time-series analysis
- geographic masking
- scientific visualization tools

The toolbox is designed to be lightweight, modular, and compatible with standard MATLAB installations.


# Installation

Clone the repository and add it to your MATLAB path:

git clone https://github.com/edugonrod/OceanDataTools.git
addpath(genpath('OceanDataTools'))


# Toolbox Structure

OceanDataTools/
├── Geo/
├── Graphics/
├── Masks/
├── Ocean/
├── IO/
├── Stats/
├── Utils/
└── colormaps/

Each directory groups functions by purpose.


# Main Capabilities


## Geographic Utilities

Functions for geographic calculations and spatial grid manipulation:

- great-circle distance calculations
- geographic gradients on spherical grids
- shapefile and grid cropping
- geographic kriging interpolation
- coordinate indexing utilities
- astronomical season date estimation
- coastline extraction from GSHHG database
- kilometer-to-degree conversions

Main functions:

geodistance  
geogradient  
cropGrid  
cropShapefile  
krigingGeo  
llToIndex  
geocircle  
gshhgland  
kmToDeg  
seasonDates  


## Oceanographic Analysis

Diagnostics commonly used in physical and biogeochemical oceanography:

- geostrophic velocity
- relative vorticity
- Okubo–Weiss parameter
- Rossby deformation radius
- Brunt–Väisälä frequency
- water-column stratification diagnostics
- mixed layer depth and pycnocline depth estimation
- vertical structure classification relative to MLD and pycnocline
- vertical productivity zone thickness estimation
- marine heatwave detection
- ocean front detection
- eddy detection, masking, tracking, and statistics
- wind stress curl and Ekman pumping
- velocity direction and magnitude diagnostics
- vertical profile fitting and integration

Main functions:

geostrophicVelocity  
relativevorticity  
okuboweiss  
rossbyradius  
stratification  
bruntVaisala  
mldPyc  
profileStructure  
vpzThickness  
fitProfileIntegral  
detectEddies  
maskEddies  
trackEddies  
eddyStats  
detectFronts  
windStressCurl  
extractExtremeUV  
uvToAngle  
uvToDir  
uvToWindDir  
windDirToDeg  
windrose  
tsDiagram  


## Time Series and Statistics

Tools for statistical analysis and climatology generation:

- incremental statistics
- harmonic period detection
- climatology construction and updates
- group-based statistical summaries
- Jenks natural breaks classification

Main functions:

CumStats  
findPeriods  
initClimatology  
updateclimatology  
getClimatology  
initStats  
jenksbreaks  
groupstats  


## Masking and Spatial Selection

Polygon tools for efficient spatial masking and regional analysis:

- raster masks from polygons
- geographic masking utilities
- polygon optimization for fast plotting
- multi-polygon point inclusion tests
- interactive polygon drawing tools

Main functions:

polygons2mask  
optimizePolygons  
inpolygons  
geomask  
drawgeopolygons  


## Visualization Tools

Utilities for scientific visualization:

- colored vector field plotting
- shaded confidence bands
- anomaly highlighting
- wind rose diagrams
- temperature–salinity diagrams
- seasonal background shading
- NaN-aware image visualization
- animated GIF generation
- logarithmic colorbars
- axis styling utilities

Main functions:

quivercol  
plotband  
shadeanomaly  
windrose  
tsDiagram  
fancyframe  
imagescNaN  
gifWriter  
logbar  
minorticks  
pltseasons  
xticklabel2rows  


## Data Input/Output

Basic tools for reading oceanographic datasets:

- NetCDF ocean data readers
- metadata inspection utilities
- NASA Blue Marble imagery reader
- recursive file search tools

Main functions:

readOceanNC  
ncOceanInfo  
readbluemarble  
findFiles  


## Utility Functions

General-purpose utilities supporting numerical workflows:

- area-weighted statistics
- grid-cell area calculations
- date conversion utilities
- indexing helpers
- duplicate detection
- integer and parity tests
- struct unpacking tools
- coordinate rotation
- percentage normalization

Main functions:

areaIntegral  
areaMean  
areaWeights  
consecutive  
dateToYMD  
duplicates  
entire  
extractValues  
fraction  
isentire  
iseven  
isodd  
index2Dto3D  
indexDates  
indexGroups  
minmax  
toPercent  
rotateCoords  
sub2ind3d  
unpackstruct  
ymdToDatetime  


## Colormaps

Oceanographic colormaps for visualization:

algae  
parcmap  
sstcmap  
stdcmap  
wyrcmap  


# Example

[data,lon,lat,time] = readOceanNC('file.nc');

eddies = detectEddies(data,lon,lat);
tracks = trackEddies(eddies);

stats = eddyStats(tracks);


# Author

Eduardo Gonzalez Rodriguez  
CICESE – Centro de Investigación Científica y de Educación Superior de Ensenada 
La Paz, B.C.S., Mexico 
egonzale@cicese.edu.mx


# Citation

If you use this toolbox in scientific work, please cite it using the information provided in the CITATION.cff file or via the Zenodo DOI:

https://doi.org/10.5281/zenodo.19115529
