# Philippine Administrative Boundaries — Vector Tile Server

A [Martin](https://github.com/maplibre/martin) tile server that serves [PMTiles](https://docs.protomaps.com/pmtiles/) vector tiles of Philippine administrative boundaries, from country level down to barangay level.

## Administrative Levels

| Level | Source Name | ID Field | Description |
|-------|------------|----------|-------------|
| 0 | `country` | — | National boundary |
| 1 | `regions` | `ADM1_PCODE` | Regions |
| 2 | `provinces` | `ADM2_PCODE` | Provinces |
| 3 | `cities-municipalities` | `ADM3_PCODE` | Cities & Municipalities |
| 4 | `barangays` | `ADM4_PCODE` | Barangays |

## Option 1: Use the Hosted Server (No Setup)

Point your MapLibre GL JS sources directly to the hosted tile server at **`ph-boundaries.jmrecondo.com`**:

```ts
const TILE_SERVER = "https://ph-boundaries.jmrecondo.com";

map.addSource("ph-barangays", {
    type: "vector",
    url: `${TILE_SERVER}/barangays`,
    promoteId: "ADM4_PCODE",
});

map.addSource("ph-cities", {
    type: "vector",
    url: `${TILE_SERVER}/cities-municipalities`,
    promoteId: "ADM3_PCODE",
});

map.addSource("ph-provinces", {
    type: "vector",
    url: `${TILE_SERVER}/provinces`,
    promoteId: "ADM2_PCODE",
});

map.addSource("ph-regions", {
    type: "vector",
    url: `${TILE_SERVER}/regions`,
    promoteId: "ADM1_PCODE",
});

map.addSource("ph-country", {
    type: "vector",
    url: `${TILE_SERVER}/country`,
});
```

### Tile URLs

| Level | TileJSON | XYZ Tiles |
|-------|------------|----------|
| Barangays | `https://ph-boundaries.jmrecondo.com/barangays` | `.../barangays/{z}/{x}/{y}` |
| Cities & Municipalities | `https://ph-boundaries.jmrecondo.com/cities-municipalities` | `.../cities-municipalities/{z}/{x}/{y}` |
| Provinces | `https://ph-boundaries.jmrecondo.com/provinces` | `.../provinces/{z}/{x}/{y}` |
| Regions | `https://ph-boundaries.jmrecondo.com/regions` | `.../regions/{z}/{x}/{y}` |
| Country | `https://ph-boundaries.jmrecondo.com/country` | `.../country/{z}/{x}/{y}` |

## Option 2: Self-Host with Docker

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose

### Quick Start

```bash
git clone https://github.com/jmrec/ph-administrative-boundaries.git

cd ph-administrative-boundaries

docker compose up -d
```

The server will be available at `http://localhost:3080`.

To check available sources:
```bash
curl http://localhost:3080/catalog
```

### Configuration
Tile sources are defined in [config/config.yml](/config/config.yml). To use your own local PMTiles files instead of the remote CDN, update the paths:

```yml
pmtiles:
  sources:
    barangays:
      path: /data/ph_barangays.pmtiles
      type: mvt
```

Then place your `.pmtiles` files in the `data/` directory.

> [!IMPORTANT]
CORS — If your map is served from a different domain, browsers will block tile requests unless CORS is configured. Update [config.yml](/config/config.yml) to specify origins:

```yml
cors:
  # Sets `Access-Control-Max-Age` Header. [default: null]
  # null means not setting the header for preflight requests
  max_age: 3600
  # Sets the `Access-Control-Allow-Origin` header [default: *]
  # '*' will use the requests `ORIGIN` header
  origin:
    - https://example.org
```

## Data Source
Philippine administrative boundaries from the [Humanitarian Data Exchange (HDX)](https://data.humdata.org/) —
[COD Administrative Boundaries for the Philippines](https://data.humdata.org/dataset/cod-ab-phl), contributed by [OCHA Philippines](https://data.humdata.org/organization/ocha-philippines).

## License
This project is licensed under the MIT License — see [LICENSE](/LICENSE) for details.