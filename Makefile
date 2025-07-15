# Makefile for PMTiles conversion and hosting

# Variables
GDB_PATH = src/S_0604-374.gdb
OUTPUT_FILE = docs/a.pmtiles
LAYERS_FILE = layers.txt
TEMP_DIR = /tmp/pmtiles_convert
PORT = 8080

# Shell functions (embedded scripts)
define fix_layer_name
fix_layer_name() { \
	case "$$1" in \
		"administrtiveBoudaryArea") echo "administrativeBoundaryArea" ;; \
		"vegitation") echo "vegetation" ;; \
		*) echo "$$1" ;; \
	esac; \
}
endef

define convert_layer_to_geojson
convert_layer_to_geojson() { \
	local layer_name=$$1; \
	local fixed_layer_name=$$(fix_layer_name "$$layer_name"); \
	echo "Processing layer: $$layer_name -> $$fixed_layer_name"; \
	ogr2ogr -f GeoJSONSeq /dev/stdout "$(GDB_PATH)" "$$layer_name" \
	| jq -c 'del(.properties.Shape_Length, .properties.Shape_Area)' \
	| jq -c --arg layer "$$fixed_layer_name" '. + {"tippecanoe": {"layer": $$layer, "minzoom": 0, "maxzoom": 14}}' \
	>> "$(TEMP_DIR)/all_layers.geojsonl"; \
}
endef

# Default target
.PHONY: all
all: $(OUTPUT_FILE) docs/style.json

# Alias for main target
.PHONY: build
build: all

# Create docs directory
docs:
	mkdir -p docs

# Convert File Geodatabase to PMTiles
$(OUTPUT_FILE): $(GDB_PATH) $(LAYERS_FILE) | docs
	@echo "Converting File Geodatabase to PMTiles..."
	@mkdir -p $(TEMP_DIR)
	@rm -f $(TEMP_DIR)/all_layers.geojsonl
	@echo "Converting all layers to combined GeoJSON sequence..."
	@while IFS= read -r layer_name; do \
		[ -z "$$layer_name" ] && continue; \
		if [ "$$layer_name" = "administrtiveBoudaryArea" ]; then \
			fixed_layer_name="administrativeBoundaryArea"; \
		elif [ "$$layer_name" = "vegitation" ]; then \
			fixed_layer_name="vegetation"; \
		else \
			fixed_layer_name="$$layer_name"; \
		fi; \
		if [ "$$layer_name" = "building" ]; then \
			echo "Processing layer: $$layer_name -> $$fixed_layer_name (Zoom 14 only)"; \
			ogr2ogr -f GeoJSONSeq /dev/stdout "$(GDB_PATH)" "$$layer_name" \
			| jq -c 'del(.properties.Shape_Length, .properties.Shape_Area)' \
			| jq -c --arg layer "$$fixed_layer_name" '. + {"tippecanoe": {"layer": $$layer, "minzoom": 14, "maxzoom": 14}}' \
			>> "$(TEMP_DIR)/all_layers.geojsonl"; \
		else \
			echo "Processing layer: $$layer_name -> $$fixed_layer_name"; \
			ogr2ogr -f GeoJSONSeq /dev/stdout "$(GDB_PATH)" "$$layer_name" \
			| jq -c 'del(.properties.Shape_Length, .properties.Shape_Area)' \
			| jq -c --arg layer "$$fixed_layer_name" '. + {"tippecanoe": {"layer": $$layer, "minzoom": 0, "maxzoom": 14}}' \
			>> "$(TEMP_DIR)/all_layers.geojsonl"; \
		fi; \
	done < $(LAYERS_FILE)
	@echo "Creating combined PMTiles file..."
	@tippecanoe \
		--output="$(OUTPUT_FILE)" \
		--maximum-zoom=14 \
		--minimum-zoom=0 \
		--drop-densest-as-needed \
		--extend-zooms-if-still-dropping \
		--force \
		"$(TEMP_DIR)/all_layers.geojsonl"
	@if [ $$? -eq 0 ]; then \
		echo "✓ Successfully created: $(OUTPUT_FILE)"; \
		echo "File size: $$(du -h "$(OUTPUT_FILE)" | cut -f1)"; \
	else \
		echo "✗ Failed to create PMTiles file"; \
		exit 1; \
	fi
	@rm -rf $(TEMP_DIR)
	@echo "Conversion completed! PMTiles file is ready for GitHub Pages."

# Build target (alias for all)
.PHONY: build
build: $(OUTPUT_FILE)

# Host the docs folder using Caddy
.PHONY: host
host: $(OUTPUT_FILE)
	@echo "Starting Caddy server on port $(PORT)..."
	@echo "Serving docs/ directory at http://localhost:$(PORT)"
	@echo "PMTiles file available at: http://localhost:$(PORT)/a.pmtiles"
	@echo "Press Ctrl+C to stop the server"
	caddy file-server --root docs --listen :$(PORT)

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning generated files..."
	rm -rf $(OUTPUT_FILE)
	rm -rf $(TEMP_DIR)

# Show layer information
.PHONY: info
info:
	@echo "File Geodatabase layers:"
	@echo "======================="
	@while IFS= read -r layer_name; do \
		[ -z "$$layer_name" ] && continue; \
		echo "=== Layer: $$layer_name ==="; \
		ogrinfo -so "$(GDB_PATH)" "$$layer_name" || echo "Error: Layer $$layer_name not found"; \
		echo ""; \
	done < $(LAYERS_FILE)

