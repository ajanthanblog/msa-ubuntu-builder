# ubuntu-basic-builder - here I'm fetching the latest ubuntu base image from docker hub
# https://hub.docker.com/_/ubuntu?tab=tags
FROM ubuntu:latest

# Maintainer name used in image meta data
LABEL maintainer="Ajanthan <ajanthaneng@email.com>"

ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building ubuntu builder image for MSA deployment" \
      io.k8s.display-name="OpenShift MSA Builder Image" \
      io.openshift.expose-services="8097:http" \
      io.openshift.tags="builder,java,maven,gradle" \
      io.openshift.s2i.scripts-url="image:///home/ajanmsa/s2iscripts" \
      io.openshift.s2i.destination="/home/ajanmsa/sourceandartifacts"

#Installing the needed dependents

RUN apt-get update && apt-get install -y \
curl
CMD /bin/bash

RUN apt-get update && apt-get install -y \
unzip
CMD /bin/bash

#Create a user and continue the setup through that user
RUN useradd -ms /bin/bash ajanmsa
USER ajanmsa
WORKDIR /home/ajanmsa

RUN mkdir -p /home/ajanmsa/sourceandartifacts
RUN mkdir -p /home/ajanmsa/s2iscripts
RUN mkdir -p /home/ajanmsa/apps

# ----------------Packages needs to be installed-----------------------------
RUN mkdir /home/ajanmsa/temp

# Install Java

COPY ./packs/jdk-8u221-linux-x64.tar.gz /home/ajanmsa/temp

RUN echo "Unziping Java Distribution" \
  && tar -xzf /home/ajanmsa/temp/jdk-8u221-linux-x64.tar.gz -C /home/ajanmsa/ \
   \
  && echo "Cleaning Temp" \
  && rm -f /home/ajanmsa/temp/jdk-8u221-linux-x64.tar.gz

ENV JAVA_HOME /home/ajanmsa/jdk1.8.0_221
ENV PATH $PATH:$JAVA_HOME/bin


# Install Maven - This is not needed for this but adding as a sample for maven builds

ARG MAVEN_VERSION=3.6.1
ARG USER_HOME_DIR="/home/ajanmsa"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN echo "Downloading maven" \
  && curl -fsSL -o /home/ajanmsa/temp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  \
  && echo "Unziping maven" \
  && tar -xzf /home/ajanmsa/temp/apache-maven.tar.gz -C /home/ajanmsa/ \
  \
  && echo "Cleaning Temp" \
  && rm -f /home/ajanmsa/temp/apache-maven.tar.gz

# Define environmental variables required by maven
ENV MAVEN_HOME /home/ajanmsa/apache-maven-3.6.1
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV PATH $PATH:$MAVEN_HOME/bin

# Install Gradle

ARG GRADLE_VERSION=5.6
ARG GRADLE_BASE_URL=https://services.gradle.org/distributions

RUN mkdir -p /home/ajanmsa/gradle \
  && echo "Downloading gradle" \
  && curl -fsSL -o /home/ajanmsa/temp/gradle.zip ${GRADLE_BASE_URL}/gradle-${GRADLE_VERSION}-bin.zip \
  \
  && echo "Unziping gradle" \
  && unzip -d /home/ajanmsa/ /home/ajanmsa/temp/gradle.zip \
   \
  && echo "Cleaning Temp" \
  && rm -f /home/ajanmsa/temp/gradle.zip

# Define environmental variables required by gradle
ENV GRADLE_HOME /home/ajanmsa/gradle-5.6
ENV PATH $PATH:$GRADLE_HOME/bin

# ---------------------------Verifying the Installation---------------------

RUN gradle -v
RUN java -version
RUN mvn -version

# ----------------------------Package Installation Ends---------------------
COPY ./s2i/bin/ /home/ajanmsa/s2iscripts/

USER ajanmsa

EXPOSE 8097

CMD ["/home/ajanmsa/s2iscripts/usage"]
