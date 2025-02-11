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
Render the Service name.
*/}}
{{- define "lightstreamer.service.name" -}}
{{ .Values.service.name | default (printf "%s-%s" (include "lightstreamer.fullname" . ) "service") }}
{{- end }}

{{/*
Render the Service target port.
*/}}
{{- define "lightstreamer.service.targetPort" -}}
{{- $serverKeyName := "Values.service.targetPort" }}
{{- $serverKey := .Values.service.targetPort }}
{{- include "lightstreamer.configuration.validateServerRef" (list . $serverKeyName $serverKey) }}
{{- include "lightstreamer.configuration.serverPortName" $serverKey -}}
{{- end }}

{{/*
Render the port used health check.
*/}}
{{- define "lightstreamer.deployment.healthcheckPort" -}}
{{- $ := index . 0 }}
{{- $probeName := index . 1 }}
{{- $serverKeyName := printf "deployment.probes.%s.healthCheck.serverRef" $probeName }}
{{- $serverKey := (index . 2).serverRef }}
{{- include "lightstreamer.configuration.validateServerRef" (list $ $serverKeyName $serverKey) }}
{{- include "lightstreamer.configuration.serverPortName" $serverKey -}}
{{- end }}

{{/*
Render a probe for the deployment descriptor.
*/}}
{{- define "lightstreamer.deployment.probe" -}}
{{- $ := index . 0}}
{{- $probe := index . 1 }}
{{- $probeName := index . 2 }}
{{- if ($probe).enabled }}
{{ printf "%sProbe:" $probeName }}
  {{- with $probe.healthCheck }}
  httpGet:
    path: /lightstreamer/healthcheck
    port: {{ include "lightstreamer.deployment.healthcheckPort" (list $ $probeName .) }}
    scheme: {{ (get $.Values.servers .serverRef).enableHttps | default false | ternary "HTTPS" "HTTP" }}
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
  {{- else }}
    {{- toYaml (required (printf "either specify %s.healthCheck or %s.default" $probeName $probeName) $probe.default) | nindent 2 }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Render all the probes for the deployment descriptor-
*/}}
{{- define "lightstreamer.deployment.all-probes" -}}
{{- $probes := .Values.deployment.probes }}
{{- range $probeName, $probe := $probes }}
{{- include "lightstreamer.deployment.probe" (list $ $probe $probeName) }}
{{- end }}
{{- end }}

{{/*
Validate all the server configurations, ensuring that at least on enabled 
server exists and no duplicated names or ports are defined.
*/}}
{{- define "lightstreamer.configuration.validateAllServers" }}
{{- $usedNames := list }}
{{- $usedPorts := list }}
{{- range $serverKey, $server :=.Values.servers }}
  {{- if $server.enabled }}
    {{- /* CHECK SERVER NAMES */ -}}
    {{- $serverName := required (printf "servers.%s.name must be set" $serverKey) $server.name }}
    {{- if has $serverName $usedNames }}
      {{- fail (printf "servers.%s.name \"%s\" already used" $serverKey $serverName ) }}
    {{- end }}
    {{- $usedNames = append $usedNames $serverName }}
    {{- /* CHECK SERVER PORTS */ -}}
    {{- $serverPort := required (printf "servers.%s.port must be set" $serverKey) (int $server.port) }}
    {{- if has $serverPort $usedPorts }}
      {{- fail (printf "servers.%s.port \"%d\" already used" $serverKey $serverPort ) }}
    {{- end }}
    {{- $usedPorts = append $usedPorts $serverPort }}
  {{- end }}
{{- end }}
{{- if $usedNames | empty }} 
  {{- fail "At least one enabled server must be defined" }}
{{- end }}
{{- end }}

{{/*
Validate a server configuration reference, ensuring that the server exists and is enabled.
*/}}
{{- define "lightstreamer.configuration.validateServerRef" }}
{{- $ := index . 0 }}
{{- $serverKeyName := index . 1 }}
{{- $serverKey := required (printf "%s must be set" $serverKeyName) (index . 2) }}
{{- $server := required (printf "servers.%s not defined" $serverKey) (get $.Values.servers $serverKey ) }}
{{- if not $server.enabled }}
  {{- printf "%s must set to an enabled server" $serverKeyName | fail }}
{{- end }}
{{- end }}

{{/*
  Render the server name when used as port reference.
*/}}
{{- define "lightstreamer.configuration.serverPortName" -}}
{{ . | lower | replace "_" "- " }}
{{- end }}

