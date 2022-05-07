#!/bin/bash

set -e -u

REGISTRY=docker.io
VERSION=${CCP_IMAGE_TAG-"debian-14.2-3.0.0"}
GIS_VERSION=${CCP_POSTGIS_IMAGE_TAG-"debian-14.2-3.1-3.0.0" }
CCP_IMAGE_PREFIX=${CCP_IMAGE_PREFIX-"zhonghl003"}
IMAGES=(
    # radondb-pgbackrest
    # radondb-pgbouncer
    # radondb-upgrade
    radondb-pgbadger
    # radondb-pgadmin4 
    # radondb-pgpool
)
GISIMAGE=(
    radondb-postgres-gis
)

function echo_green() {
    echo -e "\033[0;32m"
    echo "$1"
    echo -e "\033[0m"
}

for image in "${IMAGES[@]}"; do
    echo_green "=> Pushing ${REGISTRY?}/$CCP_IMAGE_PREFIX/${image?}:${VERSION?}.."
    docker tag $CCP_IMAGE_PREFIX/${image?}:${VERSION?} ${REGISTRY?}/$CCP_IMAGE_PREFIX/${image?}:${VERSION?}
    docker push ${REGISTRY?}/$CCP_IMAGE_PREFIX/${image?}:${VERSION?}
done

for gis_image in "${GISIMAGE[@]}"; do
    echo_green "=> Pushing ${REGISTRY?}/$CCP_IMAGE_PREFIX/${gis_image?}:${GIS_VERSION?}.."
    docker tag $CCP_IMAGE_PREFIX/${gis_image?}:${GIS_VERSION?} ${REGISTRY?}/$CCP_IMAGE_PREFIX/${gis_image?}:${GIS_VERSION?}
    docker push ${REGISTRY?}/$CCP_IMAGE_PREFIX/${gis_image?}:${GIS_VERSION?}
done

echo_green "=> Done!"

exit 0