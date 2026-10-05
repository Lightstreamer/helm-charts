{{/*
Copyright (C) 2025 Lightstreamer Srl

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "lightstreamer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lightstreamer.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "lightstreamer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
General labels
*/}}
{{- define "lightstreamer.labels" -}}
helm.sh/chart: {{ include "lightstreamer.chart" . }}
{{ include "lightstreamer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{ include "lightstreamer.commonLabels" . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lightstreamer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lightstreamer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lightstreamer.commonLabels" -}}
{{- with .Values.commonLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "lightstreamer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lightstreamer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the Service name.
*/}}
{{- define "lightstreamer.service.name" -}}
{{- .Values.service.name | default (printf "%s-%s" (include "lightstreamer.fullname" . ) "service") }}
{{- end }}

{{/*
Create the management Service name.
*/}}
{{- define "lightstreamer.management.service.name" -}}
{{- printf "%s-%s" (include "lightstreamer.fullname" .) "management" }}
{{- end }}

{{/*
Create the Service target port.
*/}}
{{- define "lightstreamer.service.targetPort" -}}
{{- $ := index . 0 }}
{{- $portIndex := index .1 }}
{{- $serverKeyName := printf "service.ports[%d].targetPort" (int $portIndex) }}
{{- $serverKey := index . 2 }}
{{- include "lightstreamer.configuration.servers.validateServerRef" (list $ $serverKeyName $serverKey) }}
{{- include "lightstreamer.configuration.servers.serverPortName" $serverKey -}}
{{- end }}

{{/*
Validate the Service port name, ensuring that it matches one of the port names defined in service.ports.
*/}}
{{- define "lightstreamer.service.validateServicePortName" -}}
{{- $ := index . 0}}
{{- $portName := index . 1 }}
{{- $portNames := list }}
{{- range $.Values.service.ports | default list }}
{{- $portNames = append $portNames .name }}
{{- end }}
{{- if not (has $portName $portNames) }}
{{- fail (printf "service.ports[].name \"%s\" does not match any port name defined in service.ports" $portName) }}
{{- end }}
{{- end }}

{{/*
Resolve and validate the ingress backend port from a given port name.
Accepts ($ portName) where portName may be empty (unnamed single port fallback).
Emits either "name: <x>" or "number: <x>" as appropriate.
*/}}
{{- define "lightstreamer.ingress.backendPort" -}}
{{- $ := index . 0 }}
{{- $portName := index . 1 | kebabcase | trunc 15 | trimSuffix "-" }}
{{- if $portName }}
{{- include "lightstreamer.service.validateServicePortName" (list $ $portName) }}
name: {{ $portName }}
{{- else }}
number: {{ (first $.Values.service.ports).port }}
{{- end }}
{{- end }}

{{/*
Validate and render the defaultBackend block for the Ingress.
Enforces:
- If no rules and multiple ports: defaultBackend is required.
- If defaultBackend set but single port has no name: error.
- If no rules and single port: auto-defaults to that port.
Accepts the root context $.
*/}}
{{- define "lightstreamer.ingress.defaultBackend" -}}
{{- $ := . }}
{{- $firstPort := first $.Values.service.ports }}
{{- $firstPortName := $firstPort.name | kebabcase | trunc 15 | trimSuffix "-" }}
{{- $singlePort := eq (len $.Values.service.ports) 1 }}
{{- $defaultBackend := $.Values.ingress.defaultBackend }}
{{- $hasRules := $.Values.ingress.rules }}
{{- if and $defaultBackend $singlePort (not $firstPortName) }}
  {{- fail "ingress.defaultBackend cannot be set when the single service port has no name" }}
{{- end }}
{{- if and (not $hasRules) (not $singlePort) (not $defaultBackend) }}
  {{- fail "ingress.defaultBackend must be set when no rules are defined and multiple service ports exist" }}
{{- end }}
{{- if or $defaultBackend (and (not $hasRules) $singlePort) }}
defaultBackend:
  service:
    name: {{ include "lightstreamer.service.name" $ }}
    port:
      {{ include "lightstreamer.ingress.backendPort" (list $ ($defaultBackend | default $firstPortName)) | indent 6 | trim }}
{{- end }}
{{- end }}

{{/*
Render all the probes for the deployment descriptor.
*/}}
{{- define "lightstreamer.deployment.all-probes" -}}
{{- $probes := .Values.deployment.probes }}
{{- $allowedProbeNames := list "startup" "liveness" "readiness" }}
{{- range $probeName, $probe := $probes }}
{{- if has $probeName $allowedProbeNames }}
  {{- include "lightstreamer.deployment.probe" (list $ $probe $probeName) }}
{{- else }}
  {{- fail (printf "deployment.probes.%s is not a valid probe name. Allowed values are: %s" $probeName $allowedProbeNames) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Render a probe for the deployment descriptor.
*/}}
{{- define "lightstreamer.deployment.probe" -}}
{{- $ := index . 0}}
{{- $probe := index . 1 }}
{{- $probeName := index . 2 }}
{{- if ($probe).enabled }}
{{- with $probe }}
{{ printf "%sProbe:" $probeName }}
  {{- if .serverRef }}
    {{- if has $probeName (list "liveness" "startup") }}
      {{- include "lightstreamer.deployment.probe.healthCheck.httpGet" (list $ .serverRef $probeName) }}
    {{- else }}
      {{- if .checkScriptRef }}
        {{- $scriptName := required "deployment.probes.readiness.checkScriptRef.key must be set" .checkScriptRef.key }}
        {{- include "lightstreamer.deployment.probe.readinessCheck.command" (list $ .serverRef $scriptName) }}
      {{- else }}
        {{- include "lightstreamer.deployment.probe.readinessCheck.httpGet" (list $ .serverRef) }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- toYaml (required (printf "Either specify deployment.probes.%s.serverRef or deployment.probes.%s.default" $probeName $probeName) $probe.default) | nindent 2 }}
  {{- end }}
  initialDelaySeconds: {{ .initialDelaySeconds }}
  periodSeconds: {{ .periodSeconds }}
  failureThreshold: {{ .failureThreshold }}
    {{- if eq $probeName "readiness" }}
  successThreshold: {{ .successThreshold }}
    {{- end }}
  timeoutSeconds: {{ .timeoutSeconds }}
    {{- if ne $probeName "readiness" }}
  terminationGracePeriodSeconds: {{ .terminationGracePeriodSeconds }}
    {{- end }}
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Render the HTTP GET probe for health check.
*/}}
{{- define "lightstreamer.deployment.probe.healthCheck.httpGet" }}
{{- $ := index . 0}}
{{- $serverRef := index . 1 }}
{{- $probeName := index . 2 }}
  httpGet:
    path: "/lightstreamer/healthcheck"
    port: {{ include "lightstreamer.management.healthcheckPort" (list $ $probeName $serverRef) }}
    scheme: {{ (get $.Values.servers $serverRef).enableHttps | default false | ternary "HTTPS" "HTTP" }}
{{- end }}

{{/*
Create the port used for the health check.
*/}}
{{- define "lightstreamer.management.healthcheckPort" -}}
{{- $ := index . 0 }}
{{- $probeName := index . 1 }}
{{- $serverKeyName := printf "deployment.probes.%s.serverRef" $probeName }}
{{- $serverKey := index . 2 }}
{{- include "lightstreamer.configuration.servers.validateServerRef" (list $ $serverKeyName $serverKey) }}
{{- $hc := $.Values.management.healthCheck }}
{{- if not $hc.enableAvailabilityOnAllServers }}
  {{- $found := false }}
  {{- range $hc.availableOnServers }}
    {{- if eq . $serverKey }}
      {{- $found = true }}
    {{- end }}
  {{- end }}
  {{- if not $found }}
    {{- fail (printf "%s: the health check url is not available for server '%s'. Either add '%s' to management.healthCheck.availableOnServers[] or set management.healthCheck.enableAvailabilityOnAllServers to true" $serverKeyName $serverKey $serverKey) }}
  {{- end }}
{{- end }}
{{- include "lightstreamer.configuration.servers.serverPortName" $serverKey -}}
{{- end }}

{{/*
  Render the HTTP GET probe for readiness check.
*/}}
{{- define "lightstreamer.deployment.probe.readinessCheck.httpGet" }}
{{- $ := index . 0}}
{{- $serverRef := index . 1 }}
  httpGet:
    path: "/lightstreamer/readiness_check"
    port: {{ include "lightstreamer.management.readinessCheckPort" (list $ "readiness" $serverRef) }}
    scheme: {{ (get $.Values.servers $serverRef).enableHttps | default false | ternary "HTTPS" "HTTP" }}
{{- end }}

{{/*
  Render the command probe for readiness check.
*/}}
{{- define "lightstreamer.deployment.probe.readinessCheck.command" }}
{{- $ := index . 0}}
{{- $serverRef := index . 1 }}
{{- $scriptName := index . 2 }}
{{- $portName := include "lightstreamer.management.readinessCheckPort" (list $ "readiness" $serverRef) }}
{{- $_ := set $.Values.deployment.probes "renderReadinessCheckScript" true }}
{{- $serverPort := (get $.Values.servers $serverRef).port }}
{{- $serverScheme := (get $.Values.servers $serverRef).enableHttps | default false | ternary "https" "http" }}
  exec:
    command:
      - "/bin/sh"
      - "-c"
      {{- /*
        curl flags:
        - `-f`  fail fast on HTTP >= 400 so the probe reports non-ready.
        - `-s`  silent (no progress meter).
        - `-S`  keep error messages on stderr when combined with `-s`.
        - `-k`  (https only) skip TLS certificate verification: the server
                may present a self-signed cert and this call is intra-pod
                against localhost, so hostname/CA validation adds no value.
      */}}
      - "curl -fsS{{ if eq $serverScheme "https" }}k{{ end }} {{ $serverScheme }}://localhost:{{ $serverPort }}/lightstreamer/readiness_check | /lightstreamer/bin/readiness-check-script/{{ $scriptName }}"
{{- end }}

{{/*
Create the port used for the readiness check.
*/}}
{{- define "lightstreamer.management.readinessCheckPort" -}}
{{- $ := index . 0 }}
{{- $serverKeyName := "deployment.probes.readiness.serverRef" }}
{{- $serverKey := index . 2 }}
{{- include "lightstreamer.configuration.servers.validateServerRef" (list $ $serverKeyName $serverKey) }}
{{- $hc := $.Values.management.readinessCheck }}
{{- if not $hc.enableAvailabilityOnAllServers }}
  {{- $found := false }}
  {{- range $hc.availableOnServers }}
    {{- if eq . $serverKey }}
      {{- $found = true }}
    {{- end }}
  {{- end }}
  {{- if not $found }}
    {{- fail (printf "%s: the readiness_check url is not available for server '%s'. Either add '%s' to management.readinessCheck.availableOnServers[] or set management.readinessCheck.enableAvailabilityOnAllServers to true" $serverKeyName $serverKey $serverKey) }}
  {{- end }}
{{- end }}
{{- include "lightstreamer.configuration.servers.serverPortName" $serverKey -}}
{{- end }}

{{/*
Validate all the server configurations, ensuring that at least one enabled
server exists and no duplicated names or ports are used.
*/}}
{{- define "lightstreamer.configuration.servers.validateAllServers" }}
{{- $usedNames := list }}
{{- $usedPorts := list }}
{{- range $serverKey, $server :=.Values.servers }}
  {{- if not $server }}
    {{ printf "servers.%s must be set" $serverKey | fail }}
  {{- end }}
  {{- /* Set the enabled flag to default true value if not set */ -}}
  {{- $_ := set $server "enabled" (not (eq $server.enabled false)) }}
  {{- if $server.enabled }}
    {{- /* Check the server names */ -}}
    {{- $serverName := required (printf "servers.%s.name must be set" $serverKey) $server.name }}
    {{- if has $serverName $usedNames }}
      {{- fail (printf "servers.%s.name \"%s\" already used" $serverKey $serverName ) }}
    {{- end }}
    {{- $usedNames = append $usedNames $serverName }}
    {{- /* Check the server ports */ -}}
    {{- $serverPort := required (printf "servers.%s.port must be set" $serverKey) $server.port }}
    {{- if has $serverPort $usedPorts }}
      {{- fail (printf "servers.%s.port \"%d\" already used" $serverKey (int $serverPort) ) }}
    {{- end }}
    {{- $usedPorts = append $usedPorts $serverPort }}
  {{- end }}
{{- end }}
{{- if not $usedNames }}
  {{- fail "At least one enabled server must be defined" }}
{{- end }}
{{- end }}

{{/*
Validate a server configuration reference, ensuring that the server exists and is enabled.
*/}}
{{- define "lightstreamer.configuration.servers.validateServerRef" }}
{{- $ := index . 0 }}
{{- $serverKeyName := index . 1 }}
{{- $serverKey := required (printf "%s must be set" $serverKeyName) (index . 2) }}
{{- $server := required (printf "servers.%s not defined" $serverKey) (get $.Values.servers $serverKey ) }}
{{- if not $server.enabled }}
  {{- printf "%s must set to an enabled server" $serverKeyName | fail }}
{{- end }}
{{- end }}

