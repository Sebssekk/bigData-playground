## HDFS
hdfs namenode -format && start-dfs.sh 
## YARN
start-yarn.sh
httpfs.sh start 
## HIVE
hdfs dfs -mkdir -p /tmp 
hdfs dfs -mkdir -p /user/hive/warehouse
schematool -dbType derby -initSchema
nohup hiveserver2 > hiveserver2.log &
hdfs dfs -mkdir -p /hbase
hdfs dfs -mkdir -p /flume01 
## SPARK
hdfs dfs -mkdir -p /spark-logs
${SPARK_HOME}/sbin/start-history-server.sh
${SPARK_HOME}/sbin/start-all.sh
nohup jupyter notebook \
--ip 0.0.0.0 \
--port 8888 \
--no-browser \
--NotebookApp.token='' \
--NotebookApp.password='' \
> jupyter-error.log &
## HBASE
start-hbase.sh
hbase-daemon.sh start thrift -p 9090 --infoport 9095 
hbase-daemon.sh start rest -p 8090 --infoport 8095 
## SQOOP
sqoop2-server start
tail -f /dev/null
