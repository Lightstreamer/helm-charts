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
Render the Lightstreamer configuration file.
*/}}
{{- define "lightstreamer.configuration" -}}
<?xml version="1.0" encoding="UTF-8"?>
<!-- Do not remove this line. File tag: server_conf-APV-7.4.0. -->

<lightstreamer_conf>

<!--
    The following elements, subelements and attributes are consulted
    by Lightstreamer Server to setup its own configuration. Elements with
    an empty or blank value are ignored and considered as not defined at all.
    Elements described as "cumulative" can be inserted multiple times in the
    same place. Note that element and attribute names are handled in a case
    insensitive way.

    A very simple variable-expansion feature is available. Element or attribute
    values of the form $propname are expanded by looking for a corresponding
    JVM property (which, for instance, can be defined by adding
    -Dpropname=propvalue to the Server command line arguments in the launch
    script). If the property is not defined, then the element or attribute
    is considered as not defined at all. Optionally, system environment
    variables can also be referred (see <env_prefix> below).
    Note that the variable-expansion feature is not available for setting
    the value of non-leaf elements.
    If needed, the variable-expansion feature can be disabled for an element
    or for an element's attribute (let's say: attr) by adding prop_prefix=""
    or, respectively, attr_prop_prefix="" to the element (note that these
    "prop_prefix" attributes are handled in a special way). This also allows
    for setting a prefix other than "$".

    All the element or attribute values described as directory or file paths
    can be expressed as absolute or relative pathnames; when relative,
    they are considered as relative to the directory that contains this
    configuration file.
    Note that, on Windows, if a drive name is not specified, a double initial
    slash or backslash is needed to make a path absolute.
-->

<!--
  =====================
  LICENSE CONFIGURATION
  =====================
-->

    <!-- Mandatory. Path of the configuration file for all licensing and version
         configuration stuff. The file path is relative to the conf directory. -->
    <edition_conf>./lightstreamer_edition_conf.xml</edition_conf>

<!--
  ===============================
  HTTP/HTTPS SERVER CONFIGURATION
  ===============================
-->

{{- include "lightstreamer.configuration.servers.validateAllServers" . -}}
{{- range $serverKey, $server :=.Values.servers }}
  {{- if $server.enabled }}
    <!-- Optional and cumulative (but at least one from <http_server> and
         <https_server> should be defined). HTTP server socket configuration.
         Multiple listening sockets can be defined, by specifying multiple
         <http_server> elements. This allows, for instance, the coexistence
         of private and public ports.
         The "name" attribute is mandatory. Note that it is notified to the
         client upon connection and it is made available to application code
         by the Unified Client SDKs through the serverSocketName property
         in the ConnectionDetails class. It must be an ASCII string with no
         control characters and it must be unique among all <http_server>
         and <https_server> blocks. -->
  {{- $enableHttps := .enableHttps | default false }}
  {{- $elementType := $enableHttps | ternary "https" "http" }}
    <{{ $elementType }}_server name={{ .name | quote }}>

        <!-- Mandatory for this block. Listening TCP port. -->
        <port>{{ int .port }}</port>

        <!-- Optional. Size of the system buffer for incoming TCP connections
             (backlog). Overrides the default system setting. -->
  {{- if not (quote .backlog | empty) }}
        <backlog>{{ int .backlog }}</backlog>
  {{- else }}
        <!--
        <backlog>50</backlog>
        -->
  {{- end }}

        <!-- Optional. Provides meta-information on how this listening socket
             will be used, according with the deployment configuration.
             This can inform the Server of a restricted set of requests expected
             on the port, which may improve the internal backpressure mechanisms.
             It can be one of the following:
             - CREATE_ONLY
               Declares that the port is only devoted to "S" connections,
               according with the provided Clustering.pdf document.
             - CONTROL_ONLY
               Declares that the port is only devoted to "CR" connections,
               according with the provided Clustering.pdf document.
               The Server will enforce the restriction.
             - PRIORITY
               If set, requests issued to this port will follow a fast track.
               In particular, they will be never enqueued to the SERVER thread
               pool, but only the ACCEPT pool; and they will not be subject to any
               backpressure-related limitation (like <accept_pool_max_queue>).
               This should ensure that the requests will be fulfilled as soon as
               possible, even when the Server is overloaded.
               Such priority port is, therefore, ideal for opening the Monitoring
               Dashboard to inspect overload issues in place. It can also be used
               to open sessions on a custom Adapter Set, but, in that case, any
               thread pool specifically defined for the Adapters will be entered,
               with possible enqueueing.
               Anyway, such port is only meant for internal use and it is
               recommended not to leave it publicly accessible.
             - GENERAL_PURPOSE
               To be set when the port can be used for any kind of request.
               It can always be set in case of doubts.
             Note that ports can be CREATE_ONLY or CONTROL_ONLY only depending
             on client behavior. For clients based on LS SDK libraries, this is
             related to the use of the <control_link_address> setting. Usage
             examples are provided in the Clustering.pdf document.
             Default: GENERAL_PURPOSE. -->
  {{- if .portType }}
    {{- if not (mustHas .portType (list "CREATE_ONLY" "CONTROL_ONLY" "PRIORITY" "GENERAL_PURPOSE")) }}
      {{- fail "portType must be set with a valid value" }}
    {{- end }}
        <port_type>{{ .portType }}</port_type>
  {{- else }}
        <!--
        <port_type>PRIORITY</port_type>
        -->
  {{- end }}

        <!-- Optional. Settings that allow some control over the HTTP headers
             of the provided responses. Header lines can only be added to those
             used by the Server, either by specifying their value or by copying
             them from the request.
             Multiple rules can be defined; their order is ignored.
             In any case of replicated header fields, multiple lines will be
             inserted; it is assumed that multiple occurrences are allowed for
             those fields.
             No syntax and consistency checks are performed on the resulting
             HTTP headers; only custom or non-critical fields should be used.
             The header names involved are always converted to lower case. -->
        <response_http_headers>
  {{- with .responseHttpHeaders}}

            <!-- Optional and cumulative. Requests to look for any header
                 lines for the specified field name on the HTTP request header
                 and to copy them to the HTTP response header.
                 The "name" attribute is mandatory; a final ":" is optional.
                 The value should be left empty. -->
    {{- range .echo }}
            <echo name={{ . | quote }} />
    {{- else }}
            <!--
            <echo name="cookie" />
            -->
    {{- end }}

            <!-- Optional and cumulative. Requests to add to the HTTP response
                 header a line with the specified field name and value.
                 The "name" attribute is mandatory; a final ":" is optional.
                 The suggested setting for "X-Accel-Buffering" may help to enable
                 streaming support when proxies of several types are involved. -->
    {{- range .add }}
            <add name={{ required "responseHttpHeaders.add[].name must be set" .name | quote }}>{{ .value }}</add>
    {{- else }}
            <!--
            <add name="my-header">MyValue</add>
            -->
    {{- end }}
  {{ end }}
        </response_http_headers>

        <!-- Optional. Can be used on a multihomed host to specify the IP address
             to bind the server socket to.
             The default is to accept connections on any/all local addresses. -->
  {{- if .listeningInterface }}
        <listening_interface>{{ .listeningInterface }}</listening_interface>
  {{- else }}
        <!--
        <listening_interface>200.0.0.1</listening_interface>
        -->
  {{- end }}

        <!-- Optional. Settings that allow for better recognition of the remote
             address of the connected clients. This can be done in two ways:
             - by taking advantage of the X-Forwarded-For HTTP header, that
               intermediate HTTP proxies and level-7 Load Balancers usually set
               to supply connection routing information in an incremental way
               (this is done through the "skip_local_forwards" subelement);
             - by receiving the routed address directly from a TCP reverse proxy
               or level-4 Load Balancer through the Proxy Protocol, when the
               proxy is configured to do so (this is done through the
               "proxy_protocol_enabled" subelement).
             The two techniques can also coexist, but, in that case, the address
             received through the proxy protocol would always be considered as
             the real client address and all addresses in the chain specified
             in X-Forwarded-For would be considered as written by client-side
             proxies.
             The address determined in this way will be used in all cases
             in which the client address is reported or checked. For logging
             purposes, the connection endpoint will still be written, but the
             real remote address, if available and different, will be added.
             The determined address may also be sent to the clients, depending
             on the Client SDK in use.
             The optional "private" attribute (whose default is "N"), if set to
             "Y", prevents the determined address from being sent to the clients.
             In fact, the address is notified to the client upon connection and
             it is made available to application code by the most recent
             Unified Client SDKs through the clientIp property in the
             ConnectionDetails class.
             For instance, the attribute can and should be set to "Y" in case
             the identification of the remote address is not properly tuned
             and the determined address may be a local one.
             If the whole block is omitted, this just means that all settings
             are at their defaults. -->
  
  {{- $enablePrivate := (not (eq (.clientIdentification).enablePrivate false)) }}
  {{- $enableProxyProtocol := (.clientIdentification).enableProxyProtocol | default false }}
  {{- $proxyProtocolTimeoutMillis := int (not (quote (.clientIdentification).proxyProtocolTimeoutMillis | empty) | ternary (.clientIdentification).proxyProtocolTimeoutMillis 1000) }}
  {{- $enableForwardsLogging := (.clientIdentification).enableForwardsLogging | default false }}
  {{- $skipLocalForwards := int (.clientIdentification).skipLocalForwards }}
        <client_identification private={{ $enablePrivate | ternary "Y" "N" | quote }}>

            <!-- Optional. If Y, instructs the Server that the connection endpoint
                 is a reverse proxy or load balancer that sends client address
                 information through the Proxy Protocol. The received address and
                 port will be used as the real client address and port.
                 In particular, they will appear in all log lines for this client
                 (but for the "LightstreamerLogger.connections" logger).
                 On the other hand, the reported protocol will always refer to
                 the actual connection.
                 There is no dynamic detection of the proxy protocol; hence, if Y
                 is set, all connections to this port must speak the proxy protocol
                 (for instance, any healthcheck requests should be configured
                 properly on the proxy) and, if N is set, no connection can speak
                 the proxy protocol, otherwise the outcome would be unspecified.
                 On the other hand, if Y, both proxy protocol version 1 and 2 are
                 handled; only information for normal TCP connections is considered.
                 Default: N. -->
            <proxy_protocol_enabled>{{ $enableProxyProtocol | ternary "Y" "N" }}</proxy_protocol_enabled>

            <!-- Optional. Timeout applied while reading for information through
                 the proxy protocol, when enabled. Note that a reverse proxy or
                 load balancer speaking the proxy protocol is bound to send
                 information immediately after connection start; so the timeout
                 can only apply to cases of wrong configuration, local network
                 issues or illegal access to this port.
                 For this reason, the read is performed directly in the ACCEPT
                 thread pool and this setting protects that pool against such
                 unlikely events.
                 Default: 1000. -->
            <proxy_protocol_timeout_millis>{{ $proxyProtocolTimeoutMillis }}</proxy_protocol_timeout_millis>

            <!-- Optional, but nonzero values forbidden if "proxy_protocol_enabled"
                 is Y. Number of entries in the X-Forwarded-For header that are
                 expected to be supplied on each HTTP request (including Websocket
                 handshake) by the intermediate nodes (e.g. reverse proxies, load
                 balancers) that stand in the local environment.
                 If N entries are expected from local nodes, this means that the
                 Nth-nearest entry corresponds to the node connected to the farthest
                 local intermediate node, hence to the client. So, that entry will
                 be used as the real client address. In particular, it will appear
                 in all log lines that refer to the involved HTTP request or
                 Websocket.
                 If set to 0 or left at the default, all entries in X-Forwarded-For
                 will be considered as written by client-side proxies, hence the
                 connection endpoint address will be used (unless, of course,
                 "proxy_protocol_enabled" is set to Y, which overrides the behavior).
                 Note that a similar correction for port and protocol is not applied;
                 hence, when an address corrected through a nonzero setting is
                 reported, any port and protocol associated will still refer to the
                 actual connection.
                 Default: 0. -->
            <skip_local_forwards>{{ $skipLocalForwards }}</skip_local_forwards>

            <!-- Optional. If Y, causes the list of entries of the X-Forwarded-For
                 header, when available, to be added to log lines related to the
                 involved HTTP request or Websocket.
                 If "skip_local_forwards" is nonzero, only the entries farther
                 than the determined "real" remote address are included.
                 These entries are expected to be written by client-side proxies.
                 Default: N. -->
            <log_forwards>{{ $enableForwardsLogging | ternary "Y" "N" }}</log_forwards>
        </client_identification>

  {{- if $enableHttps }}
    {{ if .sslConfig | empty }} 
      {{ printf "servers.%s.sslConfig must be set" $serverKey | fail }}
    {{ end }}
    {{- with .sslConfig }}
        <!-- Optional. If defined, overrides the default JVM's Security Provider
             configured in the java.security file of the JDK installation. This allows
             the use of different Security Providers dedicated to single listening ports.
             When configuring a Security Provider, the related libraries should be added
             to the Server classpath. This is not needed for the Conscrypt provider,
             which is already available in the Server distribution (but note that the
             library includes native code that only targets the main platforms). -->
      {{- if .tlsProvider }}
        <TLS_provider>{{ .tlsProvider }}</TLS_provider>
      {{- else }}
        <!--
        <TLS_provider>Conscrypt</TLS_provider>
        -->
      {{- end }}

        <!-- Mandatory for this block. Reference to the keystore used by the HTTPS
             service. The keystore type should be specified in the optional "type"
             attribute; the currently supported types are:
             - JKS, which is the Sun/Oracle's custom keystore type, whose
               support is made available by every Java installation;
             - PKCS12, which is supported by all recent Java installations;
             - PKCS11, which as a bridge to an external PKCS11 implementation;
               this is an experimental extension; contact Lightstreamer
               Support for details.
             The default value is JKS.
             With a JKS or PKCS12 keystore, the <keystore_file> and <keystore_password>
             subelements are mandatory. The access to the included certificates
             is subject to the following constraints:
             - only the first certificate found in the keystore can be sent
               to the Client;
             - the password of the keystore and the password of the included
               certificate should be the same (hence, the <keystore_password>
               subelement refers to both);
             - the support of keystore contents may depend on the Security Provider
               in use; for instance, keystores with dual RSA/ECC certificates
               are not fully supported by the Conscrypt provider.
             Instructions on how to setup a JKS keystore are provided in the
             TLS/SSL Certificates document. -->
      {{- with required (printf "servers.%s.sslConfig.keystoreRef must be set" $serverKey) .keystoreRef }}
        {{- include "lightstreamer.configuration.keystore" (list $.Values.keystores .)  | nindent 8 }}
      {{- end }}

      {{- if and .allowCipherSuites .removeCipherSuites }}
        {{ printf "servers.%s.sslConfig.allowCipherSuites and servers.%s.sslConfig.removeCipherSuites cannot be used together" $serverKey $serverKey | fail }}
      {{- end }}

        <!-- Optional and cumulative, but forbidden if <remove_cipher_suites> is used.
             Specifies all the cipher suites allowed for the TLS/SSL interaction,
             provided that they are included, with the specified name, in the set
             of "supported" cipher suites of the underlying Security Provider.
             The default set of the "supported" cipher suites is logged at startup
             by the LightstreamerLogger.io.ssl logger at DEBUG level.
             If not used, the <remove_cipher_suites> element is considered; hence, if
             <remove_cipher_suites> is also not used, all cipher suites enabled by
             the Security Provider will be available.
             The order in which the cipher suites are specified can be enforced as the
             server-side preference order (see <enforce_server_cipher_suite_preference>). -->
      {{- range $index, $cipherSuite := .allowCipherSuites }}
        <allow_cipher_suite>{{ required (printf "servers.%s.sslConfig.allowCipherSuites[%d] must be set" $serverKey (int $index)) $cipherSuite }}</allow_cipher_suite>
      {{- else }}
        <!--
        <allow_cipher_suite>TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384</allow_cipher_suite>
        -->
        <!--
        <allow_cipher_suite>........</allow_cipher_suite>
        -->
        <!--
        <allow_cipher_suite>........</allow_cipher_suite>
        -->
      {{- end }}

        <!-- Optional and cumulative, but forbidden if <allow_cipher_suite> is used.
             Pattern to be matched against the names of the enabled cipher suites
             in order to remove the matching ones from the enabled cipher suites set.
             Any pattern in java.util.regex.Pattern format can be specified.
             This allows for customization of the choice of the cipher suites
             to be used for incoming https connections (note that reducing
             the set of available cipher suites may cause some client requests
             to be refused).
             When this setting is used, the server-side preference order of the
             cipher suites is determined by the underlying Security Provider.
             Note that the selection is operated on the default set of the cipher
             suites "enabled" by the Security Provider, not on the wider set of
             the "supported" cipher suites. The default set of the "enabled" cipher
             suites is logged at startup by the LightstreamerLogger.io.ssl
             logger at DEBUG level. -->
      {{- range $index, $cipherSuite := .removeCipherSuites }}
        <allow_cipher_suite>{{ required (printf "servers.%s.sslConfig.removeCipherSuites[%d] must be set" $serverKey (int $index)) $cipherSuite }}</allow_cipher_suite>
      {{- else }}             
        <!--
        <remove_cipher_suites>TLS_RSA_</remove_cipher_suites>
        -->
      {{- end }}

        <!-- Optional. Determines which side should express the preference when
             multiple cipher suites are in common between server and client.
             Can be one of the following:
             - Y: The Server will choose the cipher suite based on its own preference
                  order. This is determined by the optional "order" attribute:
                  - if "JVM" (which is the default), the ordering is demanded
                    to the underlying Security Provider, which, usually,
                    privileges the strongest suites;
                  - if "config" (which is allowed only if <allow_cipher_suite>
                    is used), the order in which the <allow_cipher_suite>
                    elements are specified determines the preference order.
             - N: The Server will get a cipher suite based on the preference order
                  specified by the client. For instance, the client might privilege
                  faster, but weaker, suites.
             Note, however, that the underlying Security Provider may ignore
             this setting. This is the case, for instance, of the Conscrypt provider.
             Default: N. -->
      {{- $order := (.enforceServerCipherSuitePreference).order | default "JVM" }}
      {{- $enabled := not (eq (.enforceServerCipherSuitePreference).enabled false) }}
      {{- if not (mustHas $order (list "JVM" "config")) }}
        {{- fail printf ("server.%s.sslConfig.enforceServerCipherSuitePreference must be one of: \"JVM\", \"config\"" $serverKey) }}
      {{- end }}
        <enforce_server_cipher_suite_preference order={{ $order | quote }}>{{ $enabled | ternary "Y" "N" }}</enforce_server_cipher_suite_preference>

        <!-- Optional. If Y, causes any client-initiated TLS renegotiation request
             to be refused by closing the connection. This policy may be evaluated
             in a trade-off between encryption strength and performance risks.
             Note that, with the default SunJSSE Security Provider, a better way
             to achieve the same at a global JVM level is by setting the dedicated
             "jdk.tls.rejectClientInitiatedRenegotiation" JVM property to true.
             Default: N. -->
      {{- if not (quote .enableTlsRenegotiation | empty) }}
        <disable_TLS_renegotiation>{{ .enableTlsRenegotiation | ternary "N" "Y" }}</disable_TLS_renegotiation>
      {{- else }}
        <!--
        <disable_TLS_renegotiation>Y</disable_TLS_renegotiation>
        -->
      {{- end }}

        <!-- Optional and cumulative, but forbidden if <remove_protocols> is used.
             Specifies one or more protocols allowed for the TLS/SSL interaction,
             among the ones supported by the underlying Security Provider.
             For Oracle JVMs, the available names are the "SSLContext Algorithms"
             listed here:
             https://docs.oracle.com/en/java/javase/17/docs/specs/security/standard-names.html#sslcontext-algorithms
             If not used, the <remove_protocols> element is considered; hence, if
             <remove_protocols> is also not used, all protocols enabled by the
             Security Provider will be available. -->
      {{- range .allowProtocols }}
        <allow_protocol>{{ required "sslConfig.allowProtocols[] must be set" . }}</allow_protocol>
      {{- else }}
        <!--
        <allow_protocol>TLSv1.2</allow_protocol>
        -->
        <!--
        <allow_protocol>TLSv1.3</allow_protocol>
        -->
      {{- end }}

        <!-- Optional and cumulative, but forbidden if <allow_protocol> is used.
             Pattern to be matched against the names of the enabled TLS/SSL protocols
             in order to remove the matching ones from the enabled protocols set.
             Any pattern in java.util.regex.Pattern format can be specified.
             This allows for customization of the choice of the TLS/SSL protocols
             to be used for an incoming https connection (note that reducing
             the set of available protocols may cause some client requests
             to be refused).
             Note that the selection is operated on the default set of the
             protocols "enabled" by the Security Provider, not on the wider set of
             the "supported" protocols. The default set of the "enabled" protocols
             is logged at startup by the LightstreamerLogger.io.ssl
             logger at DEBUG level. -->
      {{- range .removeProtocols }}
        <remove_protocols>{{ required "sslConfig.removeProtocols[] must be set" . }}</remove_protocols>
      {{- else }}
        <!--
        <remove_protocols>SSL</remove_protocols>
        -->
      {{- end }}

        <!-- Optional. Instructs the underlying Security Provider on whether to use
             stateless (when Y) or stateful (when N) session resumption on this port,
             if supported (possibly depending on the protocol version in use).
             Note that stateful resumption implies the management of a TLS session
             cache, whereas stateless resumption is slightly more demanding in
             terms of CPU and bandwidth.
             Note, however, that this setting is currently supported only if the
             Conscrypt Security Provider is used. For instance, with the default
             SunJSSE Security Provider, the use of stateful or stateless resumption
             can only be configured at global JVM level, through the
             "jdk.tls.server.enableSessionTicketExtension" JVM property.
             Default: If left empty or not defined, the type of resumption will be
             decided by the underlying Security Provider, based on its own
             configuration. -->
      {{- if not (quote .enableStatelessTlsSessionResumption | empty) }}
        <enable_stateless_TLS_session_resumption>{{ .enableStatelessTlsSessionResumption | ternary "Y" "N" }}</enable_stateless_TLS_session_resumption>
      {{- else }}
        <!--
        <enable_stateless_TLS_session_resumption>Y</enable_stateless_TLS_session_resumption>
        -->
      {{- end }}

        <!-- Optional. Size of the cache used by the TLS implementation to handle
             TLS session resumptions when stateful resumption is configured
             (see <enable_stateless_TLS_session_resumption>).
             A value of 0 poses no size limit.
             Note, however, that the underlying Security Provider may ignore
             this setting (possibly depending on the protocol version in use).
             Default: If left empty or not defined, the cache size is decided by the
             underlying Security Provider. For the default SunJSSE, it is 20480
             TLS sessions, unless configured through the
             "javax.net.ssl.sessionCacheSize" JVM property. -->
      {{- if not (quote .tlsSessionCacheSize | empty) }}
        <TLS_session_cache_size>{{ int .tlsSessionCacheSize }}</TLS_session_cache_size>
      {{- else }}
        <!--
        <TLS_session_cache_size>10000</TLS_session_cache_size>
        -->
      {{- end }}

        <!-- Optional. Maximum time, in seconds, in which a TLS session is kept
             available to the client for resumption. This holds for both stateless
             and stateful TLS resumption (see <enable_stateless_TLS_session_resumption>).
             In the latter case, the session also has to be kept in a cache.
             A value of 0 poses no time limit.
             Note, however, that the underlying Security Provider may ignore
             this setting (possibly depending of the protocol version in use).
             Default: If left empty or not defined, the maximum time is decided by the
             underlying Security Provider. For the default SunJSSE, it is 86400
             seconds, unless configured through the
             "jdk.tls.server.sessionTicketTimeout" JVM property. -->
      {{- if not (quote .tlsSessionTimeoutSeconds | empty) }}
        <TLS_session_timeout>{{ int .tlsSessionTimeoutSeconds }}</TLS_session_timeout>
      {{- else }}
        <!--
        <TLS_session_timeout>3600</TLS_session_timeout>
        -->
      {{- end }}

        <!-- Optional. If Y, tries to improve the TLS session resumption feature
             by providing the underlying Security Provider with information on
             the client IPs and ports. This makes sense only if client IPs can be
             determined (see the <client_identification> block).
             Default: N. -->
      {{- if not (quote .enableClientHintsForTlsSessionResumption | empty) }}
        <use_client_hints_for_TLS_session_resumption>{{ .enableClientHintsForTlsSessionResumption | ternary "Y" "N" }}</use_client_hints_for_TLS_session_resumption>
      {{- else }}
        <!--
        <use_client_hints_for_TLS_session_resumption>Y</use_client_hints_for_TLS_session_resumption>
        -->
      {{- end }}

        <!-- Optional. Request to provide the Metadata Adapter with the
             "principal" included in the client TLS/SSL certificate, when available.
             Can be one of the following:
             - Y: Upon each client connection, the availability of a client TLS/SSL
                  certificate is checked. If available, the included
                  identification data will be supplied upon calls to notifyUser.
             - N: No certificate information is supplied to notifyUser and no
                  check is done on the client certificate.
             Note that a check on the client certificate can also be requested
             through <force_client_auth>.
             Default: N. -->
      {{- if not (quote .enableClientAuth | empty) }}
        <use_client_auth>{{ .enableClientAuth | ternary "Y" "N" }}</use_client_auth>
      {{- else }}
        <!--
        <use_client_auth>Y</use_client_auth>
        -->
      {{- end }}

        <!-- Optional. Request to only allow clients provided with a valid TLS/SSL
             certificate. Can be one of the following:
             - Y: Upon each client connection, a valid TLS/SSL certificate is
                  requested to the client in order to accept the connection.
             - N: No check is done on the client certificate.
             Note that a certificate can also be requested to the client as a
             consequence of <use_client_auth>.
             Default: N. -->
      {{- if not (quote .enableMandatoryClientAuth | empty) }}
        <force_client_auth>{{ .enableMandatoryClientAuth | ternary "Y" "N" }}</force_client_auth>
      {{- else }}
        <!--
        <force_client_auth>Y</force_client_auth>
        -->
      {{- end }}

        <!-- Optional and only used when at least one of <use_client_auth> and
             <force_client_auth> is set to Y. Reference to a keystore to be used
             by the HTTPS service to accept client certificates.
             It can be used to supply client certificates that should be
             accepted, in addition to those with a valid certificate chain,
             for instance while testing with self-signed certificates.
             See the <keystore> block above for general details on keystore
             configuration (although the subelement names are different).
             Note that the further constraints reported there with regard to
             accessing the certificates in a JKS keystore don't hold in this
             case, where the latter is used as a truststore.
             Moreover, the handling of keystore replacement doesn't apply here. -->
      {{- if or .enableClientAuth .enableMandatoryClientAuth }}
          {{- with required "sslConfig.truststoreRef must be set since either sslConfig.enableClientAuth or sslConfig.enableMandatoryClientAuth are enabled " .truststoreRef }}
               {{- include "lightstreamer.configuration.truststore" (list $.Values.keystores .)  | nindent 8 }}
          {{- end }}
      {{- else }}
        <!--
        <truststore type="JKS">
            <truststore_file>./myserver.truststore</truststore_file>
            <truststore_password type="text">mypassword</truststore_password>
        </truststore>
        -->
      {{- end }}
    {{- end }}
  {{- end }}

    </{{ $elementType }}_server>
  {{ end }}
{{- end }}

    <!-- GLOBAL SOCKET SETTINGS -->
{{- with required "globalSocket must be set" .Values.globalSocket }}
    <!-- Mandatory. Longest inactivity time accepted while waiting for a slow
         request to be received. If this value is exceeded, the socket is
         closed. Reusable HTTP connections are also closed if they are not
         reused for longer than this time.
         The time actually considered may be approximated and may be a few
         seconds higher, for internal performance reasons.
         A 0 value suppresses the check. -->
    <read_timeout_millis>{{ int (required "globalSocket.readTimeoutMillis must be set" .readTimeoutMillis) }}</read_timeout_millis>

    <!-- Optional. Longest inactivity time accepted while waiting for a slow
         operation during a TLS/SSL handshake. This involves both reads,
         writes, and encryption tasks managed by the "TLS-SSL HANDSHAKE"
         or "TLS-SSL AUTHENTICATION" internal pools. If this value is
         exceeded, the socket is closed.
         The time actually considered may be approximated and may be a few
         seconds higher, for internal performance reasons.
         A 0 value suppresses the check.
         Default: 4000 ms. -->
  {{- if not (quote .handshakeTimeoutMillis | empty) }}
    <handshake_timeout_millis>{{ int .handshakeTimeoutMillis }}</handshake_timeout_millis>
  {{- else }}
    <!--
    <handshake_timeout_millis>2000</handshake_timeout_millis>
    -->
  {{- end }}

    <!-- Optional. Maximum length in bytes accepted for a request.
         For an HTTP GET request, the limit applies to the whole request,
         including the headers.
         For an HTTP POST request, the limit applies to the header part and the
         body part separately.
         For a request over a WebSocket, the limit applies to the request
         message payload. -->
    <request_limit>{{ int .requestLimit | default 5000 }}</request_limit>

    <!-- Optional. Longest operation time accepted while writing data on a
         socket. If this value is exceeded, the socket is closed. Note that
         this may also affect very slow clients.
         The time actually considered may be approximated and may be a few
         seconds higher, for internal performance reasons.
         If missing or 0, the check is suppressed. -->
    <write_timeout_millis>{{ int .writeTimeoutMillis | default 120000 }}</write_timeout_millis>

    <!-- Optional. Enabling the use of the full HTTP 1.1 syntax for all the
         responses, upon HTTP 1.1 requests. Can be one of the following:
         - Y: HTTP 1.1 is always used, when possible.
         - N: HTTP 1.0 is always used; this is possible for all HTTP requests,
              but it will prevent WebSocket support.
         - AUTO: HTTP 1.0 is used, unless HTTP 1.1 is required in order to
                 support specific response features.
         Default: Y. -->
    <!--
    <use_http_11>Y</use_http_11>
    -->

    <!-- Optional. WebSocket support configuration. The support is enabled
         by default. -->
    <websocket>

        <!-- Optional. Enabling of the WebSocket support.
             Can be one of the following:
             - Y: the Server accepts requests for initiating a WebSocket
                  interaction through a custom protocol;
             - N: the Server refuses requests for WebSocket interaction.
             Disabling WebSocket support may be needed when the local
             network infrastructure (for instance the Load Balancer) does
             not handle WebSocket communication correctly and the WebSocket
             transport is not already disabled on the client side through
             the Lightstreamer Client Library in use. The Client Library, upon the
             Server refusal, will resort to HTTP streaming without any
             additional delay to session establishment.
             Default: Y. -->
  {{- with required "webSocket must be set" .webSocket }}
        <!--
        <enabled>N</enabled>
        -->

        <!-- Optional. Maximum time the Server is allowed to wait before
             answering to a client "ping" request. In case a client sends
             very frequent "ping" requests, only the "pong" associated to
             the most recent request received is sent, while the previous
             requests will be ignored.
             Note that the above is possible also when 0 is specified.
             Default: 0. -->
    {{- if not (quote .maxPongDelayMillis | empty) }}
        <max_pong_delay_millis>{{ int .maxPongDelayMillis }}</max_pong_delay_millis>
    {{- else }}
        <!--
        <max_pong_delay_millis>1000</max_pong_delay_millis>
        -->
    {{- end }}

        <!-- Optional. Maximum time the Server is allowed to wait for the
             client "close" frame, in case the Server is sending its own
             "close" frame first, in order to try to close the connection
             in a clean way.
             If not specified, no timeout is set and the global
             <read_timeout_millis> limit applies. -->
    {{- if not (quote .maxClosingWaitMillis | empty) }}
        <max_closing_wait_millis>{{ int .maxClosingWaitMillis }}</max_closing_wait_millis>
    {{- else }}
        <!--
        <max_closing_wait_millis>1000</max_closing_wait_millis>
        -->
    {{- end }}

        <!-- Optional. Maximum payload size allowed for an outbound frame.
             When larger updates have to be sent, the related WebSocket
             messages will be split into multiple frames.
             A lower limit for the setting may be enforced by the Server.
             Default: 16384. -->
    {{- if not (quote .maxOutboundFrameSize | empty) }}
        <max_outbound_frame_size>{{ int .maxOutboundFrameSize }}</max_outbound_frame_size>
    {{- else }}
        <!--
        <max_outbound_frame_size>4096</max_outbound_frame_size>
        -->
    {{- end }}
  {{- end }}

    </websocket>
{{- end }}