# Test conversion with a single layer
.PHONY: test
test: | docs
	@echo "Testing conversion with building layer..."
	@$(fix_layer_name)
	@mkdir -p output
	@convert_single_layer() { \
		local layer_name=$$1; \
		local fixed_layer_name=$$(fix_layer_name "$$layer_name"); \
		echo "Processing layer: $$layer_name -> $$fixed_layer_name"; \
		ogr2ogr -f GeoJSONSeq /dev/stdout "$(GDB_PATH)" "$$layer_name" \
		| jq -c 'del(.properties.Shape_Length, .properties.Shape_Area)' \
		| jq -c --arg layer "$$fixed_layer_name" '. + {"tippecanoe": {"layer": $$layer, "minzoom": 0, "maxzoom": 14}}' \
		| tippecanoe \
			--output="output/$${fixed_layer_name}.pmtiles" \
			--layer="$$fixed_layer_name" \
			--maximum-zoom=14 \
			--minimum-zoom=0 \
			--drop-densest-as-needed \
			--extend-zooms-if-still-dropping \
			--force; \
		echo "Completed: $$layer_name -> $${fixed_layer_name}.pmtiles"; \
	}; \
	convert_single_layer "building"

# Check if required tools are installed
.PHONY: check-deps
check-deps:
	@echo "Checking dependencies..."
	@command -v ogr2ogr >/dev/null 2>&1 || { echo "Error: ogr2ogr not found. Please install GDAL."; exit 1; }
	@command -v jq >/dev/null 2>&1 || { echo "Error: jq not found. Please install jq."; exit 1; }
	@command -v tippecanoe >/dev/null 2>&1 || { echo "Error: tippecanoe not found. Please install tippecanoe."; exit 1; }
	@command -v caddy >/dev/null 2>&1 || { echo "Error: caddy not found. Please install Caddy."; exit 1; }
	@echo "All dependencies are installed!"

# List all layers in the GDB
.PHONY: list-layers
list-layers:
	@echo "Listing layers in $(GDB_PATH)..."
	@ogrinfo $(GDB_PATH) | grep "Layer:" | sed 's/.*Layer: \([^ ]*\).*/\1/' | sort

# Update layers.txt file
.PHONY: update-layers
update-layers:
	@echo "Updating layers.txt..."
	@ogrinfo $(GDB_PATH) | grep "Layer:" | sed 's/.*Layer: \([^ ]*\).*/\1/' | sort > $(LAYERS_FILE)
	@echo "Updated $(LAYERS_FILE) with $$(wc -l < $(LAYERS_FILE)) layers"

# Check layer ordering in style.json
.PHONY: check-layer-order
check-layer-order:
	echo "Checking layer order in style.json..."
	echo "Expected render order:"; \
	jq -r '.renderOrder[]' docs/layer-config.json || echo "layer-config.json not found or invalid"; \
	echo "Current style.json order:"; \
	jq -r '.layers[] | .id' docs/style.json || echo "style.json not found or invalid"

# Validate layer configuration
.PHONY: validate-layers
validate-layers: check-layer-order
	@echo "Validating layer configuration..."
	@echo "Checking if all layers from GDB are configured..."
	@while IFS= read -r layer_name; do \
		[ -z "$$layer_name" ] && continue; \
		if jq -e --arg layer "$$layer_name" '.layerOrder.renderOrder[] | select(. == $$layer)' docs/layer-config.json >/dev/null 2>&1; then \
			echo "✓ $$layer_name configured"; \
		else \
			echo "✗ $$layer_name missing from configuration"; \
		fi; \
	done < $(LAYERS_FILE)

# Generate style.json from Pkl configuration
.PHONY: generate-style
generate-style: docs/style.json

docs/style.json: style-generation/style.pkl style-generation/config/*.pkl style-generation/layers/*.pkl | docs
	@echo "🎨 Generating style.json from Pkl configuration..."
	cd style-generation && pkl eval style.pkl -o ../docs/style.json
	@echo "✓ Generated docs/style.json"

# Validate Pkl configuration
.PHONY: validate-pkl
validate-pkl:
	@echo "🔍 Validating Pkl configuration..."
	cd style-generation && pkl eval style.pkl > /dev/null
	@echo "✓ Pkl configuration is valid"

# Setup complete website structure
.PHONY: setup-site
setup-site: $(OUTPUT_FILE)
	@echo "Website structure is already set up!"
	@echo "Files available:"
	@echo "  - docs/index.html (main viewer)"
	@echo "  - docs/style.json (MapLibre style)"
	@echo "  - docs/a.pmtiles (PMTiles data)"
	@echo "  - docs/docs/ (documentation)"

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all               - Convert GDB to PMTiles (default)"
	@echo "  build             - Same as 'all'"
	@echo "  host              - Start Caddy server to host docs/ folder"
	@echo "  clean             - Remove generated files"
	@echo "  info              - Show information about GDB layers"
	@echo "  test              - Test conversion with single layer"
	@echo "  check-deps        - Check if required tools are installed"
	@echo "  list-layers       - List all layers in the GDB"
	@echo "  update-layers     - Update layers.txt file from GDB"
	@echo "  check-layer-order - Check layer ordering in style.json"
	@echo "  validate-layers   - Validate layer configuration"
	@echo "  generate-style    - Generate style.json from Pkl configuration"
	@echo "  validate-pkl      - Validate Pkl configuration syntax"
	@echo "  setup-site        - Show website structure information"
	@echo "  help              - Show this help message"
