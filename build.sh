#!/bin/sh

# docker build \
#   --build-arg JAR_FILE="app.jar" \
#   --build-arg RUN_FILE="app.sh" \
#   --build-arg APPLICATION_YML_FILE="application.yml" \
#   --build-arg APPLICATION_DB_YML_FILE="application-db.yml" \
#   -f Dockerfile \
#   -t springboot.example \
#   .

if [ "$#" -eq 7 ]; then

    if [ ! -d "$7" ]; then echo 'ROOT_DIR not exist: '$7; exit 1; fi

    cd $7

    if [ ! -f "$1" ]; then echo 'JAR_FILE not exist: '$1; exit 1; fi
    if [ ! -f "$2" ]; then echo 'RUN_FILE not exist: '$2; exit 1; fi
    if [ ! -f "$3" ]; then echo 'APPLICATION_YML_FILE not exist: '$3; exit 1; fi
    if [ ! -f "$4" ]; then echo 'APPLICATION_YML_FILE not exist: '$4; exit 1; fi
    if [ ! -f "$5" ]; then echo 'DOCKERFILE not exist: '$5; exit 1; fi

    docker build \
     --build-arg JAR_FILE="$1" \
     --build-arg RUN_FILE="$2" \
     --build-arg APPLICATION_YML_FILE="$3" \
     --build-arg APPLICATION_DB_YML_FILE="$4" \
     -f "$5" \
     -t "$6" \
     .

else
    echo 'Usage: '$0' [JAR_FILE] [RUN_FILE] [APPLICATION_YML_FILE] [APPLICATION_DB_YML_FILE] [DOCKERFILE] [IMAGENAME] [ROOT_DIR]'
    echo
    echo 'Example:'
    echo '       '$0' "app.jar" "app.sh" "application.yml" "application-db.yml" "Dockerfile" "springboot-example:latest" "/root/docker/springboot-example"'
    exit 0
fi