<!--
  ======================
  SECURITY CONFIGURATION
  ======================
-->

{{- with required "security must be set" .Values.security }}
    <!-- Optional. Disabling of the protection for JavaScript pages, supplied
         by the Server, that carry user data.
         JavaScript pages can be supplied upon requests by old versions of the
         Web and Node.js (Unified API) Client Libraries, whereas recent versions
         no longer make use of this kind of pages. The protection prevents such
         pages from being imported in a <script> block and, as a consequence,
         from being directly executed within a hosting page regardless of its
         origin.
         This protection allows the Server to fully comply with the
         prescriptions to prevent the so-called "JavaScript Hijacking".
         Can be one of the following:
         - Y: the protection is enabled.
         - N: the protection is disabled.
              It can be set in order to support communication between the
              application front-end pages and Lightstreamer Server in specific
              use cases; see the Client Guide for the Web (Unified API) Client SDK
              earlier than 8.0.0 for details. It can also be set in order
              to ensure compatibility with even older Web Client Libraries
              (version 4.1 build 1308 or previous).
              Note, however, that basic protection against JavaScript
              Hijacking can still be granted, simply by ensuring that request
              authorization is never based on information got from the request
              cookies. This already holds for any session-related request other
              than session-creation ones, for which the request URL is always
              checked against the Server-generated session ID.
              For session-creation requests, this depends on the Metadata
              Adapter implementation, but can be enforced by setting
              <forward_cookies> to N.
         Default: Y. -->
    <use_protected_js>{{ .enableProtectedJs | default false | ternary "Y" "N" }}</use_protected_js>

    <!-- Optional. Use this setting to enable the forwarding of the cookies to
         the Metadata Adapter through the httpHeaders argument of the "notifyUser"
         method.
         Please note that in any case cookies should not be used to authenticate
         users, otherwise, having <use_protected_js> set to N and/or a too permissive
         policy in the <cross_domain_policy> will expose the server to CSRF attacks.
         Can be one of the following:
         - Y: cookies are forwarded to the Metadata Adapter.
         - N: cookies are hidden from the Metadata Adapter.
         Default: N. -->
    <forward_cookies>{{ .enableCookiesForwarding | default false | ternary "Y" "N" }}</forward_cookies>
  {{ with required "security.crossDomainPolicy must be set" .crossDomainPolicy -}}
    {{- $crossDomainPolicyEnabled := not (eq .enabled false ) }}
    {{- if $crossDomainPolicyEnabled }} 
    <!-- Optional. List of origins to be allowed by the browsers to consume
         responses to requests sent to this Server through cross-origin XHR or
         through WebSockets; in fact, when a requesting page asks for streaming
         data in this way, the browser should specify the page origin through the
         "Origin" HTTP header, to give the Server a chance to accept or refuse
         the request. This is the most common way streaming data is requested
         by the Web (Unified API) Client Library. You can see the Client Guide
         for the Web (Unified API) Client SDK earlier than 8.0.0
         for details on all the possible use cases.
         If a request origin is not matched against any of the configured rules,
         a Websocket initiation request will be refused, whereas a HTTP request
         will not be denied (i.e.: a 200 OK will be returned) but the response
         body will be left empty, in accordance with the CORS specifications.
         If no origin is specified by the user-agent, the request will always be
         accepted.
         Note that sending the Origin header is a client-side duty. In fact,
         most modern browsers, upon a request for a cross-origin XHR or WebSocket
         by a page, will send the Origin header, while older browsers will directly
         fail to send the request. Non-browser clients usually don't have to perform
         origin checks; so they don't send the Origin header and thus their requests
         are always authorized.
         In case the client wishes to send custom headers to the server, it requires
         an approval from the server itself. The accept_extra_headers attribute
         of this element permits to specify a comma separated list of extra headers
         to be allowed in the client requests. Note that a space is expected after
         each comma (e.g.: accept_extra_headers="custom-header1, custom-header2").
         The accept_credentials attribute can be used to specify if the server should
         authorize the client to send its credentials on a CORS request. This flag
         does not impact the user/password sent over the Lightstreamer protocol,
         but, if set to false, might prevent, or force a fallback connection, on
         clients sending CORS requests carrying cookies, http-basic-authentication or
         client-side certificates. Default is Y.
         In case an HTTP OPTIONS request is sent to authorize future requests,
         the server allows the client to store the result of such OPTIONS
         request for a number of seconds configured in the options_max_age
         attribute of this element (default is 3600). Thus a previously authorized
         client may not give up its authorization, even if the related origin is
         removed from the list and the server is restarted, until its authorization
         expires. -->    
     {{- $acceptCredentials := not (eq .acceptCredentials false) }}
     {{- $acceptExtraHeaders := .acceptExtraHeaders | default "" }}
    <cross_domain_policy{{- if .optionsMaxAgeSeconds }} options_max_age={{ .optionsMaxAgeSeconds | quote }}{{- end }} accept_extra_headers={{ $acceptExtraHeaders | quote }} accept_credentials={{ $acceptCredentials | ternary "Y" "N" | quote }}>

        <!-- Optional and cumulative. Declaration of an Origin allowed
             to consume responses to cross-origin requests.
             Each <allow_access_from> element will define a rule against which
             Origin headers will be checked.
             Each rule must define a scheme, a host and a port in the following way:
             - scheme: a valid scheme name (usually http or https) or *; the latter
               matches both http and https scheme, but it doesn't match other schemes.
             - host: a valid host name, IPv4 or IPv6 representing an authorized Origin.
               Also a * is accepted with the meaning of "any host or IP".
               If a host name is specified it can be prefixed with a wildcard as long
               as at least the second level domain is explicitly specified (i.e.:
               *.my-domain.com and *.sites.my-domain.com are valid entries
               while *.com is not)
             - port: a valid port or * to specify any port.
             Note that by setting three *'s any origin will be accepted, without
             performing any check. In particular, any scheme will be accepted,
             not just http and https. -->
      {{- range $key, $value := .allowAccessFrom }}
        {{- if $value }}
          {{- $scheme := required (printf "security.crossDomainPolicy.allowsAccess.%s.scheme must be set" $key) $value.scheme }} 
          {{- $host := required (printf "security.crossDomainPolicy.allowsAccess.%s.host must be set" $key) $value.host }} 
          {{- $port := required (printf "security.crossDomainPolicy.allowsAccess.%s.port must be set" $key) $value.port }} 
        <allow_access_from scheme={{ $scheme | quote }} host={{ $host | quote }} port={{ $port | quote }} />
        {{- end }}
      {{- else }}
        <!--
        <allow_access_from scheme="https" host="www.my-domain.com" port="443" />
        -->
        <!--
        <allow_access_from scheme="*" host="*.my-domain.com" port="*" />
        -->
        <!--
        <allow_access_from scheme="*" host="192.168.0.101" port="*" />
        -->
        <!--
        <allow_access_from scheme="*" host="2001:0db8:aaaa:0000:0000:dddd:eeee:0000" port="*" />
        -->
        <!--
        <allow_access_from scheme="*" host="2001:0db8:aaaa::dddd:eeee:0" port="*" />
        -->
      {{- end }}

    </cross_domain_policy>
    {{- end }}
  {{- end }}

    <!-- Optional and cumulative. Origin domain or subdomain to be allowed
         by the browsers to access data on HTML pages supplied by this Server.
         This was one of the ways used by the Web (Unified API) Client SDK
         earlier than 8.0.0 to request streaming data; see the Client Guide
         for these Web (Unified API) Client SDK versions for details
         on which use cases involve accessing data through HTML pages.
         In this kind of requests, the requesting page should be allowed by
         the browser to access data contained in the Server-originated page
         only if both pages declare a common subdomain. So, the page should
         declare a subdomain as its "document.domain" property and will ask
         the Server to declare the same subdomain on the response page.
         In that case, the Server will be allowed to set the requested
         subdomain as the "document.domain" property of the data page only
         if configured here, otherwise the whole request will be refused.
         On the other hand, if no <allowed_domain> element is configured,
         then this check is disabled. Note that, in any case, the consistency
         of the declared subdomain with the url used to request the data page
         must be ensured by the browser.
         If the requesting page doesn't specify any subdomain for the response,
         the request will always be allowed; in this case, a same-domain access
         to the Server data page will be performed by the browser. -->
  {{- range $index, $domain := .allowedDomains }}
    <allowed_domain>{{ required (printf "security.allowedDomains[%d] must be set" (int $index)) $domain }}</allowed_domain>
  {{- else }}
    <!--
    <allowed_domain>my-domain.com</allowed_domain>
    -->
    <!--
    <allowed_domain>my-alt-domain.com</allowed_domain>
    -->
  {{- end }}

    <!-- Optional. Server identification policy to be used for all server
         responses. Upon any HTTP request, the Server identifies itself
         through the "Server" HTTP response header. However, omitting version
         information may make external attacks more difficult.
         Can be one of the following:
         - FULL: the Server identifies itself as:
                 Lightstreamer Server/X.Y.Z build BBBB (Lightstreamer Push Server - www.lightstreamer.com) EEEEEE edition
         - MINIMAL: the Server identifies itself, depending on the Edition:
             for Enterprise edition, as:
                 Lightstreamer Server
             for Community edition, as:
                 Lightstreamer Server (Lightstreamer Push Server - www.lightstreamer.com) COMMUNITY edition
         Default: FULL. -->
  {{- if .serverIdentificationPolicy }}
    {{- $admittedIdentificationPolicies := list "FULL" "MINIMAL" }}
    {{- if not (has .serverIdentificationPolicy $admittedIdentificationPolicies) }}
      {{- printf "security.serverIdentificationPolicy must be one of: %s" $admittedIdentificationPolicies | fail }}
    {{- end }}
    <server_tokens>{{ .serverIdentificationPolicy }}</server_tokens>
  {{- else }}
    <!--
    <server_tokens>MINIMAL</server_tokens>
    -->
  {{- end }}
{{- end }}

