function print_help() {
  echo """\
Usage : ./.sh COMMAND [SERVICE]

Available COMMANDS :
start     Start up the ./
stop      Stop the ./ and clean storage dirs
login     Exec bash commands on the specified service

[ Moreover you can use any COMMAND you would use with 'docker-compose' ]
"""
}


if [ $# -gt 0 -a ! -z "$1"  ]; then
  if [ "$1" == "start" ]; then
    docker compose -f ./CLUSTER/hadoop/docker-compose.yaml up -d
  elif [ "$1" == "stop" ]; then
    docker compose -f ./CLUSTER/hadoop/docker-compose.yaml down 
    echo "Cleaning data ... "
    sudo rm -r ./CLUSTER/hdfs-storage-space/*/*
  elif [ "$1" == "login" ]; then
    if [ $# -gt 1 ]; then
      docker compose -f ./CLUSTER/hadoop/docker-compose.yaml exec "$2" bash
    else 
      echo "[ERROR] for 'login' you shoud specify a sercice."
      print_help
    fi
  else
    docker compose -f ./CLUSTER/hadoop/docker-compose.yaml "$@"
  fi 
else
  print_help
fi
