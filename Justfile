raw_folder := "./data/raw"
processed_folder := "./data/processed"

barangay_shp := raw_folder / "shapefiles/barangay/*.shp"
barangay_geojson := processed_folder / "geojson/processed_barangay.geojson"
barangay_pmtiles := processed_folder / "pmtiles/processed_barangay.pmtiles"
barangay_mlt_pmtiles := processed_folder / "mlt/processed_barangay.mlt.pmtiles"

combined_pmtiles := processed_folder / "pmtiles/phl_admin_benguet.pmtiles"
combined_mlt_pmtiles := processed_folder / "mlt/phl_admin_benguet.mlt.pmtiles"

# List project structure
tree *flags:
    tree -I '.git|misc' --dirsfirst {{ flags }} .

prepare-dirs:
    mkdir -p "{{ processed_folder }}/geojson"
    mkdir -p "{{ processed_folder }}/pmtiles"
    mkdir -p "{{ processed_folder }}/mlt"

mapshaper level id_col="": prepare-dirs
    #!/usr/bin/env bash
    set -euo pipefail

    ID="{{ id_col }}"
    if [ -z "$ID" ]; then
        case "{{ level }}" in
            province) ID="adm2_pcode" ;;
            city)     ID="adm3_pcode" ;;
            *)        ID="adm4_pcode" ;;
        esac
    fi

    mapshaper "{{ raw_folder }}/shapefiles/{{ level }}/*.shp" \
        -filter 'adm2_name === "Benguet"' \
        -rename-layers "{{ level }}" \
        -clean \
        -o id-field="$ID" precision=0.000001 "{{ processed_folder }}/geojson/processed_{{ level }}.geojson"

tippecanoe level: prepare-dirs
    tippecanoe -o "{{ processed_folder }}/pmtiles/processed_{{ level }}.pmtiles" \
        -zg \
        -P \
        --simplify-only-low-zooms \
        --detect-shared-borders \
        --drop-densest-as-needed \
        "{{ processed_folder }}/geojson/processed_{{ level }}.geojson"

mlt-convert level: prepare-dirs
    mlt convert \
        "{{ processed_folder }}/pmtiles/processed_{{ level }}.pmtiles" \
        "{{ processed_folder }}/mlt/processed_{{ level }}.mlt.pmtiles"

# Process a custom or specific level from start to finish
process level: (mapshaper level) (tippecanoe level) (mlt-convert level)

# Level shortcuts
barangay: (process "barangay")
city:     (process "city")
province: (process "province")


mapshaper-all: (mapshaper "province") (mapshaper "city") (mapshaper "barangay")
tippecanoe-all: (tippecanoe "province") (tippecanoe "city") (tippecanoe "barangay")
mlt-all: (mlt-convert "province") (mlt-convert "city") (mlt-convert "barangay")

# Process every level individually end-to-end
all-levels: (process "province") (process "city") (process "barangay")

tippecanoe-combined *flags: prepare-dirs
    tippecanoe -o "{{ combined_pmtiles }}" \
        -z 16 \
        -P \
        --simplify-only-low-zooms \
        --detect-shared-borders \
        --drop-densest-as-needed \
        {{ flags }} \
        -L province:"{{ processed_folder }}/geojson/processed_province.geojson" \
        -L city:"{{ processed_folder }}/geojson/processed_city.geojson" \
        -L barangay:"{{ processed_folder }}/geojson/processed_barangay.geojson"

# Convert the combined multi-layer PMTiles to MLT
mlt-combined: prepare-dirs
    mlt convert "{{ combined_pmtiles }}" "{{ combined_mlt_pmtiles }}"

combined: mapshaper-all tippecanoe-combined mlt-combined