<!--
  ====================================
  LOGGING AND MANAGEMENT CONFIGURATION
  ====================================
-->

    <!-- Mandatory. Path of the configuration file for the internal logback-based
         logging system. The file path is relative to the conf directory. -->
    <logback_properties>./lightstreamer_log_conf.xml</logback_properties>
{{- with required "management must be set" .Values.management }}

    <!-- Optional. A set of Clients whose activity is not to be logged. -->
    <no_logging_ip>

        <!-- Cumulative. IP address of a Client to exclude from logging. -->
  {{- if .noLoggingIpAddresses }}
     {{- range .noLoggingIpAddresses }}
        <ip_value>{{ . }}</ip_value>
     {{- end }}
  {{- else }}
        <!--
        <ip_value>200.0.0.10</ip_value>
        -->
  {{- end }}
    </no_logging_ip>

    <!-- Optional. Enabling of the inclusion of the user password in the log
         of the client requests for new sessions, performed by the
         "LightstreamerLogger.requests" logger at INFO level.
         Can be one of the following:
         - Y: the whole request is logged;
         - N: the request is logged, but for the value of the LS_password
              request parameter.
         Note that the whole request may still be logged by some loggers,
         but only at DEBUG level, which is never enabled in the default
         configuration.
         Default: N. -->
  {{- if (quote .enablePasswordVisibilityOnRequestLog | empty) }}
    <!--
    <show_password_on_request_log>Y</show_password_on_request_log>
    -->
  {{- else }}
    <show_password_on_request_log>{{ .enablePasswordVisibilityOnRequestLog | ternary "Y" "N" }}</show_password_on_request_log>
  {{- end }}

    <!-- Optional. Threshold time for long Adapter call alerts.
         All Data and Metadata Adapter calls should perform as fast
         as possible, to ensure that client requests are accomplished quickly.
         Slow methods may also require that proper thread pools are configured.
         Hence, all invocations to the Adapters (but for the initialization
         phase) are monitored and a warning is logged whenever their execution
         takes more than this time.
         A 0 value disables the check.
         Default: 1000. -->
    <unexpected_wait_threshold_millis>{{ int .unexpectedWaitThresholdMillis }}</unexpected_wait_threshold_millis>

    <!-- Optional. Threshold time for long asynchronous processing alerts.
         Data and Metadata Adapter calls, even when performed through
         asynchronous invocations (where available), should still take
         a reasonable time to complete. This is especially important if limits
         to the number of concurrent tasks are set; moreover, tasks forgotten
         for any reason and never completed may cause a memory leak.
         Hence, the longest current execution time is periodically sampled
         by the Server Monitor on each pool and, whenever it exceeds this
         threshold on a pool, a warning is logged. Note that warning messages
         can be issued repeatedly. A 0 value disables the check.
         Default: 10000. -->
  {{- $asyncProcessingThresholdMillis := .asyncProcessingThresholdMillis | default 60000 }}
    <async_processing_threshold_millis>{{ int .asyncProcessingThresholdMillis }}</async_processing_threshold_millis>

    <!-- Optional. Threshold wait time for a task enqueued for running on any
         of the internal thread pools.
         The current wait time is periodically sampled by the Server Monitor
         on each pool and, whenever it exceeds this threshold on a pool,
         a warning is logged. Note that warning messages can be issued
         repeatedly. A 0 value disables the check.
         Default: 10000. -->
  {{- if (quote  .maxTaskWaitMillis | empty) }}
    <!--
    <max_task_wait_millis>0</max_task_wait_millis>
    -->
  {{- else }}
    <max_task_wait_millis>{{ int .maxTaskWaitMillis }}</max_task_wait_millis>
  {{- end }}

    <!-- Mandatory. Sampling time for internal load statistics (Server
         Monitor). These statistics are available through the JMX interface;
         some of these statistics are logged by the Internal Monitor log
         or can be subscribed to through the internal Monitoring Adapter Set.
         Full JMX features is an optional feature, available depending
         on Edition and License Type. -->
    <collector_millis>{{ int (required "management.collectorMillis must be set" .collectorMillis) }}</collector_millis>

    <!-- Mandatory (if you wish to use the provided "stop" script).
         JMX preferences and external access configuration.
         Full JMX features is an optional feature, available depending
         on Edition and License Type; if not available, only the
         Server shutdown operation via JMX is allowed. To know what
         features are enabled by your license, please see the License
         tab of the Monitoring Dashboard (by default,
         available at /dashboard). -->
    <jmx>
  {{- with required "management.jmx must be set" .jmx }}

        <!-- Mandatory (if you wish to use the provided "stop" script).
             Enables the standard RMI Connector.
             The remote MBean server will be accessible through this url:
             "service:jmx:rmi:///jndi/rmi://<host>:<port>/lsjmx".
             If full JMX features is not available, only the "Server" MBean
             is supplied and only the Server shutdown operation is available.
             The JVM platform MBean server is also exposed and it is accessible
             through the url:
             "service:jmx:rmi:///jndi/rmi://<host>:<port>/jmxrmi".
             Note that the configuration of the connector applies to both cases;
             hence, access to the JVM platform MBean server from this connector
             is not configured through the "com.sun.management.jmxremote" JVM
             properties.
             Also note that TLS/SSL is an optional feature, available depending on
             Edition and License Type. To know what features are enabled by your
             license, please see the License tab of the Monitoring Dashboard
             (by default, available at /dashboard). -->
        <rmi_connector>
    {{- with required "management.jmx.rmiConnector must be set" .rmiConnector }}
      {{- $rmiConnectorEnabled := not (eq .enabled false) }}
      {{- if $rmiConnectorEnabled}}

            <!-- Mandatory for this block. TCP port on which the RMI Connector will
                 be available. This is the port that has to be specified in the
                 client access url.
                 The optional "ssl" attribute, when set to "Y", enables TLS/SSL
                 communication. Note that this case is not managed by some JMX
                 clients, like jconsole. -->
        {{- $rmiPort := required "management.jmx.rmiConnector.port must be set" .port }}
        {{- $rmiPortValue := required "management.jmx.rmiConnector.port.value must be set" $rmiPort.value }}
        {{- $rmiPortEnableSsl := $rmiPort.enableSsl | default false }}
            <port ssl={{ $rmiPortEnableSsl | ternary "Y" "N" | quote }}>{{ int $rmiPortValue }}</port>

            <!-- Optional. TCP port that will be used by the RMI Connector for
                 its own communication stuff. The port has not to be specified
                 in the client access url, but it may have to be considered for
                 firewall settings.
                 The optional "ssl" attribute, when set to "Y", enables TLS/SSL
                 communication by the connector; TLS/SSL at this level is supported
                 by some JMX clients, like jconsole, that don't support TLS/SSL
                 on the main port. If omitted, the same setting used for <port>
                 is considered.
                 Default: the same as configured in <port>. -->
        {{- $rmiDataPortValue := (.dataPort).value | default $rmiPortValue }}
        {{- $rmiDataPortEnableSsl := ((.dataPort).enableSsl | quote | empty) | ternary $rmiPortEnableSsl (.dataPort).enableSsl }}
            <data_port ssl={{ $rmiDataPortEnableSsl | ternary "Y" "N" | quote }}>{{ int $rmiDataPortValue }}</data_port>

            <!-- Optional. A hostname by which the RMI Server can be reached from
                 all the clients. In fact, the RMI Connector, for its own
                 communication stuff, does not use the hostname specified in the
                 client access url, but needs an explicit server-side configuration.
                 Note that, if you wish to use the provided "stop" script, the
                 specified hostname has to be visible also from local clients.
                 Default: any setting provided to the "java.rmi.server.hostname"
                 JVM property. -->
        {{- if .hostname }}
            <hostname>{{ .hostname }}</hostname>
        {{- else }}
            <!--
            <hostname>push.mycompany.com</hostname>
            -->
        {{- end }}

            <!-- Optional. Enabling of a preliminary test on the reachability
                 of the RMI Server through the configured hostname. Note that the
                 reachability is not needed for the Server itself, so the test is only
                 for the benefit of other clients, including the "stop" script;
                 but, since other clients may be run in different environments,
                 the outcome of this test may not be significant.
                 Can be one of the following:
                 - Y: Enables the test; if the test fails, the whole Server startup
                      will fail. If successful and the "stop" script is launched in
                      the same environment of the Server, the script should work.
                 - N: Disables the test, but this setting can be overridden by
                      setting <ensure_stopping_service> to Y.
                 Default: Y. -->
            {{- $enablePortTest := not (eq .enablePortTest false) }}
            <test_ports>{{ $enablePortTest | ternary "Y" "N" }}</test_ports>

            <!-- Optional. Timeout to be posed on the connection attempts through
                 the RMI Connector. If 0, no timeout will be posed.
                 The setting affects:
                 - The reachability test (if enabled through <test_ports>).
                 - The connector setup operation; in fact this operation may involve
                   a connection attempt, whose failure, however, would not prevent
                   the setup from being successful. If the configured hostname were
                   not visible locally, the setup might take long time; by setting
                   a timeout, the operation would not block the whole Server startup.
                   However, the RMI Connector (and the "stop" script) might not be
                   available immediately after the startup, and any late failure
                   preventing the connector setup would be ignored.
                 On the other hand, the setting is ignored by the "stop" script.
                 Default: 0. -->
            <test_timeout_millis>{{ int .testTimeoutMillis | default 5000 }}</test_timeout_millis>

            <!-- Optional. Can be used on a multihomed host to specify the IP
                 address to bind the HTTP/HTTPS server sockets to, for all the
                 communication.
                 Note that, when a listening interface is configured and depending
                 on the local network configuration, specifying a suitable
                 <hostname> setting may be needed to make the connector accessible,
                 even from local clients.
                 The default is to accept connections on any/all local addresses. -->
        {{- if .listeningInterface }}
            <listening_interface>{{ .listeningInterface }}</listening_interface>
        {{- else }}
            <!--
            <listening_interface>200.0.0.1</listening_interface>
            -->
        {{- end }}

            <!-- Optional. Reference to the keystore to be used in case TLS/SSL
                 is enabled for part or all the communication.
                 See the <keystore> block inside <https_server> for general
                 details on keystore configuration. These include the runtime
                 replacement of the keystore, with one difference:
                 if the load of the new keystore fails, the RMI Connector
                 may be left unreachable.
                 Default: if the block is missing, any settings provided to the
                 "javax.net.ssl.keyStore" and "javax.net.ssl.keyStorePassword"
                 JVM properties will apply. -->
        {{- if or $rmiPortEnableSsl $rmiDataPortEnableSsl }}
        {{- with required (printf "management.jmx.rmiConnector.sslConfig must be set") .sslConfig }}
          {{- with required "management.jmx.rmiConnector.sslConfig.keystoreRef must be set" .keystoreRef }}
            {{- include "lightstreamer.configuration.keystore" (list $.Values.keystores .) | nindent 12 }}
          {{- end }}

          {{- if and .allowCipherSuites .removeCipherSuites }}
            {{ printf "management.jmx.rmiConnector.sslConfig.allowCipherSuites and management.jmx.rmiConnector.sslConfig.removeCipherSuites cannot be used together" | fail }}
          {{- end }}

            <!-- Optional and cumulative, but forbidden if <remove_cipher_suites> is used.
                 Specifies all the cipher suites allowed for the interaction, in case
                 TLS/SSL is enabled for part or all the communication.
                 See notes for <allow_cipher_suite> under <https_server>. -->
          {{- range $index, $cipherSuite := .allowCipherSuites }}
            <allow_cipher_suite>{{ required (printf "management.jmx.rmiConnector.sslConfig.allowCipherSuite[%d] must be set" (int $index)) $cipherSuite }}</allow_cipher_suite>
          {{- end }}

            <!-- Optional and cumulative, but forbidden if <allow_cipher_suite> is used.
                 Pattern to be matched against the names of the enabled cipher suites
                 in order to remove the matching ones from the enabled cipher suites set
                 to be used in case TLS/SSL is enabled for part or all the communication.
                 See notes for <remove_cipher_suites> under <https_server>. -->
          {{- range $index, $cipherSuite := .removeCipherSuites }}
            <remove_cipher_suites>{{ required (printf "management.jmx.rmiConnector.sslConfig.removeCipherSuites[%d] must be set" (int $index)) $cipherSuite }}</remove_cipher_suites>
          {{- end }}

            <!-- Optional. Determines which side should express the preference when
                 multiple cipher suites are in common between server and client
                 (in case TLS/SSL is enabled for part or all the communication).
                 See notes for <enforce_server_cipher_suite_preference> under <https_server>.
                 Default: N. -->
          {{- $order := (.enforceServerCipherSuitePreference).order | default "JVM" }}
          {{- $enabled := not (eq (.enforceServerCipherSuitePreference).enabled false) }}
          {{- if not (mustHas $order (list "JVM" "config")) }}
            {{- fail printf ("management.jmx.rmiConnector.sslConfig.enforceServerCipherSuitePreference must be one of: \"JVM\", \"config\"") }}
          {{- end }}
            <enforce_server_cipher_suite_preference order={{ $order | quote }}>{{ $enabled | ternary "Y" "N" }}</enforce_server_cipher_suite_preference>

          {{- if and .allowProtocols .removeProtocols }}
            {{ printf "management.jmx.rmiConnector.sslConfig.allowProtocols and management.jmx.rmiConnector.sslConfig.removeProtocols cannot be used together" | fail }}
          {{- end }}

            <!-- Optional and cumulative, but forbidden if <remove_protocols> is used.
                 Specifies one or more protocols allowed for the TLS/SSL interaction,
                 in case TLS/SSL is enabled for part or all the communication.
                 See notes for <allow_protocol> under <https_server>. -->
          {{- range $index, $protocol := .allowProtocols }}
            <allow_protocol>{{ required (printf "management.jmx.rmiConnector.sslConfig.allowProtocols[%d] must be set" (int $index)) $protocol }}</allow_protocol>
          {{- end }}

            <!-- Optional and cumulative, but forbidden if <allow_protocol> is used.
                 Pattern to be matched against the names of the enabled TLS/SSL
                 protocols in order to remove the matching ones from the enabled
                 protocols set to be used in case TLS/SSL is enabled for part
                 or all the communication.
                 See notes for <remove_protocols> under <https_server>. -->
          {{- range $index, $protocol := .removeProtocols }}
            <remove_protocols>{{ required (printf "management.jmx.rmiConnector.sslConfig.removeProtocols[%d] must be set" (int $index)) $protocol }}</remove_protocols>
          {{- end }}
        {{- end }} {{/* sslConfig */}}
        {{- end }} {{/* or .port.enableSsl (.dataPort).enableSsl */}}

            <!-- Optional. Enabling of the RMI Connector access without credentials.
                 Can be one of the following:
                 - Y: requests to the RMI Connector are always allowed;
                 - N: requests to the RMI Connector are subject to user authentication;
                      the allowed users are set in the "user" elements.
                 Default: N. -->
            <public>{{ .enablePublicAccess | default false | ternary "Y" "N"}}</public>

            <!-- Optional and cumulative (but ineffective if "public" is set to "Y").
                 Credentials of the users enabled to access the RMI Connector.
                 Both "id" and "password" attributes are mandatory.
                 If "public" is set to "N", at least one set of credentials should
                 be supplied in order to allow access through the connector.
                 This is also needed if you wish to use the provided "stop" script;
                 the script will always use the first user supplied. -->
        {{- if not .enablePublicAccess }}
          {{- range $index, $secretRef := .credentialsSecrets}}
            {{- $_ := required (printf "management.jmx.rmiConnector.credentialsSecrets[%d] must be set" (int $index)) $secretRef }}
            <user id="$env.LS_RMI_CREDENTIAL_{{ $secretRef | upper | replace "-" "_" }}_USER" password="$env.LS_RMI_CREDENTIAL_{{ $secretRef | upper | replace "-" "_"}}_PASSWORD" />
          {{- end }}
        {{- else}}
            <!--
            <user id="other_user" password="other_password" />
            -->
        {{- end }}
      {{- end }}
    {{- end }} {{/* rmiConnector */}}
        </rmi_connector>

        <!-- Optional. Enables Sun/Oracle's JMXMP connector.
             The connector is supported by the Server only if Sun/Oracle's JMXMP
             implementation library is added to the Server classpath;
             see README.TXT in the JMX SDK for details.
             The remote server will be accessible through the url:
             "service:jmx:jmxmp://<host>:<port>". -->
      {{- if (.jmxmpConnector).enabled }}
        <jmxmp_connector>

            <!-- Mandatory for this block. TCP port on which Sun/Oracle's JMXMP
                 connector will be listening. This is the port that has to be
                 specified in the client access url. -->
            <port>{{ int (required "management.jmx.jmxmpConnector.port must be set" .jmxmpConnector.port) }}</port>

        </jmxmp_connector>
      {{- else }}
        <!--
        <jmxmp_connector>
        -->
            <!-- Mandatory for this block. TCP port on which Sun/Oracle's JMXMP
                 connector will be listening. This is the port that has to be
                 specified in the client access url. -->
            <!--
            <port>9999</port>
            -->

        <!--
        </jmxmp_connector>
        -->
    {{- end }}

        <!-- Optional. Disabling of the availability of session-related mbeans,
             the ones identified by type="Session". Can be one of the following:
             - Y: no mbeans of type "Session" are generated, but for a fake mbean
                  which acts as a reminder that the option can be enabled;
             - sampled_statistics_only: for each active session, a corresponding
                  mbean of type "Session" is available, but all the statistics
                  based on periodic sampling are disabled;
             - N: for each active session, a corresponding mbean of type "Session"
                  is available with full functionality.
             The support for session-related mbeans can pose a significant
             overload on the Server when many sessions are active and many of them
             are continuously created and closed. For this reason, the support is
             disabled by default.
             Default: Y. -->
    {{- if .sessionMbeanAvailability }}
      {{- $sessionAvailabilityMap := dict "active" "N" "inactive" "Y" "sampled_statistics_only" "sampled_statistics_only" -}}
      {{- if not (mustHas .sessionMbeanAvailability (keys $sessionAvailabilityMap)) }}
        {{- fail (printf "management.jmx.sessionMbeanAvailability must be one of: %s" (keys $sessionAvailabilityMap)) }}
      {{- end }}
        <disable_session_mbeans>{{ get $sessionAvailabilityMap .sessionMbeanAvailability }}</disable_session_mbeans>
    {{- else }}
        <!--
        <disable_session_mbeans>N</disable_session_mbeans>
        -->
    {{- end }}

        <!-- Optional. Disabling of all properties provided by the various MBeans
             that can, potentially, return extremely long lists. In fact, various
             JMX agents extract the property values from the MBeans all together;
             but extremely long values may clutter the agent and prevent also the
             acquisition of other properties. This issue may also affect the JMX Tree.
             For all these properties, corresponding operations are also provided.
             Can be one of the following:
             - Y: properties that can, potentially, return extremely long lists
                  won't yield the correct value, but just a reminder text; for
                  instance, this applies to 'CurrentSessionList' in the ResourceMBean.
             - N: all list properties are enabled; in some cases, their value
                  may be an extremely long list; consider, for instance,
                  'CurrentSessionList' in the ResourceMBean.
             Default: N. -->
    {{- $enableLongListProperties := not (eq .enableLongListProperties false) }}
        <disable_long_list_properties>{{ $enableLongListProperties | ternary "N" "Y"}}</disable_long_list_properties>
  {{- end }}
    </jmx>

    <!-- Optional. Startup check that the conditions for the correct working
         of the provided "stop" script are met (see the <jmx> block).
         Can be one of the following:
         - Y: If the JMX RMI Connector is not configured or the ServerMBean
              cannot be started, the startup will fail.
              This also enforces the check of the JMX port reachability
              (see <test_ports> and the remarks on the test effectiveness);
              if the test fails, the startup will also fail
         - N: No check is made that the "stop" script should work.
              This may not be a problem, because the Server can be stopped
              in other ways. The provided installation scripts also close
              the Server without resorting to the "stop" script.
         Default: N. -->
    <ensure_stopping_service>{{ .enableStoppingServiceCheck | default false | ternary "Y" "N" }}</ensure_stopping_service>

    <!-- Optional. Configuration of the Monitoring Dashboard.
         The dashboard is a webapp whose pages are embedded in Lightstreamer
         Server and supplied by the internal web server. The main page has
         several tabs, which provide basic monitoring statistics in graphical
         form; the last one shows the newly introduced JMX Tree,
         which enables JMX data view and management from the browser.
         The Dashboard leans on an internal Adapter Set, named "MONITOR".
         The following elements configure access restrictions to Monitoring
         Dashboard pages.
         *** IMPORTANT *** The Monitoring Dashboard enables data view and
         management, including the Server shutdown operation, from a remote
         browser. We recommend configuring the credentials and protecting them
         by making the Monitoring Dashboard only available on https server
         sockets through the settings below. Further restrictions can be
         applied to the JMX Tree only. See PRODUCTION_SECURITY_NOTES.TXT for
         a full check-list.
         Note that basic monitoring statistics are also available to any
         Lightstreamer application; in fact, an instance of a special internal
         monitoring Data Adapter can be embedded in any custom Adapter Set,
         by specifying "MONITOR" in place of the Data Adapter class name.
         For a listing of the supplied items, see the General Concepts document.
         The <enable_hostname_lookup> setting below also affects the monitoring
         Data Adapter. On the other hand, access restrictions to a monitoring
         Data Adapter instance embedded in a custom Adapter Set is only managed
         by the custom Metadata Adapter included. -->
    <dashboard>
  {{- with required "management.dashboard must be set" .dashboard }}
    {{- $dashboardEnabled := not (eq .enabled false) }}
    {{- if $dashboardEnabled }}

        <!-- Optional. Enabling of the requests for the JMX Tree page, which is
             part of the Monitoring Dashboard.
             This page, whose implementation is based on the "jminix" library,
             enables JMX data view and management, including the Server shutdown
             operation, from the browser.
             Can be one of the following:
             - Y: the Server supports requests for JMX Tree pages, though further
                  fine-grained restrictions may also apply;
             - N: the Server ignores requests for JMX Tree pages, regardless of
                  the credentials supplied and the server socket in use; the
                  dashboard tab will just show a "disabled page" notification.
             Default: N. -->

      {{- $enableJmxTree := not (eq .enableJmxTree false) }}
        <jmxtree_enabled>{{ $enableJmxTree | ternary "Y" "N" }}</jmxtree_enabled>

        <!-- Optional. Enabling of the access to the Monitoring Dashboard
             pages without credentials.
             Can be one of the following:
             - Y: requests for the Monitoring Dashboard are always accepted.
             - N: requests for the Monitoring Dashboard are subject to a check
                  for credentials to be specified through the "user" elements;
                  hence, a user credential submission dialog may be presented
                  by the browser.
                  If no "user" elements are defined, the Monitoring Dashboard
                  will not be accessible in any way.
             Default: N. -->
      {{- $enablePublicAccess := not (eq .enablePublicAccess false) }}
        <public>{{ $enablePublicAccess | ternary "Y" "N" }}</public>

        <!-- Optional and cumulative (but ineffective if "public" is set to "Y").
             Credentials of the users enabled to access the Monitoring Dashboard.
             Both "id" and "password" attributes are mandatory.
             The optional "jmxtree_visible" attribute (whose default is "Y")
             allows for restriction of the access to the JMX Tree on a user basis;
             it is only effective if <jmxtree_enabled> is set to "Y". -->
      {{- if and .credentials (not .enablePublicAccess) }}
        {{- range $credential := .credentials }}
          {{- $secretRef := required "management.dashboard.credentials[].secretRef must be set" ($credential).secretRef }}
          {{- $enableJmxTreeVisibility := not (eq $credential.enableJmxTreeVisibility false) }}
        <user id="$env.LS_DASHBOARD_CREDENTIAL_{{ $credential.secretRef | upper | replace "-" "_" }}_USER" password="$env.LS_DASHBOARD_CREDENTIAL_{{ .secretRef | upper | replace "-" "_"}}_PASSWORD" jmxtree_visible={{ $enableJmxTreeVisibility | ternary "Y" "N" | quote }} />
        {{- end }}
      {{- else}}
        <!--
        <user id="put_your_dashboard_user_here" password="put_your_dashboard_password_here" />
        -->
        <!--
        <user id="other_user" password="other_password" jmxtree_visible="N" />
        -->
      {{- end }}

        <!-- Optional. Enabling of the access to the Monitoring Dashboard pages
             through all server sockets. Can be one of the following:
             - Y: requests to the Monitoring Dashboard can be issued through
                  all the defined server sockets.
             - N: requests to the Monitoring Dashboard can be issued only
                  through the server sockets specified in the "available_on_server"
                  elements, if any; otherwise, requests to the dashboard url
                  will get a "page not found" error.
                  If no "available_on_server" elements are defined, requests to
                  the Monitoring Dashboard will not be possible in any way.
             Disabling the Dashboard on a server socket causes the internal "MONITOR"
             Adapter Set to also become unavailable from that socket. This does not
             affect in any way the special "MONITOR" Data Adapter.
             Default: N. -->
      {{- $enableAvailabilityOnAllServers := not (eq .enableAvailabilityOnAllServers false) }}
        <available_on_all_servers>{{ $enableAvailabilityOnAllServers | ternary "Y" "N" }}</available_on_all_servers>

        <!-- Optional and cumulative (but ineffective if "available_on_all_servers"
             is set to "Y").
             Specific server sockets for which requests to the Monitoring Dashboard
             will be allowed, that can be identified through the mandatory "name"
             attribute.
             The optional "jmxtree_visible" attribute (whose default is "Y")
             allows for restriction of the access to the JMX Tree on a TCP port
             basis; it is only effective if <jmxtree_enabled> is set to "Y". -->
      {{- if not $enableAvailabilityOnAllServers }}
        {{- range $index, $value := .availableOnServers }}
          {{- include "lightstreamer.configuration.servers.validateServerRef" (list $ (printf "management.dashboard.availableOnServers[%d].serverRef" (int $index)) $value.serverRef) }}
          {{- $serverRef := (get $.Values.servers $value.serverRef).name }}
          {{- $enableJmxTreeVisibility := not (eq $value.enableJmxTreeVisibility false) }}
        <available_on_server name={{ $serverRef | quote }} jmxtree_visible={{ $enableJmxTreeVisibility | ternary "Y" "N" | quote }} />
        {{- else }}
        <!--
        <available_on_server name="Lightstreamer HTTPS Server" />
        -->
        <!--
        <available_on_server name="Lightstreamer HTTP Server" jmxtree_visible="N" />
        -->
        {{- end }}
      {{- end }}

        <!-- Optional. URL path to map the Monitoring Dashboard pages to.
             An absolute path must be specified.
             Default: /dashboard -->
      {{- if .urlPath }}
        {{ if not (hasPrefix "/" .urlPath) }}
          {{ printf "management.dashboard.urlPath must start with a /" | fail }}
        {{ end }}
        <dashboard_url_path>{{ .urlPath }}</dashboard_url_path>
      {{- else }}
        <!--
        <dashboard_url_path>/my_dashboard</dashboard_url_path>
        -->
      {{- end }}

        <!-- Optional. Enabling of the reverse lookup on Client IPs and inclusion
             of the Client hostnames while monitoring client activity.
             This setting affects the Monitor Console page and also affects
             any instance of the monitoring Data Adapter embedded in a custom
             Adapter Set.
             Can be one of the following:
             - Y: the Client hostname is determined on Client activity
                  monitoring; note that the determination of the client hostname
                  may be heavy for some systems;
             - N: no reverse lookup is performed and the Client hostname is not
                  included on Client activity monitoring.
             Default: N. -->
        <enable_hostname_lookup>{{ .enableHostnameLookup | default false | ternary "Y" "N" }}</enable_hostname_lookup>
    {{- end }} 
  {{ end }} {{/* dashboard */}}
    </dashboard>

  {{- with required "management.healthCheck must be set" .healthCheck }}
    {{- $healthCheckEnabled := not (eq .enabled false) }}
    {{- if $healthCheckEnabled }}
    <!-- Optional. Configuration of the "/lightstreamer/healthcheck" request
         url, which allows a load balancer to test for Server responsiveness
         to external requests. The Server should always answer to the
         request with the "OK\r\n" content string (unless overridden through
         the JMX interface). The Server may log further information to the
         dedicated "LightstreamerHealthCheck" logger.
         Support for clustering is an optional feature, available depending
         on Edition and License Type. -->
    <healthcheck>

        <!-- Optional. Enabling of the healthcheck url on all server sockets.
             Can be one of the following:
             - Y: healthcheck requests can be issued through all the defined
                  server sockets;
             - N: healthcheck requests can be issued only through the server
                  sockets specified in the "available_on_server" elements,
                  if any.
             Default: N. -->
      {{- if (quote .enableAvailabilityOnAllServers | empty) }}
        <!--
        <available_on_all_servers>Y</available_on_all_servers>
        -->
      {{- else }}
        <available_on_all_servers>{{ .enableAvailabilityOnAllServers | ternary "Y" "N" }}</available_on_all_servers>
      {{- end }}

        <!-- Optional and cumulative (but ineffective if "available_on_all_servers"
             is set to "Y").
             Specific server sockets for which healthcheck requests can be issued,
             that can be identified through the mandatory "name" attribute. -->
      {{- if not .enableAvailabilityOnAllServers }}
        {{- range $index, $value := .availableOnServers }}
          {{- include "lightstreamer.configuration.servers.validateServerRef" (list $ (printf "management.healthCheck.availableOnServers[%d].serverRef" (int $index)) $value.serverRef) }}
        <available_on_server name={{ (get $.Values.servers $value.serverRef).name | quote }} />
        {{- else }}
        <!--
        <available_on_server name="Lightstreamer HTTP Server" />
        -->
        {{- end }}
      {{- end }}
      </healthcheck>
    {{- end }}
  {{- end }}
{{- end }}

