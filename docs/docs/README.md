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
- **Configuration Files**:
  - `style-generation/config/Colors.pkl`: Color settings
  - `style-generation/config/Sources.pkl`: Data source settings
  - `style-generation/layers/`: Layer definitions
  - `style-generation/style.pkl`: Main style configuration

### Web Map Viewer
- **MapLibre GL JS**: Interactive map rendering
- **GitHub Pages**: Static hosting

### Automation
- **Makefile**: Integrated processes for conversion and style generation
- **Example Targets**:
  - `make build`: Execute PMTiles and style generation
  - `make validate-pkl`: Validate Pkl configuration syntax
  - `make generate-style`: Generate `docs/style.json`

This architecture ensures efficient and consistent execution of processes from data conversion to style generation and hosting.

## GitHub Pages

This directory is published via GitHub Pages, making the PMTiles file accessible on the web.
