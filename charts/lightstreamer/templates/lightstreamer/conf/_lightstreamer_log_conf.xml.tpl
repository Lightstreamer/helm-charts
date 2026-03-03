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
Render the Lightstreamer logging configuration file
*/}}
{{- define "lightstreamer.configuration.log" -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: log_conf-APV-7.3.0. -->

<configuration scan="true" scanPeriod="10 seconds">
{{- with required "logging must be set" .Values.logging }}

  <!--
    A custom StatusListener used to log the internal status of Logback.
    This custom implementation is similar to the standard OnConsoleStatusListener
    implementation but will only log WARN and ERROR messages from Logback's internal
    status and will log on the standard error instead of logging on the standard output.
  -->
  <StatusListener class="com.lightstreamer.logback.Logging$OnConsoleErrorWarningStatusListener" />

  <!--
    This Appender is provided by Lightstreamer Kernel.
    It has to be used in addition to other Appenders in order to make
    log messages available to the internal Monitoring Data Adapter.
    Generic Appender configuration elements are supported,
    but for message formatting instructions, which are ignored.
  -->
  <appender name="LSProducer" class="com.lightstreamer.logback.ProducerAppender">
    <!--
    <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
      <level>warn</level>
    </filter>
    -->
  </appender>

  <!--
    Typical configuration of file Appenders for log messages.

    This configuration takes advantage of a useful extension of Logback
    native Appender RollingFileAppender provided by Lightstreamer Kernel.
    The com.lightstreamer.logback.RelativeFileAppenders$RollingFileAppender
    Appender behaves like the native one, but resolves relative file name
    specifications by starting from the directory containing this
    configuration file.
    The com.lightstreamer.logback.RelativeFileAppenders$FileAppender Appender
    is also available.

    Note that the log file names used for different logback appenders should
    be different.
  -->
  <!--
  <appender name="LSRolling" class="com.lightstreamer.logback.RelativeFileAppenders$RollingFileAppender">
  -->
    <!--
    <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
      <level>info</level>
    </filter>
    -->
    <!--
    <File>../logs/ls.log</File>

    <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
      <FileNamePattern>../logs/ls.log.%i</FileNamePattern>
      <MinIndex>1</MinIndex>
      <MaxIndex>5</MaxIndex>
    </rollingPolicy>

    <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">
      <MaxFileSize>1024KB</MaxFileSize>
    </triggeringPolicy>

    <encoder>
      <pattern>%d{"dd.MMM.yy HH:mm:ss,SSS"} &lt;%5.5(%p%marker)&gt; %m%n</pattern>
    </encoder>
    -->
  <!--
  </appender>
  -->

  {{- /* DEFINITION OF APPENDERS */ -}}
  {{- range $key, $val := .appenders }}
    {{- $name := printf "%s%s" "LS" (title $key) }}
    {{- if not (has $val.type (list "DailyRollingFile" "Console")) }}
      {{- fail (printf "logging.appenders.%s.type must be one of: \"DailyRollingFile\", \"Console\"" $key) }}
    {{- end }}
    {{- if eq $val.type "DailyRollingFile" }}
  <appender name={{ $name | quote }} class="com.lightstreamer.logback.RelativeFileAppenders$RollingFileAppender">
    <!--
    <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
      <level>info</level>
    </filter>
    -->
      {{ $fileName := required (printf "logging.appenders.%s.fileName must be set" $name) $val.fileName }}
      {{- $logsDir := include "lightstreamer.logs.dir" . }}
      {{- if $val.volumeRef }}
        {{- $extraVolumeNames := list }}
        {{- range $.Values.deployment.extraVolumes }}
          {{- $extraVolumeNames = append $extraVolumeNames .name }}
        {{- end }}
        {{- $extraVolumeNames := $extraVolumeNames | uniq }}
        {{- if not (has $val.volumeRef $extraVolumeNames) }}
          {{- fail (printf "logging.appenders.%s.volumeRef must be set to a volume defined in deployment.extraVolumes" $key) }}
        {{- end }}
        {{- $logsDir = printf "%s/%s" $logsDir $val.volumeRef }}
      {{- end }}
    <File>{{ $logsDir }}/{{ $fileName }}</File>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
      <!-- daily rollover -->
      {{- $fileNamePattern := required (printf "logging.appenders.%s.fileNamePattern must be set" $name) $val.fileNamePattern}}
      <fileNamePattern>{{ $logsDir }}/{{ $fileNamePattern }}</fileNamePattern>
    </rollingPolicy>
    {{- else if eq $val.type "Console" }}
  <appender name={{ $name | quote }} class="ch.qos.logback.core.ConsoleAppender">
    <!--
    <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
      <level>info</level>
    </filter>
    -->
    {{- end }}
    <encoder>
      <pattern>{{ required (printf "logging.appenders.%s.pattern must be set" $key) $val.pattern | replace "<" "&lt;" | replace ">" "&gt;" }}</pattern>
    </encoder>
  </appender>
  {{- end }}
  {{- /* END DEFINITION OF APPENDERS */ -}}

  <!--
    NOTE ON CUSTOM EXTENSIONS:
    You can configure custom appenders, or filters, or other extensions,
    provided that you add your own jars and/or third party jars to the
    proper ClassLoader. Look for "logging_lib_path" in the launch script.
  -->



  <!--
    The following is the base logger of all logging messages printed by
    Lightstreamer Kernel (with a few exceptions).

    Messages logged at INFO level notify major server activities,
    like session starting and ending. If these messages are enabled,
    they are also supplied to the internal MONITOR data adapter,
    together with WARN and ERROR messages.

    Messages logged at DEBUG level notify minor operations
    and all data flow inside the Server. They should not be enabled
    with production load levels.
    No useful messages are logged at TRACE level. The level is reserved
    for debug versions of the Server.

    Severe ERROR messages are logged with a "FATAL" marker; in fact, a FATAL
    level is not natively supported by logback.
    Thanks to the marker, these messages can be filtered through logback's
    MarkerFilter.
    By the factory pattern configuration, FATAL is logged instead of ERROR
    for these messages (note the tricky "%-5.5(%p%marker)" pattern).
  -->
  {{- with .loggers }}
    {{- with .lightstreamerLogger }}
  <logger name="LightstreamerLogger" level={{ include "lightstreamer.configuration.log.level" . | quote}}>
    <!--<appender-ref ref="LSRolling" />-->
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
    <appender-ref ref="LSProducer" />
      <!-- must be set in order to send log messages to internal MONITOR provider -->
  </logger>
    {{- end }}



  <!--
    These two loggers are used by the internal monitoring system to log
    load statistics at INFO level.
    LightstreamerMonitorText logs statistics with a human-readable syntax;
    LightstreamerMonitorTAB logs statistics with a CSV syntax.

    The frequency of the samples produced by the internal monitoring system
    is governed by the <collector_millis> configuration element.
    However, a resampling to lower frequencies can be performed, based on the
    level specified for each logger; in particular:
      at TRACE level, all samples are logged;
      at DEBUG level, one sample out of 10 is logged;
      at INFO level, one sample out of 60 is logged;
      at a higher level, no log is produced.
    The resampling behavior can be changed at runtime, by changing the level;
    however, if the level is set to ERROR on startup, the logger will be
    disabled throughout the life of the Server, regardless of further changes.

    When resampling is in place, note that, for each displayed sample, values
    that are supposed to be averaged over a timeframe still refer to the
    current sample's timeframe (based on <collector_millis>); however, values
    that are supposed to be the maximum over all timeframes refer also to the
    samples that were not displayed.
    On the other hand, delta statistics, like "new connections", are always
    collected starting from the previous logged sample.
  -->
    {{- with .lightstreamerMonitorText }}
  <logger name="LightstreamerMonitorText" level={{ include "lightstreamer.configuration.log.level" . | quote}}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with .lightstreamerMonitorTAB }}
  <logger name="LightstreamerMonitorTAB" level={{ include "lightstreamer.configuration.log.level" . | quote}}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}


    {{- with .lightstreamerLogger }}
      {{- with .subLoggers }}
  <!--
    The following subloggers are used to separate logging messages in families
  -->

  <!-- logging of system components initialization -->
  <!-- at DEBUG level, initialization details, error details and all configuration
       settings are reported -->
  <logger name="LightstreamerLogger.init"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "init") }}>
  </logger>

  <!-- logging of license check phase -->
  <!-- at DEBUG level, check details and error details can be found in case
       of license check failure -->
  <logger name="LightstreamerLogger.license"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "license") }}>
  </logger>

  <!-- logging of background activities and related configuration and issues -->
  <logger name="LightstreamerLogger.kernel"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "kernel") }}/>

  <!-- logging of external services activity -->
  <!-- at DEBUG level, details on external services activities and configuration,
       as well as details on connectivity issues, are reported. -->
  <logger name="LightstreamerLogger.external"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "external") }}/>

  <!-- logging of activity and issues in connection management -->
  <logger name="LightstreamerLogger.io"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "io") }}/>

  <!-- logging of activity and issues in TLS configuration -->
  <!-- at DEBUG level, details on the protocol and cipher suite configuration are reported -->
  <logger name="LightstreamerLogger.io.ssl"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "io.ssl") }}/>

  <!-- logging of client request dispatching -->
  <!-- at DEBUG level, request processing details are reported -->
  <!-- All log from this logger and its subloggers reports the IP and port of the involved connection -->
  <logger name="LightstreamerLogger.connections"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "connections") }}/>

  <!-- logging of issues related to TLS/SSL configuration and handshake management -->
  <!-- at DEBUG level, details on the cipher suites are reported -->
  <logger name="LightstreamerLogger.connections.ssl"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "connections.ssl") }}/>

  <!-- logging of client request interpretation issues -->
  <!-- at WARN level, each time a request contains an unexpected HTTP header,
     which the Server refuses or ignores, a notification is reported
     that an interpretation error is possible -->
  <!-- at INFO level, details upon request refusals are reported -->
  <!-- at DEBUG level, details for all requests and responses are reported -->
  <logger name="LightstreamerLogger.connections.http"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "connections.http") }}/>

  <!-- logging of details for issues related to requests over WebSockets -->
  <!-- at DEBUG level, details for all requests and responses are reported -->
  <logger name="LightstreamerLogger.connections.WS"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "connections.WS") }}/>

  <!-- logging of issues related to information received via the proxy protocol,
     when enabled -->
  <!-- at DEBUG level, details of all information received are reported -->
  <logger name="LightstreamerLogger.connections.proxy"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "connections.proxy") }}/>

  <!-- logging of internal web server activity; it also logs requests of
     static resources related to push requests -->
  <!-- at DEBUG level, error details are reported -->
  <!-- All log from this logger and its subloggers reports the IP and port of the involved connection -->
  <logger name="LightstreamerLogger.webServer"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "webServer") }}/>

  <!-- logging of request management related to the JMX Tree feature -->
  <!-- at DEBUG level, error details are reported -->
  <logger name="LightstreamerLogger.webServer.jmxTree"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "webServer.jmxTree") }}/>

  <!-- logging of handling of special requests from apple clients related to MPN -->
  <!-- at DEBUG level, error details are reported -->
  <logger name="LightstreamerLogger.webServer.appleWebService"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "webServer.appleWebService") }}/>

  <!-- logging of parsing and elaboration of client requests -->
  <!-- at DEBUG level, client request details are reported -->
  <!-- All log from this logger and its subloggers reports the IP and port of the involved connection -->
  <logger name="LightstreamerLogger.requests"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "requests") }}/>

  <!-- logging of elaboration of client polling requests -->
  <logger name="LightstreamerLogger.requests.polling"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "requests.polling") }}/>

  <!-- logging of elaboration of client message requests -->
  <!-- at DEBUG level, details on the message forwarding are reported -->
  <logger name="LightstreamerLogger.requests.messages"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "requests.messages") }}/>

  <!-- logging of Data Adapters interactions -->
  <!-- at DEBUG level, details on subscription operations are reported -->
  <logger name="LightstreamerLogger.subscriptions"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "subscriptions") }}/>

  <!-- logging of events coming from the Data Adapters -->
  <!-- at DEBUG level, all update events are dumped -->
  <logger name="LightstreamerLogger.subscriptions.upd"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "subscriptions.upd") }}/>

  <!-- logging of events preprocessing stage -->
  <!-- at DEBUG level, events dispatched to ItemEventBuffers are dumped -->
  <logger name="LightstreamerLogger.preprocessor"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "preprocessor") }}/>

  <!-- logging of internal thread management and events dispatching -->
  <logger name="LightstreamerLogger.scheduler"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "scheduler") }}/>

  <!-- logging of InfoPump and ItemEventBuffers internal activity -->
  <!-- at DEBUG level, updates to be sent to the clients are dumped -->
  <logger name="LightstreamerLogger.pump"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "pump") }}/>

  <!-- logging of management of messages received from the clients -->
  <!-- at DEBUG level, details of message processing are logged -->
  <!-- All log from this logger reports the IP and port of the involved connection -->
  <logger name="LightstreamerLogger.pump.messages"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "pump.messages") }}/>

  <!-- logging of socket write activity -->
  <!-- at DEBUG level, all socket writes are dumped -->
  <!-- All log from this logger reports the IP and port of the involved connection -->
  <logger name="LightstreamerLogger.push"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "push") }}/>

  <!-- logging of mobile push notifications activity, done through the various subloggers -->
  <logger name="LightstreamerLogger.mpn"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn") }}/>

  <!-- logging of MPN Module recurrent activity -->
  <!-- at INFO level, main operation exit points and outcomes are dumped -->
  <!-- at DEBUG level, the various operation entry and exit points are logged -->
  <logger name="LightstreamerLogger.mpn.lifecycle"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.lifecycle") }}/>

  <!-- logging of mobile push notifications activity -->
  <!-- at INFO level, main operation exit points and outcomes are dumped -->
  <!-- at DEBUG level, the various operation entry and exit points are logged -->
  <logger name="LightstreamerLogger.mpn.operations"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.operations") }}/>

  <!-- logging of mobile push notifications request processing;
       requests include those from clients (through the "client" sublogger)
       and those related to internal operations -->
  <!-- at INFO level, all request processing exit points and outcomes are dumped -->
  <!-- at DEBUG level, all request processing entry points are logged -->
  <!-- All log related to client requests reports the IP and port of the involved connection -->
  <logger name="LightstreamerLogger.mpn.requests"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.requests") }}/>

  <!-- logging of mobile push notifications activity related to notification gathering -->
  <!-- at INFO level, all push notifications ready to be sent are dumped -->
  <logger name="LightstreamerLogger.mpn.pump"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.pump") }}/>

  <!-- logging of mobile push notifications activity related to database -->
  <!-- at DEBUG level, all database operation entry and exit points are logged -->
  <logger name="LightstreamerLogger.mpn.database"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.database") }}/>

  <!-- logging of mobile push notifications activity related to database transactions -->
  <!-- at INFO level, statistics on the database transactions are logged -->
  <!-- at DEBUG level, all database transaction entry and exit points are logged -->
  <logger name="LightstreamerLogger.mpn.database.transactions"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.database.transactions") }}/>

  <!-- logging of mobile push notifications activity related to Apple platforms;
       for activity related to notification submission,
       specific subloggers are present for each application, e.g.:
       LightstreamerLogger.mpn.apple.com.mydomain.myapp -->
  <!-- at INFO level, all push notification payloads are dumped -->
  <logger name="LightstreamerLogger.mpn.apple"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.apple") }}/>

  <!-- logging of mobile push notifications activity related to Google platforms;
       for activity related to notification submission,
       specific subloggers are present for each application, e.g.:
       LightstreamerLogger.mpn.google.com.mydomain.myapp -->
  <!-- at INFO level, all push notification payloads are dumped -->
  <logger name="LightstreamerLogger.mpn.google"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.google") }}/>

  <!-- logging of issues related to the special adapters handled by the MPN Module -->
  <logger name="LightstreamerLogger.mpn.status_adapters"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "mpn.status_adapters") }}/>

  <!-- logging of JavaScript client messages -->
  <!-- at DEBUG level, log messages sent by the Web and Node.js (Unified API) Client Libraries
       are logged. Remote logging must be enabled on the client side. -->
  <!-- All log from this logger reports the IP and port of the involved connection -->
  <logger name="LightstreamerLogger.webclient"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "webclient") }}/>

  <!-- logging of JMX setup issues; note that full JMX features could be restricted
       depending on Edition and License Type. -->
  <!-- at DEBUG level, JMX connectors initialization details are logged. -->
  <logger name="LightstreamerLogger.monitoring"{{ include "lightstreamer.configuration.log.subloggers.level" (list . "monitoring") }}/>
      {{- end }} {{/* .subLoggers */}}
    {{- end }} {{/* .lightstreamerLogger */}}


    {{ with .lightstreamerHealthCheck }}
  <!--
    The following logger logs healthcheck request processing at INFO level.
    The logger does not inherit from "LightstreamerLogger" in order
    to simplify sending the log to a dedicated appender.
    All log from this logger reports the IP and port of the involved connection.
  -->
  <logger name="LightstreamerHealthCheck" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}

    {{- with .lightstreamerProxyAdapters }}
  <!--
    This logger is only used by the provided Proxy Data and Metadata Adapters,
    when used.
    It logs Adapter activity at INFO, WARN, ERROR and FATAL level
    (the latter through the "FATAL" marker).
    At DEBUG level, outcoming request and incoming response messages are also dumped.
    At TRACE level, incoming real-time update messages are also dumped.
  -->
  <logger name="LightstreamerProxyAdapters" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
    <!--<appender-ref ref="LSRolling" />-->
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}



  <!--
    Log from third-party libraries used internally by the Server.
    All the log produced by these libraries is routed, by keeping the category names,
    to the JDK's java.util.logging system first, then routed to Logback.
    Hence, this log can be consumed by defining the loggers below.

    If any Adapter should log through the java.util.logging support
    on the same categories, (either directly, or by using the same JDK services,
    or through some third-party library), this log will be shared with the Server log.

    If, for any reason, it is required that the configuration of the java.util.logging
    system for some of these categories is done elsewhere, then the mappings done here
    can be disabled at startup, by just removing or commenting out the corresponding
    loggers below, or by setting them to level OFF.
    Disabling the mapping may also prevent inefficiency for heavy loggers.
  -->

  <!--
    These loggers are related to Hibernate, a component used by the MPN Module
    for its persistence with the database. In case of need, please refer to
    Hibernate documentation for more information on its logging categories and
    their configuration.
  -->
    {{- with (get . "org.hibernate") }}
  <logger name="org.hibernate" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}

    {{- with (get . "java.sql") }}
  <logger name="java.sql" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}

    {{- with  (get . "org.jboss.logging") }}
  <logger name="org.jboss.logging" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}

    {{- with  (get . "com.zaxxer.hikari") }}
  <logger name="com.zaxxer.hikari" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}

  <!--
    These loggers are related to other third-party libraries used internally
    by the Server.
  -->
    {{- with  (get . "org.apache.http") }}
  <logger name="org.apache.http" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "com.github.markusbernhardt.proxy") }}
  <logger name="com.github.markusbernhardt.proxy" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "org.restlet") }}
  <logger name="org.restlet" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "org.jminix") }}
  <logger name="org.jminix" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "common.jmx.velocity") }}
  <logger name="common.jmx.velocity" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "com.turo") }}
  <logger name="com.turo" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "com.google") }}
  <logger name="com.google" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "io.netty") }}
  <logger name="io.netty" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "org.codehaus.janino") }}
  <logger name="org.codehaus.janino" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "io.grpc") }}
  <logger name="io.grpc" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "io.opencensus") }}
  <logger name="io.opencensus" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "org.conscrypt") }}
  <logger name="org.conscrypt" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}

  <!--
    These loggers are related to JDK services.
  -->
    {{- with (get . "javax.management.remote") }}
  <logger name="javax.management.remote" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "javax.management.mbeanserver") }}
  <logger name="javax.management.mbeanserver" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "com.sun.jmx.remote") }}
  <logger name="com.sun.jmx.remote" level={{ .level | quote }}>
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}
    {{- with (get . "javax.net.ssl") }}
  <logger name="javax.net.ssl" level={{ include "lightstreamer.configuration.log.level" . | quote }}>
    <!-- this also requires that the JVM property javax.net.debug is set as an empty string (supported since java 9) -->
      {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
    {{- end }}

  {{- end }} {{/* .loggers */}}

  <!-- Extra loggers -->
  {{- range $loggerName, $logger := .extraLoggers }}
  <logger name={{ $loggerName | quote }} level={{ include "lightstreamer.configuration.log.level" $logger | quote }}>
    {{- include "lightstreamer.configuration.log.appender_ref" (list $.Values.logging.appenders .) | indent 4 }}
  </logger>
  {{- end }} {{/* .extraLoggers */}}

  <!--
    Setting properties in the root logger is not needed, as all log
    messages fall in one of the loggers defined above.
  -->
  <root>
  </root>

</configuration>
{{- end }} {{/* .Values.logging */}}
{{- end }}
