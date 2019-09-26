# Spring Boot Application on Docker
```
```
This Docker image is intended for running a Spring Boot application.
>	* Base image oracle/serverjre:8

FYI https://spring.io/guides/gs/spring-boot-docker/

***

## Prepare

### Docker Image Oracle Linux 7 with Oracle Server JRE:

This repository contains a sample Docker configuration to facilitate installation and environment setup for DevOps users. This project includes a Dockerfile for Server JRE 8 based on Oracle Linux with include <b>package rootfiles</b> (for enable root bash profile).
>	* Base image oraclelinux:7-slim

FYI: https://github.com/rlagutinhub/docker.oraclejava

```bash
mkdir ~/oraclejava; cd ~/oraclejava

# Dockerfile
cat > Dockerfile
FROM oraclelinux:7-slim

MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>

ENV JAVA_PKG=server-jre-8u*-linux-x64.tar.gz \
    JAVA_HOME=/usr/java/default

ADD $JAVA_PKG /usr/java/

RUN yum -y install rootfiles tar gzip && \
    rm -rf /var/cache/yum/* && \
    export JAVA_DIR=$(ls -1 -d /usr/java/*) && \
    ln -s $JAVA_DIR /usr/java/latest && \
    ln -s $JAVA_DIR /usr/java/default && \
    alternatives --install /usr/bin/java java $JAVA_DIR/bin/java 20000 && \
    alternatives --install /usr/bin/javac javac $JAVA_DIR/bin/javac 20000 && \
    alternatives --install /usr/bin/jar jar $JAVA_DIR/bin/jar 20000

# Download serverJRE 8.x to root of oraclejava repo
wget http://download.oracle.com/otn/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/server-jre-8u172-linux-x64.tar.gz
cp server-jre-8u172-linux-x64.tar.gz ~/oraclejava/

# Build docker image
docker build -t oracle/serverjre:8 .

# Result
docker image ls
REPOSITORY TAG IMAGE ID CREATED SIZE
oracle/serverjre 8 fca1db36746d 5 days ago 280MB # base image + server jre
oraclelinux 7-slim 874477adb545 2 weeks ago 118MB # base image
```

### Building an example Application with Spring Boot:

FYI https://spring.io/guides/gs/spring-boot/

```bash
# Required packages
apt install openjdk-11-jre openjdk-11-jdk-headless
apt install maven

# Build application
git clone https://github.com/spring-guides/gs-spring-boot.git
cd into gs-spring-boot/initial
mvn package

# Copy jar to root of this repo
cp target/gs-spring-boot-0.1.0.jar ~/docker.springboot-example/app.jar
```

### Building Docker image:

```bash
./build.sh \
 "app.jar" \
 "app.sh" \
 "application.yml" \
 "application-db.yml" \
 "Dockerfile" \
 "springboot.example:latest" \
 "/root/docker/docker.springboot-example"
```

or

```bash
docker build \
  --build-arg JAR_FILE="app.jar" \
  --build-arg RUN_FILE="app.sh" \
  --build-arg APPLICATION_YML_FILE="application.yml" \
  --build-arg APPLICATION_DB_YML_FILE="application-db.yml" \
  -f Dockerfile \
  -t springboot.example \
  .
```

***

## Properties

```vim application.yml```
* application properties file
```console
service:
  version: "@service.version@"
  exampleWsdl: http://example-srv.example.com/ws/example.wsdl
management:
  security:
    enabled: false
spring:
  jpa:
    properties:
      hibernate:
        dialect: org.hibernate.dialect.Oracle10gDialect
        format_sql: true
  jackson:
    serialization:
      indent_output: true
  profiles:
    include: db
scheduled:
  extData: 0 0 1 0/2 * ?
  transferToExample: 0 0 1 2 3 ?
```
```vim application-db.yml```
* db connection properties file
```console
db:
  example-db:
    driver-class-name: oracle.jdbc.OracleDriver
    jdbcUrl: jdbc:oracle:thin:@db.example.com:1521:example
    username: username
    password: passw0rd
    testOnBorrow: true
    validationQuery: SELECT 'Hellow World!' from EXAMPLE
    continue-on-error: true
```
```java options```
* java parameters are set through system environment variable
* default ```-Djava.security.egd=file:/dev/./urandom -Xms256m -Xmx2048m```


***

## Usage

### Standalone
Run with custom settings:
```bash
docker run -dit \
 --stop-timeout 60 \
 -e "JAVA_OPTIONS=-Djava.security.egd=file:/dev/./urandom -Xms1024m -Xmx1024m" \
 --name springboot-example \
 --network=bridge \
 -p 8080:8080/tcp \
 springboot-example:latest
```
### Docker Swarm Mode
Run with custom settings: ```docker stack deploy --compose-file docker-compose.yml springboot-example```
```console
version: '3.7'
services:
  app:
    image: springboot-example:latest
    volumes:
      - logs:/logs
    networks:
       - proxy
    environment:
      - "JAVA_OPTIONS=-Djava.security.egd=file:/dev/./urandom -Xms1024m -Xmx1024m"
    configs:
       - source: ws_example_application.yml
         target: /application.yml
       - source: ws_example_application-db.yml
         target: /application-db.yml
    stop_grace_period: 1m
    deploy:
      # mode: global
      replicas: 1
      update_config:
        parallelism: 2
        delay: 10s
        order: start-first
      restart_policy:
        condition: on-failure
        delay: 10s
        max_attempts: 1
        window: 120s
      labels:
        # https://docs.traefik.io/configuration/backends/docker/#on-containers
        - "traefik.enable=true"
        - "traefik.port=8080"
        # - "traefik.weight=10"
        - "traefik.frontend.rule=Host:ws-example.example.com,ws-example.test.example.com"
        # - "traefik.frontend.rule=Host:ws-example.example.com,ws-example.test.example.com;PathPrefixStrip:/app"
        - "traefik.frontend.entryPoints=http"
        # - "traefik.frontend.entryPoints=http,https"
        # - "traefik.frontend.headers.SSLRedirect=true"
        # - "traefik.frontend.auth.basic.users=root:$$apr1$$mLRjS/wr$$QqrALWNDgW9alDmnb9DeK1"
        # - "traefik.backend.loadbalancer.stickiness=true"
        - "traefik.backend.loadbalancer.method=wrr"
      # placement:
        # constraints:
          # - node.role == manager
          # - node.role == worker
          # - node.labels.springboot == true
networks:
  proxy:
    external: true
configs:
  ws_example_application.yml:
    external: true
  ws_example_application-db.yml:
    external: true
volumes:
  logs:
    external: true

```

***

## Result

Open a browser and see the demo at `http://<server>`

![alt text](https://raw.githubusercontent.com/rlagutinhub/docker.springboot-example/master/screen1.png)
![alt text](https://raw.githubusercontent.com/rlagutinhub/docker.springboot-example/master/screen2.png)

https://raw.githubusercontent.com/rlagutinhub/docker.springboot-example/master/example.run.log

## On DockerHub / GitHub
___
* DockerHub [rlagutinhub/docker.springboot-example](https://hub.docker.com/r/rlagutinhub/docker.springboot-example)
* GitHub [rlagutinhub/docker.springboot-example](https://github.com/rlagutinhub/docker.springboot-example)
