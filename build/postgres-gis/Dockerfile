ARG BASEOS
ARG BASEVER
ARG PG_FULL
ARG PREFIX
ARG DFSET
ARG PACKAGER
ARG PG_MAJOR
ARG POSTGIS_LBL
FROM ${PREFIX}/radondb-postgres:${BASEOS}-${PG_FULL}-${BASEVER} AS extension_builder


LABEL name="postgres-gis" \
	summary="Includes PostGIS extensions on top of radondb-postgres" \
	description="An identical image of radondb-postgres with the extra PostGIS packages added for users that require PostGIS." \
	io.k8s.description="postgres-gis container" \
	io.k8s.display-name="RadonDB PostGIS" \
	io.openshift.tags="postgresql,postgres,postgis,spatial,geospatial,gis,map,database,ha,radondb"

USER 0



ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update ;apt-get install -y --no-install-recommends \
	postgresql-${PG_MAJOR//.}-pgrouting \
	openssh-server \
	postgresql-${PG_MAJOR//.}-pgaudit \
	postgresql-${PG_MAJOR//.}-partman \
	postgresql-${PG_MAJOR//.}-cron \
	pgbackrest \
	psmisc \
	postgresql-${PG_MAJOR//.}-wal2json \
	curl \
	file \
	gettext \
	hostname \
	procps \
	unzip \
	bzip2 \
	lz4 \
	krb5-user \
	patroni \
	postgresql-${PG_MAJOR//.}-postgis-3 \
	postgresql-plperl-${PG_MAJOR//.} \
	postgresql-pltcl-${PG_MAJOR//.} ;\
	sed -i 's/^/#/g' /etc/pgbackrest.conf ;\
	rm -rf /var/cache/apt/*

# open up the postgres port
EXPOSE 5432

EXPOSE 5432

ADD bin/postgres-gis /opt/radondb/bin/postgres

ENTRYPOINT ["/opt/radondb/bin/uid_postgres.sh"]

USER 26

CMD ["/opt/radondb/bin/start.sh"]