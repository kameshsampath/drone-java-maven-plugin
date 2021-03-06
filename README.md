# Drone Java Maven Plugin

A [Drone](https://drone.io) plugin to build Java applications using [Apache Maven](https://maven.apache.org).

## Usage

The following settings changes this plugin's behavior.

* context_dir (optional) The context directory within the source repository where `pom.xml` is found to execute the maven goals. Defaults to Drone workspace root.
* goals (optional) An array of maven goals to run.Defaults: `-DskipTests clean install`.
* maven_modules (optional) An array of maven modules to be built incase of a multi module maven project.
* maven_mirror_url (optional) The Maven repository mirror url.
* server_user (optional) The username for the maven repository manager server.
* server_password (optional) The password for the maven repository manager server.
* proxy_user (optional) The username for the proxy server.
* proxy_password (optional) The password for the proxy server.
* proxy_port (optional) Port number for the proxy server.
* proxy_host (optional) Proxy server Host.
* proxy_non_proxy_hosts (optional) An array of non proxy server hosts.
* proxy_protocol (optional) Protocol for the proxy ie http or https.

Below is an example `.drone.yml` that uses this plugin.

```yaml
kind: pipeline
name: default

steps:
- name: build-java-app
  image: docker.io/kameshsampath/drone-java-maven-plugin:v1.0.2
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
  docker.io/kameshsampath/drone-java-maven-plugin:v1.0.2
```