<!--
  =========================
  ENVIRONMENT CONFIGURATION
  =========================
-->

    <!-- Optional. If set, modifies the behavior of the variable-expansion
         feature in this configuration file. It specifies a prefix such that,
         if a $propname value is found and propname starts with this prefix,
         the propname will be searched among the system environment variables
         rather than the JVM properties. -->
    <env_prefix>env.</env_prefix>

    <!-- Optional. Path of the file system directory that contains all the
         Adapter Set configuration. The path is relative to the conf directory.
         Default: ../adapters -->
    <!--
    <adapters_dir>../my_adapters</adapters_dir>
    -->
    <adapters_dir>../{{ include "lightstreamer.adapters.adaptersDir" . }}</adapters_dir>

    <!-- Optional. If Y, enables the $propname syntax on the "adapters.xml"
         files. It is the same variable-expansion feature available on this file.
         See the comment in this file's header for the full description of the
         feature, where the optional "env_prefix" attribute here takes the place
         of the <env_prefix> element cited there (note that setting an empty
         attribute value corresponds to not setting the attribute at all).
         Default: N -->
    <enable_expansion_for_adapters_config env_prefix="env.">Y</enable_expansion_for_adapters_config>

    <!-- Optional. Path of the file system directory that contains the Java
         classes and JAR files shared by the Adapters; they must be placed
         under the "classes" and "lib" subdirectories, respectively.
         The path is relative to the conf directory.
         Default: ../shared -->
    <!--
    <shared_dir>../my_shared</shared_dir>
    -->

