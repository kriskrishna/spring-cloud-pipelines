#!/usr/bin/env bash

function deployAppWithName() {
al artifactName="${2}"
	local env="${3}"
	local useManifest="${4:-true}"
	local manifestOption
	manifestOption=$(if [[ "${useManifest}" == "false" ]]; then
		echo "--no-manifest";
	else
		echo "";
	fi)
	local lowerCaseAppName
	lowerCaseAppName=$(toLowerCase "${appName}")
	local hostname="${lowerCaseAppName}"
	local memory="${APP_MEMORY_LIMIT:-256m}"
	# TODO: This is very JVM specific
	local buildPackUrl="${JAVA_BUILDPACK_URL:-https://github.com/cloudfoundry/java-buildpack.git#v3.8.1}"
	if [[ "${PAAS_HOSTNAME_UUID}" != "" ]]; then
		hostname="${hostname}-${PAAS_HOSTNAME_UUID}"
	fi
	if [[ ${env} != "PROD" ]]; then
		hostname="${hostname}-${env}"
	fi
	echo "Deploying app with name [${lowerCaseAppName}], env [${env}] with manifest [${useManifest}] and host [${hostname}]"
	if [[ ! -z "${manifestOption}" ]]; then
		# TODO: This is very JVM specific
		"${CF_BIN}" push "${lowerCaseAppName}" -m "${memory}" -i 1 -p "${OUTPUT_FOLDER}/${artifactName}.${BINARY_EXTENSION}" -n "${hostname}" --no-start -b "${buildPackUrl}" "${manifestOption}"
	else
		# TODO: This is very JVM specific
		"${CF_BIN}" push "${lowerCaseAppName}" -p "${OUTPUT_FOLDER}/${artifactName}.${BINARY_EXTENSION}" -n "${hostname}" --no-start -b "${buildPackUrl}"
	fi
	local applicationDomain
	applicationDomain="$(appHost "${lowerCaseAppName}")"
	echo "Determined that application_domain for [${lowerCaseAppName}] is [${applicationDomain}]"
	setEnvVar "${lowerCaseAppName}" 'APPLICATION_DOMAIN' "${applicationDomain}"
	# TODO: This is very JVM specific
	setEnvVar "${lowerCaseAppName}" 'JAVA_OPTS' '-Djava.security.egd=file:///dev/urandom'

}

export -f deployAppName
