if [ "$1" != "" ]; then
cp ~/.sh/initdb.sh ~/github/mongo_core/configdb
~/.sh/resync.sh
docker exec -ti $1 bash -c "/data/configdb/initdb.sh"
fi
# ~/github/mongo_core/configdb/initdb.sh : /data/configdb/initdb.sh
# [yones@keyax50 .sh [keyaxdo]]$ docker ps -f name=mongo -q
# 06bd980d0745
# if [[ -z $1 ]]; then
if [ "$1" == "" ]; then
(echo -ne 'db.getSiblingDB("admin").runCommand(' ; cat /run/secrets/kyxadmin | jq .dbsroot | tr -d "\n" ; echo ');') | mongo
(echo -ne 'db.getSiblingDB("admin").runCommand(' ; cat /run/secrets/kyxadmin | jq .dbsuser | tr -d "\n" ; echo ');') | mongo
(echo -ne 'db.getSiblingDB("admin").runCommand(' ; cat /run/secrets/kyxadmin | jq .dbsdemo | tr -d "\n" ; echo ');') | mongo
(echo -ne 'db.getSiblingDB("admin").runCommand(' ; cat /run/secrets/kyxadmin | jq .usersadmin | tr -d "\n" ; echo ');') | mongo
(echo -ne 'db.getSiblingDB("admin").runCommand(' ; cat /run/secrets/kyxadmin | jq .dbowner | tr -d "\n" | cat - ; echo ');') | mongo
(echo -ne 'db.getSiblingDB("admin").runCommand(' ; cat /run/secrets/kyxadmin | jq .dbuser | tr -d "\n" ; echo ');') | mongo
fi
# && command not found  ??          ; ok 
# {echo  ;  }  command not found  (echo  ;    )  ok

#[yones@keyax50 ~ [keyaxdo]]$ docker exec  -ti d683512b6c1c  bash -c "/data/configdb/initdb.sh"
#MongoDB shell version v3.4.10
#connecting to: mongodb://127.0.0.1:27017
#MongoDB server version: 3.4.10
#{ "ok" : 1 }
#{ "ok" : 1 }
#{ "ok" : 1 }
#bye
#[yones@keyax50 ~ [keyaxdo]]$ 

