ARG BASEOS
ARG BASEVER
ARG PG_FULL
ARG PREFIX
ARG BASE_IMAGE_OS

# For RHEL8 all arguments used in main code has to be specified after FROM
ARG DFSET
ARG PACKAGER
ARG PG_MAJOR
ARG UPGRADE_PG_VERSIONS



# Add in the repository files with the correct PostgreSQL versions

# install the highest version of PostgreSQL + pgAudit and its dependencies as
# well as unzip

FROM ${PREFIX}/radondb-postgres:${BASEOS}-${PG_FULL}-${BASEVER} AS extension_builder

USER 0
RUN apt-get -y update && \
	apt-get -y install cmake libkrb5-dev ca-certificates wget curl build-essential libicu-dev postgresql-server-dev-${PG_MAJOR//.} -y --no-install-recommends && \
	rm -rf /var/cache/apt/* /tmp/*
# build pgnodemx
RUN rm -rf /external_extensions && mkdir -p /external_extensions/pgnodemx && cd /external_extensions/pgnodemx;\
	set -eux;curl -SL https://github.com/crunchydata/pgnodemx/$(curl -s https://github.com/crunchydata/pgnodemx/releases | \
	grep -m1 -Eo "archive/refs/tags/[^/]+\.tar\.gz") | tar --strip-components=1 -xzv -C /external_extensions/pgnodemx ; \
	make USE_PGXS=1 && make USE_PGXS=1 install; 

FROM ${PREFIX}/radondb-postgres:${BASEOS}-${PG_FULL}-${BASEVER}
USER 0
LABEL name="upgrade" \
	summary="Provides a pg_upgrade capability that performs a major PostgreSQL upgrade." \
	description="Provides a means to perform a major PostgreSQL upgrade from an earlier version to PostgreSQL ${PG_MAJOR}." \
	io.k8s.description="postgres upgrade container" \
	io.k8s.display-name="RadonDB PostgreSQL upgrade container" \
	io.openshift.tags="postgresql,postgres,upgrade,database,radondb"
COPY --from=extension_builder /etc/apt/sources.list /etc/apt/sources.list
COPY --from=extension_builder /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/pgdg.list
COPY --from=extension_builder /usr/lib/postgresql/${PG_MAJOR}/lib /usr/lib/postgresql/${PG_MAJOR}/lib
COPY --from=extension_builder /usr/share/postgresql/${PG_MAJOR}/extension /usr/share/postgresql/${PG_MAJOR}/extension
# For RHEL8 all arguments used in main code has to be specified after FROM

# add in all of the earlier version of PostgreSQL. It will install the version
# above, but the dependencies are handled
RUN apt-get update ;for pg_version in $UPGRADE_PG_VERSIONS; do \
	apt-get install -y --no-install-recommends \
	postgresql-${pg_version} \
	postgresql-${pg_version}-postgis-3 \
	postgresql-${pg_version}-pgaudit ;\
	done && rm -rf /var/cache/apt/* ;

RUN mkdir -p /opt/radondb/bin /pgolddata /pgnewdata /opt/radondb/conf
ADD bin/upgrade/ /opt/radondb/bin
ADD bin/common /opt/radondb/bin
ADD conf/upgrade/ /opt/radondb/conf

RUN chown -R postgres:postgres /opt/radondb /pgolddata /pgnewdata && \
	chmod -R g=u /opt/radondb /pgolddata /pgnewdata

# The VOLUME directive must appear after all RUN directives to ensure the proper
# volume permissions are applied when building the image
VOLUME /pgolddata /pgnewdata

# Defines a unique directory name that will be utilized by the nss_wrapper in the UID script
ENV NSS_WRAPPER_SUBDIR="upgrade"

ENTRYPOINT ["opt/radondb/bin/uid_postgres.sh"]

USER 26

CMD ["/opt/radondb/bin/start.sh"]
