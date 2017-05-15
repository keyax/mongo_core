docker run -tiP    \
                -v /dockvols/mongo$1/db:/data/db \
                -v /dockvols/mongo$1/config:/data/configdb \
                -v /dockvols/mongo$1/log:/var/log/mongodb \
                -v /home/yones/github/mongo_core:/home \
                -e PARAMS="--auth --bind_ip_all" --name mongo$1 --rm keyax/mongo_core 

#                -e PARAMS="--auth --bind_ip_all -f /home/mongod.conf"
