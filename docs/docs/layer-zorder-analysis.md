# Layer Z-Order Configuration for S_0604-374 Dataset

## Layer Ordering Principles

Layers are arranged from bottom to top following cartographic conventions:
1. **Background/Base layers** (lowest z-index)
2. **Polygon layers** (area features)
3. **Line layers** (linear features)
4. **Point layers** (highest z-index)

Within each category, layers are ordered by:
- Importance/visibility priority
- Size (larger features below smaller ones)
- Semantic relationships

## Proposed Layer Order (Bottom to Top)

### Background/Base Polygons (z-index: 1-10)
1. **waterSurface** (z-index: 1)
   - Type: Polygon
   - Rationale: Water bodies form the base landscape

2. **vegetation** (z-index: 2)
   - Type: Polygon  
   - Rationale: Natural land cover, base layer for terrain

3. **artificialCoverage** (z-index: 3)
   - Type: Polygon
   - Rationale: Human-made surface coverage

### Infrastructure Polygons (z-index: 11-20)
4. **roadArea** (z-index: 11)
   - Type: Polygon
   - Rationale: Road surfaces, infrastructure base

5. **building** (z-index: 12)
   - Type: Polygon
   - Rationale: Buildings are prominent features, should be visible above base layers

### Linear Features (z-index: 21-40)
6. **contourLine** (z-index: 21)
   - Type: Line
   - Rationale: Topographic reference, should be subtle background

7. **linearWaterFeature** (z-index: 22)
   - Type: Line
   - Rationale: Rivers/streams, natural features

8. **linearTopographicFeature** (z-index: 23)
   - Type: Line
   - Rationale: Natural terrain features

9. **administrativeBoundaryArea** (z-index: 24)
   - Type: Line
   - Rationale: Administrative boundaries, important reference

10. **geographicalNames** (z-index: 25)
    - Type: Line
    - Rationale: Place name indicators

11. **supplementaryRoadLine** (z-index: 26)
    - Type: Line
    - Rationale: Secondary road infrastructure

12. **roadCenterLine** (z-index: 27)
    - Type: Line
    - Rationale: Primary road network, high visibility priority

13. **structures_ln** (z-index: 28)
    - Type: Line
    - Rationale: Built infrastructure lines

### Point Features (z-index: 41-60)
14. **geodeticReference** (z-index: 41)
    - Type: Point
    - Rationale: Survey points, technical reference

15. **pointTopographicFeature** (z-index: 42)
    - Type: Point
    - Rationale: Natural landmark points

16. **roadAreaattribute** (z-index: 43)
    - Type: Point
    - Rationale: Road-related attributes

17. **linearfacility** (z-index: 44)
    - Type: Point
    - Rationale: Linear infrastructure points

18. **structures_pt** (z-index: 45)
    - Type: Point
    - Rationale: Built structures, important landmarks

19. **facility** (z-index: 46)
    - Type: Point
    - Rationale: Public facilities, highest priority points

## Implementation Options

### Option 1: Update style.json with explicit z-index
```json
{
  "layers": [
    {
      "id": "waterSurface",
      "type": "fill",
      "source": "pmtiles-source",
      "source-layer": "waterSurface",
      "metadata": {"z-order": 1},
      "paint": {...}
    },
    // ... continue in order
  ]
}
```

### Option 2: Create separate layer order configuration file
```yaml
# layers-zorder.yaml
layer_order:
  - layer: waterSurface
    z_index: 1
    type: polygon
    category: base
  - layer: vegetation
    z_index: 2
    type: polygon
    category: base
  # ... continue
```

### Option 3: Embed in Makefile as layer processing order
```makefile
LAYER_ORDER = waterSurface vegetation artificialCoverage roadArea building \
              contourLine linearWaterFeature linearTopographicFeature \
              administrativeBoundaryArea geographicalNames supplementaryRoadLine \
              roadCenterLine structures_ln geodeticReference pointTopographicFeature \
              roadAreaattribute linearfacility structures_pt facility
```

### Option 4: JSON configuration for web viewer
```json
{
  "layerOrder": {
    "polygons": [
      "waterSurface",
      "vegetation", 
      "artificialCoverage",
      "roadArea",
      "building"
    ],
    "lines": [
      "contourLine",
      "linearWaterFeature",
      "linearTopographicFeature", 
      "administrativeBoundaryArea",
      "geographicalNames",
      "supplementaryRoadLine",
      "roadCenterLine",
      "structures_ln"
    ],
    "points": [
      "geodeticReference",
      "pointTopographicFeature",
      "roadAreaattribute",
      "linearfacility", 
      "structures_pt",
      "facility"
    ]
  }
}
```

## Recommended Approach

**Primary**: Update `docs/style.json` with layers ordered correctly
**Secondary**: Create `docs/layer-config.json` for programmatic access
**Documentation**: Add z-order table to README.md

This ensures both visual correctness and developer accessibility to layer ordering logic.
