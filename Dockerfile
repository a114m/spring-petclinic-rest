FROM java:8

COPY . /app
WORKDIR /app

RUN DB_TYPE=hsqldb ./mvnw clean package

RUN mkdir /server
WORKDIR /server

RUN curl -LO http://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.30/bin/apache-tomcat-8.5.30.tar.gz
RUN tar -xvzf apache-tomcat-8.5.30.tar.gz
RUN cp /app/target/spring-petclinic-1.5.2.war apache-tomcat-8.5.30/webapps/petclinic.war

ENTRYPOINT ["/server/apache-tomcat-8.5.30/bin/catalina.sh"]
CMD ["run"]

EXPOSE 8080
