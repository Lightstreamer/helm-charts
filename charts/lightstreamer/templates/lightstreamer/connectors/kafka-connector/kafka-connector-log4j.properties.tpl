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
Render the logger configuration.
*/}}
{{- define "lightstreamer.kafka-connector.logging-logger-conf" -}}
{{- $admittedLoggingLevels := list "INFO" "DEBUG" "WARN" "ERROR" "FATAL" -}}
{{- $globalAppenders := index . 0 -}}
{{- $loggerName := index . 1 -}}
{{- $logger := index . 2 -}}
{{- range $appenderName := $logger.appenders }}
  {{- if not (hasKey $globalAppenders $appenderName) }}
    {{- fail (printf "connectors.kafkaConnector.logging.appenders.%s not defined" $appenderName) }}
  {{- end }}
{{- end }}
{{- if not (mustHas $logger.level $admittedLoggingLevels) }}
  {{- fail (printf "connectors.kafkaConnector.logging.kafkaConnector.logging.loggers.%s.level must be one of %s" $loggerName $admittedLoggingLevels) }}
{{- end }}
{{- $appendersList := "" }}
{{- if $logger.appenders }} 
  {{- $appendersList = printf ", %s" (join ", " $logger.appenders) }}
{{- end }}
log4j.logger.{{ $loggerName }}={{ $logger.level }}{{ $appendersList }}
{{- end }}

{{/*
Render the Kafka Connector logging configuration file.
*/}}
{{- define "lightstreamer.kafka-connector.logging-conf" -}}
{{- with required "kafkaConnector.logging must be set" .Values.connectors.kafkaConnector.logging }}

  {{- /* Render the global loggers */ -}}
# Global loggers
  {{- range $loggerName, $logger := .loggers }}
    {{- include "lightstreamer.kafka-connector.logging-logger-conf" (list $.Values.connectors.kafkaConnector.logging.appenders $loggerName $logger) }}
  {{- end }}

  {{- /* Render the appenders */}}
  {{ range $appenderName, $appender := .appenders }}
# {{ $appenderName | quote }} Appender
    {{- $type := default "" ($appender).type }}
    {{- if not (mustHas $type (list "DailyRollingFile" "Console")) }}
      {{- fail (printf "connectors.kafkaConnector.logging.appenders.%s.type must be one of: \"DailyRollingFile\" \"Console\"" $appenderName) }}
    {{- end }}
    {{- if eq $type "DailyRollingFile" }}
      {{- $fileName := required (printf "connectors.kafkaConnector.logging.appenders.%s.fileName must be set" $appenderName) $appender.fileName }}
log4j.appender.{{ $appenderName }}=org.apache.log4j.RollingFileAppender
log4j.appender.{{ $appenderName }}.layout.ConversionPattern={{ required (printf "kafkaConnector.logging.appenders.%s.pattern must be set" $appenderName) $appender.pattern }}
log4j.appender.{{ $appenderName }}.File=../../logs/{{ $fileName }}
    {{- else if eq $type "Console" }}
log4j.appender.{{ $appenderName }}=org.apache.log4j.ConsoleAppender
log4j.appender.{{ $appenderName }}.Target=System.out
    {{- end }}
    {{- $pattern := required (printf "kafkaConnector.logging.appenders.%s.pattern must be set" $appenderName) $appender.pattern }}
log4j.appender.{{ $appenderName }}.layout=org.apache.log4j.PatternLayout
log4j.appender.{{ $appenderName }}.layout.ConversionPattern={{ $pattern }}
  {{ end }}
{{- end }}

{{- /* Render connection loggers */ -}}
{{- range $key, $connection := $.Values.connectors.kafkaConnector.connections }}
  {{- if and $connection.enabled $connection.logger }}
# {{ $connection.name | quote }} logger
    {{- include "lightstreamer.kafka-connector.logging-logger-conf" (list $.Values.connectors.kafkaConnector.logging.appenders $connection.name $connection.logger) }}
  {{- end }}
{{ end }}

{{- end }}
