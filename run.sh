#!/usr/bin/env bash

set -e
set -o pipefail

init_maven_settings() {
	[[ -f $MAVEN_CONFIG/settings.xml ]] && \
	echo "using existing $MAVEN_CONFIG/settings.xml" && return 0
cat > "$MAVEN_CONFIG/settings.xml" <<EOF
<settings>
	<servers>
	<!-- The servers added here are generated from environment variables. Don't change. -->
	<!-- ### SERVER's USER INFO from ENV ### -->
	</servers>
	<mirrors>
	<!-- The mirrors added here are generated from environment variables. Don't change. -->
	<!-- ### mirrors from ENV ### -->
	</mirrors>
	<proxies>
	<!-- The proxies added here are generated from environment variables. Don't change. -->
	<!-- ### HTTP proxy from ENV ### -->
	</proxies>
</settings>
EOF
xml=""
if [ -n "${PLUGIN_PROXY_HOST}" -a -n "${PLUGIN_PROXY_PORT}" ]; then
	xml="<proxy>\
	<id>genproxy</id>\
	<active>true</active>\
	<protocol>${PROXY_PROTOCOL}</protocol>\
	<host>${PLUGIN_PROXY_HOST}</host>\
	<port>${PLUGIN_PROXY_PORT}</port>"
	if [ -n "${PLUGIN_PROXY_USER}" -a -n "${PROXY_PASSWORD}" ]; then
	xml="$xml\
		<username>${PLUGIN_PROXY_USER}</username>\
		<password>${PROXY_PASSWORD}</password>"
	fi
	if [ -n "${PROXY_NON_PROXY_HOSTS//,/|}" ]; then
	xml="$xml\
		<nonProxyHosts>${PROXY_NON_PROXY_HOSTS//,/|}</nonProxyHosts>"
	fi
	xml="$xml\
		</proxy>"
	sed -i "s|<!-- ### HTTP proxy from ENV ### -->|$xml|" "$MAVEN_CONFIG/settings.xml"
fi
if [ -n "${PLUGIN_SERVER_USER}" -a -n "${PLUGIN_SERVER_PASSWORD}" ]; then
	xml="<server>\
	<id>serverid</id>"
	xml="$xml\
		<username>${PLUGIN_SERVER_USER}</username>\
		<password>${PLUGIN_SERVER_PASSWORD}</password>"
	xml="$xml\
		</server>"
	sed -i "s|<!-- ### SERVER's USER INFO from ENV ### -->|$xml|" "$MAVEN_CONFIG/settings.xml"
fi
if [ -n "${PLUGIN_MAVEN_MIRROR_URL}" ]; then
	xml="    <mirror>\
	<id>mirror.default</id>\
	<url>${PLUGIN_MAVEN_MIRROR_URL}</url>\
	<mirrorOf>*</mirrorOf>\
	</mirror>"
	sed -i "s|<!-- ### mirrors from ENV ### -->|$xml|" "$MAVEN_CONFIG/settings.xml"
fi
}

if [ -z "$MAVEN_CONFIG" ]; 
then
  # TODO enable it when running as non-root user
  # MAVEN_CONFIG=/home/dev/.m2
  MAVEN_CONFIG=/root/.m2
fi

init_maven_settings

if [ "${PLUGIN_LOG_LEVEL}" == "debug" ];
then
	cat "$MAVEN_CONFIG/settings.xml"
fi

# if no plugin goals is specified run -DskipTests clean install
if [ -z "$PLUGIN_GOALS" ];
then 
  printf "No \$PLUGIN_GOALS defined, using default goals -DskipTests clean install"
  PLUGIN_GOALS="-DskipTests clean install"
else
  PLUGIN_GOALS="${PLUGIN_GOALS//,/ }"
fi 

if [ -n "${PLUGIN_MAVEN_MODULES}" ];
then
  PLUGIN_GOALS="-pl ${PLUGIN_MAVEN_MODULES} ${PLUGIN_GOALS}"
fi

MVN_COMMAND="mvn -B -s ${MAVEN_CONFIG}/settings.xml ${PLUGIN_GOALS}"

if [ -n "${PLUGIN_CONTEXT_DIR}" ];
then
  MVN_COMMAND=" $MVN_COMMAND -f ${PLUGIN_CONTEXT_DIR}"
fi

if [ "${PLUGIN_LOG_LEVEL}" == "debug" ];
then
	printf "Running command %s" "${MVN_COMMAND}"
fi

exec bash -c "$MVN_COMMAND"