# 🗾 S_0604-374 Dataset - PMTiles Converter

A project to convert Esri File Geodatabase to PMTiles format vector tiles and display them interactively on the web using MapLibre GL JS and Apple Pkl for style generation.

## 📖 Overview

This project converts 20 layers contained in `S_0604-374.gdb` (Esri File Geodatabase) to PMTiles format and provides a web map viewer that can be hosted on GitHub Pages. The conversion process is fully automated using a Makefile pipeline, with MapLibre GL styles generated from Apple Pkl configuration files for type-safe and maintainable styling.

## 🗂️ File Structure

```
experimental-dili-beta/
├── README.md                 # This file
├── LICENSE                   # CC0 1.0 Universal License
├── Makefile                  # Conversion & hosting Makefile
├── layers.txt                # Layer list (20 layers)
├── src/
│   └── S_0604-374.gdb/      # Source data (Esri File Geodatabase)
├── style-generation/         # Apple Pkl style configuration
│   ├── config/              # Colors, sources, layer order
│   ├── layers/              # Layer definitions by type
│   └── style.pkl            # Main style assembly
└── docs/                     # GitHub Pages directory
    ├── index.html            # Main map viewer
    ├── style.json            # Generated MapLibre GL style
    ├── a.pmtiles            # Converted PMTiles file
    ├── layer-config.json     # Layer ordering configuration
    └── docs/                 # Technical documentation
        ├── README.md         # Documentation index
        └── layer-zorder-analysis.md  # Layer ordering details
```

## 🚀 Quick Start

### 1. Check Dependencies
```bash
make check-deps
```

### 2. Generate PMTiles File
```bash
make build
```

### 3. Local Preview
```bash
make host
```

Access http://localhost:8080 in your browser

## 🛠️ Technical Stack

### Data Conversion Pipeline
```
Esri GDB → ogr2ogr → GeoJSON Sequence → jq → tippecanoe → PMTiles
```

