# Dockerfile with Scala, SBT, Kubernetes, AWS CLI and Docker

This repository contains **Dockerfile** of:
* [Scala](http://www.scala-lang.org)
* [sbt](http://www.scala-sbt.org)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
* [AWS CLI](https://aws.amazon.com/cli/)
* [Docker](https://www.docker.com/)
* [Sonar-Scanner](https://docs.sonarqube.org/latest/)

## Base Docker Image ##

* `circleci/openjdk:8u232-jdk-stretch` provides the JDK, SBT and Docker.
  * [Dockerfile](https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/8u232-jdk-stretch/Dockerfile)
  * [background](https://circleci.com/docs/2.0/circleci-images/#openjdk)
  * [Tag on Dockerhub](https://hub.docker.com/r/circleci/openjdk/tags?page=1&name=8u232-jdk-stretch)
  
## Additions ##

We add Scala (version in tag), AWS CLI (latest), Kubectl (version in tag) and Sonar-Scanner (version `3.3`).

## Dockerhub ##

This image is automatically released to Dockerhub for every tag: https://hub.docker.com/r/moia/scala-on-circleci

## License ##

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
