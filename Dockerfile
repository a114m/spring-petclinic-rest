FROM java:8

COPY . /app
WORKDIR /app

RUN DB_TYPE=hsqldb ./mvnw clean package

RUN mkdir /server
WORKDIR /server

RUN curl -LO http://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz
RUN tar -xvzf apache-tomcat-8.5.31.tar.gz
RUN mv apache-tomcat-8.5.31 tomcat
RUN cp /app/target/spring-petclinic-1.5.2.war tomcat/webapps/petclinic.war

ENTRYPOINT ["/server/tomcat/bin/catalina.sh"]
CMD ["run"]

EXPOSE 8080