<!--
  ==========================
  PUSH SESSION CONFIGURATION
  ==========================
-->
{{- with required "pushSession must be set" .Values.pushSession }}
    <!-- Optional and cumulative. If used, defines one or multiple alternative
         url paths for all requests related to the streaming services, which
         will be composed by the specified prefix followed by /lightstreamer.
         Then it will be possible to instruct the Unified Client SDKs to use
         an alternative path by adding its prefix to the supplied Server address.
         The specified path prefixes must be absolute.
         Note that, regardless of this setting, the standard path, which is
         /lightstreamer, is always active.
         By supporting dedicated paths, it becomes possible to address different
         Server installations with the same hostname, by instructing an
         intermediate proxy to forward each client request to the proper place
         based on the prefix, even if the prefix is not stripped off by the proxy.
         However, this support does not apply to the Internal Web Server
         and to the Monitoring Dashboard. -->
    {{- if .serviceUrlPrefixes }}
      {{- range .serviceUrlPrefixes }}
    <service_url_prefix>{{ . }}</service_url_prefix>
      {{- end }}
    {{- else }}
    <!--
    <service_url_prefix>/server1</service_url_prefix>
    -->
    <!--
    <service_url_prefix>/server1ws</service_url_prefix>
    -->
    {{- end }}

    <!-- Mandatory. Maximum size of HTTP streaming responses; when the maximum size is
         reached, the connection is closed but the session remains active and
         the Client can continue listening to the item update events by binding
         the session to another connection.
         This setting is also used as the maximum length allowed for poll
         responses; if more data were available, they would be kept for the next
         poll request.
         The Setting is not used for streaming responses over WebSockets.
         The optimal content-length for web clients (i.e. browser user agents)
         should not be too high, in order to reduce the maximum allocated memory
         on the client side. Also note that some browsers, in case of a very
         high content-length, may reduce streaming capabilities (noticed with
         IE8 and 4GB).
         This setting can be overridden by the Clients (some LS client libraries
         actually set their own default).
         The lowest possible value for the content-length is decided by the Server,
         so as to allow the connection to send a minimal amount of data. -->
    <content_length>
    {{- with .contentLength }}

        <!-- Mandatory for this block. Define the maximum size of HTTP streaming
             responses (and the upper limit for polling responses). -->
        <default>{{ int (required "pushSession.contentLength.default must be set" .default) }}</default>

        <!-- Optional and cumulative. Through the "value" attribute, defines the
             HTTP content-length to be used for stream/poll responses (overriding
             the setting in "default") when all the conditions specified through
             the subelements are met.
             Multiple occurrences of "special_case" are evaluated in sequence,
             until one is enabled. -->
        {{- if .specialCases }}
          {{- range .specialCases }}
        <special_case value={{ required "pushSession.specialCases[].value must be set" .value | quote }}>
            <!-- Mandatory and cumulative. Defines a condition on the user-agent
                 supplied with the request, which should include the string
                 specified through the "contains" attribute. -->
            {{- if empty .userAgentContains }}
               {{- fail "pushSession.specialCases[].userAgentContains must be set" }}
            {{- else }}
               {{- range .userAgentContains }}
            <user_agent contains={{ . | quote }} />
               {{- end }}
            {{- end }}
        </special_case>
          {{- end }}
        {{- else }}
        <!--
        <special_case value="100000">
        -->
            <!-- Mandatory and cumulative. Defines a condition on the user-agent
                 supplied with the request, which should include the string
                 specified through the "contains" attribute. -->
            <!--
            <user_agent contains="Symbian OS" />
            -->
        <!--
        </special_case>
        -->
        {{- end }}
    {{- end }}
    </content_length>

    <!-- Optional. Maximum lifetime allowed for single HTTP streaming responses;
         when this timeout expires, the connection is closed, though the
         session remains active and the Client can continue listening to the
         UpdateEvents by binding the session to another connection.
         Setting this timeout is not needed in normal cases; it is provided
         just in case any user agent or intermediary node turned out to be
         causing issues on very long-lasting HTTP responses.
         The Setting is not applied to polling responses and to streaming
         responses over WebSockets.
         If not specified, no limit is set; the streaming session duration
         will be limited only by the "content_length" setting and, at least,
         by the keep-alive message activity. -->
    {{- if (quote .maxStreamingMillis | empty) }}
    <!--
    <max_streaming_millis>480000</max_streaming_millis>
    -->
    {{- else }}
    <max_streaming_millis>{{ int .maxStreamingMillis }}</max_streaming_millis>
    {{- end }}

    <!-- Optional. Enabling the use of the "chunked" transfer encoding,
         as defined by the HTTP 1.1 specifications, for sending the response
         body on HTTP streaming connections. Can be one of the following:
         - Y: The "chunked" transfer encoding will be used anytime an
              HTTP 1.1 response is allowed, which will enforce the use
              of HTTP 1.1 (see "use_http_11").
         - N: Causes no transfer encoding (that is, the "identity" transfer
              encoding) to be used for all kinds of responses.
         - AUTO: The "chunked" transfer encoding will be used only when
                 an HTTP 1.1 response is being sent (see "use_http_11").
         Though with "chunked" transfer encoding the content-length header
         is not needed on the HTTP response header, configuring a content
         length for the Server is still mandatory and the setting is obeyed
         in order to put a limit to the response length.
         Default: Y. -->
    <!--
    <use_chunked_encoding>Y</use_chunked_encoding>
    -->

    <!-- Optional. Enabling the use of the "gzip" content encoding,
         as defined by the HTTP 1.1 specifications, for sending the resource
         contents on HTTP responses; compression is currently not supported
         for responses over WebSockets. Can be one of the following:
         - Y: Gzip compression will be used anytime an HTTP 1.1 response
              is allowed (for streaming responses, the "chunked" transfer
              encoding should also be allowed), provided that the client has
              declared to accept it through the proper http request headers.
         - N: Causes no specific content encoding to be applied for all kinds
              of contents.
         - AUTO: Gzip compression will not be used, unless using it is
                 recommended in order to handle special cases (and provided
                 that all the conditions for compression are met; see case
                 Y above).
         Streaming responses are compressed incrementally.
         The use of compression may relieve the network level at the expense
         of the Server performance. Note that bandwidth control and output
         statistics are still based on the non-compressed content.
         Default: AUTO. -->
    {{- if .useCompression}}
      {{- if not (has .useCompression (list "Y" "N" "AUTO")) }}
        {{- fail "pushSession.useCompression must be one of: \"Y\", \"N\", \"AUTO\"" }}
      {{- end }}
    <use_compression>{{ .useCompression }}</use_compression>
    {{- else }}
    <!--
    <use_compression>N</use_compression>
    -->
    {{- end }}

    <!-- Optional. Size of the response body below which compression is not
         applied, regardless of the "use_compression" setting, as we guess
         that no benefit would come. It is not applied to streaming responses,
         which are compressed incrementally.
         Default: 1024 bytes. -->
    {{- if (quote .compressionThreshold | empty) }}
    <!--
    <compression_threshold>0</compression_threshold>
    -->
    {{- else }}
    <compression_threshold>{{ int .compressionThreshold }}</compression_threshold>
    {{- end }}

    <!-- Optional. Configuration of the content-type to be specified in the
         response headers when answering to session requests issued by native
         client libraries and custom clients.
         Can be one of the following:
         - Y: the server will specify the text/enriched content-type. This setting
         might be preferable when communicating over certain service providers
         that may otherwise buffer streaming connections.
         - N: the server will specify the text/plain content-type.
         Default: Y. -->
    {{- if (quote .enableEnrichedContentType | empty) }}
    <!--
    <use_enriched_content_type>Y</use_enriched_content_type>
    -->
    {{- else }}
    <use_enriched_content_type>{{ .enableEnrichedContentType | ternary "Y" "N" }}</use_enriched_content_type>
    {{- end }}

    <!-- Optional. Maximum size for any ItemEventBuffer. It applies to RAW and
         COMMAND mode and to any other case of unfiltered subscription.
         For filtered subscriptions, it poses an upper limit on the maximum
         buffer size that can be granted by the Metadata Adapter or requested
         through the subscription parameters. Similarly, it poses an upper
         limit to the length of the snapshot that can be sent in DISTINCT mode,
         regardless of the value returned by getDistinctSnapshotLength.
         See the General Concepts document for details on when these buffers
         are used. An excessive use of these buffers may give rise to a
         significant memory footprint; to prevent this, a lower size limit
         can be set.
         Note that the buffer size setting refers to the number of update
         events that can be kept in the buffer, hence the consequent memory
         usage also depends on the size of the values carried by the enqueued
         updates.
         As lost updates for unfiltered subscriptions are logged on the
         LightstreamerLogger.pump logger at INFO level, if a low buffer size
         limit is set, it is advisable also setting this logger at WARN level.
         Aggregate statistics on lost updates are also provided by the JMX
         interface (if available) and by the Internal Monitor. -->
    {{- if (quote .maxBufferSize | empty) }}
    <!--
    <max_buffer_size>1000</max_buffer_size>
    -->
    {{- else }}
    <max_buffer_size>{{ int .maxBufferSize }}</max_buffer_size>
    {{- end }}

    <!-- Mandatory. Longest time a disconnected session can be kept alive
         while waiting for the Client to rebind such session to another
         connection, in order to make up for client or network latencies.
         Note that the wait is not performed when the session is being closed
         because of an explicit disconnection by the client.
         If the client has requested an inactivity check on a streaming
         connection, the same timeout is also started when no control request
         (or reverse heartbeat) has been received for the agreed time (again,
         in order to make up for client or network latencies). If it expires,
         the current streaming connection will be ended and the client
         will be requested to rebind to the session (which triggers the
         previous case). -->
    <session_timeout_millis>{{ int (required "pushSession.sessionTimeoutMillis must be set" .sessionTimeoutMillis) }}</session_timeout_millis>

    <!-- Optional. Longest time a session can be kept alive, after the
         interruption of a connection at network level, waiting for the Client
         to attempt a recovery. Since a disconnection may affect the Client
         without affecting the Server, this also instructs the Server to keep
         track of the events already sent for this time duration, to support
         unexpected recovery requests.
         The client should try a recovery request immediately after detecting
         the interruption; but, the request may come later when, for instance,
         - there is a network outage of a few seconds and the client must retry,
         - the client detects the interruption because of the stalled timeout.
         Hence, the optimal value should be tuned according with client-side
         timeouts to ensure the better coverage of cases.
         Note that recovery is available only for some client versions; if any
         other version were involved, the session would be closed immediately.
         A 0 value also prevents any accumulation of memory.
         Default: 0. -->
    {{- if (quote .sessionRecoveryMillis | empty) }}
    <!--
    <session_recovery_millis>13000</session_recovery_millis>
    -->
    {{- else }}
    <session_recovery_millis>{{ int .sessionRecoveryMillis }}</session_recovery_millis>
    {{- end }}

    <!-- Optional. Maximum number of bytes of streaming data, already sent
         or being sent to the Client, that should be kept, in order to allow
         the Client to recover the session, in case a network issue should
         interrupt the streaming connection and prevent the client from
         receiving the latest packets.
         Note that recovery is available only for some client versions;
         if any other version were involved, no data would be kept.
         A 0 value also prevents any accumulation of memory.
         Default: the value configured for "sendbuf". -->
    {{- if (quote .maxRecoveryLength | empty) }}
    <!--
    <max_recovery_length>5000</max_recovery_length>
    -->
    {{- else }}
    <max_recovery_length>{{ int .maxRecoveryLength }}</max_recovery_length>
    {{- end }}

    <!-- Optional. Maximum size supported for keeping a polling response,
         already sent or being sent to the Client, in order to allow the Client
         to recover the session, in case a network issue should interrupt
         the polling connection and prevent the client from receiving the
         latest response.
         Note that recovery is available only for some client versions;
         if any other version were involved, no data would be kept.
         A 0 value also prevents any accumulation of memory. On the other
         hand, a value of -1 relieves any limit.
         Default: -1. -->
    {{- if (quote .maxRecoveryPollLength | empty) }}
    <!--
    <max_recovery_poll_length>0</max_recovery_poll_length>
    -->
    {{- else }}
    <max_recovery_poll_length>{{ int .maxRecoveryPollLength }}</max_recovery_poll_length>
    {{- end }}

    <!-- Optional. Longest time the subscriptions currently in place on a
         session can be kept active after the session has been closed,
         in order to prevent unsubscriptions from the Data Adapter that would
         be immediately followed by new subscriptions in case the client
         were just refreshing the page.
         As a consequence of this wait, some items might temporarily appear
         as being subscribed to, even if no session were using them.
         If a session is closed after being kept active because of the
         "session_timeout_millis" or "session_recovery_millis" setting,
         the accomplished wait is considered as valid also for the
         subscription wait purpose.
         Default: the time configured for "session_timeout_millis". -->
    {{- if (quote .subscriptionTimeoutMillis | empty) }}
    <!--
    <subscription_timeout_millis>5000</subscription_timeout_millis>
    -->
    {{- else }}
    <subscription_timeout_millis>{{ int .subscriptionTimeoutMillis }}</subscription_timeout_millis>
    {{- end }}

    <!-- Optional. Timeout used to ensure the proper ordering of client-sent
         messages, within the specified message sequence, before sending them
         to the Metadata Adapter through notifyUserMessage.
         In case a client request is late or does not reach the Server,
         the next request may be delayed until this timeout expires, while
         waiting for the late request to be received; then, the next request
         is forwarded and the missing one is discarded with no further recovery
         and the client application is notified.
         Message ordering does not concern the old synchronous interfaces for
         message submission. Ordering and delaying also does not apply to the
         special "UNORDERED_MESSAGES" sequence, although, in this case,
         discarding of late messages is still possible, in order to ensure
         that the client eventually gets a notification.
         A high timeout (as the default one) reduces the discarded messages,
         by allowing the client library to reissue requests that have got lost.
         A low timeout reduces the delays of subsequent messages in case
         a request has got lost and can be used if message dropping is
         acceptable.
         Default: 30000. -->
    {{- if (quote .missingMessageTimeoutMillis | empty) }}
    <!--
    <missing_message_timeout_millis>1000</missing_message_timeout_millis>
    -->
    {{- else }}
    <missing_message_timeout_millis>{{ int .missingMessageTimeoutMillis }}</missing_message_timeout_millis>
    {{- end }}

    <!-- Optional. Configuration of the policy adopted for the delivery of
         updates to the clients. Can be one of the following:
         - Y: The Server is allowed to perform "delta delivery"; it will send
              special notifications to notify the clients of values that are
              unchanged with respect to the previous update for the same item;
              moreover, if supported by the client SDK, it may send the
              difference between previous and new value for updates which
              involve a small change.
         - N: The Server always sends to the clients the actual values in the
              updates; note that any missing field in an update from the Data
              Adapter for an item in MERGE mode is just a shortcut for an
              unchanged value, hence the old value will be resent anyway.
         Adopting the "delta delivery" is in general more efficient than always
         sending the values. On the other hand, checking for unchanged values
         and/or evaluating the difference between values puts heavier memory
         and processing requirements on the Server.
         In case "delta delivery" is adopted, the burden of recalling the
         previous values is left to the clients.
         This holds for clients based on the "SDK for Generic Client
         Development".
         This also holds for clients based on some old versions of the provided
         SDK libraries, which just forward the special unchanged notifications
         through the API interface. Old versions of the .NET, Java SE (but for
         the ls_proxy interface layer), Native Flex and Java ME libraries share
         this behavior.
         Forcing a redundant delivery would simplify the client code in all
         the above cases.
         Default: Y. -->
    {{- if (quote .enableDeltaDelivery | empty) }}
    <!--
    <delta_delivery>N</delta_delivery>
    -->
    {{- else }}
    <delta_delivery>{{ .enableDeltaDelivery | ternary "Y" "N" }}</delta_delivery>
    {{- end }}

    <!-- Optional. List of algorithms to be tried by default to perform the
         "delta delivery" of changed fields in terms of difference between
         previous and new value. This list is applied only on fields of items
         for which no specific information is provided by the Data Adapter.
         For each value to be sent to some client, the algorithms are tried
         in the order specified by this list, until one is found which is
         compatible with both client capabilities and the involved values.
         The element should be expressed as a comma-separated list of
         algorithm names. Available names are:
         - jsonpatch
             computes the difference in JSON Patch format, provided that the
             values are valid JSON representations;
         - diff_match_patch
             computes the difference with Google's "diff-match-patch" algorithm
             (the result is then serialized to the custom "TLCP-diff" format).
         Note that trying "diff" algorithms on unsuitable data may waste
         resources. For this reason, the default algorithm list is empty,
         which means that no algorithm is ever tried by default. The best
         way to enforce algorithms is to do that on a field-by-field basis
         through the Data Adapter interface.
         Default: an empty list. -->
    {{- if .defaultDiffOrders }}
      {{- range $key, $diff := .defaultDiffOrders }}
        {{- if not (has $diff (list "jsonpatch" "diff_match_patch") )}}
          {{ printf "pushSession.defaultDiffOrders[%d] must be one of: \"jsonpatch\",\"diff_match_patch\"" $key | fail }}
        {{- end }}
      {{- end }}
    <default_diff_order>{{ join "," .defaultDiffOrders }}</default_diff_order>
    {{- else }}
    <!--
    <default_diff_order>jsonpatch</default_diff_order>
    -->
    {{- end }}

    <!-- Optional. Minimum length among two update values (old and new) which
         enables the use of the JSON Patch format to express the new value as
         the difference with respect to the old one, when this is possible.
         If any value is shorter, it will be assumed that the computation
         of the difference in this way will yield no benefit.
         The special value "none" is also available. In this case, when the
         computation of the difference in JSON Patch format is possible,
         it will always be used, regardless of efficiency reasons. This can
         be leveraged in special application scenarios, when the clients
         require to directly retrieve the updates in the form of JSON Patch
         differences.
         Default: 50. -->
    {{- if (quote .jsonPatchMinLength | empty) }}
    <!--
    <jsonpatch_min_length>500</jsonpatch_min_length>
    -->
    {{- else }}
    <jsonpatch_min_length>{{ int .jsonPatchMinLength }}</jsonpatch_min_length>
    {{- end }}

    <!-- Optional. Configuration of the update management for items subscribed to
         in COMMAND mode with unfiltered dispatching, with regard to updates
         pertaining to different keys.
         Can be one of the following:
         - Y: the order in which updates are received from the Data Adapter is
              preserved when sending updates to the clients; in this case, any
              frequency limits imposed by license limitations are applied
              to the whole item and may result in a very slow update flow;
              this was the default behavior before Server 4.0 version.
         - N: provided that no updates are lost, the Server can send enqueued
              updates in whichever order; it must only ensure that, for updates
              pertaining to the same key, the order in which updates are received
              from the Data Adapter is preserved; in this case, any frequency
              limits imposed by license limitations are applied for each
              key independently.
         No item-level choice is possible. However, setting this flag as Y
         allows for backward compatibility to versions before 4.0, if needed.
         Default: N. -->
    {{- if (quote .preserveUnfilteredCommandOrdering | empty) }}
    <!--
    <preserve_unfiltered_command_ordering>Y</preserve_unfiltered_command_ordering>
    -->
    {{- else }}
    <preserve_unfiltered_command_ordering>{{ .preserveUnfilteredCommandOrdering | ternary "Y" "N" }}</preserve_unfiltered_command_ordering>
    {{- end }}

    <!--
         Optional. Policy to be adopted for the handling of session-related
         internal buffers.
         Can be one of the following:
         - Y: Internal buffers used for composing and sending updates are kept
              among session-related data throughout the life of each session;
              this speeds up update management.
         - N: Internal buffers used for composing and sending updates are
              allocated and deallocated on demand; this minimizes the
              requirements in terms of permanent per-session memory and may be
              needed in order to handle a very high number of concurrent
              sessions, provided that the per-session update activity is low.
         - AUTO: The current setting of "delta_delivery" is used; in fact,
                 setting "delta_delivery" as N may denote the need for
                 reducing permanent per-session memory.
         Default: AUTO. -->
    {{- if (quote .reusePumpBuffers | empty) }}
    <!--
    <reuse_pump_buffers>Y</reuse_pump_buffers>
    -->
    {{- else }}
    <reuse_pump_buffers>{{ .reusePumpBuffers }}</reuse_pump_buffers>
    {{- end }}

    <!-- STREAMING MODE -->

    <!-- Optional. Size to be set for the socket TCP send buffer in case of
         streaming connections.
         The ideal setting should be a compromise between throughput, data aging,
         and memory usage. A large value may increase throughput, particularly
         in sessions with a high update activity and a high roundtrip time;
         however, in case of sudden network congestion, the queue of outbound
         updates would need longer to be cleared and these updates would reach
         the client with significant delays. On the other hand, with a small
         buffer, in case of sudden network congestion, most of the ready updates
         would not be enqueued in the TCP send buffer, but inside the Server,
         where there would be an opportunity to conflate them with newer updates.
         The main problem with a small buffer is when a single update is very
         big, or a big snapshot has to be sent, and the roundtrip time is high;
         in this case, the delivery could be slow. However, the Server tries
         to detect these cases and temporarily enlarge the buffer.
         Hence, the factory setting is very small and it is comparable with
         a typical packet size. There shouldn't be any need for an even smaller
         value; also note that the system may force a minimum size.
         Higher values should make sense only if the expected throughput is
         high and responsive updates are desired.
         Default: 1600. -->
    {{- if (quote .sendbuf | empty) }}
    <!--
    <sendbuf>5000</sendbuf>
    -->
    {{- else }}
    <sendbuf>{{ int .sendbuf }}</sendbuf>
    {{- end }}

    <!-- Optional. Longest delay that the Server is allowed to apply to
         outgoing updates in order to collect more updates in the same
         packet. This value sets a trade-off between Server scalability
         and maximum data latency. It also sets an upper bound to the
         maximum update frequency for items not subscribed with unlimited
         or unfiltered frequency.
         Default: 0. -->
    {{- if (quote .maxDelayMillis | empty) }}
    <!--
    <max_delay_millis>30</max_delay_millis>
     -->
    {{- else }}
    <max_delay_millis>{{ int .maxDelayMillis }}</max_delay_millis>
    {{- end }}

    <!-- Mandatory. Longest write inactivity time allowed on the socket.
         If no updates have been sent after this time, then a small
         keep-alive message is sent.
         Note that the Server also tries other types of checks of the
         availability of current sockets, which don't involve writing data
         to the sockets.
         This setting can be overridden by the Client.
         The optional "randomize" attribute, when set to Y, causes keepalives
         immediately following a data event to be sent after a random, shorter
         interval (possibly even shorter than the "min_keepalive_millis"
         setting). This can be useful if many sessions subscribe to the same
         items and updates for these items are rare, to avoid that also the
         keepalives for these sessions occur at the same times. -->
    {{- if empty .defaultKeepaliveMillis }}
      {{- fail "pushSession.defaultKeepaliveMillis must be set" }}
    {{- else }}
      {{- with .defaultKeepaliveMillis }}
    <default_keepalive_millis{{ if not (quote .randomize | empty) }} randomize={{ .randomize | ternary "Y" "N" | quote }}{{- end }}>{{ int (required "pushSession.defaultKeepaliveMillis.value must be set" .value) }}</default_keepalive_millis>
      {{- end }}
    {{- end }}

    <!-- Mandatory. Lower bound to the keep-alive time requested by a Client.
         Must be lower than the "default_keepalive_millis" setting. -->
    <min_keepalive_millis>{{ int (required "pushSession.minKeepaliveMillis must be set" .minKeepaliveMillis) }}</min_keepalive_millis>

    <!-- Mandatory. Upper bound to the keep-alive time requested by a Client.
         Must be greater than the "default_keepalive_millis" setting. -->
    <max_keepalive_millis>{{ int (required "pushSession.maxKeepaliveMillis must be set" .maxKeepaliveMillis) }}</max_keepalive_millis>

    <!-- SMART-POLLING MODE -->

    <!-- Mandatory. Longest time a client is allowed to wait, after receiving
         a poll answer, before issuing the next poll request. Note that,
         on exit from a poll request, a session has to be kept active, while
         waiting for the next poll request.
         The session keeping time has to be requested by the Client within
         a poll request, but the Server, within the response, can notify a
         shorter time, if limited by this setting.
         The session keeping time for polling may cumulate with the keeping
         time upon disconnection, as set by "session_timeout_millis". -->
    <max_polling_millis>{{ int (required "pushSession.maxPollingMillis must be set" .maxPollingMillis) }}</max_polling_millis>

    <!-- Mandatory. Longest inactivity time allowed on the socket while waiting
         for updates to be sent to the client through the response to an
         asynchronous poll request.
         If this time elapses, the request is answered with no data, but the
         client can still rebind to the session with a new poll request.
         A shorter inactivity time limit can be requested by the client.
         The optional "randomize" attribute, when set to Y, causes polls
         immediately following a data event to wait for a random, shorter
         inactivity time. This can be useful if many sessions subscribe to
         the same items and updates for these items are rare, to avoid that
         also the following polls for these sessions occur at the same times. -->
    {{- if empty .maxIdleMillis }}
      {{- fail "pushSession.maxIdleMillis must be set" }}
    {{- else }}
      {{- with .maxIdleMillis }}
    <max_idle_millis{{ if not (quote .randomize | empty) }} randomize={{ .randomize | ternary "Y" "N" | quote }}{{- end }}>{{ int (required "pushSession.maxIdle.value must be set" .value) }}</max_idle_millis>
      {{- end }}
    {{- end }}

    <!-- Optional. Shortest time allowed between consecutive polls on a
         session. If the client issues a new polling request and less than
         this time has elapsed since the STARTING of the previous polling
         request, the polling connection is kept waiting until this time
         has elapsed.
         In fact, neither a "min_polling_millis" nor a "min_idle_millis"
         setting are provided, hence a client is allowed to request 0 for both,
         so that the real polling frequency will only be determined by
         roundtrip times.
         However, in order to avoid that a similar case causes too much load
         on the Server, this setting can be used as a protection, to limit the
         polling frequency.
         Default: 0. -->
    {{- if (quote .minInterPollMillis | empty) }}
    <!--
    <min_interpoll_millis>1000</min_interpoll_millis>
    -->
    {{- else }}
    <min_interpoll_millis>{{ int .minInterPollMillis }}</min_interpoll_millis>
    {{- end }}
{{- end }}

