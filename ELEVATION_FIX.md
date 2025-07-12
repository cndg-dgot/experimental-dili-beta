# Fix for contourLine Elevation Property Issue

The `contourLine` layer in the source File Geodatabase (`src/S_0604-374.gdb`) had all `Elevation` property values set to 0, but the actual elevation information was encoded in the `Layer` field.

## Issue Analysis

The Layer field contained encoded elevation values:
- `Layer = "21010"` represents 10m elevation
- `Layer = "21020"` represents 20m elevation  
- `Layer = "21030"` represents 30m elevation

## Solution

Modified the `Makefile` conversion process to extract elevation from the `Layer` field and populate the `Elevation` property correctly during the ogr2ogr → GeoJSON conversion:

```bash
# Extract elevation from Layer field using jq
jq -c 'if .properties.Layer == "21010" then .properties.Elevation = 10.0 
       elif .properties.Layer == "21020" then .properties.Elevation = 20.0 
       elif .properties.Layer == "21030" then .properties.Elevation = 30.0 
       else . end'
```

## Results

- **Before**: All 826 contour features had `Elevation = 0`
- **After**: 
  - 162 features with `Elevation = 10.0` (10m contours)
  - 663 features with `Elevation = 20.0` (20m contours)  
  - 1 feature with `Elevation = 30.0` (30m contours)

## Testing

Run `./test_elevation_fix.sh` to validate the fix is working correctly.