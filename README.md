[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.xxxxx.svg)](https://doi.org/10.5281/zenodo.xxxxx)

# OceanDataTools (ODT)

**OceanDataTools** is a MATLAB toolbox for processing, analyzing, and visualizing oceanographic datasets.

The toolbox provides tools commonly required in oceanographic data analysis, including:

* geographic computations
* eddy detection and tracking
* ocean front detection
* stratification diagnostics
* climatology generation
* time series analysis
* geographic masking
* visualization tools for ocean data

The toolbox is designed to be lightweight, modular, and compatible with standard MATLAB installations.

---

# Installation

Clone the repository and add it to your MATLAB path:

```matlab
git clone https://github.com/yourusername/ODT.git
addpath(genpath('ODT'))
```

---

# Toolbox Structure

```
ODT/
├── Geo/
├── Graphics/
├── Masks/
├── Ocean/
├── IO/
├── Stats/
├── Utils/
└── colormaps/
```

Each directory groups functions by purpose.

---

# Main Capabilities

## Geographic Utilities

* Great-circle distances
* Geographic gradients
* Grid cropping
* Shapefile cropping
* Geographic interpolation
* Coordinate indexing

**Main functions:**

* geodistance
* geogradient
* cropGrid
* cropShapefile
* krigingGeo
* llToIndex

---

## Oceanographic Analysis

The toolbox includes several diagnostics used in physical oceanography:

* geostrophic velocity
* relative vorticity
* Okubo–Weiss parameter
* Rossby deformation radius
* stratification diagnostics
* Brunt–Väisälä frequency

Additional tools:

* marine heatwave detection
* ocean front detection
* eddy detection and tracking
* profile fitting and vertical integration

**Main functions:**

* geostrophicVelocity
* relativevorticity
* okuboweiss
* rossbyradius
* detectEddies
* trackEddies
* eddyStats
* detectFronts

---

## Time Series and Statistics

Tools for statistical analysis and climatology generation:

* incremental statistics
* harmonic period detection
* climatology construction
* Jenks natural breaks classification

**Main functions:**

* CumStats
* findPeriods
* initClimatology
* updateclimatology
* jenksbreaks
* groupstats

---

## Masking and Spatial Selection

Polygon tools allow efficient spatial masking and regional analysis.

**Main functions:**

* polygons2mask
* optimizePolygons
* inpolygons
* geomask

---

## Visualization Tools

Utilities for scientific visualization:

* vector field plotting
* shaded bands
* anomaly shading
* wind roses
* T–S diagrams
* figure styling

**Main functions:**

* quivercol
* plotband
* shadeanomaly
* windrose
* tsDiagram
* fancyframe

---

## Data Input/Output

Basic tools for reading oceanographic datasets.

**Main functions:**

* readOceanNC
* ncOceanInfo
* readbluemarble
* findFiles

---

## Colormaps

Oceanographic colormaps for visualization.

* algae
* parcmap
* sstcmap
* stdcmap
* wyrcmap

---

# Example

```matlab
[data,lon,lat,time] = readOceanNC('file.nc');

eddies = detectEddies(data,lon,lat);
tracks = trackEddies(eddies);

stats = eddyStats(tracks);
```

---

# Author

Eduardo Gonzalez Rodriguez
CICESE – Centro de Investigación Científica y de Educación Superior de Ensenada

---

# Citation

If you use this toolbox in scientific work, please cite it using the information provided in the **CITATION.cff** file.
