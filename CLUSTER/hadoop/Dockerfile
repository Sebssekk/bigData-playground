FROM ubuntu:20.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Rome

RUN apt update -y \
    && apt -y install ssh \
    && apt -y install netcat \
    && apt -y install openjdk-8-jdk \
    && apt-get -y install sudo

FROM base AS hadoop-dev

RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz \
    && tar -xzf hadoop-3.3.3.tar.gz \
    && rm hadoop-3.3.3.tar.gz

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/" >>\
    hadoop-3.3.3/etc/hadoop/hadoop-env.sh

FROM base as hadoop

ARG UID=1000
ARG GID=1000
ARG HADOOP_INSTALL_DIR="/opt/hadoop"

RUN groupadd -g ${GID} hadoop || groupmod -n hadoop $(getent group ${GID} | cut -d: -f1) \
    && useradd --shell /bin/bash -u ${UID} -g ${GID} -m hadoop \
    && echo "hadoop ALL=NOPASSWD: /usr/sbin/service" >> /etc/sudoers \
    #&& echo -e "hadoop\nhadoop" | passwd hadoop \
    && mkdir -p ${HADOOP_INSTALL_DIR} && chown -R hadoop:hadoop ${HADOOP_INSTALL_DIR}

WORKDIR $HADOOP_INSTALL_DIR
COPY --chown=hadoop:hadoop --from=hadoop-dev /hadoop-3.3.3 .

RUN runuser -l hadoop -c "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"

FROM base as hive-dev 

RUN wget https://dlcdn.apache.org/hive/hive-3.1.2/apache-hive-3.1.2-bin.tar.gz \
    && tar -xzf apache-hive-3.1.2-bin.tar.gz \
    && rm apache-hive-3.1.2-bin.tar.gz

FROM hadoop as hive

ARG HIVE_INSTALL_DIR="/opt/hive"

RUN mkdir -p ${HIVE_INSTALL_DIR} && chown -R hadoop:hadoop ${HIVE_INSTALL_DIR}

WORKDIR $HIVE_INSTALL_DIR

COPY --chown=hadoop:hadoop --from=hive-dev /apache-hive-3.1.2-bin .

RUN echo "export HADOOP_HOME=/opt/hadoop" >> $HIVE_INSTALL_DIR/bin/hive-config.sh 

RUN rm lib/guava-* && cp /opt/hadoop/share/hadoop/hdfs/lib/guava* lib/

FROM base as spark-dev

RUN wget https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz \
    && tar -xf spark-3.2.1-bin-hadoop3.2.tgz \
    && rm spark-3.2.1-bin-hadoop3.2.tgz


FROM hive as hive-spark 

RUN apt-get -y install scala \
    && apt-get -y install python3-pip

RUN pip3 install pyspark \
    && pip3 install Jupyter \
    && pip3 install jupyter_contrib_nbextensions \
    && pip3 install jupyter_nbextensions_configurator

RUN jupyter contrib nbextension install --symlink  \
    && jupyter nbextensions_configurator enable 

ARG SPARK_INSTALL_DIR="/opt/spark"

RUN mkdir -p ${SPARK_INSTALL_DIR} && chown -R hadoop:hadoop ${SPARK_INSTALL_DIR}

WORKDIR $SPARK_INSTALL_DIR

COPY --chown=hadoop:hadoop --from=spark-dev /spark-3.2.1-bin-hadoop3.2 .

FROM base as hbase-dev

RUN wget https://dlcdn.apache.org/hbase/2.4.12/hbase-2.4.12-bin.tar.gz \
    && tar -xzf hbase-2.4.12-bin.tar.gz \
    && rm hbase-2.4.12-bin.tar.gz

FROM hive-spark AS hive-spark-hbase

ARG HBASE_INSTALL_DIR="/opt/hbase"

RUN mkdir -p ${HBASE_INSTALL_DIR} && chown -R hadoop:hadoop ${HBASE_INSTALL_DIR}

WORKDIR $HBASE_INSTALL_DIR

COPY --chown=hadoop:hadoop --from=hbase-dev /hbase-2.4.12 .

FROM base AS sqoop-dev

RUN wget https://archive.apache.org/dist/sqoop/1.99.7/sqoop-1.99.7-bin-hadoop200.tar.gz \
    && tar -xzf sqoop-1.99.7-bin-hadoop200.tar.gz \
    && rm sqoop-1.99.7-bin-hadoop200.tar.gz

FROM hive-spark-hbase as hive-spark-hbase-sqoop

ARG SQOOP_INSTALL_DIR="/opt/sqoop"

RUN mkdir -p ${SQOOP_INSTALL_DIR} && chown -R hadoop:hadoop ${SQOOP_INSTALL_DIR}

WORKDIR $SQOOP_INSTALL_DIR

COPY --chown=hadoop:hadoop --from=sqoop-dev /sqoop-1.99.7-bin-hadoop200 .

RUN rm server/lib/guava-* && cp /opt/hadoop/share/hadoop/hdfs/lib/guava* server/lib/
RUN rm server/lib/derby*

FROM base as flume-dev

RUN wget https://dlcdn.apache.org/flume/1.9.0/apache-flume-1.9.0-bin.tar.gz \
    && tar -xzf apache-flume-1.9.0-bin.tar.gz \
    && rm apache-flume-1.9.0-bin.tar.gz

FROM hive-spark-hbase-sqoop as hive-spark-hbase-sqoop-flume

ARG FLUME_INSTALL_DIR="/opt/flume"

RUN mkdir -p ${FLUME_INSTALL_DIR} && chown -R hadoop:hadoop ${FLUME_INSTALL_DIR}

WORKDIR $FLUME_INSTALL_DIR

COPY --chown=hadoop:hadoop --from=flume-dev /apache-flume-1.9.0-bin .

RUN rm lib/guava-* && cp /opt/hadoop/share/hadoop/hdfs/lib/guava* lib/

FROM hive-spark-hbase-sqoop-flume as runtime

USER hadoop

WORKDIR /home/hadoop

ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ 
# --- HADOOP VAR
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop 
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin 
# --- HIVE VAR
ENV HIVE_HOME=/opt/hive
ENV PATH=${PATH}:${HIVE_HOME}/bin
# --- SPARK VAR
ENV SPARK_HOME=/opt/spark
ENV LD_LIBRARY_PATH=${HADOOP_HOME}/lib/native:$LD_LIBRARY_PATH
ENV PATH=${PATH}:$SPARK_HOME/bin
# --- HBASE VAR
ENV HBASE_HOME=/opt/hbase
ENV PATH=$PATH:$HBASE_HOME/bin
# SQOOP
ENV SQOOP_HOME=/opt/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin
# FUME
ENV FLUME_HOME=/opt/flume
ENV PATH=$PATH:$FLUME_HOME/bin

COPY ./hadoop-entrypoint.sh .
ENTRYPOINT ["/bin/bash","./hadoop-entrypoint.sh"]  
