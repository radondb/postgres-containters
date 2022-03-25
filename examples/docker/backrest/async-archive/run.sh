#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

$DIR/cleanup.sh

docker run \
    --publish 5432:5432 \
    --volume br-aa-pgdata:/pgdata \
    --volume br-aa-backups:/backrestrepo \
    --env PG_MODE=primary \
    --env PG_USER=testuser \
    --env PG_PASSWORD=password \
    --env PG_DATABASE=userdb \
    --env PG_PRIMARY_USER=primaryuser \
    --env PG_PRIMARY_PORT=5432 \
    --env PG_PRIMARY_PASSWORD=password \
    --env PG_ROOT_PASSWORD=password \
    --env PGHOST=/tmp \
    --env PGBACKREST=true \
    --env PGBACKREST_ARCHIVE_ASYNC=y \
    --name=backrest-async-archive \
    --hostname=backrest-async-archive \
    --detach ${CCP_IMAGE_PREFIX?}/radondb-postgres:${CCP_IMAGE_TAG?}
