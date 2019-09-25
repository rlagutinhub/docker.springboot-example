# Spring Boot Application on Docker
```
```
This image is intended to be used for displaying x11 applications from container in a browser.
>	* Base image oraclelinux:7-slim

FYI https://github.com/rlagutinhub/docker_swarm-mode.novnc-internal-url

***




# build
docker build --build-arg JAR_FILE="app.jar" --build-arg RUN_FILE="app.sh" --build-arg APPLICATION_YML_FILE="application.yml" --build-arg APPLICATION_DB_YML_FILE="application-db.yml" -f Dockerfile -t springboot-example:latest .

# run
docker run -dit --stop-timeout 30 --name springboot-example.$(date +%F) --network bridge -p 8080:8080/tcp springboot-example:latest

# chek url
http://localhost:8080
