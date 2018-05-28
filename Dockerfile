FROM keyax/ubuntu_core

LABEL maintainer="yones.lebady AT gmail.com" \
      keyax.os="ubuntu core" \
      keyax.os.ver="18.04 bionic" \
      keyax.vendor="Keyax" \
      keyax.app="Mongodb 3.6.4" \
      keyax.app.ver="18.05"

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb

# grab gosu for easy step-down from root (https://github.com/tianon/gosu/releases)
ENV GOSU_VERSION 1.10
# grab "js-yaml" for parsing mongod's YAML config files (https://github.com/nodeca/js-yaml/releases)
ENV JSYAML_VERSION 3.10.0

RUN set -ex; \
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg2 --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
  #   gpg2 --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $key; || \
  #   gpg2 --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
  #   gpg2 --keyserver pgp.mit.edu --recv-keys "$key" || \
  #   gpg2 --keyserver keyserver.pgp.com --recv-keys "$key"; \
  #   gpg2 --armor --export $key | apt-key add - ; \


	gpg2 --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true;
#	\
#	wget -O /js-yaml.js "https://github.com/nodeca/js-yaml/raw/${JSYAML_VERSION}/dist/js-yaml.js";
# TODO some sort of download verification here
#	apt-get purge -y --auto-remove wget

# RUN mkdir /docker-entrypoint-initdb.d

ENV GPG_KEYS \
# pub   rsa4096 2018-04-18 [SC] [expires: 2023-04-17]
#       9DA3 1620 334B D75D 9DCB  49F3 6881 8C72 E525 29D4
# uid           [ unknown] MongoDB 4.0 Release Signing Key <packaging@mongodb.com>
	9DA31620334BD75D9DCB49F368818C72E52529D4 \
# https://docs.mongodb.com/manual/tutorial/verify-mongodb-packages/#download-then-import-the-key-file
# gpg keys for release 3.6 & 3.5.x dev listed at building docker
  2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
# version 3.4.4 keys https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# 0C49F3730359A14518585931BC711F9BA15703C6

SHELL ["/bin/bash", "-c"]
RUN set -ex; \
#	export GNUPGHOME="$(mktemp -d)"; \
	for key in $GPG_KEYS; do \
		gpg2 --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
    gpg2 --armor --export $key | apt-key add - ; \
	done; \
#	gpg2 --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mongodb.gpg; \
#	rm -r "$GNUPGHOME"; \
#	apt-key list

#    do \
#   gpg2 --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $key; || \
#   gpg2 --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
#   gpg2 --keyserver pgp.mit.edu --recv-keys "$key" || \
#   gpg2 --keyserver keyserver.pgp.com --recv-keys "$key"; \
#   gpg2 --armor --export $key | apt-key add - ; \
#   done;

ENV MONGO_MAJOR 3.6
ENV MONGO_VERSION 3.6.5
# ENV MONGO_MAJOR 4.0
# ENV MONGO_VERSION 4.0.0
ENV MONGO_PACKAGE mongodb-org

# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/$MONGO_MAJOR multiverse" | tee /etc/apt/sources.list.d/mongodb-org-$MONGO_MAJOR.list

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
## from mongodb repo production version 3.6
##--allow-unauthenticated\
### mongodb-org \
		${MONGO_PACKAGE}=$MONGO_VERSION \
		${MONGO_PACKAGE}-server=$MONGO_VERSION \
		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
  && rm -rf /var/lib/apt/lists/* \
# && rm -rf /var/lib/mongodb
	&& mv /etc/mongod.conf /etc/mongod.conf.orig
##  && mkdir -p /data/db /data/configdb \
##	&& chown -R mongodb:mongodb /data/db /data/configdb

# VOLUME /data/db /data/configdb

ADD /configdb /data/configdb

# RedHat Warning: Transparent hugepages looks to be active and should not be.
# Please look at http://bit.ly/1ZAcLjD as for how to PERMANENTLY alter this setting.
## RUN echo 'always madvise [never]' > /sys/kernel/mm/transparent_hugepage/enabled
####RUN echo 'kernel/mm/transparent_hugepage/enabled = never' > /etc/sysfs.conf
##RUN echo never > /sys/kernel/mm/transparent_hugepage/defrag
# Ubuntu disabling transparent hugepages
#      RUN echo /sys/kernel/mm/transparent_hugepage/enabled = never > /etc/sysfs.conf
# Warning: Swappiness is not set to 0.
# Please look at http://bit.ly/1k2CtNn as for how to PERMANENTLY alter this setting.
# RUN sysctl vm.swappiness=0 && echo "vm.swappiness = 0" >> /etc/sysctl.conf
# Ubuntu set swappiness 0
####RUN echo 'vm.swappiness = 0' >> /etc/sysctl.conf

USER mongodb
VOLUME /data/configdb /data/db /data/logdb
EXPOSE 10017

# COPY entrypoint.sh /home/entrypoint.sh
# RUN chmod +x /home/entrypoint.sh
ENV PARAMS "--auth --bind_ip_all -f /data/configdb/mongod.conf"
ENTRYPOINT ["/data/configdb/entrypoint.sh", "mongod $PARAMS" ]
# CMD [ "$AUTH" ]
# Contact GitHub API Training Shop Blog About
