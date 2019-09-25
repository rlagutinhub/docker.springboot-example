FROM oracle/serverjre:8
MAINTAINER Lagutin R.A. <rlagutin@mta4.ru>
ARG JAR_FILE
ARG RUN_FILE
ARG APPLICATION_YML_FILE
ARG APPLICATION_DB_YML_FILE
ADD ${JAR_FILE} app.jar
ADD ${RUN_FILE} app.sh
ADD ${APPLICATION_YML_FILE} application.yml
ADD ${APPLICATION_DB_YML_FILE} application-db.yml
VOLUME /logs
CMD ["/app.sh"]
