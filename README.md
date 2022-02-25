**This project is archived.**

---

# Builder image for Scala 2.13.x on JVM11

Includes
* [Scala 2.13.x](http://www.scala-lang.org)
* [sbt 1.3.x](http://www.scala-sbt.org)
* [kubectl (latest)](https://kubernetes.io/docs/reference/kubectl/overview/)
* [AWS CLI (latest)](https://aws.amazon.com/cli/)
* [Docker](https://www.docker.com/)
* [Sonar-Scanner (3.3.x)](https://docs.sonarqube.org/latest/)

## Base Docker Image ##

* `circleci/openjdk:11-jdk-stretch` provides the JDK and Docker.
  * [Dockerfile](https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/11.0.5-jdk-stretch/Dockerfile)
  * [background](https://circleci.com/docs/2.0/circleci-images/#openjdk)
  * [Tag on Dockerhub](https://hub.docker.com/r/circleci/openjdk/tags?page=1&name=11-jdk-stretch)

## Additions ##

We install and initialize `sbt` (latest 1.3.X) and `scala` (latest 2.13.X), the AWS CLI (latest), Kubectl (latest) and Sonar-Scanner (version `3.3`).

## Usage ##

If you use CircleCi, you can reference this image in your `.circleci/config.yml`:

```yaml
jobs:
  build:
    docker:
      - image: moia/scala-on-circleci:java11
    steps:
      - checkout
      - run: sbt compile
```

In your `build.sbt`, set `scalaVersion := "2.13.1"` and `scalacOptions := Seq("-target:11")`.


## License ##

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
