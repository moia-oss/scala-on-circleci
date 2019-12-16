# Dockerfile that contains
# - Scala
# - AWS CLI
# - kubectl
# - sonar-scanner
# - Java 8 JDK (from base image)
# - SBT (from base image)
# - Docker (from base image)

# Pull base image (https://circleci.com/docs/2.0/circleci-images/#openjdk)
# https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/8u232-jdk-stretch/Dockerfile
FROM circleci/openjdk:8u232-jdk-stretch

# Environment variables
ENV SCALA_VERSION=2.12.10
ENV SBT_VERSION=1.3.5
ENV KUBECTL_VERSION=v1.14.8
ENV SONAR_SCANNER_VERSION=3.3.0.1492
ENV SONAR_SCANNER_PACKAGE=sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip

USER root

SHELL ["/bin/bash", "-eo", "pipefail", "-x", "-c"]

# Install Scala
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release && \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /opt/ && \
  ln -s /opt/scala-* /opt/scala && \
  /opt/scala/bin/scala -version

# Initialise SBT to download scala and the compiler-bridge
RUN export TEMP="$(mktemp -d)" && \
    cd "${TEMP}" && \
    echo "class Question { def answer = 42 }" > Question.scala && \
    sbt -Dsbt.version=$SBT_VERSION "set scalaVersion := \"${SCALA_VERSION}\"" compile && \
    rm -r "${TEMP}"

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

RUN echo -e "Tag for this image:\n8u232-${SCALA_VERSION}-sbt-${SBT_VERSION}"
