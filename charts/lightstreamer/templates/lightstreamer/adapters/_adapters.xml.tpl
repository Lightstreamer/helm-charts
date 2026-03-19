{{/*
Render the Lightstreamer configuration file of an Adapter Set
*/}}
{{- define "lightstreamer.adapters" -}}
{{- $ := index . 0 -}}
{{- $adapterName := index . 1 -}}
{{- $adapter := index . 2 -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: adapters_conf-APV-7.4.5. -->

<!-- Mandatory. Define an Adapter Set and its unique ID. -->
{{- /* START ADAPTER SET */ -}}
{{- with $adapter }}
<adapters_conf id={{ .id | quote }}>

  {{- /* START ADAPTER SET POOL */ -}}
  {{- if hasKey . "adapterSetPool" }}

  <!-- ADAPTER SET POOL -->
  <adapter_set_pool>
    <max_size>{{ int (required (printf "adapters.%s.adapterSetPool.maxSize must be set" $adapterName) (.adapterSetPool).maxSize) }}</max_size>
    <max_free>{{ int (required (printf "adapters.%s.adapterSetPool.maxFree must be set" $adapterName) (.adapterSetPool).maxFree) }}</max_free>
  </adapter_set_pool>
  <!-- END ADAPTER SET POOL -->
  {{- end }}
  {{- /* END ADAPTER SET POOL */ -}}

  {{- if not (quote .enableMetadataInitializedFirst | empty) }}

  <metadata_adapter_initialised_first>{{ .enableMetadataInitializedFirst | ternary "Y" "N" }}</metadata_adapter_initialised_first>
  {{- end }}

  {{/* START METADATA PROVIDER */ -}}
  <metadata_provider>
  {{- with .metadataProvider }}
    {{- if hasKey . "inProcessMetadataAdapter" }}
      {{- /* START IN-PROCESS METADATA ADAPTER */ -}}
      {{- with .inProcessMetadataAdapter }}
        {{- if .installDir }}
    <install_dir>{{ .installDir }}</install_dir>
        {{- end }}
    <adapter_class>{{ .adapterClass }}</adapter_class>

        {{- if not (quote .classLoader | empty) }}
    <classloader>{{ .classLoader }}</classloader>
        {{- end }}

        {{- include "lightstreamer.adapters.in-process.metadata-provider.authenticationPool" . | indent 4 -}}
        {{- include "lightstreamer.adapters.in-process.metadata-provider.messagesPool" . | indent 4 -}}
        {{- include "lightstreamer.adapters.in-process.metadata-provider.mpnPool" (list $adapterName .) | indent 4 -}}

        {{- if not (quote .enableTableNotificationsSequentialization | empty) }}
    <sequentialize_table_notifications>{{ .enableTableNotificationsSequentialization | ternary "Y" "N" }}</sequentialize_table_notifications>
        {{- end }}

        {{- include "lightstreamer.adapters.in-process.common.initParams" . | indent 4 -}}

      {{- /* END IN-PROCESS METADATA ADAPTER */ -}}
      {{- end }}
    {{- else if hasKey . "proxyMetadataAdapter" }}
      {{- /* PROXY METADATA ADAPTER */ -}}
      {{- with .proxyMetadataAdapter}}
        {{- $isRobust := .enableRobustAdapter | default false -}}
    <adapter_class>{{ include "lightstreamer.adapters.proxy.common.class" . }}</adapter_class>
    <classloader>log-enabled</classloader>

        {{- include "lightstreamer.adapters.proxy.metadata-provider.authenticationPool" . | indent 4 -}}
        {{- include "lightstreamer.adapters.proxy.metadata-provider.messagesPool" . | indent 4 -}}
        {{- include "lightstreamer.adapters.proxy.metadata-provider.mpnPool" (list $adapterName .) | indent 4 -}}

        {{- if not (quote .enableTableNotificationsSequentialization | empty) }}
    <sequentialize_table_notifications>{{ .enableTableNotificationsSequentialization | ternary "Y" "N" }}</sequentialize_table_notifications>
        {{- end }}

        {{- include "lightstreamer.adapters.proxy.common.sslConfig" (list $adapterName $.Values.keystores .) | indent 4 -}}
        {{- include "lightstreamer.adapters.proxy.common.authentication" (list $adapterName .) | indent 4 -}}
        {{- include "lightstreamer.adapters.proxy.common.connection" . | indent 4 -}}
        {{- include "lightstreamer.adapters.proxy.metadata-provider.closeNotification" (list $adapterName .) | indent 4 -}}
        {{- include "lightstreamer.adapters.proxy.common.remoteParams" (list $adapterName .) | indent 4 -}}

        {{- if not (quote .enableClearingOnSessionClose | empty) }}
    <param name="clear_on_session_close">{{ .enableClearingOnSessionClose | ternary "true" "false" }}</param>
        {{- end }}

        {{- if not (quote .userDataTimeoutMillis | empty)}}
    <param name="user_data_timeout">{{ int .userDataTimeoutMillis }}</param>
        {{- end }}

        {{- if $isRobust }}
          {{- if not (quote .enableClearingOnNewRemote | empty)}}
    <param name="clear_on_new_remote">{{ .enableClearingOnNewRemote | ternary "true" "false" }}</param>
          {{- end }}
        {{- end }}

        {{- include "lightstreamer.adapters.proxy.common" (list $adapterName .) | nindent 4 -}}
      {{- /* END PROXY METADATA ADAPTER */ -}}
      {{- end }}
    {{- end }} {{/* metadataAdapter or proxyMetadataAdapter */}}
  {{- end }}
  </metadata_provider>
  {{- /* END METADATA PROVIDER */ -}}
  {{- /* START DATA PROVIDERS */ -}}
  {{- range $dataProviderName, $dataProvider := .dataProviders }}
    {{- if $dataProvider.enabled }}
    {{- $dataProviderName := default "DEFAULT" $dataProvider.name }}

  <data_provider name={{ $dataProviderName | quote }}>
      {{- /* IN-PROCESS DATA ADAPTER */ -}}
      {{- if $dataProvider.inProcessDataAdapter }}
        {{- with $dataProvider.inProcessDataAdapter }}
          {{- if .installDir }}
    <install_dir>{{ .installDir }}</install_dir>
          {{- end }}
    <adapter_class>{{ .adapterClass }}</adapter_class>
          {{- if not (quote .classLoader | empty )}}
    <classloader>{{ .classLoader }}</classloader>
          {{- end }}

    {{- include "lightstreamer.adapters.data-provider.dataAdapterPool" (list $adapterName $dataProviderName .) | nindent 4 -}}
    {{- include "lightstreamer.adapters.in-process.common.initParams" . | indent 4 -}}

        {{- end }}
      {{- /* END IN-PROCESS DATA ADAPTER */ -}}
      {{- /* PROXY DATA ADAPTER */ -}}
      {{- else if $dataProvider.proxyDataAdapter }}
        {{- with $dataProvider.proxyDataAdapter }}
          {{- $isRobust := .enableRobustAdapter | default false }}
    <adapter_class>{{ include "lightstreamer.adapters.proxy.common.class" . }}</adapter_class>
    <classloader>log-enabled</classloader>

          {{- include "lightstreamer.adapters.data-provider.dataAdapterPool" (list $adapterName $dataProviderName .) | nindent 4 -}}
          {{- include "lightstreamer.adapters.proxy.common" (list $adapterName .) | nindent 4 -}}
          {{- include "lightstreamer.adapters.proxy.common.sslConfig" (list $adapterName $.Values.keystores .) | indent 4 -}}
          {{- include "lightstreamer.adapters.proxy.common.authentication" (list $adapterName .) | indent 4 -}}
          {{- include "lightstreamer.adapters.proxy.common.connection" . | indent 4 -}}

          {{- if $isRobust }}
            {{- if .eventsRecovery }}
              {{- $possibleValues := list "leave_hole" "use_snapshot" "enforce_snapshot" -}}
              {{- if not (has .eventsRecovery $possibleValues) }}
                {{ printf "adapters.%s.dataProviders.%s.eventsRecovery must be one of: %s" $adapterName $dataProviderName $possibleValues | fail }}
              {{- end }}
    <param name="events_recovery">{{ .eventsRecovery }}</param>
            {{- end }}

            {{- if not (quote .statusItem | empty) }}
    <param name="status_item">{{ .statusItem }}</param>
            {{- end }}
          {{- end }}

          {{- include "lightstreamer.adapters.proxy.common.remoteParams" (list $adapterName .) | nindent 4 -}}

        {{- end }}
      {{- /* END PROXY DATA ADAPTER */ -}}
      {{- end }}
  </data_provider>
    {{- end }} {{- /* if $dataProvider.enabled */ -}}
  {{- end }}
  {{/* END DATA PROVIDERS */}}
</adapters_conf>
{{- end -}}
{{- /* END ADAPTER SET */ -}}
{{- end -}}
