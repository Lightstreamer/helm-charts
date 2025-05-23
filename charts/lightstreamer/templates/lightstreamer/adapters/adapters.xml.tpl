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
  {{- with .adapterSetPool }}

  <!-- ADAPTER SET POOL -->
  <adapter_set_pool>
    <max_size>{{ int (required (printf "adapters.%s.adapterSetPool.maxSize must be set" $adapterName) .maxSize) }}</max_size>
    <max_free>{{ int (required (printf "adapters.%s.adapterSetPool.maxFree must be set" $adapterName) .maxFree) }}</max_free>
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
        {{- include "lightstreamer.adapters.in-process.common.initParams" . | indent 4 -}}

        {{- if not (quote .enableTableNotificationsSequentialization | empty) }}
    <metadata_adapter_initialised_first>{{ .enableTableNotificationsSequentialization | ternary "Y" "N" }}</metadata_adapter_initialised_first>
        {{- end }}

        {{- if not (quote .maxBandwidth | empty) }}
    <param name="max_bandwidth">{{ .maxBandwidth }}</param>
        {{- end }}

        {{- if not (quote .maxFrequency | empty) }}
    <param name="max_frequency">{{ .maxFrequency }}</param>
        {{- end }}

        {{- if not (quote .bufferSize | empty) }}
    <param name="buffer_size">{{ .bufferSize }}</param>
        {{- end }}

        {{- if not (quote .prefilterFrequency | empty) }}
    <param name="prefilter_frequency">{{ .prefilterFrequency }}</param>
        {{- end }}

        {{- if not (quote .distinctSnapshotLength | empty) }}
    <param name="distinct_snapshot_length">{{ .distinctSnapshotLength }}</param>
        {{- end }}

        {{- if not (quote .allowedUsers | empty) }}
    <param name="allowed_users">{{ .allowedUsers }}</param>
        {{- end }}

        {{- /* START ITEM FAMILIES */ -}}
        {{- $counter := 0 }}
        {{- range $familyName, $family := .itemFamilies }}
          {{- if $family }}
            {{- $counter = add1 $counter }}

    <param name="item_family_{{ $counter }}">{{ required (printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.itemFamilies.%s.itemPattern must be set" $adapterName $familyName) $family.itemPattern }}</param>
        {{- if not (quote $family.dataAdapter | empty) }}
    <param name="data_adapter_for_item_family_{{ $counter }}">{{ required (printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.itemFamilies.%s.dataAdapter must be set" $adapterName $familyName) $family.dataAdapter }}</param>
            {{- $modes := regexSplit "," (required (printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.itemFamilies.%s.modes must be set" $adapterName $familyName) $family.modes) -1 }}
            {{- range $modes}}
              {{- if not (has . (list "DISTINCT" "COMMAND" "MERGE" "RAW")) }}
                {{ printf "adapters.%s.metadataProvider.inProcessMetadataAdapter.itemFamilies.%s.modes must be a comma-separated list of DISTINCT, COMMAND, MERGE, RAW" $adapterName $familyName | fail }}
              {{- end }}
            {{- end }}
        {{- end }}
    <param name="modes_for_item_family_{{ $counter }}">{{ $family.modes }}</param>
          {{- end }}
        {{- end }}
        {{- /* END ITEM FAMILIES */ -}}
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
    <metadata_adapter_initialised_first>{{ .enableTableNotificationsSequentialization | ternary "Y" "N" }}</metadata_adapter_initialised_first>
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

  <data_provider name={{ $dataProvider.name | quote }}>
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