{{/*
Render the keystore settings for the main configuration file 
*/}}
{{- define "lightstreamer.configuration.keystore" -}}
{{- $top := index . 0 -}}
{{- $key := index . 1 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}
<keystore{{- if not (quote $keyStore.type | empty) }} type={{ $keyStore.type | quote }}{{- end }}>

    <!-- Specifies a path relative to the conf directory.
         The referred file can be replaced at runtime and the new keystore
         will be loaded immediately. Only in case of successful load
         will the previous keystore be replaced.
         NOTE: The JKS keystore "myserver.keystore", which is provided out
         of the box, obviously contains an invalid certificate. In order to
         use it for your experiments, remember to add a security exception
         to your browser. -->
    <keystore_file>./keystores/{{ $key }}/{{ required (printf "keystores.%s.keystoreFilesecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</keystore_file>

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
Render the truststore settings for the Lightstreamer configuration file 
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
    <truststore_file>./keystores/{{ $key }}/{{ $keyStore.keystoreFileSecretRef.key }}</truststore_file>

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
{{- $loggerLevel := .level | default "DEBUG" }}
{{- $admittedLevels := list "INFO" "DEBUG" "WARN" "ERROR" "FATAL" "TRACE" "OFF" -}}
  {{- if not (has $loggerLevel $admittedLevels) }}
    {{- fail (printf "logging.loggers.<logger name>.level must be one of %s" $admittedLevels) }}
  {{- end }}
{{- $loggerLevel -}}
{{- end }}

{{/*
Create the logging level attribute for subloggers.
*/}}
{{- define "lightstreamer.configuration.log.subloggers.level" -}}
{{- $subloggers := index . 0 -}}
{{- $loggerName := index . 1 -}}
{{- $loggerLevel := (get $subloggers $loggerName) }}
{{- if $loggerLevel }}
  {{- $admittedLevels := list "INFO" "DEBUG" "WARN" "ERROR" "FATAL" "TRACE" "OFF" -}}
    {{- if not (has $loggerLevel $admittedLevels) }}
      {{- fail (printf "logging.loggers.lightstreamerLogger.subLoggers.%s.level must be one of %s" $loggerName $admittedLevels) }}
    {{- end }}
{{- printf " level=%s" ($loggerLevel | quote) }} 
{{- end }}
{{- end }}

{{/*
Create the full name of the Lightstreamer Kafka Connector .
*/}}
{{- define "lightstreamer.kafka-connector.fullname" -}}
{{- printf "lightstreamer-kafka-connector-%s" .Values.connectors.kafkaConnector.version }}
{{- end }}

{{/*
Render the truststore settings for the Lightstreamer Kafka Connector configuration file.
*/}}
{{- define "lightstreamer.kafka-connector.configuration.truststore" -}}
{{- $prefix := index . 0 -}}
{{- $top := index . 1 -}}
{{- $key := index . 2 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}

<param name="{{ $prefix }}.path">../../conf/keystores/{{ $key }}/{{ required (printf "keystores.%s.keystoreFileSecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

<!-- Optional. The password of the trust store.

      If not set, checking the integrity of the trust store file configured will not
      be possible. -->
<param name="{{ $prefix }}.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

{{- if not (quote $keyStore.type | empty) }}
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
      - encryption.keystore.password
      - encryption.keystore.key.password

      Default value: false. -->
<param name="{{ $prefix }}.enable">true</param>

<!-- Mandatory if key store is enabled. The path of the key store file, relative to
      the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>). -->
<param name="{{ $prefix }}.path">../../conf/keystores/{{ $key }}/{{ required (printf "keystores.%s.keystoreFilesecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

<!-- Optional. The password of the key store.

      If not set, checking the integrity of the key store file configured
      will not be possible. -->
<param name="{{ $prefix }}.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

<!-- Optional. The password of the private key in the key store file. -->
{{- if $keyStore.keyPasswordSecretRef }}
<param name="{{ $prefix }}.key.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_KEY_PASSWORD</param>
{{- else }}
<!--
<param name="{{ $prefix }}.key.password">kafka-connector-private-key-password</param>
-->
{{- end }}

{{- if not (quote $keyStore.type | empty) }}
<param name="{{ $prefix }}.keystore.type">{{ $keyStore.type }}</param>
{{- end -}}
{{- end -}}