<!--
  ======================================
  MOBILE PUSH NOTIFICATION CONFIGURATION
  ======================================
-->

    <!-- Optional. Configure the Mobile Push Notification (MPN) module.
         This module is able to receive updates
         from an item subscription on behalf of a user, and forward them to a
         mobile push notification service, such as Apple's APNs or Google's FCM.
         If not defined, the MPN module will not start in any case, and all
         requests related to mobile push notifications will be rejected.
         Mobile Push Notification support is an optional feature, available
         depending on Edition and License Type. To know what features are enabled
         by your license, please see the License tab of the Monitoring Dashboard
         (by default, available at /dashboard). -->
    <mpn>
{{- if and .Values.mpn (.Values.mpn).enabled }}
{{- with .Values.mpn }}

        <!-- Optional. MPN module master switch. If N, the MPN module will
             not start in any case, and all requests related to mobile push
             notifications will be rejected.
             Can be one of the following:
             - Y: enable MPN module;
             - N: disable MPN module.
             Note that, by enabling the module, the handling of the special
             URL configured by <apple_web_service_path> is also enabled.
             Default: N. -->
        <enabled>{{ .enabled | default false | ternary "Y" "N"}}</enabled>

        <!-- Optional. Specifies the root path of the web service URL to be
             invoked by the client application on a Safari browser to enable
             Web Push Notifications. Currently, the latter is achieved by invoking
             the window.safari.pushNotification.requestPermission method.
             Only when the MPN module is enabled, the specified path
             is reserved and the Server identifies these
             special requests and processes them as required. Setting the internal
             web server enabling setting as "Y" is not needed for this;
             note that if the internal web server is enabled, the processing
             of this path is different from the processing of the other URLs.
             Default: /apple_web_service. -->
  {{- if .appleWebServicePath }}
        <apple_web_service_path>{{ .appleWebServicePath }}</apple_web_service_path>
  {{- else }}
        <!--
        <apple_web_service_path>/applewebservice</apple_web_service_path>
        -->
  {{- end }}

        <!-- Optional. Specifies the name of the built-in data adapter that client
             SDKs may subscribe to to obtain the current status of MPN devices
             and subscriptions. This data adapter is automatically added
             to all configured Adapter Sets in an MPN-enabled Server.
             Default: MPN_INTERNAL_DATA_ADAPTER. -->
  {{- if .internalDataAdapter }}
        <internal_data_adapter>MPN_ADAPTER</internal_data_adapter>
  {{- else}}
        <!--
        <internal_data_adapter>MPN_ADAPTER</internal_data_adapter>
        -->
  {{- end }}

        <!-- Mandatory if <enabled> is Y. Hibernate configuration file path.
             The MPN module uses an Hibernate-mapped database to make the
             list of devices and subscriptions persistent and let different
             module instances communicate.
             The file path is relative to the conf directory. -->
        <hibernate_config>./mpn/hibernate.cfg.xml</hibernate_config>

        <!-- Optional. Timeout for MPN request processing. As each MPN request
             interacts with the database, a timeout is applied so that a
             disconnected database will not result in a hang client. If a
             timeout occurs during a request processing, the client receives
             a specific error.
             Default: 15000. -->
  {{- if not (quote .requestTimeoutMillis | empty) }}
        <request_timeout_millis>{{ int .requestTimeoutMillis }}</request_timeout_millis>
  {{- else }}
        <!--
        <request_timeout_millis>15000</request_timeout_millis>
        -->
  {{- end }}

        <!-- Optional. Interval between health checks on the database.
             During this health check, a number of tasks are carried out:
             takeover of dead module instances, stop and restart of
             subscriptions updated by other module instances, and
             deletion of abandoned subscriptions.
             Default: 5000. -->

  {{- if not (quote .moduleCheckPeriodMillis | empty) }}
        <module_check_period_millis>{{ int .moduleCheckPeriodMillis }}</module_check_period_millis>
  {{- else }}
        <!--
        <module_check_period_millis>5000</module_check_period_millis>
        -->
  {{- end }}

        <!-- Optional. Timeout for a health check of other modules. If a module
             fails to do its health check for this period of time, other module
             instances may consider it dead and takeover its devices and
             subscriptions. Hence, it must be longer than <module_check_period_millis>
             and it should be long enough to avoid false positives.
             In case a cluster is in place, the timeout should be longer than all
             values of <module_check_period_millis> configured for the various
             instances in the cluster.
             Default: 30000. -->
  {{- if not (quote .moduleTimeoutMillis | empty) }}
        <module_timeout_millis>{{ int .moduleTimeoutMillis }}</module_timeout_millis>
  {{- else }}
        <!--
        <module_timeout_millis>30000</module_timeout_millis>
        -->
  {{- end }}


        <!-- Optional. Enabling of the startup of the module upon Server startup.
             If module startup is prevented, or not yet completed, or completed
             unsuccessfully, the module is inactive. This means that no subscription
             processing is performed and any client MPN requests are refused.
             Can be one of the following:
             - Y: A module startup will be initiated immediately at Server startup.
                  If the "max_delay" attribute is missing or valued as -1, the
                  Server startup will be blocked until module startup completion;
                  if the module startup fails, the Server startup will fail
                  in turn.
                  Otherwise, the Server startup will be blocked only up to the
                  specified delay. If the delay expires, the Server may start with
                  the module temporarily inactive; moreover, if the module startup
                  eventually fails, the Server will keep running with an inactive
                  module.
             - N: The Server will start with an inactive module.
                  The "max_delay" attribute is ignored.
             Note: the initialization of a new module (as well as the deactivation
             of the current module), can be requested at any time through the
             JMX interface (full JMX features is an optional feature, available
             depending on Edition and License Type).
             Default: Y. -->
  {{- with .activationOnStartUp }}
    {{- if (not (quote .enabled | empty)) }}
       <activate_on_startup{{ if not (quote .maxDelayMillis | empty) }} max_delay={{ .maxDelayMillis | quote }}{{ end }}>{{ .enabled | ternary "Y" "N" }}</activate_on_startup>
    {{- else }}
       <activate_on_startup{{ if not (quote .maxDelayMillis | empty) }} max_delay={{ .maxDelayMillis | quote }}{{ end }}>Y</activate_on_startup>
    {{- end }}
  {{- else }}
        <!--
        <activate_on_startup max_delay="-1">Y</activate_on_startup>
        -->
  {{- end }}

        <!-- Optional. Enabling of the automatic initialization of a new module
             upon health check failure.
             Can be one of the following:
             - Y: Upon health check failure, the failed module will become inactive
                  and the initialization of a new module will be started; if
                  unsuccessful, the Server will keep running with an inactive module.
             - N: Upon health check failure, the failed module will become inactive
                  and the Server will keep running with an inactive module.
             See <activate_on_startup> for notes on inactive modules.
             Default: Y. -->
  {{- if not (quote .enableModuleRecovery | empty) }}
        <module_recovery_enabled>{{ .enableModuleRecovery | ternary "Y" "N" }}</module_recovery_enabled>
  {{- else }}
        <!--
        <module_recovery_enabled>N</module_recovery_enabled>
        -->
  {{- end }}

        <!-- Optional. Timeout after which an inactive device is
             considered abandoned and is permanently deleted. A device is
             considered inactive if it is suspended (i.e. its device token has
             been rejected by the MPN service) or it has no active subscriptions.
             A suspended device may be resumed with a token change (typically,
             client libraries handle this situation automatically).
             Default: 10080 (7 days). -->
  {{- if not (quote .deviceInactivityTimeoutMinutes | empty) }}
        <device_inactivity_timeout_minutes>{{ int .deviceInactivityTimeoutMinutes }}</device_inactivity_timeout_minutes>
  {{- else }}
        <!--
        <device_inactivity_timeout_minutes>10080</device_inactivity_timeout_minutes>
        -->
  {{- end }}

        <!-- Optional. Periodicity of the device garbage collector. Once every
             this number of minutes, devices that have been inactive for more than
             <device_inactivity_timeout_minutes> are permanently deleted.
             Default: 60 (1 hour). -->
  {{- if not (quote .collectorPeriodMinutes | empty) }}
        <device_collector_period_minutes>{{ int .collectorPeriodMinutes }}</device_collector_period_minutes>
  {{- else }}
        <!--
        <collector_period_minutes>60</collector_period_minutes>
        -->
  {{- end }}

        <!-- Optional. Sizes of request processor's ("MPN EXECUTOR") thread pool.
             The <max_size> parameter specifies the maximum number of threads
             the pool may use, while <max_free> specifies the maximum number
             of idle threads the pool may have.
             The request processor is devoted to process incoming MPN requests,
             such as subscription activations and deactivations. These requests
             access the database and may be subject to blocking in case of
             database disconnection.
             Default for <max_size>: 10 threads.
             Default for <max_free>: 0, meaning the pool will not consume
             resources when idle. -->
  {{- with .executorPool }}
        <executor_pool>
    {{- if not (quote .maxSize | empty) }}
            <max_size>{{ int .maxSize }}</max_size>
    {{- else }}
            <!-- <max_size>10</max_size> -->
    {{- end }}
    {{- if not (quote .maxFree | empty) }}
            <max_free>{{ int .maxFree }}</max_free>
    {{- else }}
            <!-- <max_free>0</max_free> -->
    {{- end }}
        </executor_pool>
  {{- else }}
        <!--
        <executor_pool>
            <max_size>10</max_size>
            <max_free>0</max_free>
        </executor_pool>
        -->
  {{- end }}

        <!-- Optional. Requests the creation of a specific thread pool,
             "MPN DEVICE HANDLER", specifically dedicated to the handling
             of the internal sessions that are used to receive subscription
             updates to be sent to the devices. In particular, during the startup
             phase, all the subscriptions needed to handle all the active push
             notifications are performed in a burst.
             If defined, the pool should be sized wide enough to support this
             burst of activity. The <max_size> parameter specifies the maximum
             number of threads the pool may use (default: 100 threads),
             while <max_free> specifies the maximum number of idle threads
             the pool may have (default: 0, meaning the pool will not consume
             resources when idle).
             If the pool is not defined, each "subscribe" call will be managed
             by the thread pool associated with the involved Data Adapter,
             similarly to ordinary sessions. -->
  {{- with .deviceHandlerPool }}
        <device_handler_pool>
    {{- if not (quote .maxSize | empty) }}
            <max_size>{{ int .maxSize }}</max_size>
    {{- else }}
            <!-- <max_size>10</max_size> -->
    {{- end }}
    {{- if not (quote .maxFree | empty) }}
            <max_free>{{ int .maxFree }}</max_free>
    {{- else }}
            <!-- <max_free>0</max_free> -->
    {{- end }}
        </device_handler_pool>
  {{- else }}
        <!--
        <device_handler_pool>
            <max_size>100</max_size>
            <max_free>0</max_free>
        </device_handler_pool>
        -->
  {{- end }}

        <!-- Optional. Size of the notifiers' "MPN XXX NOTIFIER" internal
             thread pool, which is devoted to composing the notifications
             payload, sending them to the notification service and processing
             the response. This task does not include blocking operations;
             however, on multiprocessor machines, allocating multiple threads
             for this task may be beneficial.
             Default: The number of available total cores, as detected by the
             JVM. -->
  {{- if not (quote .notifierPoolSize | empty) }}
        <notifier_pool_size>{{ int .notifierPoolSize }}</notifier_pool_size>
  {{- else }}
        <!--
        <notifier_pool_size>10</notifier_pool_size>
        -->
  {{- end }}

        <!-- Optional. Size of the "MPN PUMP" internal thread pool, which is
             devoted to integrating the update events pertaining to each MPN
             device and to creating the update commands that become push
             notifications, whenever needed. This task does not include
             blocking operations; however, on multiprocessor machines,
             allocating multiple threads for this task may be beneficial.
             Default: The number of available total cores, as detected by the
             JVM. -->
  {{- if not (quote .mpnPumpPoolSize | empty) }}
        <pump_pool_size>{{ int .mpnPumpPoolSize }}</pump_pool_size>
  {{- else }}
        <!--
        <mpn_pump_pool_size>10</mpn_pump_pool_size>
        -->
  {{- end }}

        <!-- Optional. Number of threads used to parallelize the implementation
             of the internal MPN timers.
             This task does not include blocking operations, but its
             computation may be heavy under high update activity; hence, on
             multiprocessor machines, allocating multiple threads for this task
             may be beneficial.
             Default: 1. -->
  {{- if not (quote .mpnTimerPoolSize | empty) }}
        <mpn_timer_pool_size>{{ int .mpnTimerPoolSize }}</mpn_timer_pool_size>
  {{- else }}
        <!--
        <mpn_timer_pool_size>2</mpn_timer_pool_size>
        -->
  {{- end }}

        <!-- Mandatory if <enabled> is Y. Specifies what to do in case of
             database failure.
             A number of internal operations are bound to the success of a
             database update. In those (hopefully) rare situations when the
             database is not available, the MPN module must know what to do:
             if it is better to abort the operation entirely (thus risking to
             lose the event) or better to continue anyway (thus risking to
             duplicate the event).
             A typical situation is the triggering of a subscription, e.g.:
             when the price of a stock raises above a threshold, the MPN module
             must both send the mobile push notification and mark the
             subscription as triggered on the database. If the database is not
             available, the MPN module may react by aborting the operation,
             i.e. no mobile push notification is sent, another one will be sent
             only when (and if) the price drops and then raises above the
             threshold again. Alternatively, it may react by continuing with
             the operation, i.e. the mobile push notification is sent anyway,
             but (since the database has not been updated) if the price drops
             and then raises again it may get sent twice.
             Specify:
             - "abort_operation" to abort the ongoing operation or
             - "continue_operation" to continue the ongoing operation. -->
  {{- if not (has .reactionOnDatabaseFailure (list "abort_operation" "continue_operation")) }}
    {{- fail "mpn.reactionOnDatabaseFailure must be one of: \"abort_operation\", \"continue_operation\"" }}
  {{- else }}
        <reaction_on_database_failure>{{ .reactionOnDatabaseFailure }}</reaction_on_database_failure>
  {{- end }}

        <!-- Optional. Path of the configuration file for Apple platforms notifier.
             The file path is relative to the conf directory. -->
        <apple_notifier_conf>./mpn/apple/apple_notifier_conf.xml</apple_notifier_conf>

        <!-- Optional. Path of the configuration file for Google platforms notifier.
             The file path is relative to the conf directory. -->
        <google_notifier_conf>./mpn/google/google_notifier_conf.xml</google_notifier_conf>

