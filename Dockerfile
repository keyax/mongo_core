FROM keyax/ubuntu_core

LABEL maintainer "yones.lebady AT gmail.com"
# LABEL net.keyax.os= "ubuntu core" \
#      net.keyax.os.ver= "16.10 yaketty" \
#      net.keyax.vendor= "Keyax" \
#      net.keyax.app= "Mongodb" \
#      net.keyay.app.ver= "2.1"

# FROM debian:jessie

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mongodb && useradd -r -g mongodb mongodb

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		numactl \
	&& rm -rf /var/lib/apt/lists/*

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

ENV GPG_KEYS \
# pub   4096R/A15703C6 2016-01-11 [expires: 2018-01-10]
#       Key fingerprint = 0C49 F373 0359 A145 1858  5931 BC71 1F9B A157 03C6
# uid                  MongoDB 3.4 Release Signing Key <packaging@mongodb.com>
	0C49F3730359A14518585931BC711F9BA15703C6
RUN set -ex; \
	export GNUPGHOME="$(mktemp -d)"; \
	for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done; \
	gpg --export $GPG_KEYS > /etc/apt/trusted.gpg.d/mongodb.gpg; \
	rm -r "$GNUPGHOME"; \
	apt-key list

# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6

ENV MONGO_MAJOR 3.4
ENV MONGO_VERSION 3.4.1
ENV MONGO_PACKAGE mongodb-org

# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
# RUN echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/$MONGO_MAJOR multiverse" > /etc/apt/sources.list.d/mongodb-org-$MONGO_MAJOR.list
# RUN echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

RUN set -x \
	&& apt-get update \
	&& apt-get install -y mongodb-org \
#		${MONGO_PACKAGE}=$MONGO_VERSION \
#		${MONGO_PACKAGE}-server=$MONGO_VERSION \
#		${MONGO_PACKAGE}-shell=$MONGO_VERSION \
#		${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
#		${MONGO_PACKAGE}-tools=$MONGO_VERSION \
  && rm -rf /var/lib/apt/lists/* \
# && rm -rf /var/lib/mongodb
#	&& mv /etc/mongod.conf /etc/mongod.conf.orig

  && mkdir -p /data/db /data/configdb \
	&& chown -R mongodb:mongodb /data/db /data/configdb
VOLUME /data/db /data/configdb

EXPOSE 27017

COPY docker-entrypoint.sh /home/entrypoint.sh
RUN chmod +x /home/entrypoint.sh

ENTRYPOINT ["/home/entrypoint.sh", "mongod", "&"]
CMD ["/bin/bash"]
# Contact GitHub API Training Shop Blog About
