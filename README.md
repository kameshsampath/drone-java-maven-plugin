# Drone Java Maven Plugin

A [Drone](https://drone.io) plugin to build Java applications using [Apache Maven](https://maven.apache.org).

## Usage

The following settings changes this plugin's behavior.

* GOALS (optional) An array of maven goals to run.Defaults: "-DskipTests clean install" .
* MAVEN_MIRROR_URL (optional) The Maven repository mirror url.
* SERVER_USER (optional) The username for the maven repository manager server.
* SERVER_PASSWORD (optional) The password for the maven repository manager server.
* PROXY_USER (optional) The username for the proxy server.
* PROXY_PASSWORD (optional) The password for the proxy server.
* PROXY_PORT (optional) Port number for the proxy server.
* PROXY_HOST (optional) Proxy server Host.
* PROXY_NON_PROXY_HOSTS (optional) Non proxy server host.
* PROXY_PROTOCOL (optional) Protocol for the proxy ie http or https.
* CONTEXT_DIR (optional) The context directory within the repository for sources on
        which we want to execute maven goals.Defaults to Drone workspace root.

Below is an example `.drone.yml` that uses this plugin.

```yaml
kind: pipeline
name: default

steps:
- name: build-java-app
  image: quay.io/kameshsampath/drone-java-maven-plugin
  pull: if-not-exists
  settings:
    goals: 
    - clean 
    - install 
```

## Building

Build the plugin image:

```text
./scripts/build.sh
```

## Testing

Execute the plugin from your current working directory:

```text
docker run --rm -e MAVEN_MIRROR_URL='http://192.168.68.120:8081/repository/maven-public/' \
  -e GOALS='clean package' \
  -e DRONE_COMMIT_SHA=8f51ad7884c5eb69c11d260a31da7a745e6b78e2 \
  -e DRONE_COMMIT_BRANCH=master \
  -e DRONE_BUILD_NUMBER=43 \
  -e DRONE_BUILD_STATUS=success \
  -w /drone/src \
  -v $(pwd):/drone/src \
  quay.io/kameshsampath/drone-java-maven-plugin
```
