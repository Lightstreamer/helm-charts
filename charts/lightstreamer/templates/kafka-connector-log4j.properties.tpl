{{/*
Render the logger configuration
*/}}
{{- define "lightstreamer.kafka-connector.logging-logger-conf" -}}
{{- /*LOGGERS RENDERING */ -}}
{{- $globalAppenders := index . 0 -}}
{{- $loggerName := index . 1 -}}
{{- $logger := index . 2 -}}
{{- range $appenderName := required (printf "%s.appenders must be set" $loggerName) $logger.appenders }}
  {{- $appenderName := required (printf "%s.appenders must be set with valid values" $loggerName) $appenderName }}
  {{- if not (hasKey $globalAppenders $appenderName) }}
    {{- fail (printf "kafkaConnector.logging.loggers.appenders.%s not defined" $appenderName) }}
  {{- end }}
{{- end }}
{{- if not (mustHas $logger.level (list "INFO" "DEBUG" "WARN" "ERROR" "FATAL")) }}
  {{- fail (printf "kafkaConnector.logging.loggers.%s.level must be one of \"INFO\", \"DEBUG\", \"WARN\", \"ERROR\", \"FATAL\"" $loggerName) }}
{{- end }}
log4j.logger.{{ $loggerName}} = {{ $logger.level }}, {{ join ", " $logger.appenders }}
{{- end }} 

{{/*
Create the Kafka Connector logging configuration
*/}}
{{- define "lightstreamer.kafka-connector.logging-conf" -}}
{{- with required "kafkaConnector.logging must be set" .Values.connectors.kafkaConnector.logging -}}
  {{- /*LOGGERS RENDERING */ -}}
  {{- if .loggers -}}
# Global loggers
    {{- range $loggerName, $logger := .loggers -}}
      {{- include "lightstreamer.kafka-connector.logging-logger-conf" (list $.Values.connectors.kafkaConnector.logging.appenders $loggerName $logger) -}}  
    {{- end -}}
    {{- /* END OF LOGGERS RENDERING */ -}}
  {{- end -}}

  {{- /* APPENDERS RENDERING */ -}}
  {{- range $appenderName, $appender := required "kafkaConnector.logging.appenders must be set" .appenders }}

# {{ $appenderName | quote }} Appender
    {{- $type := default "" ($appender).type }}
    {{- if not (mustHas $type (list "Console")) }}
        {{- fail (printf "kafkaConnector.logging.appenders.%s.type must be one of \"Console\"" $appenderName) }}
    {{- end }}
    {{- if eq $type  "Console" }}
log4j.appender.{{ $appenderName }}=org.apache.log4j.ConsoleAppender
log4j.appender.{{ $appenderName }}.Target=System.out
  	{{- end }}
log4j.appender.{{ $appenderName }}.layout=org.apache.log4j.PatternLayout	
log4j.appender.{{ $appenderName }}.layout.ConversionPattern={{ required (printf "kafkaConnector.logging.appenders.%s.pattern must be set" $appenderName) $appender.pattern }}
  {{ end }} {{/* end of appenders */}}
  {{- /* END OF APPENDERS RENDERING */ -}}

  {{- /* CONNECTION LOGGERS RENDERING */ -}}
  {{- range $key, $connection := $.Values.connectors.kafkaConnector.connections }}
    {{- if $connection.logger }}
# {{ $connection.name | quote }} logger  
      {{- include "lightstreamer.kafka-connector.logging-logger-conf" (list $.Values.connectors.kafkaConnector.logging.appenders $connection.name $connection.logger) -}}
    {{- end }}
  {{- end -}} {{/* end of connection loggers */}}
  {{- /* END OF CONNECTION LOGGERS RENDERING */ -}}
  
{{- end -}} {{/* end of .Values.connectors.kafkaConnector.logging */}}
{{- end }}