{{- end }}
{{- end }}
    </mpn>

<!--
  ========================
  WEB SERVER CONFIGURATION
  ========================
-->

{{- with .Values.webServer }}
    <!-- Optional. Path of an HTML page to be returned upon unexpected request
         URLs. This applies to URLs in reserved ranges that have no meaning.
         If the Internal web server is not enabled, this also applies to all
         non-reserved URLs; otherwise, nonexisting non-reserved URLs will get the
         HTTP 404 error as usual.
         The file content should be encoded with the iso-8859-1 charset.
         The file path is relative to the conf directory.
         Default: the proper page is provided by the Server. -->
  {{- with .errorPageRef }}
    <error_page>./error-page/{{ required "webServer.errorPageRef.key must be set" .key }}</error_page>
  {{- else }}
    <!--
    <error_page>./error-page/ErrorPage.html</error_page>
    -->
  {{- end }}


    <!-- Optional. Internal web server configuration.
         Note that some of the included settings may also apply to the
         Monitoring Dashboard pages, which are supplied through the internal
         web server. In particular, this holds for the <use_compression> and
         <compression_threshold> settings. Anyway, this does not hold for
         the <enabled> setting, as the Monitoring Dashboard accessibility
         is only configured through the <dashboard> block. -->
    <web_server>

        <!-- Optional. Enabling of the internal web server.
             Can be one of the following:
             - Y: the Server accepts requests for file resources;
             - N: the Server ignores requests for file resources.
             Default: N. -->
        <enabled>{{ .enabled | default false | ternary "Y" "N"}}</enabled>

        <!-- Optional. Path of the file system directory to be used
             by the internal web server as the root for URL path mapping.
             The path is relative to the conf directory.
             Note that the /lightstreamer URL path (as any alternative
             paths defined through <service_url_prefix>) is reserved,
             as well as the base URL path of the Monitoring Dashboard
             (see <dashboard_url_path> under the <dashboard> block);
             hence, subdirectories of the pages directory with conflicting
             names would be ignored.
             Default: ../pages -->
        {{- if .pagesDir }}
        <pages_dir>{{ .pagesDir }}</pages_dir>
        {{- else }}
        <!--
        <pages_dir>../my_pages</pages_dir>
        -->
        {{- end }}

        <!-- Optional. Caching time, in minutes, to be allowed to the browser
             (through the "expires" HTTP header) for all the resources supplied
             by the internal web server.
             A zero value disables caching by the browser.
             Default: 0. -->
        {{- if (quote .persistencyMinutes | empty) }}
        <!--
        <persistency_minutes>1000000</persistency_minutes>
        -->
        {{- else }}
        <persistency_minutes>{{ .persistencyMinutes }}</persistency_minutes>
        {{- end }}

        <!-- Optional. Path of the MIME types configuration property file.
             The file path is relative to the conf directory.
             Default: ./mime_types.properties -->
        {{- if empty .mimeTypesConfig }}
        <!--
        <mime_types_config>./my_mime_types.properties</mime_types_config>
        -->
        {{- else }}
        <mime_types_config>{{ .mimeTypesConfig }}</mime_types_config>
        {{- end }}

        <!-- Optional. Path of an HTML page to be returned as the body upon
             a "404 Not Found" answer caused by the request of a nonexistent URL.
             The file content should be encoded with the iso-8859-1 charset.
             The file path is relative to the conf directory.
             Default: the proper page is provided by the Server. -->
        {{- if empty .notFoundPage }}
        <!--
        <notfound_page>./404Page.html</notfound_page>
        -->
        {{- else }}
        <notfound_page>{{ .notFoundPage }}</notfound_page>
        {{- end }}

        <!-- Optional. Use of the "gzip" content encoding, as defined by the
             HTTP 1.1 specifications, for sending the resource contents.
             It is specified for various cases through the included rules.
             Note that the use of compression for static pages would benefit
             from an internal cache of compressed pages. However, no cache is
             provided, as the internal web server is not meant for production use.
             Default: The "gzip" content encoding is never used. -->
        <use_compression>

            <!-- Optional. Use of the "gzip" content encoding.
                 Can be one of the following:
                 - Y: Gzip compression will be used anytime an HTTP 1.1 response
                      is allowed, provided that the client has declared to support it
                      through the proper http request headers.
                 - N: Causes no specific content encoding to be applied for all kinds
                      of contents.
                 Default: N. -->
            <default>N</default>

            <!-- Optional and cumulative. Through the "value" attribute, specifies
                 whether or not to use the "gzip" content encoding (overriding the
                 setting in "default") when all the conditions specified through
                 the subelements are met.
                 Multiple occurrences of "special_case" are evaluated in sequence,
                 until one is enabled. -->
            <special_case value="Y">
                <!-- Mandatory for this block and cumulative. Defines a condition
                     on the content_type to be used for the response, which should
                     include the string specified through the "contains" attribute. -->
                <content_type contains="text" />
            </special_case>

        </use_compression>

        <!-- Optional. Size of the resource contents below which compression
             is not applied, regardless of the "use_compression" setting, as we
             guess that no overall benefit would be reached.
             Default: 8192 bytes. -->
        {{- if (quote .compressionThreshold | empty) }}
        <!--
        <compression_threshold>0</compression_threshold>
        -->
        {{- else}}
        <compression_threshold>{{ .compressionThreshold }}</compression_threshold>
        {{- end }}

        <!-- Optional. Enables the processing of the "/crossdomain.xml" URL,
             required by the Flash player in order to allow pages from
             a different host to request data to Lightstreamer Server host.
             See the "WebSite Controls" section on
             http://www.adobe.com/devnet/flashplayer/articles/flash_player_9_security.pdf
             for details on the contents of the document to be returned.
             Can be one of the following:
             - Y: The Server accepts requests for "/crossdomain.xml";
                  the file configured through the "flex_crossdomain_path"
                  setting is returned.
                  Setting the internal web server enabling setting as "Y"
                  is not needed; note that if the internal web server is
                  enabled, the processing of the "/crossdomain.xml" URL is
                  different than the processing of the other URLs.
             - N: No special processing for the "/crossdomain.xml" requests
                  is performed.
                  Note that if the internal web server is enabled, then the
                  processing of the "/crossdomain.xml" URL is performed as for
                  any other URL (i.e. a file named "crossdomain.xml" is looked
                  for in the directory configured as the root for URL path
                  mapping).
             Note that "/crossdomain.xml" is also used by the Silverlight
             runtime when "/clientaccesspolicy.xml" is not provided.
             Default: N. -->
        <!--
        <flex_crossdomain_enabled>Y</flex_crossdomain_enabled>
        -->

        <!-- Mandatory when "flex_crossdomain_enabled" is set as "Y".
             Path of the file to be returned upon requests for the
             "/crossdomain.xml" URL. It is ignored when
             "flex_crossdomain_enabled" is not set as "Y".
             The file content should be encoded with the iso-8859-1 charset.
             The file path is relative to the conf directory. -->
        <!--
        <flex_crossdomain_path>./flexcrossdomain.xml</flex_crossdomain_path>
        -->

        <!-- Optional. Enables the processing of the "/clientaccesspolicy.xml"
             URL, required by the Silverlight runtime in order to allow pages
             from a different host to request data to Lightstreamer Server host.
             See http://msdn.microsoft.com/en-us/library/cc838250(VS.95).aspx#crossdomain_communication
             for details on the contents of the document to be returned.
             Can be one of the following:
             - Y: The Server accepts requests for "/clientaccesspolicy.xml";
                  the file configured through the "silverlight_accesspolicy_path"
                  setting is returned.
                  Setting the internal web server enabling setting as "Y"
                  is not needed; note that if the internal web server is
                  enabled, the processing of the "/clientaccesspolicy.xml" URL
                  is different than the processing of the other URLs.
             - N: No special processing for the "/clientaccesspolicy.xml"
                  requests is performed.
                  Note that if the internal web server is enabled, then the
                  processing of the "/clientaccesspolicy.xml" URL is performed
                  as for any other URL (i.e. a file named "clientaccesspolicy.xml"
                  is looked for in the directory configured as the root for
                  URL path mapping).
             Note that "/crossdomain.xml" is also used by the Silverlight
             runtime when "/clientaccesspolicy.xml" is not provided.
             Default: N. -->
        {{- if (quote .enableSilverlightAccessPolicy | empty) }}
        <!--
        <silverlight_accesspolicy_enabled>Y</silverlight_accesspolicy_enabled>
        -->
        {{- else }}
        <silverlight_accesspolicy_enabled>{{ .enableSilverlightAccessPolicy | ternary "Y" "N" }}</silverlight_accesspolicy_enabled>
        {{- end }}

        <!-- Mandatory when "silverlight_accesspolicy_enabled" is set as "Y".
             Path of the file to be returned upon requests for the
             "/clientaccesspolicy.xml" URL. It is ignored when
             "silverlight_accesspolicy_enabled" is not set as "Y".
             The file content should be encoded with the iso-8859-1 charset.
             The file path is relative to the conf directory. -->
        {{- if .silverlightAccessPolicyPath }}
        <silverlight_accesspolicy_path>{{ .silverlightAccessPolicyPath }}</silverlight_accesspolicy_path>
        {{- else }}
        <!--
        <silverlight_accesspolicy_path>./silverlightaccesspolicy.xml</silverlight_accesspolicy_path>
        -->
        {{- end }}

    </web_server>
{{- end }}

<!--
  ========================
  CLUSTERING CONFIGURATION
  ========================
-->

{{- with .Values.cluster }}
    <!-- Optional. Host address to be used for control/poll/rebind connections.
         A numeric IP address can be specified as well. The use of non standard,
         unicode names may not be supported yet by some Client SDKs.
         This setting can be used in case a cluster of Server instances is in
         place, to ensure that all client requests pertaining to the same session
         are issued against the same Server instance. If the Load Balancer can
         ensure that all requests coming from the same client are always routed
         to the same Server instance, then this setting is not needed.
         See the Clustering.pdf document for details.
         Note: When this setting is used, clients based on any Unified Client SDK
         that supports the optional setEarlyWSOpenEnabled method in the
         ConnectionOptions class should invoke this method with false, to improve
         startup performances.
         In case a request comes from a web client and <control_link_machine_name>
         is also specified, the latter setting may be applied instead; see the
         comment for <control_link_machine_name> for details.
         Support for clustering is an optional feature, available depending
         on Edition and License Type. When not available, this setting is ignored. -->
    {{- if .controlLinkAddress }}
    <control_link_address>{{ .controlLinkAddress }}</control_link_address>
    {{- else }}
    <!--
    <control_link_address>push1.mycompany.com</control_link_address>
    -->
    {{- end }}

    <!-- Optional. Host name to be used, in addition to the domain name specified
         on the front-end pages, for control/poll/rebind connections coming
         from web clients. This only regards clients based on old versions of the
         Web (Unified API) Client SDK (earlier than 8.0.0). The use of non standard,
         unicode names may not be supported by old versions of the Web Client SDK.
         This setting will override the <control_link_address> setting when the
         request comes from such Web Client SDKs and the access to Server data pages
         requires that the latter share a common subdomain with application pages.
         This was one of the ways used by these SDKs
         to request streaming data; see the Client Guide
         in the Web (Unified API) Client SDK for these versions for details on the
         cases in which this setting will be preferred; note that, in this regard, the
         behavior will be slightly different when the older HTML Client Library is
         in use, so as to ensure backward compatibility.
         This option is useful if the subdomain-name part of the hostname is subject
         to changes or if the same machine needs to be addressed through multiple
         subdomain names (e.g. for multihosting purpose).
         The configured name should contain all the portions of the address except
         for the subdomain name. For example, assuming the "mycompany.com" subdomain
         is declared in the front-end pages:
         - If the full address is "push1.mycompany.com", the name should be "push1";
         - If the full address is "push.int2.cnt3.mycompany.com", the name
           should be "push.int2.cnt3".
         Refer to <control_link_address> for other remarks.
         Support for clustering is an optional feature, available depending
         on Edition and License Type. When not available, this setting is ignored. -->
    {{- if .controlLinkMachineName }}
    <control_link_machine_name>{{ .controlLinkMachineName }}</control_link_machine_name>
    {{- else }}
    <!--
    <control_link_machine_name>push1</control_link_machine_name>
    -->
    {{- end }}

    <!-- Optional. If set and positive, specifies a maximum duration to be enforced
         on each session. If the limit expires, the session is closed and the
         client can only establish a new session. This is useful when a cluster
         of Server instances is in place, as it leaves the Load Balancer the
         opportunity to migrate the new session to a different instance.
         See the Clustering document for details on this mechanism and on how
         rebalancing can be pursued. -->
    {{- if (quote .maxSessionDurationMinutes | empty) }}
    <!--
    <max_session_duration_minutes>5</max_session_duration_minutes>
    -->
    {{- else }}
    <max_session_duration_minutes>{{ int .maxSessionDurationMinutes }}</max_session_duration_minutes>
    {{- end }}

{{- end }}

<!--
  ==================
  LOAD CONFIGURATION
  ==================
-->

