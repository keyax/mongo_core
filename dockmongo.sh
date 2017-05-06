docker run -tiP -v ~/github/mongo_core/data/db:/data/db \
                -v ~/github/mongo_core/data/configdb:/data/configdb \
                --name mongo$1 --rm keyax/mongo_core
