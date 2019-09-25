# Spring Boot Application on Docker
```
```
This Docker image is intended for running a Spring Boot application.
>	* Base image oraclelinux:7-slim

FYI https://spring.io/guides/gs/spring-boot-docker/

***

#### Prepare

Docker Image Oracle Linux 7 with Oracle Server JRE:

```console
mkdir ~/oraclejava; cd ~/oraclejava
```
```bash
# Dockerfile
cat <<EOF > Dockerfile
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
EOF
```
```console
# Download Oracle Server JRE (example Java server-jre 1.8.0.172)
wget http://download.oracle.com/otn/java/jdk/8u172-b11/a58eab1ec242421181065cdc37240b08/server-jre-8u172-linux-x64.tar.gz
cp server-jre-8u172-linux-x64.tar.gz ~/oraclejava/
```
```console
# create docker image OracleJava (all required packages installed from oracle repo yum.oracle.com):
docker build -t oracle/serverjre:8 .
```
```console
# result
docker image ls
REPOSITORY TAG IMAGE ID CREATED SIZE
oracle/serverjre 8 fca1db36746d 5 days ago 280MB # base image + server jre
oraclelinux 7-slim 874477adb545 2 weeks ago 118MB # base image
```





# build
docker build --build-arg JAR_FILE="app.jar" --build-arg RUN_FILE="app.sh" --build-arg APPLICATION_YML_FILE="application.yml" --build-arg APPLICATION_DB_YML_FILE="application-db.yml" -f Dockerfile -t springboot-example:latest .

# run
docker run -dit --stop-timeout 30 --name springboot-example.$(date +%F) --network bridge -p 8080:8080/tcp springboot-example:latest

# chek url
http://localhost:8080
