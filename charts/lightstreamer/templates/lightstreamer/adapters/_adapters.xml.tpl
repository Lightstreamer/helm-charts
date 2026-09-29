{{/*
Render the Lightstreamer configuration file of an Adapter Set
*/}}
{{- define "lightstreamer.adapters" }}
{{- $ := index . 0 }}
{{- $adapterName := index . 1 }}
{{- $adapter := index . 2 -}}
<?xml version="1.0" encoding="UTF-8"?>

<!-- Mandatory. Define an Adapter Set and its unique ID. -->
{{- with $adapter }}
<adapters_conf id="{{ .id }}">

    <!-- Optional. Requests the creation of a specific "SET" thread pool, devoted
         to the management of all the client requests pertaining to sessions
         based on this Adapter Set. Only requests related with the special
         Data Adapter used to supply the state of the MPN Module (if enabled)
         are not included and fall into the global SERVER pool.
         However, for some invocations, an optional, more specific, subpool,
         as shown below, can be defined to handle them.
         In particular, the AUTHENTICATION and MSG pools are always created,
         even if not defined, hence they don't contribute to this pool.

         If not defined, these requests are managed by the global SERVER
         thread pool.
         If defined, the <max_size> and <max_free> elements are mandatory,
         with meaning similar to that of the global <server_pool_max_size>
         and <server_pool_max_free> settings. Note that <max_size> also
         indicates the maximum number of pending requests to the Remote
         Adapters.
         Using a specific thread pool is advisable if the implementation
         of any of the Adapter methods introduces delays and more specific
         thread pools are not being used. -->
  {{- if .adapterSetPool }}
    <adapter_set_pool>
        <max_size>{{ int (required (printf "adapters.%s.adapterSetPool.maxSize must be set" $adapterName) .adapterSetPool.maxSize) }}</max_size>
        <max_free>{{ int (required (printf "adapters.%s.adapterSetPool.maxFree must be set" $adapterName) .adapterSetPool.maxFree) }}</max_free>
    </adapter_set_pool>
  {{- else }}
    <!--
    <adapter_set_pool>
        <max_size>100</max_size>
        <max_free>10</max_free>
    </adapter_set_pool>
    -->
  {{- end }}

  {{- if .metadataProvider.inProcessMetadataAdapter }}

    <!-- Optional. If "Y", ensures that the call of the method 'init' of the
         Metadata Adapter ends before any 'init' of the Data Adapters is called.
         Otherwise the Metadata Adapter is initialised in parallel with all the
         other Data Adapters.

         If not defined, the default value is "Y" (i.e. Metadata Adapter
         initialised first). -->
  {{- else }}

    <!-- Optional. If "Y", ensures that the initialization of the Metadata
         Adapter ends before any initialization of the Data Adapters is performed.
         Otherwise the Metadata Adapter is initialised in parallel with all the
         other Data Adapters. In case of a Remote Adapter, the initialization
         consists of an invocation of the Metadata Init or Data Init method.
         Note that, if this flag is "Y" and there is any Remote Data Adapter
         in the Adapter Set, then, until the Metadata Adapter initialization
         is complete, the listening ports for these Remote Data Adapters will not
         be open and any connection attempt by the Remote Data Adapters will fail.

         If not defined, the default value is "Y" (i.e. Metadata Adapter
         initialised first). -->
  {{- end }}
  {{- if not (quote .enableMetadataInitializedFirst | empty) }}
    <metadata_adapter_initialised_first>{{ .enableMetadataInitializedFirst | ternary "Y" "N" }}</metadata_adapter_initialised_first>
  {{- else }}
    <!--
    <metadata_adapter_initialised_first>Y</metadata_adapter_initialised_first>
    -->  
  {{- end }}

  {{- with .metadataProvider }}
    {{- with .inProcessMetadataAdapter }}

    <!-- Mandatory. Define the Metadata Adapter. -->
    <metadata_provider>

        <!-- Optional. Specify a directory other than "."
             for this Adapter's own class and configuration files. -->
      {{- if not (quote .installDir | empty) }}
        <install_dir>{{ .installDir }}</install_dir>
      {{- else }}
        <!--
        <install_dir>my_metadata</install_dir>
        -->
      {{- end }}

        <!-- Mandatory. Java class name of the adapter.
             The Metadata Adapter class should implement either the
             com.lightstreamer.interfaces.metadata.MetadataProvider interface
             (for Adapters leveraging the old callback-based
             Java In-Process Adapter SDK)
             or the com.lightstreamer.adapter.metadata.MetadataAdapter
             interface (for Adapters leveraging the new object-based
             Java In-Process Adapter SDK v9+). -->
        <adapter_class>{{ .adapterClass }}</adapter_class>

        <!-- Optional. Determines the ClassLoader to be used to load the Adapter
             related classes. Possible values are:
             - "common": The common ClassLoader assigned to the whole Adapter Set
               is used; this ClassLoader already includes all the classes found
               in the common "lib" and "classes" folders; it also inherits from
               a global ClassLoader that includes all the classes found under the
               "shared/lib" and "shared/classes" folders. If a specific <install_dir>
               is assigned to the Adapter, classes found in its "lib" and "classes"
               subfolders are added to the Adapter Set ClassLoader.
             - "dedicated": A dedicated ClassLoader, which still inherits from the
               Adapter Set ClassLoader, is used. In this case, it is mandatory
               that a specific <install_dir> is assigned to the Adapter; hence,
               classes found in its "lib" and "classes" subfolders are added to
               the dedicated ClassLoader.
             - "log-enabled": A dedicated ClassLoader which also includes the
               slf4j library used by the Server is used; hence the Adapter shares
               the log configuration with the Server. However, in this case, the
               Adapter ClassLoader does not inherit from the Adapter Set
               ClassLoader, hence no sharing of classes with other Adapters is
               possible. If no specific <install_dir> is assigned to the Adapter,
               then the dedicated ClassLoader will be added all classes found in
               the common "lib" and "classes" folders.

             The determined ClassLoader is also set as the "context ClassLoader"
             in all Adapter method invocations.
             If not defined, the default value is "common" (i.e. the common
             Adapter Set ClassLoader is used). -->
      {{- if not (quote .classLoader | empty) }}
        <classloader>{{ .classLoader }}</classloader>
      {{- else }}
        <!--
        <classloader>dedicated</classloader>
        -->
      {{- end }}

        <!-- Optional. Enables backward compatibility of a new Adapter with old Clients.
             Only used if the Metadata Adapter leverages the new object-based
             Java In-Process Adapter SDK v9+.
             If set to Y, causes the Server to accept session creation requests
             expressed in TLCP 2.5.x or an earlier protocol and targeted to this
             Metadata Adapter.
             In fact, such requests are otherwise refused, because of the
             incompatibility between subscription specifications,
             which are based on "group ids" and "schema names" on the client side
             and on item and field lists on the Metadata Adapter side.
             With this flag set at Y, upon a subscription request, the received
             "group id" and "schema name" will be considered as space-separated lists
             of the actual item and field names.
             This assumption may or may not be correct. In case the requests of the
             old Client used to be handled by a LiteralBasedProvider or equivalent,
             this assumption is correct and the backward compatibility is ensured.
             Otherwise, it is up to the integrator to ensure that the subscriptions
             will be handled correctly.
             Note that the same holds for subscription requests from old clients
             targeted to a session that refers to this new Metadata Adapter.
             Default: N -->
        <support_LiteralBased_subscriptions>{{ not (eq .enableSupportForLiteralBasedSubscriptions false) | ternary "Y" "N" }}</support_LiteralBased_subscriptions>

        <!-- Optional. Enables backward compatibility of new Clients with an old Adapter.
             Only used if the Metadata Adapter leverages the old callback-based
             Java In-Process Adapter SDK.
             If set to Y, causes the Server to accept session creation requests
             expressed in TLCP 2.6.0 or later and targeted to this Metadata Adapter.
             In fact, such requests are otherwise refused, because of the
             incompatibility between subscription specifications,
             which are based on item and field lists on the client side
             and on "group ids" and "schema names" on the Metadata Adapter side.
             With this flag set at Y, upon a subscription request, the received
             lists of item and field names are converted in a "group id" and a
             "schema name" by joining the names in a space-separated fashion.
             Should an item or field name contain a space character, the whole
             subscription request would be refused.
             This assumption may or may not be correct. In case this Metadata Adapter
             is the LiteralBasedProvider or equivalent, this assumption is correct
             and the backward compatibility is ensured. Otherwise, it is up to the
             integrator to ensure that the subscriptions will be handled correctly.
             Note that the same holds for subscription requests from new clients
             targeted to a session that refers to this old Metadata Adapter.
             Default: N -->
        <support_TLCP26_subscriptions>{{ not (eq .enableSupportForTLCP26Subscription false) | ternary "Y" "N" }}</support_TLCP26_subscriptions>

      {{- include "lightstreamer.adapters.in-process.metadata-provider.authenticationPool" . | nindent 8 }}
      {{- include "lightstreamer.adapters.in-process.metadata-provider.messagesPool" . | nindent 8 }}
      {{- include "lightstreamer.adapters.in-process.metadata-provider.mpnPool" (list $adapterName .) | nindent 8 }}

        <!-- Optional. If "Y", ensures that all Table (i.e. Subscription) lifecycle
             notifications pertaining to the same session will be sequential,
             with no overlapping; if "N", then concurrent invocations will be
             possible.
             Note that these notifications are "notifyNewTables" and "notifyTablesClose"
             for Adapters leveraging the old callback-based Java In-Process Adapter SDK
             and "SubscriptionAdapter::onStart" and "SubscriptionAdapter::onClose"
             for Adapters leveraging the new object-based Java In-Process Adapter SDK v9+.
             Note that the final invocation to notify session termination is always
             guaranteed to occur after all the above notifications have terminated.

             If not defined, the default value is "N" (i.e. do not sequentialize). -->
      {{- if not (quote .enableTableNotificationsSequentialization | empty) }}
        <sequentialize_table_notifications>{{ .enableTableNotificationsSequentialization | ternary "Y" "N" }}</sequentialize_table_notifications>
      {{- else }}
        <!--
        <sequentialize_table_notifications>Y</sequentialize_table_notifications>
        -->
      {{- end }}

        <!-- Optional. Determines the effect of a "failure" invocation
             issued by the Adapter (according to the interface in use).
             - If "Y", it triggers the termination of the process, to prevent
               the Server from doing wrong authorizations, because of Adapter
               malfunctioning, without notice to the Clients.
             - Otherwise, the Adapter is shut down and the Adapter Set is made
               invisible from the clients. In this case, currently established Sessions
               are not closed and they can keep receiving data from the Data Adapters
               on currently established subscriptions, but further requests
               from them will be refused.
               For Adapters leveraging the old callback-based
               Java In-Process Adapter SDK, which doesn't provide a "shutdown"
               callback, the Adapter, after notifying the failure, is responsible
               for any needed cleanup.

             If not defined, the default value depends on the interface in use:
             it is "Y" for Adapters leveraging the old callback-based
             Java In-Process Adapter SDK and "N" for Adapters
             leveraging the new object-based Java In-Process Adapter SDK v9+. -->
      {{- if not (quote .exitOnFailure | empty) }}
        <exit_on_failure>{{ .exitOnFailure | ternary "Y" "N" }}</exit_on_failure>
      {{- else }}
        <!--
        <exit_on_failure>Y</exit_on_failure>
        -->
      {{- end }}

      {{- include "lightstreamer.adapters.in-process.metadata-provider.initParams" . | nindent 8 }}
    {{- else }}
    {{- with .proxyMetadataAdapter }}

    <!-- Mandatory. The Metadata Adapter is the Java Proxy Adapter. -->
    <metadata_provider>

        <!-- Optional. Specify a directory other than "."
             for this Adapter's configuration files (e.g. the keystore). -->
        <!--
        <install_dir>metadata</install_dir>
        -->
      {{- $isRobust := .enableRobustAdapter | default false }}
      {{- if $isRobust }}

        <!-- Mandatory. Java class name of the Robust Proxy Metadata Adapter.
             In this case, "ROBUST_PROXY_FOR_REMOTE_ADAPTER" is a special keyword that
             identifies the Robust Proxy Metadata Adapter, which is embedded
             in Lightstreamer Server and available out of the box.
             The Robust Proxy Metadata Adapter communicates with its remote counterpart
             through standard TCP sockets. It listens on a configurable port
             and waits for its counterpart to connect.
             Moreover, this Metadata Adapter manages the case in which the remote
             counterpart is missing, by just refusing all new requests from the
             clients and storing all state change notifications that have to be
             sent to the backend (namely, session closing and table closing
             notifications).
             Meanwhile, this Metadata Adapter keeps waiting for connection
             from a new Remote Server; upon connection, it will flush pending
             notify requests, then start working normally. However, if the remote
             counterpart has restarted from scratch, then retrieving and
             restoring the state of the previously connected instance will be
             its own burden; for how to identify the involved Server instance,
             see "remote_params_prefix" below.
             Note that the unavailability of the Metadata Adapter is a severe
             issue for Lightstreamer and all client requests performed in this
             condition will fail with an "unexpected error" cause;
             this can be avoided only for requests for new sessions (see
             "notify_user_disconnection_code" below). -->
      {{- else }}

        <!-- Mandatory. Java class name of the Proxy Metadata Adapter.
             In this case, "PROXY_FOR_REMOTE_ADAPTER" is a special keyword that
             identifies the Proxy Metadata Adapter, which is embedded
             in Lightstreamer Server and available out of the box.
             The Proxy Metadata Adapter communicates with its remote counterpart
             through standard TCP sockets. It listens on a configurable port
             and waits for its counterpart to connect. -->
      {{- end }}
        <adapter_class>{{ include "lightstreamer.adapters.proxy.common.class" . }}</adapter_class>

        <!-- Mandatory for Proxy Adapters. Determines the ClassLoader to be used
             to load the Adapter related classes (see the base template).
             In case a Proxy Adapter is configured, it is advisable to use the
             special "log-enabled" option, to let the Proxy Adapter share the
             logging support and configuration with the Server.
             If set to "dedicated", logging support must be explicitly provided,
             by adding the slf4j library, together with a suitable log
             implementation and configuration. If an "install_dir" element
             is defined, it will be used also to this purpose.
             With this special configuration, the "common" option is forbidden. -->
        <classloader>log-enabled</classloader>

        <!-- Optional. Enables backward compatibility of new Clients with this
             Proxy Adapter.
             If set to Y, causes the Server to accept session creation requests
             expressed in TLCP 2.6.0 or later and targeted to this Proxy Metadata Adapter
             (which leverages the old callback-based Java In-Process Adapter SDK).
             In fact, such requests are otherwise refused, because of the
             incompatibility between subscription specifications,
             which are based on item and field lists on the client side
             and on "group ids" and "schema names" on the Metadata Adapter side.
             With this flag set at Y, upon a subscription request, the received
             lists of item and field names are converted in a "group id" and a
             "schema name" by joining the names in a space-separated fashion.
             Should an item or field name contain a space character, the whole
             subscription request would be refused.
             This assumption may or may not be correct. In case the associated
             Remote Metadata Adapter is always a remote version of the LiteralBasedProvider
             or equivalent, this assumption is correct and the backward
             compatibility is ensured. Otherwise, it is up to the integrator
             to ensure that the subscriptions will be handled correctly.
             Note that the same holds for subscription requests from new clients
             targeted to a session that refers to this old Metadata Adapter.
             Default: N -->
        <support_TLCP26_subscriptions>{{ not (eq .enableSupportForTLCP26Subscription false) | ternary "Y" "N" }}</support_TLCP26_subscriptions>

      {{- include "lightstreamer.adapters.proxy.metadata-provider.authenticationPool" . | nindent 8 }}
      {{- include "lightstreamer.adapters.proxy.metadata-provider.messagesPool" . | nindent 8 }}
      {{- include "lightstreamer.adapters.proxy.metadata-provider.mpnPool" (list $adapterName .) | nindent 8 }}

        <!-- Optional. If "Y", ensures that all Table (i.e. Subscription) lifecycle
             notifications (that is, all the invocations to the Notify New Tables
             and Notify Tables Close methods) pertaining to the same session will
             be sequential, with no overlapping; if "N", then concurrent
             invocations will be possible.
             Note that the final invocation to Notify Session Close is always
             guaranteed to occur after all the above notifications have terminated.

             If not defined, the default value is "N" (i.e. do not sequentialize). -->
      {{- if not (quote .enableTableNotificationsSequentialization | empty) }}
        <sequentialize_table_notifications>{{ .enableTableNotificationsSequentialization | ternary "Y" "N" }}</sequentialize_table_notifications>
      {{- else }}
        <!--
        <sequentialize_table_notifications>Y</sequentialize_table_notifications>
        -->
      {{- end }}

      {{- if $isRobust }}

        <!-- Optional. Determines the effect of a "failure" invocation
             issued by the Remote Adapter (according to the interface in use).
             The flag is not exploited by a Robust Proxy Adapters, which,
             upon a "failure" invocation, always
             detaches the Remote Adapter and handles the case consequently. -->
      {{- else }}

        <!-- Optional. Determines the effect of a "failure" invocation
             issued by the Remote Adapter (according to the interface in use).
             The flag is ignored for Proxy Adapters. A "failure" invocation
             always triggers the termination of the process, to prevent
             the Server from doing wrong authorizations, because of Adapter
             malfunctioning, without notice to the Clients. -->
      {{- end }}
        <!--
        <exit_on_failure>Y</exit_on_failure>
        -->

        <!-- List of initialization parameters specific to the{{ if $isRobust }} Robust{{ else }}{{ end }} Proxy Metadata Adapter. -->
      {{- $commentSuffix := $isRobust | ternary " for all Proxy Metadata Adapters" "" }}
      {{- include "lightstreamer.adapters.proxy.common" (list $adapterName false .) | nindent 8 }}
      {{- include "lightstreamer.adapters.proxy.common.sslConfig" (list $adapterName $.Values.keystores false .) | nindent 8 }}
      {{- include "lightstreamer.adapters.proxy.common.authentication" (list $adapterName false .) | nindent 8 }}
      {{- include "lightstreamer.adapters.proxy.common.connection" (list false .) | nindent 8 }}
      {{- if $isRobust }}
      {{- include "lightstreamer.adapters.proxy.metadata-provider.notification" (list $adapterName .) | nindent 8 }}
      {{- end }}

       <!-- Optional{{ $commentSuffix }}.
            Name of the Proxy Metadata Adapter, to better identify its connections
            and threads when assessing problems.
            If not specified, the Adapter Set id,
            as configured in this file, will be used. -->
        <!--
        <param name="name">MyFeedMetadata</param>
        -->
      {{- include "lightstreamer.adapters.proxy.common.remoteParams" (list $adapterName false .) | nindent 8 }}

        <!-- Optional{{ $commentSuffix }}.
             If set to false, suppresses clearing of the cached profile data
             for a user when no sessions for the user are active. This is only for
             troubleshooting purpose, as profile data are always refreshed upon
             Notify User requests.
             Default: true. -->
      {{- if not (quote .enableClearingOnSessionClose | empty) }}
        <param name="clear_on_session_close">{{ .enableClearingOnSessionClose | ternary "true" "false" }}</param>
      {{- else }}
        <!--
        <param name="clear_on_session_close">true</param>
        -->
      {{- end }}

        <!-- Optional{{ $commentSuffix }}.
             Sets the minimum time (in milliseconds) cached profile data are kept;
             these cached data are needed in order to manage request processing before a session
             is fully started. Ignored if clear_on_session_close is false.
             Default: 10000 ms (10 seconds). -->
      {{- if not (quote .userDataTimeoutMillis | empty)}}
        <param name="user_data_timeout">{{ int .userDataTimeoutMillis }}</param>
      {{- else }}
        <!--
        <param name="user_data_timeout">1000</param>
        -->
      {{- end }}

      {{- if $isRobust }}

        <!-- Optional.
             If set to true, enforces the clearing of all internal caches when a new
             Remote Metadata Adapter instance is connected after the disconnection
             of the previous instance.
             In fact, some requests to the Remote Adapter involve aggregate data and
             are meant to be used to fulfill multiple subsequent requests from the Server,
             hence their responses are cached for a few seconds. However, for requests
             whose responses are not supposed to change with time, the cached responses
             are kept longer, so as to be used to fulfill further identical requests
             from the Server and save the submission of the related aggregate requests
             to the Remote counterpart.
             By setting true, responses obtained from a previous Remote Metadata Adapter
             instance will never be used to fulfill requests from the Server targeted
             to the new instance.
             Default: false. -->
        {{- if not (quote .enableClearingOnNewRemote | empty)}}
        <param name="clear_on_new_remote">{{ .enableClearingOnNewRemote | ternary "true" "false" }}</param>
        {{- else }}
        <!--
        <param name="clear_on_new_remote">true</param>
        -->
        {{- end }}
      {{- end }}

      {{- include "lightstreamer.adapters.proxy.common.closing" (list $adapterName false .) | nindent 8 }}
    {{- end }} {{/* of .metadataAdapter or .proxyMetadataAdapter */}}
    {{- end }}
  {{- end }} {{/* of .metadataProvider */}}

    </metadata_provider>
  {{ range $dataProviderName, $dataProvider := .dataProviders }}
    {{- if $dataProvider.enabled }}
      {{- $dataProviderName := default "DEFAULT" $dataProvider.name }}
      {{- with $dataProvider.inProcessDataAdapter }}

    <!-- Mandatory and cumulative. Define a Data Adapter.
         The "name" attribute is optional and the default name is "DEFAULT";
         if multiple Data Adapters are defined in the same Adapter Set,
         then using the "name" attribute is needed to distinguish them. -->
    <data_provider name="{{ $dataProviderName }}">

        <!-- Optional. Specify a directory other than "."
             for this Adapter's own class and configuration files. -->
        {{- if not (quote .installDir | empty) }}
        <install_dir>{{ .installDir }}</install_dir>
        {{- else }}
        <!--
        <install_dir>data</install_dir>
        -->
        {{- end }}

        <!-- Mandatory. Java class name of the adapter.
             The Data Adapter class should implement either the
             com.lightstreamer.interfaces.data.DataProvider interface,
             thus including com.lightstreamer.interfaces.data.SmartDataProvider
             which extends it
             (for Adapters leveraging the old callback-based
             Java In-Process Adapter SDK)
             or the com.lightstreamer.adapter.data.DataAdapter
             (for Adapters leveraging the new object-based
             Java In-Process Adapter SDK v9+). -->
        <adapter_class>{{ .adapterClass }}</adapter_class>

        <!-- Optional. The same as for the Metadata Adapter; see above. -->
        {{- if not (quote .classLoader | empty )}}
        <classloader>{{ .classLoader }}</classloader>
        {{- else }}
        <!--
        <classloader>dedicated</classloader>
        -->
        {{- end }}

        {{- include "lightstreamer.adapters.in-process.data-provider.dataAdapterPool" (list $adapterName $dataProviderName .) | nindent 8 }}

        <!-- Optional. Determines the effect of a "failure" invocation
             or "FailureException" throw issued by the Adapter
             (according to the interface in use).
             - If "Y", it triggers the termination of the process, to prevent
               the Server from sending wrong data, because of Adapter malfunctioning,
               without notice to the Clients.
             - Otherwise, the Adapter is shut down and made invisible from the clients.
               In this case, currently established Subscriptions are not closed,
               but they will receive no more data and further subscription requests
               will be refused.
               For Adapters leveraging the old callback-based
               Java In-Process Adapter SDK, which doesn't provide a "shutdown"
               callback, the Adapter, after notifying the failure, is responsible
               for any needed cleanup.

             If not defined, the default value depends on the interface in use:
             it is "Y" for Adapters leveraging the old callback-based
             Java In-Process Adapter SDK and "N" for Adapters
             leveraging the new object-based Java In-Process Adapter SDK v9+. -->
        {{- if not (quote .exitOnFailure | empty) }}
        <exit_on_failure>{{ .exitOnFailure | ternary "Y" "N" }}</exit_on_failure>
        {{- else }}
        <!--
        <exit_on_failure>Y</exit_on_failure>
        -->
        {{- end }}
        {{- include "lightstreamer.adapters.in-process.data-provider.initParams" . | nindent 8 }}
      {{- else }}
      {{- with $dataProvider.proxyDataAdapter }}

    <!-- Mandatory and cumulative. The Data Adapter is the Java Proxy Adapter.
         The "name" attribute is optional and the default name is "DEFAULT";
         if multiple Data Adapters are defined in the same Adapter Set,
         then using the "name" attribute is needed to distinguish them. -->
    <data_provider name="{{ $dataProviderName }}">

        <!-- Optional. Specify a directory other than "."
             for this Adapter's configuration files (e.g. the keystore). -->
        <!--
        <install_dir>data</install_dir>
        -->

        {{- $isRobust := .enableRobustAdapter | default false }}
        {{- $commentSuffix := $isRobust | ternary " for all Proxy Data Adapters" "" }}
        {{- if $isRobust }}

        <!-- Mandatory. Java class name of the Robust Proxy Data Adapter.
             In this case, "ROBUST_PROXY_FOR_REMOTE_ADAPTER" is a special keyword that
             identifies the Robust Proxy Data Adapter, which is embedded
             in Lightstreamer Server and available out of the box.
             The Robust Proxy Data Adapter communicates with its remote counterpart
             through standard TCP sockets. It listens on a configurable port
             (or, optionally, two ports) and waits for its counterpart to connect.
             Moreover, this Data Adapter manages the case in which the remote
             counterpart is missing, by accepting subscriptions and sending empty
             snapshots to the clients, when requested (note that the clients
             should be able to manage null field values for items subscribed to
             in MERGE mode).
             This Data Adapter also manages failures of the remote counterpart,
             by waiting for connection from a new Remote Server, then trying
             to recover the data flow by resubmitting all the pending subscription
             requests. However, if the remote counterpart needs to retrieve and
             restore the state of the previously connected instance, this will be
             its own burden; for how to identify the involved Server instance,
             see "remote_params_prefix" below. -->
        {{- else}}

        <!-- Mandatory. Java class name of the Proxy Data Adapter.
             In this case, "PROXY_FOR_REMOTE_ADAPTER" is a special keyword that
             identifies the Proxy Data Adapter, which is embedded
             in Lightstreamer Server and available out of the box.
             The Proxy Data Adapter communicates with its remote counterpart
             through standard TCP sockets. It listens on a configurable port
             (or, optionally, two ports) and waits for its counterpart to connect. -->
        {{- end }}
        <adapter_class>{{ include "lightstreamer.adapters.proxy.common.class" . }}</adapter_class>

        <!-- Mandatory for Proxy Adapters. Determines the ClassLoader to be used
             to load the Adapter related classes (see the base template).
             In case a Proxy Adapter is configured, it is advisable to use the
             special "log-enabled" option, to let the Proxy Adapter share the
             logging support and configuration with the Server.
             If set to "dedicated", logging support must be explicitly provided,
             by adding the slf4j library, together with a suitable log
             implementation and configuration. If an "install_dir" element
             is defined, it will be used also to this purpose.
             With this special configuration, the "common" option is forbidden. -->
        <classloader>log-enabled</classloader>

        {{- include "lightstreamer.adapters.proxy.data-provider.dataAdapterPool" (list $adapterName $dataProviderName .) | nindent 8 }}

        {{- if $isRobust }}

        <!-- Optional. Determines the effect of a "failure" invocation
             or "FailureException" throw issued by the Remote Adapter
             (according to the interface in use).
             The flag is not exploited by a Robust Proxy Adapters, which,
             upon a "failure" invocation or "FailureException" throw, always
             detaches the Remote Adapter and handles the case consequently. -->             
        {{- else }}

        <!-- Optional. Determines the effect of a "failure" invocation
             or "FailureException" throw issued by the Remote Adapter
             (according to the interface in use).
             The flag is ignored for Proxy Adapters.
             A "failure" invocation or "FailureException" throw
             always triggers the termination of the process, to prevent
             the Server from sending wrong data, because of Adapter
             malfunctioning, without notice to the Clients. -->
        {{- end }}
        <!--
        <exit_on_failure>Y</exit_on_failure>
        -->

        <!-- List of initialization parameters specific to the{{ if $isRobust }} Robust{{ else }}{{ end }} Proxy Data Adapter. -->
        {{- include "lightstreamer.adapters.proxy.common" (list $adapterName true .) | nindent 8 }}
        {{- include "lightstreamer.adapters.proxy.common.sslConfig" (list $adapterName $.Values.keystores true .) | nindent 8 }}
        {{- include "lightstreamer.adapters.proxy.common.authentication" (list $adapterName true .) | nindent 8 }}
        {{- include "lightstreamer.adapters.proxy.common.connection" (list true .) | nindent 8 }}
        {{- include "lightstreamer.adapters.proxy.data-provider.events-recovery" (list $adapterName $dataProviderName .) | indent 8 }}

        <!-- Optional{{ $commentSuffix }}.
             Name of the Proxy Data Adapter, to better identify its connections
             and threads when assessing problems.
             If not specified, the Adapter Set id and the Data Adapter name,
             as configured in this file, will be used. -->
         <!--
         <param name="name">MyFeedData</param>
         -->

        {{- include "lightstreamer.adapters.proxy.common.remoteParams" (list $adapterName true .) | nindent 8 }}
        {{- include "lightstreamer.adapters.proxy.common.closing" (list $adapterName true .) | nindent 8 }}
      {{- end }} {{/* of with sections */}}
      {{- end }}

    </data_provider>
    {{- end }} {{/* of if .enabled */}}
  {{- end }} {{/* of .dataProviders */}}

</adapters_conf>
{{- end }}  {{/* of .adapters_conf */}}
{{- end }}
