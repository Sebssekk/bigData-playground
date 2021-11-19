if [ $# -gt 1 -a ! -z "$1"  ]; then
  if ["$1" == "1"];then
    ....
  elif ["$1" == "2"];then
    ....
  if [ "$2" == "start" ]; then
    docker-compose -f CLUSTER1/hadoop/docker-compose.yaml up -d
  elif [ "$2" == "stop" ]; then
    docker-compose -f CLUSTER1/hadoop/docker-compose.yaml down \
    && rm -r CLUSTER1/hdfs-storage-space/*/*
  elif [ "$2" == "login" ]; then
    docker-compose -f CLUSTER1/hadoop/docker-compose.yaml exec "$2" bash
  else
    docker-compose -f CLUSTER1/hadoop/docker-compose.yaml "$@"
  fi 
fi
