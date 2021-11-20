FROM ubuntu:20.04

RUN apt update && apt -y install wget

RUN wget https://archive.apache.org/dist/sqoop/1.99.7/sqoop-1.99.7-bin-hadoop200.tar.gz \
&& tar -xzf sqoop-1.99.7-bin-hadoop200.tar.gz \
&& rm sqoop-1.99.7-bin-hadoop200.tar.gz

ARG SQOOP_INSTALL_DIR="/opt/sqoop"

RUN mkdir -p ${SQOOP_INSTALL_DIR} && chown -R hadoop:hadoop ${SQOOP_INSTALL_DIR}

WORKDIR $SQOOP_INSTALL_DIR

COPY --chown=hadoop:hadoop --from=sqoop-dev /sqoop-1.99.7-bin-hadoop200 .//hadoop/
