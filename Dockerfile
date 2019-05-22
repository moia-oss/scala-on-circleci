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
ENV HOME=/config

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install the AWS CLI
# RUN set -x && \
RUN apt-get install -y bash ca-certificates coreutils curl gawk git grep groff gzip jq less python sed tar zip && \
    curl -sSL https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip && \
    unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    rm awscli-bundle.zip && \
    rm -Rf awscli-bundle

# Install kubectl
# Note: Latest version may be found on:
# https://aur.archlinux.org/packages/kubectl-bin/
RUN set -x \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl

# Create non-root user (with a randomly chosen UID/GUI).
RUN useradd --uid 2342 --home /config kubectl

USER kubectl

RUN kubectl version --client

# Define working directory
WORKDIR /root