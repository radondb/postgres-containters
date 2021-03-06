ARG BASEOS
ARG BASEVER
ARG PG_FULL
ARG PREFIX
ARG DFSET
ARG PACKAGER
ARG PG_MAJOR
ARG POSTGIS_LBL
FROM ${PREFIX}/radondb-pg-base:${BASEOS}-${PG_FULL}-${BASEVER} AS extension_builder


RUN apt-get -y update && \
	apt-get -y install cmake libkrb5-dev ca-certificates wget curl build-essential libicu-dev postgresql-server-dev-${PG_MAJOR//.} -y --no-install-recommends && \
	rm -rf /var/cache/apt/* /tmp/*
# build pgnodemx
RUN rm -rf /external_extensions && mkdir -p /external_extensions/pgnodemx && cd /external_extensions/pgnodemx;\
	set -eux;curl -SL https://github.com/crunchydata/pgnodemx/$(curl -s https://github.com/crunchydata/pgnodemx/releases | \
	grep -m1 -Eo "archive/refs/tags/[^/]+\.tar\.gz") | tar --strip-components=1 -xzv -C /external_extensions/pgnodemx ; \
	make USE_PGXS=1 && make USE_PGXS=1 install; 

#build timescaledb
RUN mkdir -p /external_extensions/timescaledb && cd /external_extensions/timescaledb;\
	if [ "${PG_MAJOR//.}" -gt "11" ]; then \
	set -eux;curl -SL https://github.com/timescale/timescaledb/$(curl -s https://github.com/timescale/timescaledb/releases | \
	grep -m1 -Eo "archive/refs/tags/[^/]+\.tar\.gz") | tar --strip-components=1 -xzv -C /external_extensions/timescaledb ;\
	elif [ "${PG_MAJOR//.}" -eq "11" ]; then \
	curl -SL https://github.com/timescale/timescaledb/archive/refs/tags/2.3.0.tar.gz| tar --strip-components=1 -xzv -C /external_extensions/timescaledb ;\
	fi; \
	./bootstrap -DREGRESS_CHECKS=OFF && cd build && make && make install ;
FROM ${PREFIX}/radondb-pg-base:${BASEOS}-${PG_FULL}-${BASEVER}
COPY --from=extension_builder /etc/apt/sources.list /etc/apt/sources.list
COPY --from=extension_builder /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/pgdg.list
COPY --from=extension_builder /usr/lib/postgresql/${PG_MAJOR}/lib /usr/lib/postgresql/${PG_MAJOR}/lib
COPY --from=extension_builder /usr/share/postgresql/${PG_MAJOR}/extension /usr/share/postgresql/${PG_MAJOR}/extension
# For RHEL8 all arguments used in main code has to be specified after FROM


LABEL name="postgres" \
	summary="PostgreSQL ${PG_FULL}" \
	description="Allows multiple deployment methods for PostgreSQL, including basic single primary, streaming replication with synchronous and asynchronous replicas. Includes utilities and tools for Auditing (pgaudit), statement tracking,  Backup/Restore (pgbackrest, pg_basebackup, pgdump, pgrestore) and Benchmarking (pgbench)." \
	io.k8s.description="RadonDB PostgreSQL is the trusted open source distribution of PostgreSQL" \
	io.k8s.display-name="RadonDB PostgreSQL" \
	io.openshift.tags="postgresql,postgres,sql,nosql,database,radondb" \
	postgresql.version.major="${PG_MAJOR}" \
	postgresql.version="${PG_FULL}"

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
	postgresql-${PG_MAJOR//.}-plr \
	postgresql-pltcl-${PG_MAJOR//.} && \
	sed -i 's/^/#/g' /etc/pgbackrest.conf && \
	rm -rf /var/cache/apt/*

# open up the postgres port
# set up radondb directory
RUN mkdir -p /opt/radondb/bin /opt/radondb/conf /pgdata /pgwal /pgconf /recover /backrestrepo /var/lib/pgsql

RUN chown -R postgres:postgres /opt/radondb /var/lib/pgsql \
		/pgdata /pgwal /pgconf /recover /backrestrepo &&  \
	chmod -R g=u /opt/radondb /var/lib/pgsql \
		/pgdata /pgwal /pgconf /recover /backrestrepo

# open up the postgres port
EXPOSE 5432

ADD bin/postgres_common /opt/radondb/bin
ADD bin/common /opt/radondb/bin
ADD conf/postgres_common /opt/radondb/conf
ADD tools/pgmonitor/postgres_exporter/common /opt/radondb/bin/modules/pgexporter
ADD tools/pgmonitor/postgres_exporter/linux /opt/radondb/bin/modules/pgexporter

RUN mkdir /.ssh && chown 26:0 /.ssh && chmod g+rwx /.ssh && rm -f /run/nologin

# add volumes to allow override of pg_hba.conf and postgresql.conf
# add volumes to offer a restore feature
# add volumes to allow storage of postgres WAL segment files
# add volumes to locate WAL files to recover with
# add volumes for pgbackrest to write to
# The VOLUME directive must appear after all RUN directives to ensure the proper
# volume permissions are applied when building the image
VOLUME ["/sshd", "/pgconf", "/pgdata", "/pgwal", "/recover", "/backrestrepo"]

# Defines a unique directory name that will be utilized by the nss_wrapper in the UID script
ENV NSS_WRAPPER_SUBDIR="postgres"

ENTRYPOINT ["/opt/radondb/bin/uid_postgres.sh"]

USER 26

CMD ["/opt/radondb/bin/start.sh"]