{{/*
Create the port reference for a server configuration.
*/}}
{{- define "lightstreamer.configuration.servers.serverPortName" -}}
{{ . | kebabcase | trunc 15 | trimSuffix "-" }}
{{- end }}

{{/*
Render the keystore settings for the main configuration file.
*/}}
{{- define "lightstreamer.configuration.keystore" -}}
{{- $top := index . 0 -}}
{{- $key := index . 1 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}
{{- if not (quote $keyStore.type | empty) }}
  {{- if not (has $keyStore.type (list "JKS" "PKCS12" "PKCS11" ))}}
    {{ fail (printf "keystores.%s.type must be one of: \"JKS\", \"PKCS12\", \"PKCS11\"" $key) }}
  {{- end }}
{{- end }}
<keystore{{- if not (quote $keyStore.type | empty) }} type="{{ $keyStore.type }}"{{- end }}>

    <!-- Specifies a path relative to the conf directory.
         The referred file can be replaced at runtime and the new keystore
         will be loaded immediately. Only in case of successful load
         will the previous keystore be replaced.
         NOTE: The JKS keystore "myserver.keystore", which is provided out
         of the box, obviously contains an invalid certificate. In order to
         use it for your experiments, remember to add a security exception
         to your browser. -->
    <keystore_file>{{ include "lightstreamer.keystores.dir" . }}/{{ $key }}/{{ required (printf "keystores.%s.keystoreFilesecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</keystore_file>

    <!-- Specified the password for the keystore. The factory setting below
         refers to the test keystore "myserver.keystore", provided out of the box.
         The optional "type" attribute, whose default is "text", when set
         to "file", allows you to supply the path, relative to the conf
         directory, of a file containing the password in UTF-8 encoding.
         Note that the password has to be stored in clear, but the file could be
         protected from external access. Also pay attention that the file does
         not contain any extra line termination characters.
         In case the keystore file is replaced, a password of "file" type
         will be reread as well. This is the only way to supply a new
         password, if needed. Note that the password file should be modified
         before the keystore file. -->
    <keystore_password type="text">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</keystore_password>

</keystore>
{{- end -}}

{{/*
Render the truststore settings for the Lightstreamer configuration file.
*/}}
{{- define "lightstreamer.configuration.truststore" -}}
{{- $top := index . 0 -}}
{{- $key := index . 1 -}}
{{- $keyStore := get $top $key -}}
<truststore type={{ $keyStore.type | quote }}>

    <!-- Specifies a path relative to the conf directory.
         The referred file can be replaced at runtime and the new keystore
         will be loaded immediately. Only in case of successful load
         will the previous keystore be replaced.
         NOTE: The JKS keystore "myserver.keystore", which is provided out
         of the box, obviously contains an invalid certificate. In order to
         use it for your experiments, remember to add a security exception
         to your browser. -->
    <truststore_file>{{ include "lightstreamer.keystores.dir" . }}/{{ $key }}/{{ $keyStore.keystoreFileSecretRef.key }}</truststore_file>

    <!-- Specified the password for the keystore. The factory setting below
         refers to the test keystore "myserver.keystore", provided out of the box.
         The optional "type" attribute, whose default is "text", when set
         to "file", allows you to supply the path, relative to the conf
         directory, of a file containing the password in UTF-8 encoding.
         Note that the password has to be stored in clear, but the file could be
         protected from external access. Also pay attention that the file does
         not contain any extra line termination characters.
         In case the keystore file is replaced, a password of "file" type
         will be reread as well. This is the only way to supply a new
         password, if needed. Note that the password file should be modified
         before the keystore file. -->
    <truststore_password type="text">$env.KEYSTORE_{{ $key | upper }}_PASSWORD</truststore_password>

</truststore>
{{- end -}}

{{/*
Render the <appender-ref> element.
*/}}
{{- define "lightstreamer.configuration.log.appender_ref" -}}
{{- $top := index . 0 -}}
{{- $logger := index . 1 -}}
{{- range $appenderName := $logger.appenders }}
  {{- if not (hasKey $top $appenderName) }}
    {{- fail (printf "loggers.appenders.%s not defined" $appenderName) }}
  {{- end }}
<appender-ref ref={{ printf "%s%s" "LS" (title $appenderName) | quote }}/>
{{- end }}
{{- end }}

{{/*
Create the logging level attribute.
*/}}
{{- define "lightstreamer.configuration.log.level" -}}
{{- $top := index . 0 -}}
{{- $defaultLevel := index . 1 -}}
{{- $loggerLevel := $top.level | default $defaultLevel }}
{{- $admittedLevels := list "INFO" "DEBUG" "WARN" "ERROR" "FATAL" "TRACE" "OFF" -}}
  {{- if not (has $loggerLevel $admittedLevels) }}
    {{- fail (printf "logging.loggers.<logger name>.level must be one of %s" $admittedLevels) }}
  {{- end }}
{{- printf " level=%s" ($loggerLevel | quote) }}
{{- end }}

{{/*
Create the logging level attribute for subloggers.
*/}}
{{- define "lightstreamer.configuration.log.subloggers.level" -}}
{{- $subloggers := index . 0 -}}
{{- $loggerName := index . 1 -}}
{{- $defaultLevel := index . 2 -}}
{{- $loggerLevel := (get $subloggers $loggerName) | default $defaultLevel }}
{{- if $loggerLevel }}
  {{- $admittedLevels := list "INFO" "DEBUG" "WARN" "ERROR" "FATAL" "TRACE" "OFF" -}}
    {{- if not (has $loggerLevel $admittedLevels) }}
      {{- fail (printf "logging.loggers.lightstreamerLogger.subLoggers.%s.level must be one of %s" $loggerName $admittedLevels) }}
    {{- end }}
{{- printf " level=%s" ($loggerLevel | quote) }}
{{- end }}
{{- end }}


{{/*
Create the name of the logs folder for the Lightstreamer Server and the connectors.
*/}}
{{- define "lightstreamer.logs.dir" -}}
{{- printf "/logs" }}
{{- end }}

{{/*
Create the name of the keystores folder for storing the keystore files used by the Lightstreamer Server and the connectors
*/}}
{{- define "lightstreamer.keystores.dir" -}}
{{- print "/keystores" }}
{{- end }}

{{/*
Validate that a volume name references an existing entry in deployment.extraVolumes.
Takes a list: [extraVolumes, volumeName, errorContext].
*/}}
{{- define "lightstreamer.validateExtraVolumeRef" -}}
{{- $extraVolumes := index . 0 -}}
{{- $volumeName := index . 1 -}}
{{- $errorContext := index . 2 -}}
{{- $extraVolumeNames := list }}
{{- range $extraVolumes }}
  {{- $extraVolumeNames = append $extraVolumeNames .name }}
{{- end }}
{{- $extraVolumeNames := $extraVolumeNames | uniq }}
{{- if not (has $volumeName $extraVolumeNames) }}
  {{- fail (printf "%s must be set to a volume defined in deployment.extraVolumes" $errorContext) }}
{{- end }}
{{- end }}

{{/*
Validate all Kafka connection configurations, ensuring that at least one enabled
configuration exists and no duplicate names are used.
*/}}
{{- define "lightstreamer.kafka-connector.validateAllConnections" -}}
{{- $connectionNames := list }}
{{- range $connectionKey, $connection := required "connectors.kafkaConnector.connections must be set" .Values.connectors.kafkaConnector.connections}}
  {{- if not $connection }}
    {{- fail (printf "connectors.kafkaConnector.connections.%s must be set" $connectionKey ) }}
  {{- end }}
  {{- if $connection.enabled }}
    {{- /* Check the connection name */ -}}
    {{- $connectionName:= required (printf "connectors.kafkaConnector.connections.%s.name must be set" $connectionKey) $connection.name }}
    {{- if has $connectionName $connectionNames }}
      {{- fail (printf "connectors.kafkaConnector.connections.%s.name \"%s\" already used" $connectionKey $connectionName ) }}
    {{- end }}
    {{- $connectionNames = append $connectionNames $connectionName }}
  {{- end }}
{{- end }}
{{- if $connectionNames | empty }}
  {{- fail "At least one enabled Kafka connection configuration must be defined" }}
{{- end }}
{{- end }}

{{/*
Create the name of the temp directory to use for storing the connectors' source configuration files
*/}}
{{- define "lightstreamer.connectors.source-config.dir" -}}
{{ print "/tmp/connectors-source-conf" }}
{{- end }}

{{/*
  Create the name of the temp directory to use for storing the Lightstreamer Kafka Connector source configuration files
*/}}
{{- define "lightstreamer.connectors.source-config.kafka-connector.dir" -}}
{{ print (include "lightstreamer.connectors.source-config.dir" .) "/kafka" }}
{{- end }}

{{/*
Create the name of the temp directory to use for storing the connectors' source zip archives
*/}}
{{- define "lightstreamer.connectors.source-archives.dir" -}}
{{ print "/tmp/connectors-source-archives" }}
{{- end }}

{{/*
  Create the name of the temp directory to use for storing the Kafka Connector source zip archive
*/}}
{{- define "lightstreamer.kafka.connector.source-archive.dir" -}}
{{ print (include "lightstreamer.connectors.source-archives.dir" .) "/kafka" }}
{{- end }}

{{/*
Validate the Kafka Connector provisioning setting.
*/}}
{{- define "lightstreamer.kafka-connector.validateProvisioning" -}}
{{- $ := . }}
{{- with required "connectors.kafkaConnector.provisioning must be set" .Values.connectors.kafkaConnector.provisioning }}
  {{- /* Partial list of admitted provisioning methods */ -}}
  {{- $admittedProvisioningMethods := list "fromPathInImage" "fromGitHubRelease" "fromUrl" }}
  {{- $methods := list }}
  {{- range $methodName, $method := . }}
    {{- if and (has $methodName $admittedProvisioningMethods) $method }}
      {{- $methods = append $methods $methodName }}
    {{- end }}
  {{- end }}
  {{- if (.fromVolume).name }}
    {{- $methods = append $methods "fromVolume"}}
  {{- end }}

  {{- /* Check that only one provisioning method is set */ -}}
  {{- if or (not $methods) (gt (len $methods) 1) }}
    {{- fail (printf "connectors.kafkaConnector.provisioning must be one of %s" (append $admittedProvisioningMethods "fromVolume")) }}
  {{- end }}

  {{- $chosenMethodName := $methods | first }}
  {{- /* When fromVolume is the chosen method, check that it is correctly set */ -}}
  {{- if eq $chosenMethodName "fromVolume" }}

    {{- include "lightstreamer.validateExtraVolumeRef" (list $.Values.deployment.extraVolumes .fromVolume.name "connectors.kafkaConnector.provisioning.fromVolume.name") }}

    {{- /* Check that fromVolume.filePath is set */ -}}
    {{- if not .fromVolume.filePath }}
      {{- fail "connectors.kafkaConnector.provisioning.fromVolume.filePath must be set" }}
    {{- end }}
  {{- else }}
    {{- /* For any other provisioning method, clean up the current context from
    the partially configuration of "fromVolume" provided in values.yaml, to prevent
    any possible conflict with the chosen provisioning method */ -}}
    {{- $_ := unset . "fromVolume" }}
  {{- end }}
{{- end }}

{{- end }}

{{/*
Create the name of the Lightstreamer Kafka Connector.
*/}}
{{- define "lightstreamer.kafka-connector.name" -}}
{{- printf "kafka-connector" }}
{{- end }}

{{/*
Create the download URL of the Lightstreamer Kafka Connector.
*/}}
{{- define "lightstreamer.kafka-connector.url" -}}
{{- printf "https://github.com/Lightstreamer/Lightstreamer-kafka-connector/releases/download/v%s/lightstreamer-kafka-connector-%s.zip" . . }}
{{- end }}

{{/*
Create the name of the deployment folder the Lightstreamer Kafka Connector.
*/}}
{{- define "lightstreamer.kafka-connector.deployment.dir" -}}
{{- printf "%s/kafka-connector" (include "lightstreamer.adapters.deployment.dir" .) }}
{{- end }}

{{- define "lightstreamer.kafka-connector.schemas.dir.name" -}}
{{- printf "schemas" }}
{{- end }}

{{/*
Create the name of the logs folder for the Lightstreamer Kafka Connector.
*/}}
{{- define "lightstreamer.kafka-connector.logs.dir" -}}
{{- printf (include "lightstreamer.logs.dir" .)  }}
{{- end }}

{{/*
Render the truststore settings for the Lightstreamer Kafka Connector configuration file.
*/}}
{{- define "lightstreamer.kafka-connector.configuration.truststore" -}}
{{- $prefix := index . 0 -}}
{{- $top := index . 1 -}}
{{- $key := index . 2 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}

<param name="{{ $prefix }}.path">{{ include "lightstreamer.keystores.dir" . }}/{{ $key }}/{{ required (printf "keystores.%s.keystoreFileSecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

<!-- Optional. The password of the trust store.

     If not set, checking the integrity of the trust store file configured will not
     be possible. -->
<param name="{{ $prefix }}.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

{{- if not (quote $keyStore.type | empty) }}
  {{- if not (mustHas $keyStore.type (list "JKS" "PKCS12")) }}
    {{- fail (printf "keystores.%s.type must be one of: \"JKS\", \"PKCS12\"" $key) }}
  {{- end }}

<!-- Optional. The type of the trust store. Can be one of the following:

      - JKS
      - PKCS12

      Default value: JKS. -->
<param name="{{ $prefix }}.type">{{ $keyStore.type }}</param>
{{- end -}}
{{- end -}}

{{/*
Render the keystore settings for the Lightstreamer Kafka Connector configuration file.
*/}}
{{- define "lightstreamer.kafka-connector.configuration.keystore" -}}
{{- $prefix := index . 0 -}}
{{- $top := index . 1 -}}
{{- $key := index . 2 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}
<!-- Optional. Enable a key store. Can be one of the following:
      - true
      - false

      A key store is required if the mutual TLS is enabled on Kafka.

      If enabled, the following parameters configure the key store settings:
      - encryption.keystore.path
      - encryption.keystore.type
      - encryption.keystore.password
      - encryption.keystore.key.password

      Default value: false. -->
<param name="{{ $prefix }}.enable">true</param>

<!-- Mandatory if key store is enabled. The path of the key store file, relative to
      the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>). -->
<param name="{{ $prefix }}.path">{{ include "lightstreamer.keystores.dir" . }}/{{ $key }}/{{ required (printf "keystores.%s.keystoreFilesecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

<!-- Optional. The password of the key store.

      If not set, checking the integrity of the key store file configured
      will not be possible. -->
<param name="{{ $prefix }}.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

{{- if $keyStore.keyPasswordSecretRef }}

<!-- Optional. The password of the private key in the key store file. -->
<param name="{{ $prefix }}.key.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_KEY_PASSWORD</param>
{{- end }}

{{- if not (quote $keyStore.type | empty) }}
  {{- if not (mustHas $keyStore.type (list "JKS" "PKCS12")) }}
    {{- fail (printf "keystores.%s.type must be one of: \"JKS\", \"PKCS12\"" $key) }}
  {{- end }}

<!-- Optional. The type of the key store.
      Can be one of the following:
      - JKS
      - PKCS12

      Default value: JKS. -->
<param name="{{ $prefix }}.keystore.type">{{ $keyStore.type }}</param>
{{- end -}}
{{- end -}}

{{/*
Render the key/value record evaluator settings for the Lightstreamer Kafka Connector configuration file.
*/}}
{{- define "lightstreamer.kafka-connector.configuration.record.evaluator" -}}
{{- $ := index . 0 -}}
{{- $connection := index . 1 -}}
{{- $keyOrValue := index . 2 -}}
{{- $evaluator := get $connection.record (printf "%sEvaluator" $keyOrValue) }}
{{- if $evaluator }}
  {{- $localSchemaFiles := $.Values.connectors.kafkaConnector.localSchemaFiles }}
  {{- $key := index . 3 -}}
  {{- $type := $evaluator.type | default "STRING" }}
  {{- $protobufMessageType := $evaluator.protobufMessageType }}
  {{- if not (mustHas $type (list "AVRO" "JSON" "PROTOBUF" "KVP" "STRING" "INTEGER" "BOOLEAN" "BYTE_ARRAY" "BYTE_BUFFER" "BYTES" "DOUBLE" "FLOAT" "LONG" "SHORT" "UUID")) }}
    {{- fail (printf "connectors.kafkaConnector.connections.%s.record.%sEvaluator.type must be one of: \"AVRO\", \"JSON\", \"PROTOBUF\", \"KVP\", \"STRING\", \"INTEGER\", \"BOOLEAN\", \"BYTE_ARRAY\", \"BYTE_BUFFER\", \"BYTES\", \"DOUBLE\", \"FLOAT\", \"LONG\", \"SHORT\", \"UUID\"" $key $keyOrValue) }}
  {{- end }}
<!-- Optional. The format to be used to deserialize respectively the key and value of a
     Kafka record. Can be one of the following:

     - AVRO
     - JSON
     - PROTOBUF
     - KVP
     - STRING
     - INTEGER
     - BOOLEAN
     - BYTE_ARRAY
     - BYTE_BUFFER
     - BYTES
     - DOUBLE
     - FLOAT
     - LONG
     - SHORT
     - UUID

     Default: STRING -->
<param name="record.{{ $keyOrValue }}.evaluator.type">{{ $type }}</param>

  {{- if has $type (list "AVRO" "JSON" "PROTOBUF") -}}
    {{- if $evaluator.enableSchemaRegistry }}
      {{- $schemaRegistryRef := $connection.record.schemaRegistryRef }}
      {{- if not $schemaRegistryRef }}
        {{- fail (printf "Either set connectors.kafkaConnector.connections.%s.record.schemaRegistryRef or disable connectors.kafkaConnector.connections.%s.record.%sEvaluator.enableSchemaRegistry" $key $key $keyOrValue) }}
      {{- end }}

      {{- $schemaRegistry := required (printf "connectors.kafkaConnector.schemaRegistries.%s not defined" $schemaRegistryRef) (get ($.Values.connectors.kafkaConnector.schemaRegistries | default (dict)) $schemaRegistryRef) }}
      {{- $schemaRegistryProvider := $schemaRegistry.provider | default "CONFLUENT" }}
      {{- $_ := set $schemaRegistry "provider" $schemaRegistryProvider }}

      {{- if not (mustHas $schemaRegistryProvider (list "CONFLUENT" "AZURE")) }}
        {{- fail (printf "connectors.kafkaConnector.schemaRegistries.%s.provider must be one of: \"CONFLUENT\", \"AZURE\"" $schemaRegistryRef) }}
      {{- end }}
      {{- $_ := required (printf "connectors.kafkaConnector.schemaRegistries.%s.url must be set" $schemaRegistryRef) $schemaRegistry.url }}

      {{- if and (eq $schemaRegistryProvider "AZURE") (eq $type "PROTOBUF") }}
        {{- fail (printf "connectors.kafkaConnector.schemaRegistries.%s with provider AZURE does not support PROTOBUF evaluator type" $schemaRegistryRef) }}
      {{- end }}

      {{- /* Triggers rendering of the Schema Registry settings */ -}}
      {{- $_ := set $connection.record "renderSchemaRegistry" true }}
      {{- /* Set the whole schema registry configuration in the current context, to be used for rendering the schema registry settings */ -}}
      {{- $_ := set $connection.record "schemaRegistry" $schemaRegistry }}

<!-- Mandatory when the evaluator type is set to "AVRO" or "PROTOBUF" and no local schema
     paths are provided. Enables the use of a Schema Registry for validation respectively of
     the key and value. Can be one of the following:

     - true
     - false

      Default value: false. -->
<param name="record.{{ $keyOrValue }}.evaluator.schema.registry.enable">true</param>
    {{- else }}
      {{- with $evaluator.localSchemaFilePathRef }}
        {{ $localSchema := required (printf "connectors.kafkaConnector.localSchemaFiles.%s not defined" . ) (get ($localSchemaFiles | default dict) .) }}

<!-- Mandatory if evaluator type is set to "AVRO" or "PROTOBUF" and no Schema Registry is
     enabled. The path of the local schema (or binary descriptor) file, relative to the
     deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>) or as an
     absolute path, for message validation respectively of the key and the value. -->
<param name="record.{{ $keyOrValue }}.evaluator.schema.path">{{ include "lightstreamer.kafka-connector.schemas.dir.name" . }}/{{ . }}/{{ required (printf "connectors.kafkaConnector.localSchemaFiles.%s.key must be set" .) $localSchema.key }}</param>
        {{ if (eq $type "PROTOBUF") }}

<!-- Mandatory when the evaluator type is set to "PROTOBUF" and a binary descriptor file is
     provided through the "record.key/value.evaluator.schema.path" parameters. Specifies the
     name of the Protobuf message type to be used for deserializing the key and value of a
     Kafka record.
-->
<param name="record.{{ $keyOrValue }}.evaluator.protobuf.message.type">{{ required (printf "connectors.kafkaConnector.connections.%s.record.%sEvaluator.protobufMessageType must be set" $key $keyOrValue) $protobufMessageType }}</param>
        {{- end }}
      {{- else }}
        {{- if has $type (list "AVRO" "PROTOBUF") }}
          {{- fail (printf "Either set connectors.kafkaConnector.connections.%s.record.%sEvaluator.localSchemaFilePathRef or enable connectors.kafkaConnector.connections.%s.record.%sEvaluator.enableSchemaRegistry" $key $keyOrValue $key $keyOrValue) }}
        {{- end }}
      {{- end }} {{/* of .localSchemaFilePathRef */}}
    {{- end }} {{/* of .enableSchemaRegistry */}}
  {{- else if eq $type "KVP" }}
    {{- $keyValueSeparator := ($evaluator.kvp).keyValueSeparator | default "=" }}
    {{- $pairSeparator := ($evaluator.kvp).pairsSeparator | default "," }}

<!-- Optional but only effective when "record.key/value.evaluator.type" is set to "KVP".
     Specifies the symbol used to separate keys from values in a record key (or record
     value) serialized in the KVP format.

     Default value: "=".
-->
<param name="record.{{ $keyOrValue }}.evaluator.kvp.key-value.separator">{{ $keyValueSeparator }}</param>

<!-- Optional but only effective when "record.key/value.evaluator.type" is set to "KVP".
     Specifies the symbol used to separate multiple key-value pairs in a record key (or
     record value) serialized in the KVP format.

     Default value: ",".
-->
<param name="record.{{ $keyOrValue }}.evaluator.kvp.pairs.separator">{{ $pairSeparator }}</param>
  {{- end }} {{/* of has $type (list "AVRO" "JSON" "PROTOBUF") */}}
{{- end }}
{{- end }}

{{/*
Validate all the adapter set configurations, ensuring that:
- No duplicate adapter set ids exist.
- Possible provided provisioning settings are defined consistently.
- Either a in-process or proxy metadata adapter is defined for each enabled adapter set.
- An adapter class name is defined for each in-process metadata adapter.
- A request/reply port is defined for each proxy metadata adapter.
- An install dir is specified when using a "dedicated" class loader.
- A valid class loader is specified.
- At least one enabled data provider is defined for each enabled adapter set.
- Either a in-process or proxy data adapter is defined for each enabled data provider.
- No duplicate data provider names exist for each enabled adapter set.
- An adapter class name is defined for each in-process data adapter.
- A request/reply port is defined for each proxy data adapter.
- No clashing ports exist.
*/}}
{{- define "lightstreamer.adapters.validateAllAdapterSets" -}}
{{- $userAdapterIds := list }}
{{- $usedPorts := list }}
{{- /*$ := . */}}
{{- range $adapterName, $adapterSet := .Values.adapters}}
  {{- if not $adapterSet }}
    {{- fail (printf "adapters.%s must be set" $adapterName) }}
  {{- end }}
  {{- if $adapterSet.enabled }}
    {{/* Check the adapter sets ids */}}
    {{- $adapterId := required (printf "adapters.%s.id must be set" $adapterName) $adapterSet.id }}
    {{- if has $adapterId $userAdapterIds }}
      {{- fail (printf "adapters.%s.id \"%s\" already used" $adapterName $adapterId ) }}
    {{- end }}
    {{- $userAdapterIds = append $userAdapterIds $adapterId }}

    {{- $requireProvisioning := false }}
    {{- $metadataProvider := required (printf "adapters.%s.metadataProvider must be set" $adapterName) $adapterSet.metadataProvider -}}
    {{- $inProcess := $metadataProvider.inProcessMetadataAdapter }}
    {{- if $inProcess }}
      {{/* Check the in-process metadata adapter class name */}}
      {{- $adapterClass := required (printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.adapterClass must be set" $adapterName) $inProcess.adapterClass }}
      {{- $requireProvisioning = not (eq $adapterClass "com.lightstreamer.adapters.metadata.LiteralBasedProvider") }}

      {{/* Check the ClassLoader */}}
      {{- $classLoaderErrMsg := include "lightstreamer.adapters.in-process.common.validateClassLoader" $inProcess }}
      {{- if $classLoaderErrMsg }}
        {{- printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.classLoader %s" $adapterName $classLoaderErrMsg | fail }}
      {{- end }}

      {{/* Check the install dir */}}
      {{- if and ($inProcess.classLoader | eq "dedicated") (not $inProcess.installDir) }}
        {{- fail (printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.installDir must be set when using a dedicated class loader" $adapterName) }}
      {{- end }}
    {{- else if $metadataProvider.proxyMetadataAdapter }}
      {{- $proxy := $metadataProvider.proxyMetadataAdapter | default dict }}
      {{/* Check the proxy metadata adapter request/reply port */}}
      {{- $requestReplyPort := int (required (printf "adapters.%s.metadataProvider.proxyMetadataAdapter.requestReplyPort must be set" $adapterName) $proxy.requestReplyPort) }}
      {{- if has $requestReplyPort $usedPorts }}
        {{- fail (printf "adapters.%s.metadataProvider.proxyMetadataAdapter.requestReplyPort \"%d\" already used" $adapterName $requestReplyPort ) }}
      {{- end }}
      {{- $usedPorts = append $usedPorts $requestReplyPort }}
    {{- else }}
      {{- printf "Either specify \"inProcessMetadataAdapter\" or \"proxyMetadataAdapter\" in adapters.%s.metadataProvider " $adapterName | fail }}
    {{- end }}

    {{- $enabledDataProviders := list }}
    {{- $dataProviders := required (printf "adapters.%s.dataProviders must be set" $adapterName) $adapterSet.dataProviders }}
    {{- range $dataProviderKey, $dataProvider := $dataProviders }}
      {{- if not $dataProvider }}
        {{- fail (printf "adapters.%s.dataProviders.%s must be set" $adapterName $dataProviderKey) }}
      {{- end }}

      {{- if $dataProvider.enabled }}
        {{/* Check the data provider name */}}
        {{- $dataProviderName := default "DEFAULT" $dataProvider.name }}

        {{- if has $dataProviderName $enabledDataProviders }}
          {{- fail (printf "adapters.%s.dataProviders.%s.name \"%s\" already used" $adapterName $dataProviderKey $dataProviderName ) }}
        {{- end }}
        {{- $enabledDataProviders = append $enabledDataProviders $dataProviderName }}

        {{- if $dataProvider.inProcessDataAdapter }}
          {{- $requireProvisioning = true }}
          {{- $inProcess := $dataProvider.inProcessDataAdapter | default dict }}
          {{/* Check the in-process data adapter class name */}}
          {{- $adapterClass := required (printf "adapters.%s.dataProviders.%s.inProcessDataAdapter.adapterClass must be set" $adapterName $dataProviderKey) $inProcess.adapterClass }}

          {{/* Check the ClassLoader */}}
          {{- $classLoaderErrMsg := include "lightstreamer.adapters.in-process.common.validateClassLoader" $inProcess }}
          {{- if $classLoaderErrMsg }}
            {{- printf "adapters.%s.dataProviders.%s.inProcessDataAdapter.classLoader %s" $adapterName $dataProviderKey $classLoaderErrMsg | fail }}
          {{- end }}

          {{/* Check the install dir */}}
          {{- if and ($inProcess.classLoader | eq "dedicated") (not $inProcess.installDir) }}
            {{- fail (printf "adapters.%s.dataProviders.%s.inProcessDataAdapter.installDir must be set when using a dedicated class loader" $adapterName $dataProviderKey) }}
          {{- end }}
        {{- else if $dataProvider.proxyDataAdapter }}
          {{- $proxy := $dataProvider.proxyDataAdapter | default dict }}

          {{/* Check the request/reply port */}}
          {{- $dataProviderPort := int (required (printf "adapters.%s.dataProviders.%s.proxyDataAdapter.requestReplyPort must be set" $adapterName $dataProviderKey) $proxy.requestReplyPort) }}
          {{- if has $dataProviderPort $usedPorts }}
            {{- fail (printf "adapters.%s.dataProviders.%s.proxyDataAdapter.requestReplyPort \"%d\" already used" $adapterName $dataProviderKey $dataProviderPort ) }}
          {{- end }}
          {{- $usedPorts = append $usedPorts $dataProviderPort }}
        {{- else }}
          {{- printf "Either specify \"inProcessDataAdapter\" or \"proxyDataAdapter\" in adapters.%s.dataProviders.%s " $adapterName $dataProviderKey | fail }}
        {{- end }}
      {{- end }}
    {{- end }} {{/* of $dataProviders */}}
    {{- if $enabledDataProviders | empty }}
      {{- fail (printf "At least one enabled data provider must be defined for adapters.%s" $adapterName) }}
    {{- end }}
    {{/* Check the provisioning settings */}}
    {{- if $requireProvisioning }}
      {{- $_ := set $adapterSet "requireProvisioning" true }}
      {{- include "lightstreamer.adapters.validateProvisioning" (list $ $adapterName $adapterSet) }}
    {{- end }}

  {{- end }} {{/* of $adapterSet.enabled */}}
{{- end }}
{{- end }}

{{/*
Validate the Adapter ClassLoader.
*/}}
{{- define "lightstreamer.adapters.in-process.common.validateClassLoader" -}}
{{- if not (quote .classLoader | empty) }}
{{- $possibleValues := list "common" "dedicated" "log-enabled" }}
{{- if not (has .classLoader $possibleValues) }}
  {{- printf "must be one of: %s" (join ", " $possibleValues) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Validate the Adapter provisioning setting.
*/}}
{{- define "lightstreamer.adapters.validateProvisioning" -}}
{{- $ := index . 0 }}
{{- $adapterSetName := index . 1 }}
{{- $adapterSet := index . 2 }}
{{/* List of admitted provisioning methods */}}
{{- $admittedProvisioningMethods := list "fromPathInImage" "fromVolume" }}

{{- if not $adapterSet.provisioning }}
  {{- fail (printf "adapters.%s.provisioning must be set as at least one in-process (metadata/data) adapter has been defined" $adapterSetName) }}
{{- end }}

{{- $methods := list }}
{{- range $methodName, $method := $adapterSet.provisioning }}
  {{- if and (has $methodName $admittedProvisioningMethods) $method }}
    {{- $methods = append $methods $methodName }}
  {{- end }}
{{- end }}

{{/* Check that only one provisioning method is set */}}
{{- if or (not $methods) (gt (len $methods) 1) }}
  {{- fail (printf "adapters.%s.provisioning must be one of: %s" $adapterSetName (join ", " $admittedProvisioningMethods)) }}
{{- end }}
{{- $chosenMethodName := $methods | first }}
{{- if eq $chosenMethodName "fromVolume" }}
  {{/* Check and validate fromVolume.name */}}
  {{- $name := required (printf "adapters.%s.provisioning.fromVolume.name must be set" $adapterSetName) $adapterSet.provisioning.fromVolume.name }}
  {{- include "lightstreamer.validateExtraVolumeRef" (list $.Values.deployment.extraVolumes $name (printf "adapters.%s.provisioning.fromVolume.name" $adapterSetName)) }}
{{- end }}
{{- end }}

{{/*
Create the pages source path, used as the volume mount base path when the "pagesVolume" is configured.
*/}}
{{- define "lightstreamer.webServer.pages-source.dir" -}}
{{- printf "/pages-source" }}
{{- end }}

{{/*
Validate the sharedDir provisioning setting.
*/}}
{{- define "lightstreamer.sharedDir.validateProvisioning" -}}
{{- with .Values.sharedDir }}
  {{- $admittedProvisioningMethods := list "fromPathInImage" "fromVolume" }}
  {{- $methods := list }}
  {{- if .fromPathInImage }}
    {{- $methods = append $methods "fromPathInImage" }}
  {{- end }}
  {{- if (.fromVolume).name }}
    {{- $methods = append $methods "fromVolume" }}
  {{- end }}

  {{- /* Check that at most one provisioning method is set */ -}}
  {{- if gt (len $methods) 1 }}
    {{- fail (printf "sharedDir: only one of %s can be set" $admittedProvisioningMethods) }}
  {{- end }}

  {{- /* When fromVolume is the chosen method, check that it is correctly set */ -}}
  {{- if and $methods (eq ($methods | first) "fromVolume") }}
    {{- include "lightstreamer.validateExtraVolumeRef" (list $.Values.deployment.extraVolumes .fromVolume.name "sharedDir.fromVolume.name") }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Create the shared directory source path, used as the volume mount base path when the "sharedDir.fromVolume" provisioning method is used.
*/}}
{{- define "lightstreamer.shared.source.dir" -}}
{{- printf "/shared-source" }}
{{- end }}

{{/*
Create the Adapters path name, relative to the Lightstreamer conf directory.
*/}}
{{- define "lightstreamer.adapters.deployment.dir" -}}
{{- printf "/deployed_adapters" }}
{{- end }}

{{/*
Create the Adapters source repository path, used as the volume mount base path when the "fromVolume" provisioning method is used.
*/}}
{{- define "lightstreamer.adapters.source-repo.dir" -}}
{{- printf "/tmp/adapters-source-repo" }}
{{- end }}

{{/*
Create the Adapters source configuration path, used as the volume mount base path for the source configuration files.
*/}}
{{- define "lightstreamer.adapters.source-conf.dir" -}}
{{- printf "/tmp/adapters-source-conf" }}
{{- end }}

{{/*
Create the name of the configmap containing the adapters.xml file of a specific adapter.
*/}}
{{- define "lightstreamer.adapters.configMapName" -}}
{{- $ := index . 0 }}
{{- $adapterName := index . 1 }}
{{- include "lightstreamer.fullname" $ }}-{{ $adapterName | kebabcase }}-adapter-conf
{{- end }}

{{/*
Create the port reference for a proxy adapter configuration.
*/}}
{{- define "lightstreamer.adapters.proxyPortName" -}}
{{ . | kebabcase | trunc 15 | trimSuffix "-" }}
{{- end }}

{{/*
Create the Java class name of the Proxy Meta/Data Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.common.class" -}}
{{- .enableRobustAdapter | default false | ternary "ROBUST_PROXY_FOR_REMOTE_ADAPTER" "PROXY_FOR_REMOTE_ADAPTER" -}}
{{- end }}

{{/*
Render the <authentication_pool> block for the in-process Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.metadata-provider.authenticationPool" }}
<!-- Optional. Configures the specific "AUTHENTICATION"
     thread pool, expressly devoted to the calls to the authentication
     method against this Metadata Adapter. Note that the authentication method
     is "notifyUser" for Adapters leveraging the old callback-based
     Java In-Process Adapter SDK and "loginAsync" for Adapters leveraging
     the new object-based Java In-Process Adapter SDK v9+.
     This pool is always created, however the authentication method
     is required to be implemented asynchronously, hence the calls
     are not supposed to keep threads engaged.
     In order to keep track of the pending asynchronous requests,
     they are counted in the global statistics as part of the pool
     task queue (but not as contributing to the pool queue wait).

     By default, the pool has one fixed thread. If this block
     is defined, its <max_size> and <max_free> subelements, with meaning
     similar to that of the global <server_pool_max_size> and
     <server_pool_max_free> settings, are optional, both with default 1.
     In fact, it is not expected that more than one thread will ever be
     needed, since the implementations of the authentication method
     are required to be fast and non-blocking and to perform
     any slow processing asynchronously.

     On the other hand, configuring the pool is recommended, to constrain
     the maximum number of pending requests to the Metadata Adapter
     through the optional <max_pending_requests> subelement
     (if set <= 0, it poses no limitation; this is also the default).
     It is also possible to enforce a timeout check on the asynchronous
     requests, to prevent a buggy Adapter that never yields response to
     some requests from causing a memory leak. The checks are done lazily
     (if set <= 0, no check will be done; this is also the default).
     The optional <max_queue> subelement is also available, with meaning
     similar to the global <server_pool_max_queue>. If defined,
     the length of the queue of this pool, instead of being added to the
     length checked by <server_pool_max_queue>, will be checked against
     this limit, but with the same consequent backpressure actions. -->
{{- include "lightstreamer.adapters.metadata-provider.authenticationPool" (list false .) }}
{{- end }}

{{/*
Render the <messages_pool> block for the in-process Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.metadata-provider.messagesPool" }}
<!-- Optional. Configures the specific "MSG" thread pool,
     expressly devoted to the calls of the method which handles
     messa     ges sent by the client, against this Metadata Adapter.
     Note that the message-processing method is "notifyUserMessage"
     for Adapters leveraging the old callback-based
     Java In-Process Adapter SDK and
     "SessionAdapter::userMessageAsync" for Adapters leveraging
     the new object-based Java In-Process Adapter SDK v9+.
     This pool is always created, however the message-processing
     method is required to be implemented asynchronously, hence the calls
     are not supposed to keep threads engaged.
     In order to keep track of the pending asynchronous requests,
     they are counted in the global statistics as part of the pool
     task queue (but not as contributing to the pool queue wait).

     By default, the pool has one fixed thread. If this block
     is defined, its <max_size> and <max_free> subelements, with meaning
     similar to that of the global <server_pool_max_size> and
     <server_pool_max_free> settings, are optional, both with default 1.
     In fact, it is not expected that more than one thread will ever be
     needed, since the implementations of the message-processing method
     are require to be fast and non-blocking and to perform
     any slow processing asynchronously.

     On the other hand, configuring the pool is recommended, to constrain
     the maximum number of pending requests to the Metadata Adapter
     through the optional <max_pending_requests> subelement
     (if set <= 0, it poses no limitation; this is also the default).
     It is also possible to enforce a timeout check on the asynchronous
     requests, to prevent a buggy Adapter that never yields response to
     some requests from causing a memory leak. The checks are done lazily
     (if set <= 0, no check will be done; this is also the default).
     The optional <max_queue> subelement is also available, with meaning
     similar to the global <server_pool_max_queue>. If defined,
     the length of the queue of this pool, instead of being added to the
     length checked by <server_pool_max_queue>, will be checked against
     this limit, but with the same consequent backpressure actions. -->
{{- include "lightstreamer.adapters.metadata-provider.messagesPool" (list false .) }}
{{- end }}

{{/*
Render the <mpn_pool> block for the in-process Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.metadata-provider.mpnPool" }}
<!-- Optional. Requests the creation of a specific "MPN REQUESTS" thread
     pool, devoted to the management of all the mobile push notification
     requests pertaining to sessions based on this Adapter Set.

     If not defined, these calls are managed by the thread pool related
     with the Adapter Set, if, in turn, defined.
     If defined, the <max_size> and <max_free> elements are mandatory,
     with meaning similar to that of the global <server_pool_max_size>
     and <server_pool_max_free> settings.
     Using a specific thread pool is advisable if implementation
     of MPN operations (like "notifyMpnSubscriptionActivation" in both
     SDKs) may introduce delays. -->
{{- include "lightstreamer.adapters.metadata-provider.mpnPool" . }}
{{- end }}

{{/*
Render the custom initialization parameters for the in-process Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.metadata-provider.initParams" }}
<!-- Optional. List of initialization parameters specific to the adapter.
     The various <param> elements are not interpreted by Lightstreamer,
     but they are forwarded to the "init" method of the adapter.

     In addition, the following parameter, with obvious meaning,
     is always provided by the Server:
     - adapters_conf.id
     Note that this parameter is reserved and cannot be overridden
     by configuration.
{{- range $paramName, $paramValue := .initParams }} -->
<param name="{{ $paramName }}">{{ $paramValue }}</param>
{{- else }}

     Below are configurations of sample parameters, meant to be handled
     by the specified Metadata Adapter. -->

<!-- Optional. Sample log configuration; the path is relative to <install_dir>. -->
<!--
<param name="log_config">../adapters_log_conf.xml</param>
-->

<!-- Optional. Sample configuration for a bandwidth constraint to be returned. -->
<!--
<param name="max_bandwidth">50</param>
-->
{{- end }}
{{- end }}

{{/*
Render the <authentication_pool> block for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.authenticationPool" }}
<!-- Optional. Configures the specific "AUTHENTICATION"
     thread pool, expressly devoted to the calls of Notify User against
     the Remote Metadata Adapter.
     This pool is always created and the
     Notify User calls to Proxy Adapters are performed
     asynchronously, hence they are not supposed to keep threads engaged.
     In order to keep track of the pending asynchronous requests,
     they are counted in the global statistics as part of the pool
     task queue (but not as contributing to the pool queue wait).

     By default, the pool has one fixed thread. If this block
     is defined, its <max_size> and <max_free> subelements, with meaning
     similar to that of the global <server_pool_max_size> and
     <server_pool_max_free> settings, are optional, both with default 1.
     In fact, it is not expected that more than one thread will ever be
     needed, since the pool{{ "'" }}s only task is to forward the Notify User
     requests.
     On the other hand, configuring the pool is recommended, to constrain
     the maximum number of pending requests to the Remote Metadata Adapter
     through the optional <max_pending_remote_requests> subelement
     (if set <= 0, it poses no limitation; this is also the default).
     The optional <max_queue> subelement is also available, with meaning
     similar to the global <server_pool_max_queue>. If defined,
     the length of the queue of this pool, instead of being added to the
     length checked by <server_pool_max_queue>, will be checked against
     this limit, but with the same consequent backpressure actions. -->
{{- include "lightstreamer.adapters.metadata-provider.authenticationPool" (list true .) }}
{{- end }}

{{/*
Render the <messages_pool> block for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.messagesPool" }}
<!-- Optional. Configures the specific "MSG" thread pool,
     expressly devoted to the calls of Notify User Message, which
     handle messages sent by the client, against the Remote Metadata Adapter.
     This pool is always created and the
     Notify User Message calls to Proxy Adapters are performed
     asynchronously, hence they are not supposed to keep threads engaged.
     In order to keep track of the pending asynchronous requests,
     they are counted in the global statistics as part of the pool
     task queue (but not as contributing to the pool queue wait).

     By default, the pool has one fixed thread. If this block
     is defined, its <max_size> and <max_free> subelements, with meaning
     similar to that of the global <server_pool_max_size> and
     <server_pool_max_free> settings, are optional, both with default 1.
     In fact, it is not expected that more than one thread will ever be
     needed, since the pool{{ "'" }}s only task is to forward the Notify User
     requests.
     On the other hand, configuring the pool is recommended, to constrain
     the maximum number of pending requests to the Remote Metadata Adapter
     through the optional <max_pending_remote_requests> subelement
     (if set <= 0, it poses no limitation; this is also the default).
     The optional <max_queue> subelement is also available, with meaning
     similar to the global <server_pool_max_queue>. If defined,
     the length of the queue of this pool, instead of being added to the
     length checked by <server_pool_max_queue>, will be checked against
     this limit, but with the same consequent backpressure actions. -->
{{- include "lightstreamer.adapters.metadata-provider.messagesPool" (list true .) }}
{{- end }}

{{/*
Render the <mpn_pool> block for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.mpnPool" }}
<!-- Optional. Requests the creation of a specific "MPN REQUESTS" thread
     pool, devoted to the submission to the Remote Metadata Adapter
     of all the mobile push notification requests pertaining to sessions
     based on this Adapter Set.

     If not defined, these calls are managed by the thread pool related
     with the Adapter Set, if, in turn, defined.
     If defined, the <max_size> and <max_free> elements are mandatory,
     with meaning similar to that of the global <server_pool_max_size>
     and <server_pool_max_free> settings. Note that <max_size> also
     indicates the maximum number of pending requests to the Remote
     Metadata Adapter.
     Using a specific thread pool is advisable if the implementation
     of MPN operations (like Notify MPN Subscription Activation etc.)
     may introduce delays. -->
{{- include "lightstreamer.adapters.metadata-provider.mpnPool" . -}}
{{- end }}

{{/*
Render the <authenticationPool> block for the Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.metadata-provider.authenticationPool" -}}
{{- $isRemote := index . 0 }}
{{- $parent := index . 1 }}
{{- with $parent.authenticationPool }}
<authentication_pool>
  {{- if not (quote .maxSize | empty) }}
    <max_size>{{ int .maxSize }}</max_size>
  {{- end }}
  {{- if not (quote .maxFree | empty) }}
    <max_free>{{ int .maxFree }}</max_free>
  {{- end }}
  {{- if $isRemote }}
    {{- if not (quote .maxPendingRemoteRequests | empty) }}
    <max_pending_remote_requests>{{ int .maxPendingRemoteRequests }}</max_pending_remote_requests>
    {{- end }}
  {{- else}}
    {{- if not (quote .maxPendingRequests | empty) }}
    <max_pending_requests>{{ int .maxPendingRequests }}</max_pending_requests>
    {{- end }}
    {{- if not (quote .taskTimeoutMillis | empty) }}
    <task_timeout_millis>{{ int .taskTimeoutMillis }}</task_timeout_millis>
    {{- end }}
  {{- end }}
  {{- if not (quote .maxQueue | empty) }}
    <max_queue>{{ int .maxQueue }}</max_queue>
  {{- end }}
</authentication_pool>
{{- else }}
<!--
<authentication_pool>
    <max_size>1</max_size>
    <max_free>1</max_free>
    <max_pending_requests>100</max_pending_requests>
    <max_queue>100</max_queue>
</authentication_pool>
-->
{{- end }}
{{- end }}

{{/*
Render the <messages_pool> block for the Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.metadata-provider.messagesPool" -}}
{{- $isRemote := index . 0 }}
{{- $parent := index . 1 }}
{{- with $parent.messagesPool}}
<messages_pool>
  {{- if not (quote .maxSize | empty) }}
    <max_size>{{ int .maxSize }}</max_size>
  {{- end }}
  {{- if not (quote .maxFree | empty) }}
    <max_free>{{ int .maxFree }}</max_free>
  {{- end }}
  {{- if $isRemote }}
    {{- if not (quote .maxPendingRemoteRequests | empty) }}
    <max_pending_remote_requests>{{ int .maxPendingRemoteRequests }}</max_pending_remote_requests>
    {{- end }}
  {{- else}}
    {{- if not (quote .maxPendingRequests | empty) }}
    <max_pending_requests>{{ int .maxPendingRequests }}</max_pending_requests>
    {{- end }}
    {{- if not (quote .taskTimeoutMillis | empty) }}
    <task_timeout_millis>{{ int .taskTimeoutMillis }}</task_timeout_millis>
    {{- end }}
  {{- end }}
  {{- if not (quote .maxQueue | empty) }}
    <max_queue>{{ int .maxQueue }}</max_queue>
  {{- end }}
</messages_pool>
{{- else }}
<!--
<messages_pool>
    <max_size>1</max_size>
    <max_free>1</max_free>
    <max_pending_requests>100</max_pending_requests>
    <max_queue>100</max_queue>
</messages_pool>
-->
{{- end }}
{{- end }}

{{/*
Render the <mpn_pool> block for the Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.metadata-provider.mpnPool" -}}
{{- $adapterName := index . 0 }}
{{- $parent := index . 1 }}
{{- with $parent.mpnPool }}
<mpn_pool>
  <max_size>{{ int (required (printf "adapters.%s.metadataProviders.{}.mpnPool.maxSize must be set" $adapterName) .maxSize) }}</max_size>
  <max_free>{{ int (required (printf "adapters.%s.metadataProviders.{}.mpnPool.maxFree must be set" $adapterName) .maxFree) }}</max_free>
</mpn_pool>
{{- else }}
<!--
<mpn_pool>
    <max_size>100</max_size>
    <max_free>10</max_free>
</mpn_pool>
-->
{{- end }}
{{- end }}

{{/*
Render the common parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common" }}
{{- $adapterName := index . 0 }}
{{- $isDataAdapter := index . 1 }}
{{- $proxy := index . 2 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}
{{- $metaOrData := $isDataAdapter | ternary "Data" "Metadata" }}
{{- $commentSuffix := $isRobust | ternary (printf " for all Robust Proxy %s Adapters" $metaOrData) "" }}
<!-- Mandatory{{ $commentSuffix }}.
{{- if $isDataAdapter }}
     The request/reply port to listen on. The connection on this port will
     carry the requests/replies channels.
     However, in case the configuration of "notify_port" has to be
     leveraged, the connection will only carry the pure-replies subpart
     of the replies channel. -->
{{- else}}
     The request/reply port to listen on. The connection on this port will
     carry the requests/replies channels. -->
{{- end }}
<param name="request_reply_port">{{ int $proxy.requestReplyPort }}</param>

{{- if $isDataAdapter}}

<!-- Optional{{ $commentSuffix }}.
     The notification port to listen on. If leveraged, a two-connections
     behavior will be adopted and the connection on this second port
     will be used, unidirectionally, to carry the notifications
     subpart of the replies channel, whereas the request/reply port will
     only carry the pure-replies subpart.
     The two-ports configuration is only available to ensure backward
     compatibility with old Remote Servers, which were based on
     on a two-connections behavior for Remote Data Adapters.
     On the other hand, Remote Servers based on most recent SDK versions
     may even no longer support the two-connections behavior.
     Hence, the choice of a two-ports configuration should match
     the Remote Server behavior. Note that there is no automatic
     detection of how the Remote Server behaves. -->
<!--
<param name="notify_port">6662</param>
-->
{{- end }}

<!-- Optional{{ $commentSuffix }}.
{{- if $isDataAdapter }}
     If set, inverts the normal connection establishment behavior, by having
     the Proxy Adapter open a client socket on the configured request/reply
     port towards the Remote Adapter, using the host address specified here.
     This setting is not compatible with the setting of "notify_port".
     This is not the preferred setting but it can be useful in some scenarios.
     See a discussion in the Adapter Remoting Infrastructure architecture
     document. Obviously, the setting requires a corresponding behavior
     by the Remote Server.
     When this setting is leveraged, most of the other elements and parameters
     are still valid (in particular, the "tls" parameter), although some of their
     descriptions refer to the listening port case and should be reinterpreted;
     only the following ones are ignored:
     - interface
     - tls.enforce_server_cipher_suite_preference
     - tls.enforce_server_cipher_suite_preference.order
     - tls.force_client_auth
     - remote_address_whitelist
     Note, in particular, that the keystore parameters are parameters are available, though
     optional. This allows for authentication of the Proxy Adapter by the
     Remote Server by requesting the Proxy Adapter{{"'"}}s TLS client certificate. -->
{{- else }}
     If set, inverts the normal connection establishment behavior, by having
     the Proxy Adapter open a client socket on the configured request/reply
     port towards the Remote Adapter, using the host address specified here.
     This is not the preferred setting but it can be useful in some scenarios.
     See a discussion in the Adapter Remoting Infrastructure architecture
     document. Obviously, the setting requires a corresponding behavior
     by the Remote Server.
     When this setting is leveraged, most of the other elements and parameters
     are still valid (in particular, the "tls" parameter), although some of their
     descriptions refer to the listening port case and should be reinterpreted;
     only the following ones are ignored:
     - interface
     - tls.enforce_server_cipher_suite_preference
     - tls.enforce_server_cipher_suite_preference.order
     - tls.force_client_auth
     - remote_address_whitelist
     Note, in particular, that the keystore parameters are available, though
     optional. This allows for authentication of the Proxy Adapter by the
     Remote Server by requesting the Proxy Adapter{{"'"}}s TLS client certificate. -->
{{- end }}
{{- if not (quote $proxy.remoteHost | empty) }}
<param name="remote_host">{{ $proxy.remoteHost }}</param>
{{- else }}
<!--
<param name="remote_host">my.host.name</param>
-->
{{- end }}

<!-- Optional{{ $commentSuffix }}.
     The local network interface to bind to.
     If not specified, it will bind to any available interface. -->
{{- if not (quote $proxy.interface | empty) }}
<param name="interface">{{ $proxy.interface }}</param>
{{- else }}
<!--
<param name="interface">192.168.1.1</param>
-->
{{- end }}
{{- end }}

{{/*
Render the tls parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.sslConfig" }}
{{- $adapterName := index . 0}}
{{- $keystores := index . 1 }}
{{- $isDataAdapter := index . 2 }}
{{- $proxy := index . 3 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}
{{- $metaOrData := $isDataAdapter | ternary "Data" "Metadata" }}
{{- $commentSuffix := $isRobust | ternary (printf " for all Robust Proxy %s Adapters" $metaOrData) "" }}
{{- $sslConfig := $proxy.sslConfig | default dict }}
<!-- TLS SETTINGS -->

<!-- Optional{{ $commentSuffix }}.
{{- if $isDataAdapter }}
     If Y, enforces TLS on the listening port.
     The configuration of the port is done in a way similar
     to the TLS configuration in the Server{{"'"}}s <https_server> blocks.
     In case of two-ports configuration, the TLS configuration applies
     the same for both ports.
     See the available parameters below and find their meanings in the
     corresponding configuration elements in the Server configuration file.
     Note that the parameters with multiple values should be distinguished
     from one another by adding a dot-suffix
     (see for instance "tls.remove_cipher_suites" below).
     The choice of the suffix is free; however, if "config" is specified in
     "tls.enforce_server_cipher_suite_preference.order", then only numeric
     suffixes (not necessarily consecutive) will be accepted
     for "tls.allow_cipher_suite", to express the ordering.
     If N, the port configuration parameters below are ignored.
     Default: N. -->
{{- else }}
     If Y, enforces TLS on the listening port.
     The configuration of the port is done in a way similar
     to the TLS configuration in the Server{{"'"}}s <https_server> blocks.
     See the available parameters below and find their meanings in the
     corresponding configuration elements in the Server configuration file.
     Note that the parameters with multiple values should be distinguished
     from one another by adding a dot-suffix
     (see for instance "tls.remove_cipher_suites" below).
     The choice of the suffix is free; however, if "config" is specified in
     "tls.enforce_server_cipher_suite_preference.order", then only numeric
     suffixes (not necessarily consecutive) will be accepted
     for "tls.allow_cipher_suite", to express the ordering.
     If N, the port configuration parameters below are ignored.
     Default: N. -->
{{- end }}
{{- if $sslConfig.enabled }}
<param name="tls">Y</param>
  {{- $keystoreRef := required (printf "adapters.%s.{...}.sslConfig.keystoreRef must be set" $adapterName) $sslConfig.keystoreRef }}
  {{- include "lightstreamer.adapters.proxy.keystore" (list $keystores $sslConfig.keystoreRef) | nindent 0 }}
  {{- $counter := 0}}
  {{- range $index, $cipherSuite := $sslConfig.allowCipherSuites }}
    {{- $counter = add1 $counter }}
<param name="tls.allow_cipher_suite.{{ $counter }}">{{ required (printf "adapters.%s.{...}.sslConfig.allowCipherSuites[%d] must be set" $adapterName $index) $cipherSuite }}</param>
  {{- else }}

<!--
<param name="tls.allow_cipher_suite.1">TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384</param>
-->
<!--
<param name="tls.allow_cipher_suite.2">........</param>
-->
<!--
<param name="tls.allow_cipher_suite.3">........</param>
-->
  {{- end }}

  {{- $counter := 0}}
  {{- range $index, $cipherSuite := $sslConfig.removeCipherSuites }}
    {{- $counter = add1 $counter }}
<param name="tls.remove_cipher_suites.{{ $counter }}">{{ required (printf "adapters.%s.{...}.sslConfig.removeCipherSuites[%d] must be set" $adapterName $index) $cipherSuite }}</param>
  {{- else }}

<!--
<param name="tls.remove_cipher_suites.2">TLS_RSA_</param>
-->
  {{- end }}

  {{- if ($sslConfig.enforceServerCipherSuitePreference).enabled }}
<param name="tls.enforce_server_cipher_suite_preference">Y</param>
    {{- if not (quote $sslConfig.enforceServerCipherSuitePreference.order | empty )}}
<param name="tls.enforce_server_cipher_suite_preference.order">{{ $sslConfig.enforceServerCipherSuitePreference.order }}</param>
    {{- end }}
  {{- else }}

<!--
<param name="tls.enforce_server_cipher_suite_preference">Y</param>
<param name="tls.enforce_server_cipher_suite_preference.order">JVM</param>
-->
  {{- end }}

  {{- $counter := 0}}
  {{- range $index, $allowProtocol :=$sslConfig.allowProtocols }}
    {{- $counter = add1 $counter }}
<param name="tls.allow_protocol.{{ $counter }}">{{ required (printf "adapters.%s.{...}.sslConfig.allowProtocols[%d] must be set" $adapterName $index) $allowProtocol }}</param>
  {{- else }}

<!--
<param name="tls.allow_protocol.2">TLSv1.1</param>
-->
<!--
<param name="tls.allow_protocol.3">TLSv1.3</param>
-->
  {{- end }}

  {{- $counter := 0}}
  {{- range $index, $removeProtocol := $sslConfig.removeProtocols }}
    {{- $counter = add1 $counter }}
<param name="tls.remove_protocols.{{ $counter }}">{{ required (printf "adapters.%s.{...}.sslConfig.removeProtocols[%d] must be set" $adapterName $index) $removeProtocol }}</param>
  {{- else }}

<!--
<param name="tls.remove_protocols.1">TLSv1$</param>
-->
<!--
<param name="tls.remove_protocols.2">TLSv1.1</param>
-->
  {{- end }}

  {{- if $sslConfig.enableMandatoryClientAuth }}
<param name="tls.force_client_auth">{{ $sslConfig.enableMandatoryClientAuth | ternary "Y" "N"}}</param>
  {{- else }}

<!--
<param name="tls.force_client_auth">Y</param>
-->
  {{- end }}

  {{- if $sslConfig.truststoreRef }}
  {{- include "lightstreamer.adapters.proxy.truststore" (list $keystores $sslConfig.truststoreRef) | nindent 0 }}
  {{- end }}

<!-- Optional{{ if $isRobust }} for all Proxy Metadata Adapters{{ end }}.
     Only used if "remote_host" is configured and "tls" is Y.
     If Y, suppresses the check of the hostname in the TLS certificate,
     which, in this context, is received from the Remote Server.
     The setting is only meant to be used in a development/test scenario.
     Default: N. -->
  {{- if not (quote $sslConfig.enableHostnameVerification | empty ) }}
<param name="tls.skip_hostname_check">{{ $sslConfig.enableHostnameVerification | ternary "N" "Y" }}</param>
  {{- else }}
<!--
<param name="tls.skip_hostname_check">N</param>
-->
  {{- end }}
{{- else }}
<!--
<param name="tls">Y</param>
-->
<!--
<param name="tls.keystore.type">JKS</param>
-->
<!--
<param name="tls.keystore.keystore_file">../../conf/myserver.keystore</param>
-->
<!--
<param name="tls.keystore.keystore_password.type">file</param>
-->
<!--
<param name="tls.keystore.keystore_password">../../conf/myserver.keypass</param>
-->
<!--
<param name="tls.allow_cipher_suite.1">TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384</param>
-->
<!--
<param name="tls.allow_cipher_suite.2">........</param>
-->
<!--
<param name="tls.allow_cipher_suite.3">........</param>
-->
<param name="tls.remove_cipher_suites.1">_DHE_</param>
<!--
<param name="tls.remove_cipher_suites.2">TLS_RSA_</param>
-->
<param name="tls.enforce_server_cipher_suite_preference">Y</param>
<param name="tls.enforce_server_cipher_suite_preference.order">JVM</param>
<param name="tls.allow_protocol.1">TLSv1.2</param>
<!--
<param name="tls.allow_protocol.2">TLSv1.1</param>
-->
<!--
<param name="tls.allow_protocol.3">TLSv1.3</param>
-->
<!--
<param name="tls.remove_protocols.1">TLSv1$</param>
-->
<!--
<param name="tls.remove_protocols.2">TLSv1.1</param>
-->
<!--
<param name="tls.force_client_auth">Y</param>
-->
<!--
<param name="tls.truststore.type">JKS</param>
-->
<!--
<param name="tls.truststore.truststore_file">../../conf/myserver.truststore</param>
-->
<!--
<param name="tls.truststore.truststore_password.type">file</param>
-->
<!--
<param name="tls.truststore.truststore_password">../../conf/myserver.trustpass</param>
-->
{{- end }}
{{- end }}

{{/*
Render the authentication parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.authentication" -}}
{{- $adapterName := index . 0 }}
{{- $isDataAdapter := index . 1 }}
{{- $proxy := index . 2 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}
{{- $metaOrData := $isDataAdapter | ternary "Data" "Metadata" }}
{{- $commentSuffix := $isRobust | ternary (printf " for all Robust Proxy %s Adapters" $metaOrData) "" }}
{{- $authentication := $proxy.authentication | default dict }}
<!-- Optional{{ $commentSuffix }}.
{{- if $isDataAdapter }}
     If Y, enforces Remote Adapter authentication on the connection
     based on a user/password credential check.
     In case of two-ports configuration, the same check is performed
     on both connections.
     Note that the user names will be used in log messages at INFO level
     or above, whereas the passwords won{{"'"}}t.
     The configuration of the accepted credentials is shown below.
     Note that the various credential pairs should be distinguished
     from one another by adding a free dot-suffix to the base
     auth.credentials part.
     If N, the credential configuration parameters below are ignored.
     Default: N. -->
{{- else }}
     If Y, enforces Remote Adapter authentication on the connection
     based on a user/password credential check.
     Note that the user names will be used in log messages at INFO level
     or above, whereas the passwords won{{"'"}}t.
     The configuration of the accepted credentials is shown below.
     Note that the various credential pairs should be distinguished
     from one another by adding a free dot-suffix to the base
     auth.credentials part.
     If N, the credential configuration parameters below are ignored.
     Default: N. -->
{{- end }}
{{- if $authentication.enabled }}
<param name="auth">Y</param>
  {{- $counter := 0 }}
  {{- range $index,$secret := required (printf "adapters.%s.{...}.authentication.credentialSecrets must be set" $adapterName) $authentication.credentialSecrets }}
    {{- $_ := required (printf "adapters.%s.{...}.authentication.credentialSecrets[%d] must be set" $adapterName $index) $secret }}
    {{- $counter = add1 $counter }}
<param name="auth.credentials.{{ $counter }}.user">$env.LS_PROXY_ADAPTER_CREDENTIAL_{{ $secret | upper | replace "-" "_" }}_USER</param>
<param name="auth.credentials.{{ $counter }}.password">$env.LS_PROXY_ADAPTER_CREDENTIAL_{{ $secret | upper | replace "-" "_" }}_PASSWORD</param>
  {{- end }}
{{- else }}
<!--
<param name="auth">Y</param>
-->

<!--
<param name="auth.credentials.1.user">user1</param>
-->
<!--
<param name="auth.credentials.1.password">pwd1</param>
-->
<!--
<param name="auth.credentials.2.user">user2</param>
-->
<!--
<param name="auth.credentials.2.password">pwd2</param>
-->
{{- end }}
{{- end }}

{{/*
Render the connection-related timeout settings for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.connection" -}}
{{- $isDataAdapter := index . 0 }}
{{- $proxy := index . 1 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}
{{- $metaOrData := $isDataAdapter | ternary "Data" "Metadata" }}
{{- $commentSuffix := $isRobust | ternary (printf " for all Robust Proxy %s Adapters" $metaOrData) "" }}
<!-- Optional{{ $commentSuffix }}.
     Only used if "remote_host" is configured. Delay to be enforced
     before retrying a connection attempt to the Remote Server,
     to prevent a possible strict loop of unsuccessful attempts.
     Default: 10000. -->
{{- if and (not (quote $proxy.remoteHost | empty)) (not (quote $proxy.connectionRetryMillis | empty)) }}
<param name="connection_retry_millis">{{ int $proxy.connectionRetryMillis }}</param>
{{- else }}
<!--
<param name="connection_retry_millis">1000</param>
-->
{{- end }}

{{- if $isRobust }}

<!-- Optional{{ $commentSuffix }}.
     The timeout for initialization errors. After an unsuccessful attempt
     to achieve a connection from a remote server due to an error
     in configuration, network access or initialization, the Proxy Adapter
     will be allowed to retry listening for connections only after ensuring
     that at least this time has elapsed since the previous attempt.
     A negative value prevents further attempts, so that no remote server
     will be available.
     Default: -1. -->
  {{- if not (quote $proxy.connectionRecoveryTimeoutMillis | empty) }}
<param name="connection_recovery_timeout_millis">{{ int $proxy.connectionRecoveryTimeoutMillis }}</param>
  {{- else }}
<!--
<param name="connection_recovery_timeout_millis">10000</param>
-->
  {{- end }}

<!-- Optional.
     The timeout for the first connection attempt. Upon the Proxy Adapter
     initialization at Lightstreamer Server startup, if a remote server
     is not available, Lightstreamer Server startup can be delayed until
     this timeout expires.
     A negative value stands for an unlimited timeout.
     Note that, when Lightstreamer Server startup completes,
     as long as a connection to a remote server is still missing,
     all client requests will be refused.
     Default: -1. -->
  {{- if not (quote $proxy.firstConnectionTimeoutMillis | empty) }}
<param name="first_connection_timeout_millis">{{ int $proxy.firstConnectionTimeoutMillis }}</param>
  {{- else }}
<!--
<param name="first_connection_timeout_millis">10000</param>
-->
{{- end }}
{{- end }}
{{- end }}

{{/*
Render the notification parameters for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.notification" }}
{{- $adapterName := index . 0 }}
{{- $proxy := index . 1 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}
{{- if $isRobust }}
<!-- Optional.
     The strategy to be adopted whenever a new remote server is available
     in order to resend the state change notifications that could not
     or might not have been sent to the previous remote server.
     This involves the notifications of session closing and the optional
     notifications of table closing.
     Note that the Proxy Adapter has no way of knowing exactly if a
     notification has been processed by a remote server if no answer
     had been received at the time the connection was closed. Also
     consider that the answers from the remote server are not expected
     to come in the same sequence as the requests.
     Hence, no perfect recovery is possible and the remote server must
     be able to deal with an imperfect notification sequence.
     Currently, the only available options are:
     - pessimistic
       All notifications since the first one that could not or may not
       have been processed by the previous remote server are resent
       to the new one.
       This ensures that all notifications are processed at least once,
       but may cause some notifications to be issued for a second time.
       Even notifications that did get an answer could be resent,
       in order to preserve the original sequence.
       Note that timed out requests (see the "timeout" setting) are
       considered as processed.
     - optimistic
       Only notifications after the last one that got an answer by the
       previous remote server are resent to the new one.
     - unneeded
       No notifications are resent. In case the close notifications
       are ignored by the remote server implementation, this can save
       a possibly long playback of unneeded messages.
       Note that table notifications, for both opening and closing, are
       already omitted, unless requested by the remote server through
       the wantsTablesNotification method.
     Default: pessimistic. -->
  {{- if not (quote $proxy.closeNotificationsRecovery | empty) -}}
    {{- $possibleValues := list "pessimistic" "optimistic" "unneeded" -}}
    {{- if not (has $proxy.closeNotificationsRecovery $possibleValues) }}
      {{ printf "adapters.%s.proxyMetadataAdapter.closeNotificationsRecovery must be one of: %s" $adapterName (join ", " $possibleValues) | fail }}
    {{- end }}
<param name="close_notifications_recovery">{{ $proxy.closeNotificationsRecovery }}</param>
  {{- else }}
<!--
<param name="close_notifications_recovery">unneeded</param>
-->
  {{- end }}

<!-- Optional.
     The action to be performed when the authentication of the request
     for a new Session (through notifyUser) cannot be carried out
     because of the unavailability of the Remote Metadata Adapter.
     Can be one of the following:
     - fail
       The request will fail as though an unexpected error had been
       occurred.
     - force_retry
       The request will fail, but the server should also instruct
       the client to retry the request.
     - send_code
       The request will be refused by throwing a CreditsException
       with a custom error code that has to be specified through the
       "notify_user_disconnection_code" parameter; in this way,
       the code will be communicated to the client as a Metadata Adapter
       custom refusal code.
     Default: either send_code or fail, depending on whether or not
     the "notify_user_disconnection_code" parameter is supplied. -->
  {{- if not (quote $proxy.notifyUserOnDisconnection | empty) -}}
    {{- $possibleValues := list "fail" "force_retry" "send_code" -}}
    {{- if not (has $proxy.notifyUserOnDisconnection $possibleValues) }}
      {{ printf "adapters.%s.proxyMetadataAdapter.notifyUserOnDisconnection must be one of: %s" $adapterName (join ", " $possibleValues) | fail }}
    {{- end }}
<param name="notify_user_on_disconnection">{{ $proxy.notifyUserOnDisconnection }}</param>
  {{- else }}
<!--
<param name="notify_user_on_disconnection">force_retry</param>
-->
  {{- end }}

<!-- Optional when "notify_user_on_disconnection" is not supplied;
     mandatory when "notify_user_on_disconnection" is send_code;
     otherwise forbidden.
     An integer to be supplied as a custom error code by notifyUser,
     through a CreditsException, when the request is being refused
     because of the unavailability of the Remote Metadata Adapter.
     The code must be zero or negative, as positive codes are reserved
     by the Server.
     Default: no code will be used, hence "notify_user_on_disconnection"
     will be set as fail. -->
  {{- $disconnectionCodeMandatory := eq $proxy.notifyUserOnDisconnection "send_code" }}
  {{- if not (quote $proxy.notifyUserDisconnectionCode | empty) }}
    {{- if (has $proxy.notifyUserOnDisconnection (list "force_retry" "fail")) }}
      {{ printf "adapters.%s.proxyMetadataAdapter.notifyUserDisconnectionCode cannot be set when notifyUserOnDisconnection is 'force_retry' or 'fail'" $adapterName | fail }}
    {{- end }}
    {{- if gt (int $proxy.notifyUserDisconnectionCode) 0 }}
      {{ printf "adapters.%s.proxyMetadataAdapter.notifyUserDisconnectionCode must be a non positive integer" $adapterName | fail }}
    {{- end }}
<param name="notify_user_disconnection_code">{{ int $proxy.notifyUserDisconnectionCode }}</param>
  {{- else if $disconnectionCodeMandatory }}
    {{ printf "adapters.%s.proxyMetadataAdapter.notifyUserDisconnectionCode is mandatory when adapters.%s.proxyMetadataAdapter.notifyUserOnDisconnection is set to 'send_code'" $adapterName $adapterName | fail }}
  {{- else }}
<!--
<param name="notify_user_disconnection_code">-10</param>
-->
  {{- end }}

<!-- Optional, only effective when "notify_user_disconnection_code" is set.
     A string to be supplied as a custom error message by notifyUser,
     through a CreditsException, when the request is being refused
     because of the unavailability of the Remote Metadata Adapter.
     The message will be used in association with the error code
     configured through "notify_user_disconnection_code".
     Default: the error message is supplied by the
     Robust Proxy Metadata Adapter. -->
  {{- if and (not (quote $proxy.notifyUserDisconnectionCode | empty)) (not (quote $proxy.notifyUserDisconnectionMsg | empty)) }}
<param name="notify_user_disconnection_msg">{{ $proxy.notifyUserDisconnectionMsg }}</param>
  {{- else }}
<!--
<param name="notify_user_disconnection_msg">Remote Metadata Adapter unavailable</param>
-->
  {{- end }}
{{- end }}
{{- end }}

{{/*
Render the remote parameters and timeout settings for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.remoteParams" }}
{{- $adapterName := index . 0 }}
{{- $isDataAdapter := index . 1 }}
{{- $proxy := index . 2 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}
{{- $metaOrData := $isDataAdapter | ternary "Data" "Metadata" }}
{{- $commentSuffix := $isRobust | ternary (printf " for all Robust Proxy %s Adapters" $metaOrData) "" }}
<!-- Optional{{ $commentSuffix }}.
{{- if $isDataAdapter }}
     Determines the custom initialization parameters to be sent to the
     remote counterpart.
     The supplied value is meant as a prefix, such that all parameters
     supplied to this Proxy Adapter and whose names start with this
     prefix will be sent. The value must contain a ':' character, as all
     parameter names that don{{"'"}}t contain a ':' character are reserved.
     Hence, the normal configuration parameters will not be sent to the
     remote counterpart, unless explicitly duplicated with a prefixed
     name. Anyway, the following parameters, with obvious meaning,
     will be provided by the Proxy Adapter and will also be sent:
     - ARI.version
     - keepalive_hint.millis (optional)
     - adapters_conf.id
     - data_provider.name
     - server.instance_id
     - proxy.instance_id
     where the latter is added by the Robust Proxy Data Adapter and
     allows a Remote Data Adapter to detect if it is in replacement
     of a previous instance for the same Proxy Adapter instance.
     Default: if not defined, no custom initialization parameters
     will be sent. -->
{{- else}}
     Determines the custom initialization parameters to be sent to the
     remote counterpart.
     The supplied value is meant as a prefix, such that all parameters
     supplied to this Proxy Adapter and whose names start with this
     prefix will be sent. The value must contain a ':' character, as all
     parameter names that don{{"'"}}t contain a ':' character are reserved.
     Hence, the normal configuration parameters will not be sent to the
     remote counterpart, unless explicitly duplicated with a prefixed
     name. Anyway, the following parameters, with obvious meaning,
     will be provided by the Proxy Adapter and will also be sent:
     - ARI.version
     - keepalive_hint.millis (optional)
     - adapters_conf.id
     - server.instance_id
     - proxy.instance_id
     where the latter is added by the Robust Proxy Metadata Adapter
     and allows a Remote Metadata Adapter to detect if it is in
     replacement of a previous instance for the same Proxy Adapter
     instance, and to possibly recover the state, including the currently
     active sessions and the related users.
     Default: if not defined, no custom initialization parameters
     will be sent. -->
{{- end }}
{{- $remotePrefix := ($proxy.remoteParamsConfig).prefix -}}
{{- if not (quote $remotePrefix | empty) }}
  {{- if not (contains ":" $remotePrefix) }}
    {{ printf "adapters.%s.{...}.remoteParamsConfig.prefix must contain a colon" $adapterName | fail }}
  {{- end }}
<param name="remote_params_prefix">{{ $remotePrefix }}</param>
  {{- range $paramName, $paramValue := $proxy.remoteParamsConfig.initParams }}
    {{- if not (hasPrefix $remotePrefix $paramName) }}
      {{ printf "adapters.%s.{...}.remoteParamsConfig.initParams.%s key must start with the prefix \"%s\"" $adapterName $paramName $remotePrefix | fail }}
    {{- end }}
<param name={{ printf "%s" $paramName | quote }}>{{ $paramValue }}</param>
    {{- end }}
{{- else }}
<!--
<param name="remote_params_prefix">remote:</param>
-->
<!--
<param name="remote:xxxx">my value for the remote counterpart</param>
-->
{{- end }}

<!-- Optional{{ $commentSuffix }}.
     Timeout for sent requests. A negative value stands for an unlimited timeout.
     Timed out requests are considered as failed and later answers are ignored.
     Setting a limited timeout is recommended, to prevent a buggy Remote Adapter
     that never yields response to some requests from causing a memory leak.
     Default: 10000 ms (10 seconds). -->
{{- if not (quote $proxy.timeoutMillis | empty) }}
<param name="timeout">{{ int $proxy.timeoutMillis }}</param>
{{- else }}
<!--
<param name="timeout">10000</param>
-->
{{- end }}
{{- end }}

{{/*
Render the common closing parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.closing" }}
{{- $adapterName := index . 0 }}
{{- $isDataAdapter := index . 1 }}
{{- $proxy := index . 2 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}
{{- $metaOrData := $isDataAdapter | ternary "Data" "Metadata" }}
{{- $commentSuffix := $isRobust | ternary (printf " for all Robust Proxy %s Adapters" $metaOrData) "" }}
<!-- Optional{{ $commentSuffix }}.
     Specifies a comma-separated list of hosts allowed to connect to this proxy adapter
     in order to act as remote adapters.
     If a list is specified, connections received from addresses not in the list will be
     turned down, otherwise any connection will be accepted.
     The addresses can be in any form accepted by Java InetAddress.getByName method. -->
{{- if not (quote $proxy.remoteAddressWhitelist | empty) }}
<param name="remote_address_whitelist">{{ $proxy.remoteAddressWhitelist }}</param>
{{- else }}
<!--
<param name="remote_address_whitelist">localhost,192.168.0.190</param>
-->
{{- end }}

<!-- Optional{{ $commentSuffix }}.
{{- if $isDataAdapter }}
     Timeout for inactivity on the connection with respect to messages coming
     from the Remote Metadata Adapter.
     If neither replies nor keepalives are received within the specified
     timeout, the TCP connection will be considered broken and will be closed;
     as a consequence, a connection with a new Remote Metadata Adapter will be attempted.
     Setting a timeout is only meaningful if the Remote Metadata Adapter
     is configured to either send keepalive messages at a shorter interval, or obey
     the keepalive interval requested by this Proxy (see "keepalive_hint_millis").
     A zero or negative value stands for an unlimited timeout.
     Default: -1 (unlimited timeout). -->
{{- else }}
     Timeout for inactivity on the connection with respect to messages coming
     from the Remote Data Adapter.
     If neither replies/notifications nor keepalives are received within the specified
     timeout, the TCP connection will be considered broken and will be closed;
     as a consequence, a connections with a new Remote Data Adapter will be attempted.
     In case of two-ports configuration, the timeout applies to both connections
     independently.
     Setting a timeout is only meaningful if the Remote Data Adapter
     is configured to either send keepalive messages at a shorter interval, or obey
     the keepalive interval requested by this Proxy (see "keepalive_hint_millis").
     A zero or negative value stands for an unlimited timeout.
     Default: -1 (unlimited timeout). -->
{{- end }}
{{- if not (quote $proxy.keepaliveTimeoutMillis | empty) }}
<param name="keepalive_timeout_millis">{{ int $proxy.keepaliveTimeoutMillis }}</param>
{{- end }}

<!-- Optional{{ $commentSuffix }}.
{{- if $isDataAdapter}}
     Keepalive interval to be requested to the Remote Data Adapter.
     The value should be low enough to ensure that, if obeyed, the connections
     will pass the timeout checks (see "keepalive_timeout_millis").
     A zero or negative value stands for no keepalive request, which still allows
     the Remote Data Adapter to send keepalives for its own purpose.
     Default: Depending on the setting of keepalive_timeout_millis:
     - if not configured: -1
     - if less than 4 seconds: half the keepalive_timeout_millis
     - otherwise: 2 seconds less than the keepalive_timeout_millis. -->
{{- else }}
     Keepalive interval to be requested to the Remote Metadata Adapter.
     The value should be low enough to ensure that, if obeyed, the connection
     will pass the timeout checks (see "keepalive_timeout_millis").
     A zero or negative value stands for no keepalive request, which still allows
     the Remote Metadata Adapter to send keepalives for its own purpose.
     Default: Depending on the setting of keepalive_timeout_millis:
     - if not configured: -1
     - if less than 4 seconds: half the keepalive_timeout_millis
     - otherwise: 2 seconds less than the keepalive_timeout_millis. -->
{{- end }}
{{- if not (quote $proxy.keepaliveHintMillis | empty) }}
<param name="keepalive_hint_millis">{{ int $proxy.keepaliveHintMillis }}</param>
{{- else }}
<!--
<param name="keepalive_hint_millis">6000</param>
-->
{{- end }}
{{- end }}

{{/*
Render the <dataAdapterPool> block for the in-process Data Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.data-provider.dataAdapterPool" }}
<!-- Optional. Requests the creation of a specific "DATA" thread pool,
     expressly devoted to the management of table subscription and
     unsubscription requests for all the tables based on this Data
     Adapter. This involves the various calls to the Data Adapter
     and some calls to the Metadata Adapter. Among the latter, the most
     critical are "getItems", "getSchema", and "notifyNewTables"
     for Adapters leveraging the old callback-based
     Java In-Process Adapter SDK and "SessionAdapter::newSubscription"
     for Adapters leveraging the new object-based
     Java In-Process Adapter SDK v9+.
     The pool associated to each Metadata Adapter call can be found
     in the related API documentation.

     If not defined, these requests are managed by the thread pool
     related with the Adapter Set, if, in turn, defined.
     If defined, the <max_size> and <max_free> elements are mandatory,
     with meaning similar to that of the global <server_pool_max_size>
     and <server_pool_max_free> settings.
     Using a specific thread pool is advisable if the implementation
     of any of the involved Adapter methods introduces delays. -->
{{- include "lightstreamer.adapters.data-provider.dataAdapterPool" . }}
{{- end }}

{{/*
Render the custom initialization parameters for the in-process Data Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.data-provider.initParams" }}
<!-- Optional. List of initialization parameters specific to the adapter.
     The various <param> elements are not interpreted by Lightstreamer,
     but they are forwarded to the "init" method of the adapter.

     In addition, the following parameters, with obvious meaning,
     are always provided by the Server:
     - adapters_conf.id
     - data_provider.name
     Note that these parameters are reserved and cannot be overridden
     by configuration.
{{- range $paramName, $paramValue := .initParams }} -->
<param name="{{ $paramName }}">{{ $paramValue }}</param>
{{- else }}

    Below are configurations of sample parameters, meant to be handled
    by the specified Data Adapter. -->

<!-- Optional. Sample log configuration; the path is relative to <install_dir>. -->
<!--
<param name="log_config">../adapters_log_conf.xml</param>
-->
{{- end }}
{{- end }}

{{/*
Render the <dataAdapterPool> block for the proxy Data Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.data-provider.dataAdapterPool" }}
<!-- Optional. Requests the creation of a specific "DATA" thread pool,
     expressly devoted to the submission to the Remote Data Adapter
     of table subscription and unsubscription requests for all the tables
     based on this Data Adapter.
     This involves the calls of Subscribe and Unsubscribe to the Remote
     Data Adapter and the calls of Get Items, Get Schema, Get Item Data,
     Get User Item Data, Notify New Tables, and the MPN-related methods
     to the Remote Metadata Adapter.

     If not defined, these requests are managed by the thread pool
     related with the Adapter Set, if, in turn, defined.
     If defined, the <max_size> and <max_free> elements are mandatory,
     with meaning similar to that of the global <server_pool_max_size>
     and <server_pool_max_free> settings. Note that <max_size> also
     indicates the maximum number of pending requests to the Remote
     Adapters.
     Using a specific thread pool is advisable if the implementation
     of any of the involved Adapter methods introduces delays. -->
{{- include "lightstreamer.adapters.data-provider.dataAdapterPool" . }}
{{- end }}

{{/*
Render the <data_adapter_pool> block for the Data Adapter.
*/}}
{{- define "lightstreamer.adapters.data-provider.dataAdapterPool" -}}
{{- $adapterName := index . 0 }}
{{- $dataProviderName := index . 1 }}
{{- $parent := index . 2 }}
{{- with $parent.dataAdapterPool }}
<data_adapter_pool>
  <max_size>{{ int (required (printf "adapters.%s.dataProviders.%s.{}.dataAdapterPool.maxSize must be set" $adapterName $dataProviderName) .maxSize) }}</max_size>
  <max_free>{{ int (required (printf "adapters.%s.dataProviders.%s.{}.dataAdapterPool.maxFree must be set" $adapterName $dataProviderName) .maxFree) }}</max_free>
</data_adapter_pool>
{{- else}}
<!--
<data_adapter_pool>
    <max_size>100</max_size>
    <max_free>10</max_free>
</data_adapter_pool>
-->
{{- end }}
{{- end }}

{{/*
Render the keystore settings for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.keystore" -}}
{{- $top := index . 0 -}}
{{- $key := index . 1 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}
{{- if not (quote $keyStore.type | empty) }}
  {{- if not (has $keyStore.type (list "JKS" "PKCS12" "PKCS11" ))}}
    {{ fail (printf "keystores.%s.type must be one of: \"JKS\", \"PKCS12\", \"PKCS11\"" $key) }}
  {{- end }}
{{- end }}

{{- /* tls.keystore.type */}}
<param name="tls.keystore.type">{{ $keyStore.type }}</param>

{{- /* tls.keystore.keystore_file */}}
<param name="tls.keystore.keystore_file">{{ include "lightstreamer.keystores.dir" . }}/{{ $key }}/{{ required (printf "keystores.%s.keystoreFileSecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

{{- /* tls.keystore.keystore_password.type */}}
<param name="tls.keystore.keystore_password.type">text</param>

{{- /* tls.keystore.password */}}
<param name="tls.keystore.keystore_password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

{{- end }}

{{/*
Render the truststore settings for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.truststore" -}}
{{- $top := index . 0 -}}
{{- $key := index . 1 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}
{{- if not (quote $keyStore.type | empty) }}
  {{- if not (has $keyStore.type (list "JKS" "PKCS12" "PKCS11" ))}}
    {{ fail (printf "keystores.%s.type must be one of: \"JKS\", \"PKCS12\", \"PKCS11\"" $key) }}
  {{- end }}
{{- end }}

{{- /* tls.truststore.type */}}
<param name="tls.truststore.type">{{ $keyStore.type }}</param>

{{- /* tls.truststore.keystore_file */}}
<param name="tls.truststore.truststore_file">{{ include "lightstreamer.keystores.dir" . }}/{{ $key }}/{{ required (printf "keystores.%s.keystoreFileSecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

{{- /* tls.truststore.truststore_password.type */}}
<param name="tls.truststore.truststore_password.type">text</param>

{{- /* tls.truststore.truststore_password */}}
<param name="tls.truststore.truststore_password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>
{{- end }}


{{/*
Render the events recovery settings for the proxy Data Adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.data-provider.events-recovery" -}}
{{- $adapterName := index . 0 -}}
{{- $dataProviderName := index . 1 -}}
{{- $proxy := index . 2 }}
{{- $isRobust := $proxy.enableRobustAdapter | default false }}

{{- if $isRobust }}
<!-- Optional.
      The strategy to be adopted whenever a new remote server is available
      in order to restore the data flow for items that were subscribed to
      while no remote server was available.
      No sophisticated recovery algorithms are available, as they could
      only depend on the specific item meanings.
      Currently, the only available options are:

      - leave_hole
        The real time update flow is just restarted; this may give rise
        to an inconsistent overall flow:
        for RAW and DISTINCT subscriptions, there will be a hole in the
        event sequence;
        for MERGE and COMMAND subscriptions, out of date field values
        might be mixed with up to date field values on the same item or key;
        for COMMAND subscriptions, some keys might be missing for some
        time and others might remain garbage for long time; some harmless
        warning messages might also be issued by the Server.

      - use_snapshot
        The snapshot of the item is requested to the remote server and
        it is sent in the update flow "as is"; this strategy is suitable
        for MERGE subscriptions, while in other cases it may give rise
        to an inconsistent overall flow:
        for RAW subscriptions, there will be a hole in the event sequence
        and possible spurious entries;
        for DISTINCT subscriptions, there might be either a hole or some
        duplicates in the event sequence;
        for COMMAND subscriptions, some keys might just remain garbage
        for long time; some harmless warning messages might also be
        issued by the Server.

      - enforce_snapshot
        Upon interruption, a ClearSnapshot event is sent. Then, upon
        reconnection, the snapshot of the item is requested to the remote
        server and it is sent in the update flow as though it was a sequence
        of real-time updates; this strategy successfully restores the
        correct state for MERGE and COMMAND subscriptions, but it must be
        considered that:
        for MERGE subscriptions, the clients will see null values during
        the interruption;
        for RAW subscriptions, there will be a hole in the event sequence
        and possible spurious entries;
        for DISTINCT subscriptions, there might be either a hole or some
        duplicates in the event sequence, but the ClearSnapshot signal may
        act as a warning of the issue;
        for COMMAND subscriptions, the clients will see an empty list
        during the interruption, then the fictitious ADDs to restore the
        list, but the ClearSnapshot signal may act as a warning of the issue.

      The configured strategy will be applied with all items.
      Default: leave_hole. -->
{{- if not (quote $proxy.eventsRecovery | empty) }}
  {{- if not (has $proxy.eventsRecovery (list "leave_hole" "use_snapshot" "enforce_snapshot")) }}
  {{ printf "adapters.%s.dataProviders.%s.proxyDataAdapter.eventsRecovery must be one of: " $adapterName $dataProviderName (join ", " (list "leave_hole" "use_snapshot" "enforce_snapshot")) fail }}
  {{- end }}
<param name="events_recovery">use_snapshot</param>
{{- else}}
<param name="events_recovery">use_snapshot</param>
{{- end }}

<!-- Optional.
      Specifies an item name to be managed by the Proxy Adapter for
      carrying information about the availability of the Remote Data Adapter.
      This item will only supply one field, named "status", whose value
      may only be one of the following:
      - "connecting" if no connection with a remote server has taken place yet;
      - "connected" if a connection with a remote server is currently in place;
      - "reconnecting" if a connection with a remote server has been lost.
      The item will support subscriptions in MERGE or RAW mode and requests
      for the snapshot will also be supported.

      Note that the chosen name should be such that no conflicts with the
      item names supplied by the Remote Data Adapter can be possible.
      Also note that the Metadata Adapter must be aware of this item when
      performing permission checks.
      Default: no item is added for carrying status information. -->
{{- if not (quote $proxy.statusItem | empty) }}
<param name="status_item">{{ $proxy.statusItem}}</param>
{{- else }}
<!--
<param name="status_item">remote_adapter_status</param>
-->
{{- end }}
{{- end }}
{{- end }}

