# Style Generation Analysis

## Current Status

`docs/style.json` is currently a **manually created static file** with no automated generation process in the Makefile.

## Proposed Generation Methods

### Option 1: Apple Pkl (Recommended)

Pkl is Apple's configuration language that's perfect for generating structured data like MapLibre GL styles.

#### Advantages:
- Type safety for style definitions
- Modular configuration with imports
- Built-in validation
- Clear separation of data and logic
- Excellent for complex configurations

#### Implementation Structure:
```
style-generation/
├── style.pkl              # Main style configuration
├── layers/
│   ├── base-layers.pkl     # Water, vegetation, etc.
│   ├── infrastructure.pkl  # Buildings, roads
│   ├── linear-features.pkl # Lines and boundaries  
│   └── point-features.pkl  # POI and facilities
├── colors.pkl              # Color palette
├── sources.pkl             # Data sources configuration
└── generate-style.pkl      # Main generation script
```

### Option 2: Node.js/TypeScript

Using Node.js with TypeScript for type-safe style generation.

#### Advantages:
- Familiar JavaScript/TypeScript ecosystem
- Rich npm package ecosystem
- Easy integration with existing tools
- Good IDE support

#### Implementation Structure:
```
style-generation/
├── src/
│   ├── types/
│   │   └── maplibre-style.ts
│   ├── layers/
│   │   ├── base-layers.ts
│   │   ├── infrastructure.ts  
│   │   ├── linear-features.ts
│   │   └── point-features.ts
│   ├── config/
│   │   ├── colors.ts
│   │   ├── sources.ts
│   │   └── layer-order.ts
│   └── generate-style.ts
├── package.json
└── tsconfig.json
```

### Option 3: Deno

Using Deno for a modern runtime without npm dependencies.

#### Advantages:
- Modern JavaScript/TypeScript runtime
- Built-in TypeScript support
- No package.json needed
- Security-first approach
- Standard library

#### Implementation Structure:
```
style-generation/
├── src/
│   ├── types.ts
│   ├── layers/
│   ├── config/
│   └── generate-style.ts
├── deno.json
└── deps.ts
```

## Recommended Approach: Apple Pkl

### Why Pkl?
1. **Perfect fit**: Configuration languages excel at structured data generation
2. **Type safety**: Prevents configuration errors
3. **Modularity**: Easy to organize complex styles
4. **Validation**: Built-in schema validation
5. **Maintainability**: Clear, readable configuration files

### Implementation Plan

#### 1. Create Pkl Configuration Structure
```pkl
// style-generation/style.pkl
amends "pkl:json"

import "layers/base-layers.pkl" as baseLayers
import "layers/infrastructure.pkl" as infraLayers  
import "layers/linear-features.pkl" as linearLayers
import "layers/point-features.pkl" as pointLayers
import "sources.pkl" as sources
import "colors.pkl" as colors

output {
  version = 8
  name = "S_0604-374 Dataset Style"
  sources = sources.all
  layers = new Listing {
    ...baseLayers.all
    ...infraLayers.all
    ...linearLayers.all  
    ...pointLayers.all
  }
}
```

#### 2. Layer Configuration Example
```pkl
// style-generation/layers/base-layers.pkl
import "../colors.pkl" as colors
import "../layer-order.pkl" as order

waterSurface = new {
  id = "waterSurface"
  type = "fill"
  source = "pmtiles-source" 
  ["source-layer"] = "waterSurface"
  paint = new {
    ["fill-color"] = colors.water.primary
    ["fill-opacity"] = 0.8
    ["fill-outline-color"] = colors.water.outline
  }
  metadata = new {
    ["z-order"] = order.waterSurface
  }
}

vegetation = new {
  id = "vegetation"
  type = "fill"
  source = "pmtiles-source"
  ["source-layer"] = "vegetation" 
  paint = new {
    ["fill-color"] = colors.nature.vegetation
    ["fill-opacity"] = 0.7
  }
  metadata = new {
    ["z-order"] = order.vegetation
  }
}

all = new Listing {
  waterSurface
  vegetation
  // ... other base layers
}
```

#### 3. Integration with Makefile
```makefile
# Generate style.json from Pkl configuration
docs/style.json: style-generation/style.pkl style-generation/**/*.pkl docs/layer-config.json
	@echo "Generating style.json from Pkl configuration..."
	@pkl eval style-generation/style.pkl -f json > docs/style.json
	@echo "✓ Generated docs/style.json"

# Add to existing targets
$(OUTPUT_FILE): $(GDB_PATH) $(LAYERS_FILE) docs/style.json | docs
	# ... existing conversion process
```

#### 4. Benefits of This Approach
- **Automated consistency**: Style always matches layer configuration
- **Type safety**: Prevents invalid style definitions
- **Easy maintenance**: Modular, readable configuration
- **Version control friendly**: Clear diffs in configuration changes
- **Integration**: Seamless Makefile integration

## Alternative: Node.js Implementation

If Pkl is not preferred, here's a Node.js approach:

```typescript
// style-generation/src/generate-style.ts
import { writeFileSync } from 'fs';
import { layerConfig } from '../docs/layer-config.json';
import { generateLayers } from './layers';
import { sources } from './config/sources';

const style = {
  version: 8,
  name: "S_0604-374 Dataset Style",
  sources,
  layers: generateLayers(layerConfig)
};

writeFileSync('docs/style.json', JSON.stringify(style, null, 2));
```

## Recommendation

**Use Apple Pkl** for the following reasons:
1. Purpose-built for configuration generation
2. Excellent type safety and validation
3. Clean separation of concerns
4. Easy integration with existing toolchain
5. Future-proof and maintainable

Would you like me to implement the Pkl-based solution?
