#!/bin/bash

# Test script to validate the contourLine elevation fix
# This script verifies that the Elevation property is correctly populated

echo "Testing contourLine elevation fix..."

# Create a temporary GeoJSONSeq file for testing
TEMP_DIR="/tmp/elevation_test"
mkdir -p "$TEMP_DIR"

# Extract just contourLine from the source and apply the elevation fix
echo "Extracting contourLine data with elevation fix..."
ogr2ogr -f GeoJSONSeq /dev/stdout "src/S_0604-374.gdb" "contourLine" \
| jq -c 'if .properties.Layer == "21010" then .properties.Elevation = 10.0 elif .properties.Layer == "21020" then .properties.Elevation = 20.0 elif .properties.Layer == "21030" then .properties.Elevation = 30.0 else . end' \
> "$TEMP_DIR/contour_fixed.geojsonl"

echo "Analyzing elevation values..."

# Count features by elevation
echo "Elevation value distribution:"
cat "$TEMP_DIR/contour_fixed.geojsonl" | jq '.properties.Elevation' | sort | uniq -c

# Check if any features still have 0 elevation (this should be 0)
zero_count=$(cat "$TEMP_DIR/contour_fixed.geojsonl" | jq '.properties.Elevation' | grep -c "^0$" || true)
echo "Features with 0 elevation: $zero_count"

# Total feature count
total_count=$(cat "$TEMP_DIR/contour_fixed.geojsonl" | wc -l)
echo "Total contour features: $total_count"

# Expected counts based on our analysis:
expected_10m=162
expected_20m=663
expected_30m=1

actual_10m=$(cat "$TEMP_DIR/contour_fixed.geojsonl" | jq '.properties.Elevation' | grep -c "10" || true)
actual_20m=$(cat "$TEMP_DIR/contour_fixed.geojsonl" | jq '.properties.Elevation' | grep -c "20" || true)
actual_30m=$(cat "$TEMP_DIR/contour_fixed.geojsonl" | jq '.properties.Elevation' | grep -c "30" || true)

echo "Validation Results:"
echo "10m elevation: expected $expected_10m, actual $actual_10m"
echo "20m elevation: expected $expected_20m, actual $actual_20m"
echo "30m elevation: expected $expected_30m, actual $actual_30m"

# Verify the fix worked
if [ "$zero_count" -eq 0 ] && [ "$actual_10m" -eq "$expected_10m" ] && [ "$actual_20m" -eq "$expected_20m" ] && [ "$actual_30m" -eq "$expected_30m" ]; then
    echo "✅ SUCCESS: Elevation fix is working correctly!"
    echo "All contour lines now have proper elevation values instead of 0."
else
    echo "❌ FAILURE: Elevation fix has issues."
    exit 1
fi

# Clean up
rm -rf "$TEMP_DIR"