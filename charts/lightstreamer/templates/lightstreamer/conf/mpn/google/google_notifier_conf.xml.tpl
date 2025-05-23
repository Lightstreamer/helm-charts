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

{{- define "lightstreamer.configuration.mpn.google_notifier" -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: google_notif_conf-APV-20200124. -->

<google_notifier_conf>
{{- with .Values.mpn.googleNotifierConfig }}

   <!-- Optional. Minimum delay between successive mobile push
        notifications for the same app/device pair. Each app/device
        pair is subject to constraints on the pace mobile push
        notifications may be sent to it. For this reason, a minimum
        delay is set and may be altered with this parameter. Lowering
        it too much, and subsequently sending notifications with a high
        frequency, may cause Google's Firebase Cloud Messaging service ("FCM")
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

   <!-- Optional. Size of the notifier's "MPN XXX MESSAGING" internal thread
        pool, which is devoted to sending the notifications payload. Each
        app has a separate thread pool. On multiprocessor machines,
        allocating multiple threads for this task may be beneficial.
        Default: The number of available total cores, as detected by the
        JVM. -->
   {{- if not (quote .messagingPoolSize) | empty }}
   <messaging_pool_size>{{ int .messagingPoolSize }}</messaging_pool_size>
   {{- else }}
   <!--
   <messaging_pool_size>10</messaging_pool_size>
   -->
   {{- end }}

   <!-- Optional and cumulative.
        Configuration of a specific app that should receive mobile push
        notifications. Each <app> block configures an app corresponding to the
        package name specified in the "packageName" attribute. -->
  {{- range $appName, $app := .apps }}
    {{- if ($app).enabled }}
   <app packageName={{ (required (printf "mpn.googleNotifierConfig.apps.%s.packageName must be set" $appName) $app.packageName) | quote }}>

      <!-- Mandatory. Specifies the intended service level for the
           current app, must be one of: test, dry_run, production.
           If set to "test", notification will be logged only and no
           connection will be established with Google's servers.
           The corresponding logger is LightstreamerLogger.mpn.google,
           notifications are logged at INFO level (see
           lightstreamer_log_conf.xml).
           If set to "dry_run" or "production", notifications will
           be sent to Google's servers. If set to "dry_run",
           notifications will be accepted by Google's servers but not
           delivered to the user's device.
           If not set to "test" the following parameter becomes
           mandatory. -->
      {{- if not (has $app.serviceLevel (list "test" "dry_run" "production" )) }}
        {{- fail (printf "mpn.googleNotifierConfig.apps.%s.serviceLevel must be one of: \"test\", \"dry_run\", \"production\"" $appName) }}
      {{- else }}
      <service_level>{{ $app.serviceLevel }}</service_level>
      {{- end }}

      <!-- Optional. File path of the JSON descriptor for the service
           account credentials of this project on Firebase console.
           Must be set if the service level is "dry_run" or "production".
           The file path is relative to the directory that contains this
           configuration file. See the General Concepts document for more
           information on how to obtain this file. -->
      {{- if has $app.serviceLevel (list "dry_run" "production" ) }}
      <service_json_file>{{ $appName }}/{{ $app.serviceJsonFileRef.key }}</service_json_file>
      {{- else }}
      <!--
      <service_json_file>my_app_service.json</service_json_file>
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
{{- end }} {{/* with Values.mpn.googleNotifierConfig */}}
</google_notifier_conf>
{{- end }}
