FROM openjdk:8
ADD target/service--docker.jar service--docker.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "service--docker.jar"]