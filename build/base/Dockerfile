
FROM debian:bullseye-slim

# For RHEL8 all arguments used in main code has to be specified after FROM

ARG RELVER=bullseye-slim

LABEL MAINTAINER="RadonDB" \
	vendor="RadonDB" \
	url="https://radondb.com" \
	release="${RELVER}" \
	org.opencontainers.image.vendor="RadonDB" \
	os.version="bullseye"


ENV TZ=Asia/Shanghai

RUN target=$(uname -m);rm /bin/sh && ln -s /bin/bash /bin/sh && ln -s /usr/lib/${target}-linux-gnu /usr/lib64

RUN echo deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye main contrib non-free >/etc/apt/sources.list && \
	echo deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-updates main contrib non-free >>/etc/apt/sources.list && \
	echo deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bullseye-backports main contrib non-free >>/etc/apt/sources.list && \
	echo deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bullseye-security main contrib non-free >>/etc/apt/sources.list && \
	apt-get -y update && \
	apt-get -y install -y --no-install-recommends \
	ca-certificates \
	libnss-wrapper \
	wget \
	gettext \
	gnupg \
	dirmngr \
	curl ;\
	groupmod -g 999 tape ;\
	echo deb [ signed-by=/usr/local/share/keyrings/postgres.gpg.asc ] http://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/apt/ bullseye-pgdg main ${PGVERSION} >/etc/apt/sources.list.d/pgdg.list; \
	key='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8'; \
	export GNUPGHOME="$(mktemp -d)"; \
	mkdir -p /usr/local/share/keyrings/; \
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	gpg --batch --export --armor "$key" > /usr/local/share/keyrings/postgres.gpg.asc; \
	command -v gpgconf > /dev/null && gpgconf --kill all; \
	rm -rf "$GNUPGHOME";\
	apt-get -y update ;\
	rm -rf /var/lib/apt/lists/*; 