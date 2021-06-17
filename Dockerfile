# Dockerfile that contains
# - Scala
# - AWS CLI
# - kubectl
# - sonar-scanner
# - SBT (overwrites base image with newer version)
# - Java 11.0.X JDK (from base image)
# - Docker (from base image)

# Pull base image (https://circleci.com/docs/2.0/circleci-images/#openjdk)
# https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/8u232-jdk/Dockerfile
FROM circleci/openjdk:11-jdk-stretch

# Environment variables
ENV SCALA_VERSION=2.13.6
ENV SBT_VERSION=1.5.4
ENV SONAR_SCANNER_VERSION=3.3.0.1492
ENV SONAR_SCANNER_PACKAGE=sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip

USER root

SHELL ["/bin/bash", "-eo", "pipefail", "-x", "-c"]

# Fix apt-get
RUN apt-get update && apt-get install -y apt-transport-https

# Install SBT
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
  curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add && \
  apt-get update && \
  apt-get install sbt

# Install Scala
RUN curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /usr/share && \
  mv /usr/share/scala-$SCALA_VERSION /usr/share/scala && \
  chown -R root:root /usr/share/scala && \
  chmod -R 755 /usr/share/scala && \
  ln -s /usr/share/scala/bin/scala /usr/local/bin/scala

# Install the AWS CLI
RUN curl -sSL https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip && \
  unzip awscli-bundle.zip && \
  ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
  rm awscli-bundle.zip && \
  rm -Rf awscli-bundle && \
  /usr/local/bin/aws --version

# Install kubectl
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && apt-get install -y kubectl
RUN kubectl version --client

# Install Sonar-Scanner
RUN curl -LO https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/$SONAR_SCANNER_PACKAGE && \
  unzip ${SONAR_SCANNER_PACKAGE} -d /opt/ && \
  ln -s /opt/sonar-scanner-* /opt/sonar-scanner && \
  rm ${SONAR_SCANNER_PACKAGE}

ENV PATH="/opt/scala/bin:/opt/sonar-scanner/bin:$PATH"

USER circleci

# Define working directory
WORKDIR /home/circleci

# Prepare sbt (warm cache)
RUN sbt sbtVersion && \
  mkdir -p project && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
  echo "case object Temp" > Temp.scala && \
  sbt compile && \
  rm -r project && rm build.sbt && rm Temp.scala && rm -r target

RUN echo -e "Tag for this image:\njava11-${SCALA_VERSION}"
