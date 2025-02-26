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
Render all the probes for the deployment descriptor.
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
  {{- if not $server }}
    {{ printf "servers.%s must be set" $serverKey | fail }}
  {{- end }}
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
{{ . | kebabcase }}
{{- end }}

{{/*
Render the keystore settings for the main configuration file.
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
Create the name of the Lightstreamer Kafka Connector.
*/}}
{{- define "lightstreamer.kafka-connector.name" -}}
{{- printf "lightstreamer-kafka-connector" }}
{{- end }}

{{- define "lightstreamer.kafka-connector.validateProvisioning" -}}
{{- if not .provisioning }} 
  {{- fail "connectors.kafkaConnector.provisioning must be set" }}
{{- end }}
{{- end }}

{{/*
Create the URL of the Lightstreamer Kafka Connector.
*/}}
{{- define "lightstreamer.kafka-connector.url" -}}
{{- printf "https://github.com/Lightstreamer/Lightstreamer-kafka-connector/releases/download/v%s/%s-%s.zip" . (include "lightstreamer.kafka-connector.name" .) . }}
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

{{/*
Validate all the adapter set configurations, ensuring that:
- No duplicate adapter set ids exist.
- Either a in-process or proxy metadata adapter is defined for each enabled adapter set.
- An adapter class name is defined for each in-process metadata adapter.
- A request/reply port is defined for each proxy metadata adapter.
- At least one enabled data provider is defined for each enabled adapter set.
- Either a in-process or proxy data adapter is defined for each enabled data provider.
- No duplicate data provider names exist for each enabled adapter set.
- An adapter class name is defined for each in-process data adapter.
- A request/reply port is defined for each proxy data adapter.
- No clashing ports exist.
*/}}
{{- define "lightstreamer.adapters.validateAllAdapterSets" -}}
{{- $userAdapterIds := list -}}
{{- $usedPorts := list}}
{{- range $adapterName, $adapterSet := .Values.adapters}}
  {{- if not $adapterSet }}
    {{- fail (printf "adapters.%s must be set" $adapterName) }}
  {{- end }}
  {{- if $adapterSet.enabled }}
  {{- /* CHECK ADAPTER SET IDS */ -}}
    {{- $adapterId := required (printf "adapters.%s.id must be set" $adapterName) $adapterSet.id }}
    {{- if has $adapterId $userAdapterIds }}
      {{- fail (printf "adapters.%s.id \"%s\" already used" $adapterName $adapterId ) }}
    {{- end }}
    {{- $userAdapterIds = append $userAdapterIds $adapterId }}

    {{- $metadataProvider := required (printf "adapters.%s.metadataProvider must be set" $adapterName) $adapterSet.metadataProvider -}}
    {{- if hasKey $metadataProvider "inProcessMetadataAdapter" }}
      {{- /* CHECK IN-PROCESS METADATA ADAPTER CLASS NAME */}}
      {{- $inProcess := $metadataProvider.inProcessMetadataAdapter | default dict }}
      {{- $adapterClass := required (printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.adapterClass must be set" $adapterName) $inProcess.adapterClass }}
    {{- else if hasKey $metadataProvider "proxyMetadataAdapter" }}
      {{- $proxy := $metadataProvider.proxyMetadataAdapter | default dict }}
      {{- /* CHECK PROXY METADATA ADAPTER REQUEST/REPLY PORT */ -}}
      {{- $requestReplyPort := int (required (printf "adapters.%s.metadataProvider.proxyMetadataAdapters.requestReplyPort must be set" $adapterName) $proxy.requestReplyPort) }}
      {{- if has $requestReplyPort $usedPorts }}
        {{- fail (printf "adapters.%s.metadataProvider.proxyMetadataAdapters.requestReplyPort \"%d\" already used" $adapterName $requestReplyPort ) }}
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
        {{- /* CHECK DATA PROVIDER NAMES */ -}}
        {{- $dataProviderName := required (printf "adapters.%s.dataProviders.%s.name must be set" $adapterName $dataProviderKey) $dataProvider.name }}
        {{- if has $dataProviderName $enabledDataProviders }}
          {{- fail (printf "adapters.%s.dataProviders.%s.name \"%s\" already used" $adapterName $dataProviderKey $dataProviderName ) }}
        {{- end }}
        {{- $enabledDataProviders = append $enabledDataProviders $dataProviderName }}

        {{- if hasKey $dataProvider "inProcessDataAdapter" }}
          {{- $inProcess := $dataProvider.inProcessDataAdapter | default dict }}
          {{- /* CHECK IN-PROCESS DATA ADAPTER CLASS NAME */ -}}
          {{- $adapterClass := required (printf "adapters.%s.dataProviders.%s.inProcessMetadataAdapter.adapterClass must be set" $adapterName $dataProviderKey) $inProcess.adapterClass }}
        {{- else if hasKey $dataProvider "proxyDataAdapter" }}
          {{- $proxy := $dataProvider.proxyDataAdapter | default dict }}
          {{- /* CHECK REQUEST/REPLY PORTS */ -}}
          {{- $dataProviderPort := int (required (printf "adapters.%s.dataProviders.%s.proxyDataAdapter.requestReplyPort must be set" $adapterName $dataProviderKey) $proxy.requestReplyPort) }}
          {{- if has $dataProviderPort $usedPorts }}
            {{- fail (printf "adapters.%s.dataProviders.%s.proxyDataAdapter.requestReplyPort \"%d\" already used" $adapterName $dataProviderKey $dataProviderPort ) }}
          {{- end }}
          {{- $usedPorts = append $usedPorts $dataProviderPort }}
        {{- else }}
          {{- printf "Either specify \"inProcessDataAdapter\" or \"proxyDataAdapter\" in adapters.%s.dataProviders.%s " $adapterName $dataProviderKey | fail }}    
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if $enabledDataProviders | empty }}
      {{- fail (printf "At least one enabled data provider must be defined for adapters.%s" $adapterName) }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Create the Java class name of the Proxy Meta/Data Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.common.class" -}}
{{- .enableRobustAdapter | default false | ternary "ROBUST_PROXY_FOR_REMOTE_ADAPTER" "PROXY_FOR_REMOTE_ADAPTER" -}}
{{- end }}

{{/*
Render the <authentication_pool> block for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.authenticationPool" -}}
{{- include "lightstreamer.adapters.metadata-provider.authenticationPool" (list true .) -}}
{{- end -}}

{{/*
Render the <messages_pool> block for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.messagesPool" -}}
{{- include "lightstreamer.adapters.metadata-provider.messagesPool" (list true .) -}}
{{- end -}}

{{/*
Render the <mpn_pool> block for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.mpnPool" -}}
{{- include "lightstreamer.adapters.metadata-provider.mpnPool" . -}}
{{- end }}

{{/*
Render the <authentication_pool> block for the in-process Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.metadata-provider.authenticationPool" -}}
{{- include "lightstreamer.adapters.metadata-provider.authenticationPool" (list false .) -}}
{{- end -}}

{{/*
Render the <messages_pool> block for the in-process Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.metadata-provider.messagesPool" -}}
{{- include "lightstreamer.adapters.metadata-provider.messagesPool" (list false .) -}}
{{- end -}}

{{/*
Render the <mpn_pool> block for the in-process Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.metadata-provider.mpnPool" -}}
{{- include "lightstreamer.adapters.metadata-provider.mpnPool" . -}}
{{- end }}

{{/*
Render the <data_authentication_pool> block for the Proxy Data Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.data-provider.dataAdapterPool" -}}
{{- include "lightstreamer.adapters.data-provider.dataAdapterPool" . -}}
{{- end }}

{{/*
Render the <data_authentication_pool> block for the in-process Data Adapter.
*/}}
{{- define "lightstreamer.adapters.in-process.data-provider.dataAdapterPool" -}}
{{- include "lightstreamer.adapters.data-provider.dataAdapterPool" . -}}
{{- end }}

{{/*
Render the custom initialization parameters for the in-process adapters.
*/}}
{{- define "lightstreamer.adapters.in-process.common.initParams" -}}
{{- if .initParams }}

<!-- CUSTOM INITIALIZATION PARAMETERS -->
{{- range $paramName, $paramValue := .initParams }}
<param name={{ $paramName | quote}}>{{ $paramValue }}</param>
{{- end }}
<!-- END CUSTOM INITIALIZATION PARAMETERS -->
{{- end }}
{{- end }}

{{/*
Render the <authenticationPool> block for the Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.metadata-provider.authenticationPool" -}}
{{- $isRemote := index . 0 -}}
{{- $parent := index . 1 -}}
{{- with $parent.authenticationPool }}

<!-- AUTHENTICATION POOL -->
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
  {{- end }}
  {{- if not (quote .maxQueue | empty) }}
  <max_queue>{{ int .maxQueue }}</max_queue>
  {{- end }}
</authentication_pool>
<!-- END AUTHENTICATION POOL -->
{{- end }}
{{- end -}}

{{/*
Render the <messages_pool> block for the Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.metadata-provider.messagesPool" -}}
{{- $isRemote := index . 0 -}}
{{- $parent := index . 1 -}}
{{- with $parent.messagesPool}}

<!-- MESSAGES POOL ->
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
  {{- end }}
  {{- if not (quote .maxQueue | empty) }}
  <max_queue>{{ int .maxQueue }}</max_queue>
  {{- end }}
</message_pool>
<!-- END MESSAGES POOL ->
{{- end }}
{{- end -}}

{{/*
Render the <mpn_pool> block for the Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.metadata-provider.mpnPool" -}}
{{- with .mpnPool }}

<!-- MPN POOL -->
<mpn_pool>
  {{- if not (quote .maxSize | empty) }}
  <max_size>{{ int .maxSize }}</max_size>
  {{- end }}
  {{- if not (quote .maxFree | empty) }}
  <max_free>{{ int .maxFree }}</max_free>
  {{- end }}
</mpn_pool>
<!-- END MPN POOL -->
{{- end }}
{{- end }}

{{/*
Render the <data_adapter_pool> block for the Data Adapter.
*/}}
{{- define "lightstreamer.adapters.data-provider.dataAdapterPool" -}}
{{- with .dataAdapterPool }}
<data_adapter_pool>
  {{- if not (quote .maxSize | empty) }}
  <max_size>{{ int .maxSize }}</max_size>
  {{- end }}
  {{- if not (quote .maxFree | empty) }}
  <max_free>{{ int .maxFree }}</max_free>
  {{- end }}
</data_adapter_pool>
{{- end }}
{{- end }}

{{/*
Render the tls parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.sslConfig" }}
{{- $adapterName := index . 0}}
{{- $keystores := index . 1 -}}
{{- $parent := index . 2 -}}
{{- if (($parent).sslConfig).enabled }}

<!-- TLS SETTINGS -->
{{- with $parent.sslConfig }}
<param name="tls">Y</param>
  {{- /* tls.keystore */ -}}
  {{- $keystoreRef := required (printf "adapters.%s.{...}.sslConfig.keystoreRef must be set" $adapterName) .keystoreRef }}
  {{- include "lightstreamer.adapters.proxy.keystore" (list $keystores .keystoreRef) | nindent 0 }}

  {{- /* tls.allow_cipher_suite */ -}}
  {{- $counter := 0}}
  {{- range .allowCipherSuites }}
    {{- $counter = add1 $counter }} 
<param name="tls.allow_cipher_suite.{{ $counter }}">{{ . }}</param>
  {{- end }}

  {{- /* tls.remove_cipher_suites */ -}}
  {{- $counter := 0}}
  {{- range .removeCipherSuites }}
    {{- $counter = add1 $counter }} 
<param name="tls.remove_cipher_suites.{{ $counter }}">{{ . }}</param>
  {{- end }}  

  {{- /* tls.enforce_server_cipher_suite_preference */ -}}
  {{- if (.enforceServerCipherSuitePreference).enabled }}
<param name="tls.enforce_server_cipher_suite_preference">Y</param>
    {{- if not (quote .enforceServerCipherSuitePreference.order | empty )}}
<param name="tls.enforce_server_cipher_suite_preference.order">{{ .enforceServerCipherSuitePreference.order }}</param>
    {{- end }}
  {{- end }}  

  {{- /* tls.allow_protocol */ -}}
  {{- $counter := 0}}
  {{- range .allowProtocols }}
    {{- $counter = add1 $counter }} 
<param name="tls.allow_protocol.{{ $counter }}">{{ . }}</param>
  {{- end }}  

  {{- /* tls.remove_protocols */ -}}
  {{- $counter := 0}}
  {{- range .removeProtocols }}
    {{- $counter = add1 $counter }} 
<param name="tls.remove_protocols.{{ $counter }}">{{ . }}</param>
  {{- end }}  

  {{- /* tls.force_client_auth */ -}}
  {{- if not (quote .enableMandatoryClientAuth | empty) }}
<param name="tls.force_client_auth">{{ .enableMandatoryClientAuth | ternary "Y" "N"}}</param>
  {{- end }}

  {{- /* tls.truststore */ -}}
  {{- if .truststoreRef }}
  {{- include "lightstreamer.adapters.proxy.truststore" (list $keystores .truststoreRef) | nindent 0 }}  
  {{- end }}

  {{- /* tls.skip_hostname_check */ -}}
  {{- if not (quote .enableHostnameVerification | empty) }}
<param name="tls.skip_hostname_check">{{ .enableHostnameVerification | ternary "N" "Y" }}</param>
  {{- end }}
{{- end }}
<!-- END TLS SETTINGS -->
{{- end -}}
{{- end -}}

{{/*
Render the authentication parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.authentication" -}}
{{- $adapterName := index . 0 -}}
{{- $proxy := index . 1 -}}
{{- if ($proxy.authentication).enabled }}

<!-- AUTHENTICATION SETTINGS -->
{{- with $proxy.authentication }}
{{- /* auth */}}    
<param name="auth">Y</param>
  {{- $counter := 0 }}
  {{- if .credentialsSecrets | empty }}
    {{- fail (printf "adapters.%s.{...}.authentication.credentialsSecrets must be set" $adapterName) }}
  {{- end }}
  {{- range .credentialsSecrets }}
    {{- $counter = add1 $counter }} 
    {{- /* auth.credentials.<N>.user */}}    
<param name="auth.credentials.{{ $counter }}.user">$env.LS_PROXY_ADAPTER_CREDENTIAL_{{ . | upper | replace "-" "_" }}_USER></param>

    {{- /* auth.credentials.<N>.password */}}    
<param name="auth.credentials.{{ $counter }}.password">$env.LS_PROXY_ADAPTER_CREDENTIAL_{{ . | upper | replace "-" "_" }}_PASSWORD></param>

  {{- end }}
{{- end }}
<!-- END AUTHENTICATION SETTINGS -->
{{- end -}}
{{- end -}}

{{/*
Render the keystore settings for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.keystore" -}}
{{- $top := index . 0 -}}
{{- $key := index . 1 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}

{{- /* tls.keystore.type */}}
<param name="tls.keystore.type">{{ $keyStore.type }}</param>

{{- /* tls.keystore.keystore_file */}}
<param name="tls.keystore.keystore_file">../../conf/keystores/{{ $key }}/{{ required (printf "keystores.%s.keystoreFileSecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

{{- /* tls.keystore.keystore_password.type */}}
<param name="tls.keystore.keystore_password.type">text</param>

{{- /* tls.keystore.password */}}
<param name="tls.keystore.keystore_password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

{{- end -}}

{{/*
Render the truststore settings for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.truststore" -}}
{{- $top := index . 0 -}}
{{- $key := index . 1 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}

{{- /* tls.truststore.type */}}
<param name="tls.truststore.type">{{ $keyStore.type }}</param>

{{- /* tls.truststore.keystore_file */}}
<param name="tls.truststore.truststore_file">../../conf/keystores/{{ $key }}/{{ required (printf "keystores.%s.keystoreFileSecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

{{- /* tls.truststore.truststore_password.type */}}
<param name="tls.truststore.truststore_password.type">text</param>

{{- /* tls.truststore.truststore_password */}}
<param name="tls.truststore.truststore_password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

{{- end -}}

{{/*
Render the connection-related timeout settings for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.connection" -}}
{{- $pars := list .connectionRetryMillis .connectionRecoveryTimeoutMillis .firstConnectionTimeoutMillis -}}
{{- if not ($pars | empty) }}

  {{- /* connection_retry_millis */ -}}
  {{- if .remoteHost }}
    {{- if not (quote .connectionRetryMillis | empty) }}
<param name="connection_retry_millis">{{ int .connectionRetryMillis }}</param>
    {{- end }}
  {{- end}}

  {{- if .enableRobustAdapter }}
    {{- /* connection_recovery_timeout_millis */ -}}
    {{- if not (quote .connectionRecoveryTimeoutMillis | empty) }}
<param name="connection_recovery_timeout_millis">{{ int .connectionRecoveryTimeoutMillis }}</param>
    {{- end }}

    {{- /* first_connection_timeout_millis */ -}}
    {{- if not (quote .firstConnectionTimeoutMillis | empty) }}
<param name="first_connection_timeout_millis">{{ int .firstConnectionTimeoutMillis }}</param>
    {{- end }}
  {{- end }}

{{- end }}
{{- end -}}

{{/*
Render the close/disconnection notification settings for the Proxy Metadata Adapter.
*/}}
{{- define "lightstreamer.adapters.proxy.metadata-provider.closeNotification" -}}
{{- $adapterName := index . 0 -}}
{{- $proxy := index . 1 -}}
{{- if $proxy.enableRobustAdapter }}

{{- /* close_notifications_recovery */ -}}
{{- if $proxy.closeNotificationsRecovery -}}
{{- $possibleValues := list "pessimistic" "optimistic" "unneeded" -}}
{{- if not (has $proxy.closeNotificationsRecovery $possibleValues) }}
  {{ printf "adapters.%s.proxyMetadataAdapter.closeNotificationsRecovery must be one of: %s" $adapterName $possibleValues | fail }}
{{- end }}
<param name="close_notifications_recovery">{{ $proxy.closeNotificationsRecovery }}</param>
{{- end }}

{{- /* notify_user_on_disconnection */ -}}
{{- if $proxy.notifyUserOnDisconnection -}}
{{- $possibleValues := list "fail" "force_retry" "send_code" -}}
{{- if not (has $proxy.notifyUserOnDisconnection $possibleValues) }}
  {{ printf "adapters.%s.proxyMetadataAdapter.notifyUserOnDisconnection must be one of: %s" $adapterName $possibleValues | fail }}
{{- end }}
<param name="notify_user_on_disconnection">{{ $proxy.notifyUserOnDisconnection }}</param>
{{- end }}

{{- /* notify_user_disconnection_code */ -}}
{{- if not (quote $proxy.notifyUserDisconnectionCode | empty)  }}
  {{- if gt (int $proxy.notifyUserDisconnectionCode) 0 }}
    {{ printf "adapters.%s.proxyMetadataAdapter.notifyUserDisconnectionCode must a non positive integer" $adapterName | fail }}
  {{- end }}
<param name="notify_user_disconnection_code">{{ int $proxy.notifyUserDisconnectionCode }}</param>

  {{- /* notify_user_disconnection_msg */ -}}
  {{- if not (quote $proxy.notifyUserDisconnectionMsg | empty)  }}
<param name="notify_user_disconnection_msg">{{ $proxy.notifyUserDisconnectionMsg }}</param>
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Render the remote parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common.remoteParams" -}}
{{- $adapterName := index . 0 -}}
{{- $proxy := index . 1 -}}
{{- with $proxy.remoteParamsConfig }}
<!-- REMOTE PARAMS SETTINGS -->
  {{- $prefix := .prefix -}}
  {{- if not (quote $prefix | empty) }}
  {{- /* remote_params_prefix */}}
    {{- if not (contains ":" $prefix) }}
      {{ printf "adapters.%s.{...}.remoteParamsConfig.prefix must contain a colon" $adapterName | fail }}
    {{- end }}
<param name="remote_params_prefix">{{ $prefix }}</param>

  {{- /* remote:xxx */}}
    {{- range $paramName, $paramValue := .params}}
      {{- if not (hasPrefix $prefix $paramName) }}
       {{ printf "adapters.%s.{...}.remoteParamsConfig.params.%s key must start with the prefix \"%s\"" $adapterName $paramName $prefix | fail }}
      {{- end}}
<param name={{ printf "%s%s" $prefix $paramName | quote }}>{{ $paramValue }}</param>
    {{- end }}
  {{- end }}
<!-- END REMOTE PARAMS SETTINGS -->
{{- end }}
{{- end -}}

{{/*
Render the common parameters for the proxy adapters.
*/}}
{{- define "lightstreamer.adapters.proxy.common" -}}
{{- $adapterName := index . 0 -}}
{{- $proxy := index . 1 -}}

{{- /* request_reply_port */ -}}
<param name="request_reply_port">{{ int $proxy.requestReplyPort }}</param>

{{- /* remote_host */ -}}
{{- if not (quote $proxy.remoteHost | empty) }}
<param name="remote_host">{{ $proxy.remoteHost }}</param>
{{- end }}

{{- /* interface */ -}}
{{- if not (quote $proxy.interface | empty) }}
<param name="interface">{{ $proxy.interface }}</param>
{{- end }}

{{- /* timeout */ -}}
{{- if not (quote $proxy.timeoutMillis | empty) }}
<param name="timeout">{{ int $proxy.timeoutMillis }}</param>
{{- end }}

{{- /* remote_address_white_list */ -}}
{{- if $proxy.remoteAddressWhitelist }}
<param name="remote_address_white_list">{{ $proxy.remoteAddressWhitelist }}</param>
{{- end }}

{{- /* keep_alive */ -}}    
{{- if not (quote $proxy.keepaliveTimeoutMillis | empty) }}
<param name="keep_alive">{{ int $proxy.keepaliveTimeoutMillis }}</param>
{{- end }}

{{- /* keep_alive_hint */ -}}        
{{- if not (quote $proxy.keepaliveHintMillis | empty) }}
<param name="keep_alive_hint">{{ int $proxy.keepaliveHintMillis }}</param>
{{- end }}
{{- end -}}    