{{- with .Values.load }}
    <!-- Optional. Maximum number of concurrent client sessions allowed.
         Requests for new sessions received when this limit is currently
         exceeded will be refused; on the other hand, operation on sessions
         already established is not limited in any way.
         Note that closing and reopening a session on a client when this limit
         is currently met may cause the new session request to be refused.
         The limit can be set as a simple, heuristic protection from Server
         overload.
         Default: unlimited. -->
    {{- if (quote .maxSessions | empty) }}
    <!--
    <max_sessions>1000</max_sessions>
    -->
    {{- else }}
    <max_sessions>{{ int .maxSessions }}</max_sessions>
    {{- end }}

    <!-- Optional. Maximum number of concurrent MPN devices sessions allowed.
         Once this number of devices has been reached, requests to active
         mobile push notifications will be refused.
         The limit can be set as a simple, heuristic protection from Server
         overload from MPN subscriptions.
         Default: unlimited. -->
    {{- if (quote .maxMpnDevices | empty) }}
    <!--
    <max_mpn_devices>1000</max_mpn_devices>
    -->
    {{- else }}
    <max_mpn_devices>{{ int .maxMpnDevices }}</max_mpn_devices>
    {{- end }}

    <!-- Optional. Limit to the overall size, in bytes, of the buffers
         devoted to I/O operations that can be kept allocated for reuse.
         If 0, removes any limit to the allocation (which should remain
         limited, based on the maximum concurrent buffer needs).
         If -1, disables buffer reuse at all and causes all allocated
         buffers to be released immediately.
         Default: 200000000 -->
    {{- if (quote .maxCommonNioBufferAllocation | empty) }}
    <!--
    <max_common_nio_buffer_allocation>0</max_common_nio_buffer_allocation>
    -->
    {{- else }}
    <max_common_nio_buffer_allocation>{{ int .maxCommonNioBufferAllocation }}</max_common_nio_buffer_allocation>
    {{- end }}

    <!-- Optional. Limit to the overall size, in bytes, of the buffers
         used internally to compose update packets that can be kept
         allocated for reuse.
         If 0, removes any limit to the allocation (which should remain
         limited, based on the maximum concurrent buffer needs).
         If -1, disables buffer reuse at all and causes all allocated
         buffers to be released immediately.
         Default: 200000000 -->
    {{- if (quote .maxCommonPumpBufferAllocation | empty) }}
    <!--
    <max_common_pump_buffer_allocation>0</max_common_pump_buffer_allocation>
    -->
    {{- else }}
    <max_common_pump_buffer_allocation>{{ int .maxCommonPumpBufferAllocation }}</max_common_pump_buffer_allocation>
    {{- end }}

    <!--
         Optional. Number of distinct NIO selectors (each one with its own
         thread) that will share the same operation. Different pools will be
         prepared for different I/O operations and server sockets, which may
         give rise to a significant overall number of selectors.
         Further selectors may be created because of the <selector_max_load>
         setting.
         Default: The number of available total cores, as detected by the JVM. -->
    {{- if (quote .selectorPoolSize | empty) }}
    <!--
    <selector_pool_size>1</selector_pool_size>
    -->
    {{- else }}
    <selector_pool_size>{{ int .selectorPoolSize }}</selector_pool_size>
    {{- end }}

    <!-- Optional. Maximum number of keys allowed for a single NIO selector.
         If more keys have to be processed, new temporary selectors will be
         created. If the value is 0, then no limitations are applied and extra
         selectors will never be created.
         The base number of selectors is determined by the <selector_pool_size>
         setting.
         Default: 0. -->
    {{- if (quote .selectorMaxLoad | empty) }}
    <!--
    <selector_max_load>1000</selector_max_load>
    -->
    {{- else }}
    <selector_max_load>{{ int .selectorMaxLoad }}</selector_max_load>
    {{- end }}

    <!--
         Optional. Number of threads used to parallelize the implementation
         of the internal timers.
         This task does not include blocking operations, but its computation
         may be heavy under high update activity; hence, on multiprocessor
         machines, allocating multiple threads for this task may be beneficial.
         Default: 1. -->
    {{- if (quote .timerPoolSize | empty) }}
    <!--
    <timer_pool_size>2</timer_pool_size>
    -->
    {{- else }}
    <timer_pool_size>{{ int .timerPoolSize }}</timer_pool_size>
    {{- end }}

    <!--
         Optional. Size of the "EVENTS" internal thread pool, which is devoted
         to dispatching the update events received from a Data Adapter to the
         proper client sessions, according with each session subscriptions.
         This task does not include blocking operations; however, on
         multiprocessor machines, allocating multiple threads for this task
         may be beneficial.
         Default: The number of available total cores, as detected by the JVM. -->
    {{- if (quote .eventsPoolSize | empty) }}
    <!--
    <events_pool_size>10</events_pool_size>
    -->
    {{- else }}
    <events_pool_size>{{ int .eventsPoolSize }}</events_pool_size>
    {{- end }}

    <!--
         Optional. Size of the "SNAPSHOT" internal thread pool, which is devoted
         to dispatching the snapshot events upon new subscriptions from client
         sessions.
         This task does not include blocking operations; however, on
         multiprocessor machines, allocating multiple threads for this task
         may be beneficial.
         Default: The number of available total cores, as detected by the JVM,
         or 10, if the number of cores is less. -->
    {{- if (quote .snapshotPoolSize | empty) }}
    <!--
    <snapshot_pool_size>10</snapshot_pool_size>
    -->
    {{- else }}
    <snapshot_pool_size>{{ int .snapshotPoolSize }}</snapshot_pool_size>
    {{- end }}

    <!--
         Optional. Size of the "PUMP" internal thread pool, which is devoted
         to integrating the update events pertaining to each session and to
         creating the update commands for the client, whenever needed.
         This task does not include blocking operations; however, on
         multiprocessor machines, allocating multiple threads for this task
         may be beneficial.
         Default: The number of available total cores, as detected by the JVM. -->
    {{- if (quote .pumpPoolSize | empty) }}
    <!--
    <pump_pool_size>10</pump_pool_size>
    -->
    {{- else }}
    <pump_pool_size>{{ int .pumpPoolSize }}</pump_pool_size>
    {{- end }}

    <!--
        Optional. Maximum number of tasks allowed to be queued to enter
        the "PUMP" thread pool before undertaking backpressure actions.
        In particular, the same restrictive actions associated to the
        <server_pool_max_queue> check will be performed (regardless
        that <server_pool_max_queue> itself is set).
        A steadily long queue on the PUMP pool may be the consequence of
        a CPU shortage due to a huge streaming activity.
        A negative value disables the check.
        Default: -1. -->
    {{- if (quote .pumpPoolMaxQueue | empty) }}
    <!--
    <pump_pool_max_queue>1000</pump_pool_max_queue>
    -->
    {{- else }}
    <pump_pool_max_queue>{{ int .pumpPoolMaxQueue }}</pump_pool_max_queue>
    {{- end }}

    <!--
        Optional. Maximum number of threads allowed for the "SERVER" internal
        pool, which is devoted to the management of the client requests.
        This kind of tasks includes operations that are potentially blocking:
        - getHostName;
        - socket close;
        - calls to a Metadata Adapter that may need to access to some
          external resource (i.e. mainly notifyUser, getItems, getSchema;
          other methods should be implemented as nonblocking, by leaning
          on data cached by notifyUser);
        - calls to a Data Adapter that may need to access to some
          external resource (i.e. subscribe and unsubscribe, though it
          should always be possible to implement such calls asynchronously);
        - file access by the internal web server, though it should be used
          only in demo and test scenarios.
        Note that specific thread pools can optionally be defined in order
        to handle some of the tasks that, by default, are handled by the
        SERVER thread pool. They are defined in "adapters.xml"; see the
        templates provided in the In-Process Adapter SDK for details.
        A zero value means a potentially unlimited number of threads.
        Default: 1000. -->
    {{- if (quote .serverPoolMaxSize | empty) }}
    <!--
    <server_pool_max_size>100</server_pool_max_size>
    -->
    {{- else }}
    <server_pool_max_size>{{ int .serverPoolMaxSize }}</server_pool_max_size>
    {{- end }}

    <!--
        Optional, but mandatory if "server_pool_max_size" is set to 0.
        Maximum number of idle threads allowed for the "SERVER" internal
        pool, which is devoted to the management of the client requests.
        Put in a different way, it is the minimum number of threads that can
        be present in the pool. To accomplish this setting, at pool
        initialization, suitable idle threads are created; then, each time
        a thread becomes idle, it is discarded only if enough threads are
        already in the pool.
        It must not be greater than "server_pool_max_size" (unless the latter
        is set to 0, i.e. unlimited); however, it may be lower, in case
        "server_pool_max_size" is kept high in order to face request bursts;
        a zero value means no idle threads allowed in the pool, though this
        is not recommended for performance reasons.
        Default: 10, if "server_pool_max_size" is not defined;
        otherwise, the same as "server_pool_max_size", unless the latter
        is set to 0, i.e. unlimited, in which case this setting is mandatory. -->
    {{- if (quote .serverPoolMaxFree | empty) }}
    <!--
    <server_pool_max_free>0</server_pool_max_free>
    -->
    {{- else }}
    <server_pool_max_free>{{ int .serverPoolMaxFree }}</server_pool_max_free>
    {{- end }}

    <!--
        Optional. Maximum number of tasks allowed to be queued to enter
        the "SERVER" thread pool before undertaking backpressure actions.
        In particular, as long as the number is exceeded, the creation
        of new sessions will be refused and made to fail; additionally,
        the same restrictive action on the accept loops associated to the
        <accept_pool_max_queue> check will be performed (regardless
        that <accept_pool_max_queue> itself is set).
        In case some dedicated pool is defined in "adapters.xml" to override
        the SERVER pool for specific tasks, its queue is still considered
        and it is added to the SERVER pool queue length.
        On the other hand, if the MPN DEVICE HANDLER pool is defined in the <mpn>
        block, it also overrides the SERVER or dedicated pools, but its queue
        is not included in the check.
        A negative value disables the check.
        Default: 100. -->
    {{- if (quote .serverPoolMaxQueue | empty) }}
    <!--
    <server_pool_max_queue>-1</server_pool_max_queue>
    -->
    {{- else }}
    <server_pool_max_queue>{{ int .serverPoolMaxQueue }}</server_pool_max_queue>
    {{- end }}

    <!--
        Optional. Maximum number of threads allowed for the "ACCEPT" internal
        pool, which is devoted to the parsing of the client requests.
        This task does not include blocking operations; however, on
        multiprocessor machines, allocating multiple threads for this task
        may be beneficial.
        Only in corner cases, it is possible that some operations turn
        out to be blocking; in particular:
        - getHostName, only if banned hostnames are configured;
        - socket close, only if banned hostnames are configured;
        - read from the "proxy protocol", only if configured;
        - service of requests on a "priority port", only available for
          internal use.
        A zero value means a potentially unlimited number of threads.
        Default: The number of available total cores, as detected by the JVM,
        which is also the minimum number of threads left in the pool. -->
    {{- if (quote .acceptPoolMaxSize | empty) }}
    <!--
    <accept_pool_max_size>100</accept_pool_max_size>
    -->
    {{- else }}
    <accept_pool_max_size>{{ int .acceptPoolMaxSize }}</accept_pool_max_size>
    {{- end }}

    <!--
        Optional. Maximum number of tasks allowed to be queued to enter
        the "ACCEPT" thread pool before undertaking backpressure actions.
        The setting only affects the listening sockets with <port_type>
        configured as CREATE_ONLY. As long as the number is exceeded,
        the accept loops of these sockets will be kept waiting.
        By suspending the accept loop, some SYN packets from the clients may be
        discarded; the effect may vary depending on the backlog settings.
        Note that, in the absence of sockets configured as CREATE_ONLY,
        no backpressure action will take place.
        A long queue on the ACCEPT pool may be the consequence of a CPU
        shortage during (or caused by) a high client connection activity.
        A negative value disables the check.
        Default: -1. -->
    {{- if (quote .acceptPoolMaxQueue | empty) }}
    <!--
    <accept_pool_max_queue>100</accept_pool_max_queue>
    -->
    {{- else }}
    <accept_pool_max_queue>{{ int .acceptPoolMaxQueue }}</accept_pool_max_queue>
    {{- end }}

    <!--
        Optional. Size of the "TLS-SSL HANDSHAKE" internal pool, which is
        devoted to the management of operations needed to accomplish TLS/SSL
        handshakes on the listening sockets specified through <https_server>.
        In particular, this pool is only used when the socket is not configured
        to request the client certificate (see <use_client_auth> and
        <force_client_auth>); in this case, the tasks are not
        expected to be blocking. Note that the operation may be CPU-intensive;
        hence, it is advisable to set a value smaller than the number of
        available cores.
        Default: Half the number of available total cores, as detected by the JVM
        (obviously, if there is only one core, the default will be 1). -->
    {{- if (quote .handshakePoolSize | empty) }}
    <!--
    <handshake_pool_size>10</handshake_pool_size>
    -->
    {{- else }}
    <handshake_pool_size>{{ int .handshakePoolSize }}</handshake_pool_size>
    {{- end }}

    <!--
        Optional. Maximum number of tasks allowed to be queued to enter the
        "TLS-SSL HANDSHAKE" thread pool before undertaking backpressure actions.
        The setting only regards the listening sockets specified through
        <https_server> that are not configured to request the client certificate.
        More precisely:
        - If there are https sockets with <port_type> configured as CREATE_ONLY,
          then, as long as the number is exceeded, the accept loops of these
          sockets will be kept waiting.
          By suspending the accept loop, some SYN packets from the clients may be
          discarded; the effect may vary depending on the backlog settings.
        - Otherwise, if there are https sockets configured as CONTROL_ONLY and none
          is configured as the default GENERAL_PURPOSE, then, as long as the
          number is exceeded, the accept loops of these sockets will be kept
          waiting instead.
          Additionally, the same action on the accept loops associated to the
          <accept_pool_max_queue> check will be performed (regardless that
          <accept_pool_max_queue> itself is set). Note that the latter action
          may affect both http and https sockets.
        Note that, in the absence of sockets configured as specified above,
        no backpressure action will take place.
        A negative value disables the check.
        Default: 100. -->
    {{- if (quote .handshakePoolMaxQueue | empty) }}
    <!--
    <handshake_pool_max_queue>-1</handshake_pool_max_queue>
    -->
    {{- else }}
    <handshake_pool_max_queue>{{ int .handshakePoolMaxQueue }}</handshake_pool_max_queue>
    {{- end }}

    <!--
        Optional. Maximum number of threads allowed for the
        "TLS-SSL AUTHENTICATION" internal pool, which is used instead of the
        "TLS-SSL HANDSHAKE" pool for listening sockets that are configured
        to request the client certificate. This kind of task may exhibit
        a blocking behavior in some cases.
        A zero value means a potentially unlimited number of threads.
        Default: The same as configured for the SERVER thread pool. -->
    {{- if (quote .httpsAuthPoolMaxSize | empty) }}
    <!--
    <https_auth_pool_max_size>10</https_auth_pool_max_size>
    -->
    {{- else }}
    <https_auth_pool_max_size>{{ int .httpsAuthPoolMaxSize }}</https_auth_pool_max_size>
    {{- end }}

    <!--
        Optional. Maximum number of idle threads allowed for the
        "TLS-SSL AUTHENTICATION" internal pool.
        It behaves in the same way as the "server_pool_max_free" setting.
        Default: The same as configured for the SERVER thread pool. -->
    {{- if (quote .httpsAuthPoolMaxFree | empty) }}
    <!--
    <https_auth_pool_max_free>0</https_auth_pool_max_free>
    -->
    {{- else }}
    <https_auth_pool_max_free>{{ int .httpsAuthPoolMaxFree }}</https_auth_pool_max_free>
    {{- end }}

    <!--
        Optional. Maximum number of tasks allowed to be queued to enter
        the "TLS-SSL AUTHENTICATION" thread pool before undertaking
        backpressure actions.
        The effect is similar to the more common <handshake_pool_max_queue>,
        with the difference that it regards listening sockets specified through
        <https_server> that are configured to request the client certificate
        (see <use_client_auth> and <force_client_auth>).
        A negative value disables the check.
        Default: 100. -->
    {{- if (quote .httpsAuthPoolMaxQueue | empty) }}
    <!--
    <https_auth_pool_max_queue>-1</https_auth_pool_max_queue>
    -->
    {{- else }}
    <https_auth_pool_max_queue>{{ int .httpsAuthPoolMaxQueue }}</https_auth_pool_max_queue>
    {{- end }}

    <!--
        Optional. Maximum number of sessions that can be left in "prestarted"
        state, that is, waiting for the first bind or control operation,
        before undertaking backpressure actions.
        In particular, the same restrictive actions associated to the
        <server_pool_max_queue> check will be performed (regardless
        that <server_pool_max_queue> itself is set).
        The setting is meant to be used in configurations which define
        a CREATE_ONLY port in http and a CONTROL_ONLY port in https.
        In these cases, and when a massive client reconnection is occurring,
        the number of pending bind operations can grow so much that the
        needed TLS handshakes can take arbitrarily long and cause the
        clients to time-out and restart session establishment from scratch.
        However, consider that the presence of many clients that don't
        perform their bind in due time could keep other clients blocked.
        Note that, if defined, the setting will also inhibit
        <handshake_pool_max_queue> and <https_auth_pool_max_queue>
        from affecting the accept loop of CONTROL_ONLY ports in https.
        A negative value disables the check.
        Default: -1. -->
    {{- if (quote .prestartedMaxQueue | empty) }}
    <!--
    <prestarted_max_queue>1000</prestarted_max_queue>
    -->
    {{- else }}
    <prestarted_max_queue>{{ int .prestartedMaxQueue }}</prestarted_max_queue>
    {{- end }}

    <!--
        Optional. Policy to be adopted in order to manage the extraction
        of the field values from the item events and their conversion to
        a transferrable format.
        Can be one of the following:
        - Y: causes field conversion to be performed before the events
             are dispatched to the various sessions; this may lead to some
             wasted conversions, in case an event is filtered out later by all
             interested clients or in case a field is not subscribed to by any
             client.
             Note that events which don't provide an iterator (see the Data
             Adapter interface documentation) cannot be managed in this way.
        - N: causes field conversion to be performed only as soon as it is
             needed; in this case, as the same event object may be shared by
             many sessions, some synchronization logic is needed and this may
             lead to poor scaling in case many clients subscribe to the same
             item.
        Default: Y. -->
    {{- if (quote .forceEarlyConversions | empty) }}
    <!--
    <force_early_conversions>N</force_early_conversions>
    -->
    {{- else }}
    <force_early_conversions>{{ .forceEarlyConversions | ternary "Y" "N" }}</force_early_conversions>
    {{- end }}

{{- end }}

</lightstreamer_conf>
{{- end -}}
