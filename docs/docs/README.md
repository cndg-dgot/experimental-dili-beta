# 📚 S_0604-374 Dataset Documentation

This directory contains technical documentation related to the PMTiles conversion and web map visualization of the S_0604-374 dataset.

## 📄 Documentation Index

### Technical Specifications
- **[layer-zorder-analysis.md](layer-zorder-analysis.md)** - Layer Z-order configuration and cartographic principles

### Apple Pkl Configuration
This project uses **Apple Pkl** for generating MapLibre GL styles:
- Type safety and compile-time validation
- Modular design for improved maintainability
- Automated build process

For details, refer to the "Style Generation with Pkl" section in [../README.md](../README.md).

## 📊 PMTiles Data

- `../a.pmtiles` - Unified PMTiles file containing all layers
- `../style.json` - MapLibre GL style generated from Pkl
- `../layer-config.json` - Layer ordering configuration

## 📂 Source Data

- **Source**: `../../src/S_0604-374.gdb`
- **Number of Layers**: 19
- **Format**: Esri File Geodatabase

## 🏗️ Architecture Overview

This project adopts the following architecture:

### Data Conversion Pipeline
- **Esri File Geodatabase** → **PMTiles**: Conversion to GeoJSON using GDAL/OGR, followed by PMTiles generation with Tippecanoe
- **Layer Name Correction**: Automated functions in the Makefile to fix English spelling errors
- **Layer Ordering**: Based on cartographic principles recorded in `docs/layer-config.json`

### Style Generation
- **Apple Pkl**: Type-safe and modular MapLibre GL style generation
- **Modern MapLibre GL**: All styles use `interpolate` expressions instead of deprecated `stops`
- **Japan GSI Standards**: Contour lines use official Japan Geospatial Survey Institute colors (#8B5A2B)
- **Optimized Layer Ordering**: Cartographically correct stacking (e.g., contours between base and buildings)
- **Configuration Files**:
  - `style-generation/config/Colors.pkl`: Color settings
  - `style-generation/config/Sources.pkl`: Data source settings
  - `style-generation/layers/`: Layer definitions
  - `style-generation/style.pkl`: Main style configuration

### Web Map Viewer
- **MapLibre GL JS**: Interactive map rendering with feature inspection popups
- **Modern Styling**: Uses `interpolate` expressions for future-proof MapLibre GL compatibility
- **Interactive Features**: 
  - Hover/click popups for feature attribute inspection
  - Layer visibility toggles
  - Navigation and geolocation controls
- **GitHub Pages**: Static hosting

### Automation
- **Makefile**: Integrated processes for conversion and style generation
- **Example Targets**:
  - `make build`: Execute PMTiles and style generation
  - `make validate-pkl`: Validate Pkl configuration syntax
  - `make generate-style`: Generate `docs/style.json`

This architecture ensures efficient and consistent execution of processes from data conversion to style generation and hosting.

## Project Context: FOSS4G 2025 Talk

This documentation is part of the project presented at [FOSS4G 2025](https://talks.osgeo.org/foss4g-2025/talk/review/CFU7FEHYF9B3Y7HYTTJK7BQTXLYJPHW9):

**Cloud-native spatial data ecosystem in the rise of the National Geospatial Data Center of Timor-Leste**

The National Center for Geospatial Data (CNDG) of Timor-Leste is developing a cloud-native spatial data ecosystem. This project showcases the use of go-pmtiles, Tippecanoe, MapLibre GL JS, Martin, and GitHub Pages to improve geospatial data accessibility and usability in Timor-Leste, with support from JICA's geospatial unit.

The initiative aims to provide scalable, real-time access to geospatial information for government and development partners, supporting sustainable development, urban planning, disaster response, and more.

For details, see the [FOSS4G 2025 talk abstract](https://talks.osgeo.org/foss4g-2025/talk/review/CFU7FEHYF9B3Y7HYTTJK7BQTXLYJPHW9).

---

## GitHub Pages

This directory is published via GitHub Pages, making the PMTiles file accessible on the web.
