# Springboot-Docker

Spring Boot with Docker
This guide walks you through the process of building a Docker image for running a Spring Boot application.

What you’ll build
Docker is a Linux container management toolkit with a "social" aspect, allowing users to publish container images and consume those published by others. A Docker image is a recipe for running a containerized process, and in this guide we will build one for a simple Spring boot application.

What you’ll need
About 15 minutes

A favorite text editor or IDE

JDK 1.8 or later

Gradle 4+ or Maven 3.2+

You can also import the code straight into your IDE:

Spring Tool Suite (STS)

IntelliJ IDEA

If you are NOT using a Linux machine, you will need a virtualized server. By installing VirtualBox, other tools like the Mac’s boot2docker, can seamlessly manage it for you. Visit VirtualBox’s download site and pick the version for your machine. Download and install. Don’t worry about actually running it.

You will also need Docker, which only runs on 64-bit machines. See https://docs.docker.com/installation/#installation for details on setting Docker up for your machine. Before proceeding further, verify you can run docker commands from the shell. If you are using boot2docker you need to run that first.

Set up a Spring Boot app
Now you can create a simple application

The class is flagged as a @SpringBootApplication and as a @RestController, meaning it’s ready for use by Spring MVC to handle web requests. @RequestMapping maps / to the home() method which just sends a 'Hello World' response. The main() method uses Spring Boot’s SpringApplication.run() method to launch an application.

Now we can run the application without the Docker container (i.e. in the host OS).

If you are using Maven, execute:

./mvnw package && java -jar target/gs-spring-boot-docker-0.1.0.jar
and go to localhost:8080 to see your "Hello Docker World" message.

Containerize It
Docker has a simple "Dockerfile" file format that it uses to specify the "layers" of an image. So let’s go ahead and create a Dockerfile in our Spring Boot project:

Dockerfile

FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
This Dockerfile is very simple, but that’s all you need to run a Spring Boot app with no frills: just Java and a JAR file. The project JAR file is ADDed to the container as "app.jar" and then executed in the ENTRYPOINT.

Dockerfile


FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG DEPENDENCY=target/dependency
COPY ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY ${DEPENDENCY}/META-INF /app/META-INF
COPY ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"]

Build a Docker Image with Maven
In the Maven pom.xml you should add a new plugin like this (see the plugin documentation for more options): :

pom.xml

<properties>
   <docker.image.prefix>springio</docker.image.prefix>
</properties>
<build>
    <plugins>
        <plugin>
            <groupId>com.spotify</groupId>
            <artifactId>dockerfile-maven-plugin</artifactId>
            <version>1.4.9</version>
            <configuration>
                <repository>${docker.image.prefix}/${project.artifactId}</repository>
            </configuration>
        </plugin>
    </plugins>
</build>
The configuration specifies 1 mandatory thing: the repository with the image name, which will end up here as springio/gs-spring-boot-docker.

The configuration specifies 4 things:

a task to unpack the fat jar file

the image name (or tag) is set up from the jar file properties, which will end up here as springio/gs-spring-boot-docker

the location of the unpacked jarfile, which we could have hard coded in the Dockerfile

a build argument for docker pointing to the jar file

You can build a tagged docker image and then push it to a remote repository with Gradle in one command:

$ ./gradlew build docker
After the Push
A "docker push" will fail for you (unless you are part of the "springio" organization at Dockerhub), but if you change the configuration to match your own docker ID then it should succeed, and you will have a new tagged, deployed image.


Debugging the application in a Docker container
To debug the application JPDA Transport can be used. So we’ll treat the container like a remote server. To enable this feature pass a java agent settings in JAVA_OPTS variable and map agent’s port to localhost during a container run. With the Docker for Mac there is limitation due to that we can’t access container by IP without black magic usage.

$ docker run -e "JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,address=5005,server=y,suspend=n" -p 8080:8080 -p 500
