FROM keyax/ubuntu_core

LABEL maintainer="yones.lebady AT gmail.com" \
      keyax.os="ubuntu core" \
      keyax.os.ver="16.04 xenial" \
      keyax.vendor="Keyax" \
      keyax.app="Mongodb 3.5.6 dev" \
      keyax.app.ver="2.2"


# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb
USER mongodb
### RUN apt-get update \
### 	&& apt-get install -y \
  ## --no-install-recommends \
###  sysfsutils \
##    		numactl \
###  && apt-get autoremove && apt-get clean \
# delete all the apt list files since they're big and get stale quickly
###  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# this forces "apt-get update" in dependent images, which is also good

# grab gosu for easy step-down from root
# ENV GOSU_VERSION 1.7
# RUN set -x \
#	# && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
#	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
#	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
#	&& export GNUPGHOME="$(mktemp -d)" \
#	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
#	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
#	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
#	&& chmod +x /usr/local/bin/gosu \
#	&& gosu nobody true \
#	&& apt-get purge -y --auto-remove ca-certificates wget

## ENV GPG_KEYS \
# pub   4096R/A15703C6 2016-01-11 [expires: 2018-01-10]
#       Key fingerprint = 0C49 F373 0359 A145 1858  5931 BC71 1F9B A157 03C6
# uid                  MongoDB 3.4 Release Signing Key <packaging@mongodb.com>
## 	0C49F3730359A14518585931BC711F9BA15703C6
## RUN set -ex; \
##	export GNUPGHOME="$(mktemp -d)"; \
##	for key in $GPG_KEYS; do \
##		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
##	done; \
##	gpg --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mongodb.gpg; \
##	rm -r "$GNUPGHOME"; \
##	apt-key list


# gpg keys for release 3.5.x dev & 3.6 listed at building docker
RUN ["/bin/bash", "-c",  "set -ex; \
            gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58712A2291FA4AD5; \
            gpg --armor --export 58712A2291FA4AD5 | apt-key add -"]
# to enable key & remove gpg: WARNING: options in `/root/.gnupg/gpg.conf' are not yet active during this run

# version 3.4.4 keys https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6

ENV MONGO_MAJOR 3.5
ENV MONGO_VERSION 3.5.6
ENV MONGO_PACKAGE mongodb-org

# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# RUN echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/$MONGO_MAJOR multiverse" > /etc/apt/sources.list.d/mongodb-org-$MONGO_MAJOR.list
# RUN echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
## from mongodb repo dev version 3.5.6
##      --allow-unauthenticated\
      mongodb-org-unstable \
## from mongodb repo production version 3.4.4
##    mongodb-org \
# from ubuntu repo version 3.2.11
##    mongodb \
#		${MONGO_PACKAGE}=$MONGO_VERSION \
#		${MONGO_PACKAGE}-server=$MONGO_VERSION \
#		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
#		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
#		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
  && rm -rf /var/lib/apt/lists/* \
# && rm -rf /var/lib/mongodb
#	&& mv /etc/mongod.conf /etc/mongod.conf.orig
###  && echo kernel/mm/transparent_hugepage/enabled = never >> /etc/sysfs.conf \
  && mkdir -p /data/db /data/configdb \
	&& chown -R mongodb:mongodb /data/db /data/configdb
VOLUME /data/db /data/configdb /home

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

EXPOSE 27017

# COPY entrypoint.sh /home/entrypoint.sh
# RUN chmod +x /home/entrypoint.sh
ENV AUTH --auth
RUN echo "auth: $AUTH"
ENTRYPOINT ["/home/entrypoint.sh", "mongod --auth --bind_ip_all" ]
# CMD [ "$AUTH" ]
# Contact GitHub API Training Shop Blog About
