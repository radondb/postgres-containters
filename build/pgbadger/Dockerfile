ARG BASEOS
ARG BASEVER
ARG PG_FULL
ARG PREFIX
ARG BASE_IMAGE_OS
FROM golang:1.15.5 as badgerserver-build
WORKDIR /
ADD badger badger
RUN CGO_ENABLED=0 GOOS=linux go build -a -o badgerserver ./badger

FROM ${PREFIX}/radondb-base:${BASE_IMAGE_OS}

# For RHEL8 all arguments used in main code has to be specified after FROM
ARG DFSET
ARG PACKAGER

ARG PG_MAJOR

LABEL name="pgbadger" \
	summary="HTTP wrapper around the PGBadger PostgreSQL utility" \
	description="Has an HTTP REST interface. You GET http://host:10000/api/badgergenerate, and it will generate a pgbadger report on a database container's log files." \
	io.k8s.description="pgBadger" \
	io.k8s.display-name="pgBadger" \
	io.openshift.tags="postgresql,postgres,monitoring,pgbadger,database,radondb"
# Preserving PGVERSION out of paranoia
ENV PGVERSION="${PGMAJOR}"

RUN groupadd -g 26 postgres && useradd -g 26 -u 26 postgres
RUN apt-get update ;apt-get install -y --no-install-recommends \
	pgbadger ;\
	rm -rf /var/cache/apt/*



RUN mkdir -p /opt/radondb/bin /opt/radondb/conf /report

COPY --from=badgerserver-build \
	/badgerserver \
	/opt/radondb/bin
ADD conf/pgbadger /opt/radondb/conf
ADD bin/common /opt/radondb/bin
ADD bin/pgbadger /opt/radondb/bin

RUN chown -R postgres:postgres /opt/radondb /report /bin && \
	chmod -R g=u /opt/radondb /report /bin

# pgbadger port
EXPOSE 10000

# The VOLUME directive must appear after all RUN directives to ensure the proper
# volume permissions are applied when building the image
VOLUME ["/pgdata", "/report"]

# Defines a unique directory name that will be utilized by the nss_wrapper in the UID script
ENV NSS_WRAPPER_SUBDIR="pgbadger"

ENTRYPOINT ["opt/radondb/bin/uid_postgres.sh"]

USER 26

CMD ["/opt/radondb/bin/start-pgbadger.sh"]