### Tools Used
- **[GDAL/OGR](https://gdal.org/)** - Geospatial data conversion library
- **[jq](https://stedolan.github.io/jq/)** - JSON processing tool
- **[tippecanoe](https://github.com/felt/tippecanoe)** - Vector tile generation tool
- **[MapLibre GL JS](https://maplibre.org/)** - Web map rendering
- **[PMTiles](https://protomaps.com/docs/pmtiles)** - Cloud-native tile format
- **[Caddy](https://caddyserver.com/)** - Local development server

## 📊 Dataset Details

### Source Data
- **Source**: `src/S_0604-374.gdb`
- **Format**: Esri File Geodatabase
- **Layer Count**: 20
- **PMTiles Size**: 1.2MB
- **Data Types**: Buildings, roads, water bodies, contour lines, facilities, etc.
- **Map Center**: [125.537868, -8.559112] (Dili, Timor-Leste)
- **Zoom Range**: 0-14 (building layer: zoom 14 only)

### Included Layers

| Layer Name | Type | Description | Z-Index | Category | Corrected |
|-----------|------|-------------|---------|----------|-----------|
| waterSurface | Polygon | Water surfaces | 1 | Base | |
| vegetation | Polygon | Vegetation | 2 | Base | ✅ |
| artificialCoverage | Polygon | Artificial coverage | 3 | Base | |
| roadArea | Polygon | Road areas | 11 | Infrastructure | |
| building | Polygon | Buildings | 12 | Infrastructure | Zoom 14 only |
| contourLine | Line | Contour lines | 21 | Reference | |
| linearWaterFeature | Line | Linear water features | 22 | Natural | |
| linearTopographicFeature | Line | Linear topographic features | 23 | Natural | |
| administrativeBoundaryArea | Line | Administrative boundary area | 24 | Reference | ✅ |
| geographicalNames | Line | Geographical names | 25 | Reference | |
| supplementaryRoadLine | Line | Supplementary road lines | 26 | Transportation | |
| roadCenterLine | Line | Road center lines | 27 | Transportation | |
| structures_ln | Line | Structures (lines) | 28 | Infrastructure | |
| geodeticReference | Point | Geodetic reference points | 41 | Reference | |
| pointTopographicFeature | Point | Point topographic features | 42 | Natural | |
| roadAreaattribute | Point | Road area attributes | 43 | Transportation | |
| linearfacility | Point | Linear facilities | 44 | Infrastructure | |
| structures_pt | Point | Structures (points) | 45 | Infrastructure | |
| facility | Point | Facilities | 46 | POI | |

### Layer Ordering Strategy
Layers are arranged following cartographic best practices:
- **Z-Index 1-10**: Base polygon layers (water, vegetation, artificial coverage)
- **Z-Index 11-20**: Infrastructure polygon layers (roads, buildings)  
- **Z-Index 21-40**: Linear features (contours, boundaries, transportation)
- **Z-Index 41-60**: Point features (facilities, landmarks, references)

Configuration details are available in `docs/layer-config.json`.

### Special Layer Configurations
- **Building Layer**: Optimized for zoom level 14 only to improve performance and reduce file size
- **Automatic Spelling Correction**: Layer names with spelling errors are corrected during conversion
- **Zoom-Responsive Styling**: Different styling rules applied based on zoom level

## 🔧 Style Generation with Pkl

This project uses **[Apple Pkl](https://pkl-lang.org/)** for type-safe, maintainable MapLibre GL style generation. The Pkl configuration provides better maintainability and validation compared to manually editing JSON.

### Pkl Configuration Structure
```
style-generation/
├── config/
│   ├── Colors.pkl          # Color palette definitions
│   ├── Sources.pkl         # Data source configurations
│   └── LayerOrder.pkl      # Layer ordering rules
├── layers/
│   ├── BaseLayers.pkl      # Polygon base layers (water, vegetation)
│   ├── InfrastructureLayers.pkl  # Infrastructure polygons (buildings, roads)
│   ├── LinearLayers.pkl    # Line features (roads, boundaries, contours)
│   └── PointLayers.pkl     # Point features (facilities, landmarks)
└── style.pkl              # Main style assembly
```

### Style Generation Commands
```bash
make validate-pkl        # Validate Pkl configuration syntax
make generate-style      # Generate docs/style.json from Pkl
```

The `build` target automatically generates both PMTiles and style.json, ensuring consistency between data and visualization.

### Benefits of Pkl-Based Workflow
- **Type Safety**: Compile-time validation of MapLibre GL style properties
- **Modularity**: Separate concerns (colors, layers, sources) into focused modules
- **Maintainability**: Easy to update colors, layer ordering, or styling rules
- **Documentation**: Self-documenting configuration with built-in comments
- **Validation**: Early error detection before runtime

## 🎯 Makefile Commands

### Basic Commands
```bash
make                 # Execute PMTiles conversion + style generation
make build           # Execute PMTiles conversion + style generation (same as above)
make host            # Host with Caddy server on localhost:8080
make clean           # Clean up generated files
```

### Development & Debug
```bash
make check-deps      # Check dependency tools
make test            # Test conversion with single layer (building)
make info            # Show detailed information for all layers
make list-layers     # List layers contained in GDB
make update-layers   # Update layers.txt to latest state
make validate-pkl    # Validate Pkl configuration syntax
make generate-style  # Generate style.json from Pkl configuration
```

### Others
```bash
make setup-site      # Check website structure
make help            # List available commands
```

## 🔧 Conversion Process Details

### 1. Layer Name Correction
```bash
# Automatically correct spelling errors with functions embedded in Makefile
fix_layer_name() {
    case "$1" in
        "administrtiveBoudaryArea") echo "administrativeBoundaryArea" ;;
        "vegitation") echo "vegetation" ;;
        *) echo "$1" ;;
    esac
}
```

### 2. GeoJSON Text Sequence Conversion
```bash
ogr2ogr -f GeoJSONSeq /dev/stdout "$GDB_PATH" "$layer_name"
```

### 3. Add tippecanoe Properties
```bash
# Regular layers (zoom 0-14)
jq -c --arg layer "$fixed_layer_name" '
    . + {
        "tippecanoe": {
            "layer": $layer,
            "minzoom": 0,
            "maxzoom": 14
        }
    }
'

# Building layer (zoom 14 only for performance)
jq -c --arg layer "$fixed_layer_name" '
    . + {
        "tippecanoe": {
            "layer": $layer,
            "minzoom": 14,
            "maxzoom": 14
        }
    }
'
```

### 4. PMTiles Generation
```bash
tippecanoe \
    --output="docs/a.pmtiles" \
    --maximum-zoom=14 \
    --minimum-zoom=0 \
    --drop-densest-as-needed \
    --extend-zooms-if-still-dropping \
    --force
```

## 🌐 Web Viewer Features

### Main Viewer (`docs/index.html`)
- **Interactive Map**: Using MapLibre GL JS v5.0.0
- **Layer Controls**: Toggle display of buildings, roads, water, contours
- **Navigation**: Zoom, pan, geolocation
- **Responsive Design**: Desktop and mobile compatible
- **PMTiles Protocol**: Direct access to cloud-native tile format
- **Initial View**: Centered on Dili, Timor-Leste at zoom 15.76

### Style Definition (`docs/style.json`)
- **All 20 Layers Supported**: Appropriate visualization for each layer
- **Pkl-Generated**: Type-safe style generation using Apple Pkl
- **Zoom Responsive**: Style adjustments based on zoom level
- **Color Coding**: Intuitive colors based on layer type and usage
- **Performance Optimized**: Building layer only visible at zoom 14

## 📱 GitHub Pages Deployment

### Setup Instructions
1. Go to GitHub repository Settings → Pages
2. Source: Deploy from a branch
3. Branch: main/master, Folder: /docs

### Access URLs
- **Main Map**: `https://username.github.io/repository-name/`
- **Documentation**: `https://username.github.io/repository-name/docs/`
- **PMTiles File**: `https://username.github.io/repository-name/a.pmtiles`

## 🔍 Troubleshooting

### Common Issues

#### 1. Dependency Tools Not Found
```bash
# For macOS
brew install gdal jq tippecanoe caddy

# For Ubuntu
sudo apt-get install gdal-bin jq
# tippecanoe and caddy require separate installation
```

#### 2. PMTiles Conversion Fails
```bash
# Check GDB file
make info

# Test with single layer
make test

# Clean up temporary files
make clean
```

#### 3. Web Viewer Doesn't Display Data
- Check if PMTiles file is generated: `ls -la docs/a.pmtiles`
- Check browser developer tools for errors
- For CORS errors, use `make host` for local server

### Log Checking
```bash
# For detailed logs
make build 2>&1 | tee conversion.log
```

## 🔍 Inspect PMTiles Data

You can inspect the PMTiles data interactively using the following link:

[Inspect PMTiles Data](https://pmtiles.io/#url=https%3A%2F%2Fcndg-dgot.github.io%2Fexperimental-dili-beta%2Fa.pmtiles&map=14.32/-8.56292/125.54093)

## 📄 License

The code in this repository is released under the **CC0 1.0 Universal (CC0 1.0) Public Domain Dedication**. This means you can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)

For the source data (S_0604-374.gdb), please follow the data provider's terms of use as this repository does not claim ownership over the original dataset.

## 🤝 Contributing

Bug reports and feature improvement suggestions are welcome via GitHub Issues.

---

**Created**: July 9, 2025  
**Last Updated**: July 12, 2025