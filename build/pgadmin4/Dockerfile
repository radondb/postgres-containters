ARG BASEOS
ARG BASEVER
ARG PG_FULL
ARG PREFIX
ARG BASE_IMAGE_OS
FROM ${PREFIX}/radondb-postgres:${BASEOS}-${PG_FULL}-${BASEVER}
USER 0
# For RHEL8 all arguments used in main code has to be specified after FROM
ARG BASEOS
ARG PACKAGER
ARG PG_MAJOR

# Needed due to lack of environment substitution trick on ADD

LABEL name="pgadmin4" \
        summary="pgAdmin4 GUI utility" \
        description="Provides GUI for the pgAdmin 4 utility." \
        io.k8s.description="pgadmin4 container" \
        io.k8s.display-name="pgAdmin 4" \
        io.openshift.tags="postgresql,postgres,monitoring,pgadmin4,pgadmin,database,radondb"

RUN mkdir -p /opt/radondb/bin /opt/radondb/conf /var/lib/pgadmin /var/log/pgadmin \
        /certs /run/httpd
RUN curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | apt-key add; \
        echo "deb http://mirrors.tuna.tsinghua.edu.cn/postgresql/pgadmin/pgadmin4/apt/bullseye pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list
RUN apt-get update ;apt-get install -y --no-install-recommends \
	pgadmin4 \
        chown -R 2:0 /usr/lib/python3.6/site-packages/pgadmin4-web \
        /var/lib/pgadmin /var/log/pgadmin /certs /etc/httpd /run/httpd \
        /var/log/httpd \
        && chmod -R g=u /usr/lib/python3.6/site-packages/pgadmin4-web \
        /var/lib/pgadmin /var/log/pgadmin /certs /etc/httpd /run/httpd /var/log/httpd \
        && ln -sf /var/lib/pgadmin/config_local.py /usr/lib/python3.6/site-packages/pgadmin4-web/config_local.py \
        && ln -sf /var/lib/pgadmin/pgadmin.conf /etc/httpd/conf.d/pgadmin.conf \
        && alternatives --set python /usr/bin/python3 ; \
	rm -rf /var/cache/apt/*

# Preserving PGVERSION out of paranoia
ENV PGROOT="/usr/pgsql-${PG_MAJOR}" PGVERSION="${PG_MAJOR}"

ADD bin/pgadmin4/ /opt/radondb/bin
ADD bin/common /opt/radondb/bin
ADD conf/pgadmin4/ /opt/radondb/conf

RUN cp /opt/radondb/conf/httpd.conf /etc/httpd/conf/httpd.conf \
        && rm /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/ssl.conf

EXPOSE 5050

# The VOLUME directive must appear after all RUN directives to ensure the proper
# volume permissions are applied when building the image
VOLUME ["/var/lib/pgadmin", "/certs", "/run/httpd"]

# Defines a unique directory name that will be utilized by the nss_wrapper in the UID script
ENV NSS_WRAPPER_SUBDIR="pgadmin"

ENTRYPOINT ["opt/radondb/bin/uid_daemon.sh"]

USER 2

CMD ["/opt/radondb/bin/start-pgadmin4.sh"]
