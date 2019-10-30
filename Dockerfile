# Dockerfile that contains
# - Scala
# - AWS CLI
# - kubectl
# - sonar-scanner
# - Java 8 JDK (from base image)
# - SBT (from base image)
# - Docker (from base image)

# Pull base image (https://circleci.com/docs/2.0/circleci-images/#openjdk)
# https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/8u232-jdk/Dockerfile
FROM circleci/openjdk:11.0.5-jdk-stretch

# Environment variables
ENV SCALA_VERSION=2.13.1
ENV KUBECTL_VERSION=v1.16.1
ENV SONAR_SCANNER_VERSION=3.3.0.1492
ENV SONAR_SCANNER_PACKAGE=sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip

USER root

SHELL ["/bin/bash", "-eo", "pipefail", "-x", "-c"]

# Install current SBT
RUN apt-get update && apt-get install apt-transport-https
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add
RUN apt-get update && apt-get install sbt
RUN mkdir project && echo "sbt.version=1.3.3" > project/build.properties && echo "scalaVersion := \"2.13.1\"" > build.sbt
RUN sbt sbtVersion

# Install the AWS CLI
RUN curl -sSL https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip && \
  unzip awscli-bundle.zip && \
  ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
  rm awscli-bundle.zip && \
  rm -Rf awscli-bundle && \
  /usr/local/bin/aws --version

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
  mv kubectl /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl && \
  kubectl version --client

# Install Sonar-Scanner
RUN curl -LO https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/$SONAR_SCANNER_PACKAGE && \
  unzip ${SONAR_SCANNER_PACKAGE} -d /opt/ && \
  ln -s /opt/sonar-scanner-* /opt/sonar-scanner && \
  rm ${SONAR_SCANNER_PACKAGE}

ENV PATH="/opt/scala/bin:/opt/sonar-scanner/bin:$PATH"

USER circleci

# Define working directory
WORKDIR /home/circleci

RUN echo -e "Tag for this image:\n11.0.5-${SCALA_VERSION}-${KUBECTL_VERSION}"
