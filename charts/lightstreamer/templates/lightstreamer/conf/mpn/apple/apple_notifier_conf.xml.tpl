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

{{- define "lightstreamer.configuration.mpn.apple_notifier" -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: apple_notif_conf-APV-20200124. -->

<apple_notifier_conf>
{{- with .Values.mpn.appleNotifierConfig }}
  <env_prefix>env.</env_prefix>

   <!-- Optional. Minimum delay between successive mobile push
        notifications for the same app/device pair. Each app/device
        pair is subject to constraints on the pace mobile push
        notifications may be sent to it. For this reason, a minimum
        delay is set and may be altered with this parameter. Lowering
        it too much, and subsequently sending notifications with a high
        frequency, may cause Apple's Push Notification Service ("APNs")
        to close the connection and ban (temporarily or permanently) any
        successive notifications.
        Mobile push notifications fired by a trigger are not subject to
        this limit and may be sent at higher pace.
        Default: 1000 (1 sec) -->
  {{- if not (quote .minSendDelayMillis) | empty }}
     <min_send_delay_millis>{{ int .minSendDelayMillis }}</min_send_delay_millis>
  {{- else }}
   <!--
   <min_send_delay_millis>1000</min_send_delay_millis>
   -->
  {{- end }}

   <!-- Optional. Maximum number of concurrent connections to APNS
        services. The connection pool starts with 1 connection and grows
        automatically as the load increases. In case the expected load is
        very high, increasing the pool maximum size my be beneficial.
        For apps with development service level, this parameter is ignored.
        Default: 1 -->
  {{- if not (quote .maxConcurrentConnections) | empty }}
   <max_concurrent_connections>{{ int .maxConcurrentConnections }}</max_concurrent_connections>
  {{- else }}
   <!--
   <max_concurrent_connections>10</max_concurrent_connections>
   -->
  {{- end }}

   <!-- Optional. Timeout for connecting to APNS services. In case of slow
        outgoing connectivity, increasing the timeout may be beneficial.
        Default: 30000 (30 sec) -->
  {{- if not (quote .connectionTimeoutMillis) | empty }}
   <connection_timeout>{{ int .connectionTimeoutMillis }}</connection_timeout>
  {{- else }}
   <!--
   <connection_timeout>30000</connection_timeout>
   -->
  {{- end }}

   <!-- Optional and cumulative.
        Configuration of a specific app that should receive mobile push
        notifications. As per documentation, each app has a specific
        app ID which corresponds to the bundle ID of the app's binary.
        Each <app> block configures an app corresponding to the "id"
        attribute.
        Note that for web apps (i.e. targeting Safari push notification) the
        ID must begin with "web.", e.g.: "web.com.mydomain.myapp". -->
  {{- range $appName, $app := .apps }}
    {{- if ($app).enabled }}
   <app id={{ (required (printf "mpn.appleNotifierConfig.apps.%s.id must be set" $appName) $app.id) | quote }}>

      <!-- Mandatory. Specifies the intended service level for the
           current app ID, must be one of: test, development, production.
           If set to "test", notification will be logged only and no
           connection will be established with Apple's servers.
           The corresponding logger is LightstreamerLogger.mpn.apple,
           notifications are logged at INFO level (see lightstreamer_log_conf.xml).
           If set to "development" or "production", notifications will
           be sent to, respectively, Apple's development or
           production servers. In this case the following two parameters
           become mandatory.
           Note that for web apps (i.e. targeting Safari push notification)
           the "development" service level should not be used, as there is no
           corresponding "development" client environment that can receive
           notifications. Use either "production" or "test". -->
      {{- if not (has $app.serviceLevel (list "test" "development" "production" )) }}
        {{- fail (printf "mpn.appleNotifierConfig.apps.%s.serviceLevel must be one of: \"test\", \"development\", \"production\"" $appName) }}
      {{- else }}
      <service_level>{{ $app.serviceLevel }}</service_level>
      {{- end }}

      <!-- Optional. File path of the keystore with Apple's
           certificate for the current app ID. Must be set if
           the service level is "development" or "production".
           The file path is relative to the directory that contains this
           configuration file. -->
      {{- if has $app.serviceLevel (list "development" "production") }}
        {{- $keyStoreName := required (printf "mpn.appleNotifierConfig.apps.%s.keystoreRef must be set because of service level set to \"%s\"" $appName $app.serviceLevel) $app.keystoreRef }}
        {{- $keyStore := required (printf "mpn.appleNotifierConfig.keystores.%s not defined" $keyStoreName) (get ($.Values.mpn.appleNotifierConfig.keystores | default dict) $keyStoreName) }}
      <keystore_file>keystores/{{ $keyStoreName }}/{{ required (printf "mpn.appleNotifierConfig.keystores.%s.keystoreFileSecretRef.key must be set" $keyStoreName) ($keyStore.keystoreFileSecretRef).key }}</keystore_file>
      <keystore_password>$env.LS_MPN_APPLE_KEYSTORE_{{ $keyStoreName | upper | replace "-" "_" }}_PASSWORD</keystore_password>
      {{- end }}
      <!--
      <keystore_file>my_app_keystore.p12</keystore_file>
      -->

      <!-- Optional. Password of the keystore with Apple's
           certificate for the current app ID. Must be set if
           the service level is "development" or "production". -->
      <!--
      <keystore_password>mypassword</keystore_password>
      -->

      <!-- Optional. File path of the push package zip file. This file contains
           a descriptor of the web app (i.e. targeting Safari push notification),
           and is mandatory only for web apps (ignore in other cases). See
           the General Concepts document for more information on how to produce
           this file. -->
      {{- if hasPrefix "web." $app.id }}
        {{- if $app.pushPackageFileRef }}
          {{- $name := required (printf "mpn.appleNotifierConfig.apps.%s.pushPackageFileRef.name must be set" $appName) $app.pushPackageFileRef.name }}
          {{- $key := required (printf "mpn.appleNotifierConfig.apps.%s.pushPackageFileRef.key must be set" $appName) $app.pushPackageFileRef.key }}
      <push_package_file>{{ $appName }}/{{ $key }}</push_package_file>
        {{- else }}
          {{- fail (printf "mpn.appleNotifierConfig.apps.%s.pushPackageFileRef must be set for a web app" $appName) }}
        {{- end }}
      {{- else }}
      <!--
      <push_package_file>pushPackage.zip</push_package_file>
      -->
      {{- end }}

      <!-- Optional. Specifies the list of trigger expressions that will be
           accepted. Each <accept> element is a Java-compatible regular expression
           (see java.util.regex.Pattern): triggers requested via client APIs will
           be compared with each regular expression, and accepted only if there
           is at least one match.
           Remember that the MPN Module supports, as trigger, any Java boolean
           expression, including use of JDK classes and methods, with the addition
           of field references syntax (see the iOS Client SDK for more information).
           Hence, this check is a safety measure required to avoid that clients
           can request triggers potentially dangerous for the Server, as each
           trigger may contain arbitrary Java code.
           If left commented out or empty, no triggers will be accepted.
           Please note that using an "accept all" regular expression like .*
           is possible, but still leaves the Server exposed to the danger of
           maliciously crafted triggers. Anyway, the Metadata Adapter has a second
           chance to check for trigger allowance.
           The example shown below is for a typical notification on threshold,
           where a field is compared against a numeric constant.
           Note: submitted trigger expressions are compared with this list of
           regular expressions after their named-arguments have been converted
           to indexed-arguments. Always specify fields with the "$[digits]" format,
           not the "${name}" format. -->
      {{- if $app.triggerExpressions }}
      <trigger_expressions>
        {{- range $trigger := $app.triggerExpressions }}
         <accept>{{ $trigger | replace "<" "&lt;" | replace ">" "&gt;" }}</accept>
        {{- end }}
      </trigger_expressions>
      {{- else }}
      <!--
      <trigger_expressions>
         <accept>Double\.parseDouble\(\$\[\d+\]\) [&lt;&gt;] [+-]?(\d*\.)?\d+</accept>
      </trigger_expressions>
      -->
      {{- end }}
   </app>

    {{- end }} {{/* if ($app).enabled */}}
  {{- end }} {{/* range .apps */}}
{{- end }} {{/* with Values.mpn.appleNotifierConfig */}}
</apple_notifier_conf>
{{- end }}
