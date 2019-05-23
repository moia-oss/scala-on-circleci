# Dockerfile that contains
# - Scala
# - SBT (from base image)
# - kubectl
# - AWS CLI
# - Docker (from base image)

# Pull base image (https://circleci.com/docs/2.0/circleci-images/#openjdk)
# https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/8u212-jdk-stretch/Dockerfile
FROM circleci/openjdk:8u212-jdk-stretch

USER root

# Environment variables
ENV SCALA_VERSION=2.12.8
ENV KUBECTL_VERSION=v1.14.2
ENV SONAR_SCANNER_VERSION=3.3.0.1492
ENV SONAR_SCANNER_PACKAGE=sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip
ENV SONAR_SCANNER_HOME=/home/sonar-scanner-${SONAR_SCANNER_VERSION}/bin

# Install Scala
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release && \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /home/circleci/ && \
  echo >> /home/circleci/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:\$PATH" >> /home/circleci/.bashrc

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
  unzip ${SONAR_SCANNER_PACKAGE} -d /home && \
  rm ${SONAR_SCANNER_PACKAGE} && \
  echo "export PATH=${SONAR_SCANNER_HOME}:\$PATH" >> /home/circleci/.bashrc

USER circleci

# Define working directory
WORKDIR /home/circleci