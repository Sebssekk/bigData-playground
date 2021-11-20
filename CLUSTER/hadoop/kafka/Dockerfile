FROM ubuntu:20.04

RUN apt update \
&& apt -y install openjdk-11-jdk \
&& apt install -y wget

ARG UID=1000
ARG GID=1000
ARG KAFKA_INSTALL_DIR="/opt/kafka"
RUN groupadd -g ${GID} kafka || groupmod -n kafka $(getent group ${GID} | cut -d: -f1) \
&& useradd --shell /bin/bash -u ${UID} -g ${GID} -m kafka \
#&& echo "hadoop ALL=NOPASSWD: /usr/sbin/service" >> /etc/sudoers \
#&& echo -e "hadoop\nhadoop" | passwd hadoop \
&& mkdir -p ${KAFKA_INSTALL_DIR} && chown -R kafka:kafka ${KAFKA_INSTALL_DIR}

WORKDIR $KAFKA_INSTALL_DIR
RUN wget https://dlcdn.apache.org/kafka/3.0.0/kafka_2.13-3.0.0.tgz \
&& tar -xzf kafka_2.13-3.0.0.tgz --strip 1 \
&& rm kafka_2.13-3.0.0.tgz

USER kafka

ENTRYPOINT ["bin/kafka-server-start.sh" , "config/server.properties"]
