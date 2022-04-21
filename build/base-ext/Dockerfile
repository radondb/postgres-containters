ARG BASEOS
ARG BASEVER
ARG PG_FULL
ARG PREFIX
FROM ${PREFIX}/radondb-base:${BASEOS}-${PG_FULL}-${BASEVER}

# For RHEL8 all arguments used in main code has to be specified after FROM
ARG BASEOS
ARG PACKAGER

LABEL name="radondb-base-ext" \
	summary="Includes base extensions required to load in additional PostgreSQL extensions." \
	description="Includes base extensions required to load in additional PostgreSQL extensions."


RUN if [ "$BASEOS" = "centos8" ] ; then \
	apt-get -y update && \
	apt-get -y install -y --no-install-recommends \
	perl ;\
	rm -rf /var/lib/apt/lists/*;  
fi