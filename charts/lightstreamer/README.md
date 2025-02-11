

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 7.4.5](https://img.shields.io/badge/AppVersion-7.4.5-informational?style=flat-square)

Lightstreamer Helm Chart

**Homepage:** <https://github.com/Lightstreamer/helm-charts>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| The Lightstreamer support team | <support@lightstreamer.com> |  |

## Source Code

* <https://github.com/Lightstreamer/helm-charts/tree/main/charts/lightstreamer>

## Installing the Chart

To install the chart with the release name `lightstreamer-app`:

```console
$ helm repo add lightstreamer https://lightstreamer.github.io/helm-charts
$ helm install lightstreamer-app lightstreamer/lightstreamer -n lightstreamer --create-namespace
```

## Settings

### Common settings

#### [commonLabels](./values.yaml#L28)

     
Common labels to apply to all resources

**Default:** `{}`
#### [fullnameOverride](./values.yaml#L26)

     
Replace the chart's default resource naming convention

**Default:** `""`
#### [image](./values.yaml#L31)

     
Lightstreamer Docker Image settings

**Default:**

```
{"pullPolicy":"IfNotPresent","repository":"lightstreamer","tag":"latest"}
```
#### [image.repository](./values.yaml#L33)

     
Remote registry from which to pull the Lightstreamer Docker image

**Default:** `"lightstreamer"`
#### [image.tag](./values.yaml#L38)

     
The tag of the image to pull

**Default:** `.Chart.appVersion`
#### [nameOverride](./values.yaml#L24)

     
Override the default name of the chart

**Default:** `""`
### Servers configuration
 
#### [servers](./values.yaml#L926)

     
Mandatory. Map of HTTP/S server socket configurations. Every key in the map defines a specific listening socket configuration, which can then be referenced through the whole configuration. Defining multiple listening socket allows the coexistence of private and public ports. This allows the use of multiple address for accessing the Sever via TLS/SSL, because different HTTPS sockets can use different keystores. In particular this is the case when the Server is behind load balancer and the `cluster.controlLinkAddress` setting is leveraged to ensure that all requests issued by the same client are dispatched to the same Server instance.

**Default:**

```
{"defaultServer":{"backlog":null,"clientIdentification":{"enableForwardsLogging":null,"enablePrivate":null,"enableProxyProtocol":null,"proxyProtocolTimeoutMillis":null,"skipLocalForwards":null},"enableHttps":false,"enabled":true,"listeningInterface":null,"name":"Lightstreamer HTTP Server","port":8080,"portType":null,"responseHttpHeaders":{"add":[{"name":"X-Accel-Buffering","value":"no"}],"echo":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableClientAuth":null,"enableClientHintsForTlsSessionResumption":null,"enableMandatoryClientAuth":null,"enableStatelessTlsSessionResumption":null,"enableTlsRenegotiation":null,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"keyStoreRef":"myServerKeystore","removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"tlsProvider":null,"tlsSessionCacheSize":null,"tlsSessionTimeoutSeconds":null,"trustStoreRef":null}}}
```
#### [servers.defaultServer](./values.yaml#L928)

     
At least one must be provided. An HTTP server socket configuration.

**Default:**

```
{"backlog":null,"clientIdentification":{"enableForwardsLogging":null,"enablePrivate":null,"enableProxyProtocol":null,"proxyProtocolTimeoutMillis":null,"skipLocalForwards":null},"enableHttps":false,"enabled":true,"listeningInterface":null,"name":"Lightstreamer HTTP Server","port":8080,"portType":null,"responseHttpHeaders":{"add":[{"name":"X-Accel-Buffering","value":"no"}],"echo":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableClientAuth":null,"enableClientHintsForTlsSessionResumption":null,"enableMandatoryClientAuth":null,"enableStatelessTlsSessionResumption":null,"enableTlsRenegotiation":null,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"keyStoreRef":"myServerKeystore","removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"tlsProvider":null,"tlsSessionCacheSize":null,"tlsSessionTimeoutSeconds":null,"trustStoreRef":null}}
```
#### [servers.defaultServer.backlog](./values.yaml#L952)

     
Optional. Size of the system buffer for incoming TCP connections Overrides the default system setting.

**Default:** `the system setting`
#### [servers.defaultServer.clientIdentification](./values.yaml#L1042)

     
Optional. Settings that allow for better recognition of the remote address of the connected clients. This can be done in two ways:  - by taking advantage of the X-Forwarded-For HTTP header, that   intermediate HTTP proxies and level-7 Load Balancers usually set to   supply connection routing information in an incremental way (this is   done through the `skipLocalForwards` setting);  - by receiving the routed address directly from a TCP reverse proxy or   level-4 Load Balancer through the Proxy Protocol, when the proxy is   configured to do so (this is done through the `enableProxyProtocol`    setting).  The two techniques can also coexist, but, in that case, the address through the proxy protocol would always be considered as the real client address and all addresses in the chain specified in X-Forwarded-For would be considered as written by client-side proxies. The address determined in this way will be used in all cases in which the client address is reported or checked. For logging purposes, the connection endpoint will still be written, but the real remote address, if available and different, will be added. The determined address may also be sent to the clients, depending on the Client SDK in use.

**Default:** `all settings at their defaults`
#### [servers.defaultServer.clientIdentification.enableForwardsLogging](./values.yaml#L1107)

     
Optional. If set to `true`, causes the list of entries of the X-Forwarded-For header, when available, to be added to log lines related to the involved HTTP request or Websocket. If `skipLocalForwards` is nonzero, only the entries farther than the determined "real" remote address are included. These entries are expected to be written by client-side proxies.

**Default:** `false`
#### [servers.defaultServer.clientIdentification.enablePrivate](./values.yaml#L1052)

     
Optional.  If set to `true`, prevents the determined address from being sent to the clients. In fact, the address is notified to the client upon connection and it is made available to application code by the most recent Unified Client SDKs through the `clientIp` property in the `ConnectionDetails` class. For instance, the flag can and should be set to `true` in case the identification of the remote address is not properly tuned and the determined address may be a local one.

**Default:** `false`
#### [servers.defaultServer.clientIdentification.enableProxyProtocol](./values.yaml#L1069)

     
Optional. If set to `true`, instructs the Server that the connection endpoint is a reverse proxy or load balancer that sends client address information through the Proxy Protocol. The received address and port will be used as the real client address and port. In particular, they will appear in all log lines for this client (but for the `lightstreamerLogger.connections` logger). On the other hand, the reported protocol will always refer to the actual connection. There is no dynamic detection of the proxy protocol; hence, if enabled, all connections to this port must speak the proxy protocol (for instance, any healthcheck requests should be configured properly on the proxy) and, if not, no connection can speak the proxy protocol, otherwise the outcome would be unspecified. On the other hand, if enabled, both proxy protocol version 1 and 2 are handled; only information for normal TCP connections is considered.

**Default:** `false`
#### [servers.defaultServer.clientIdentification.proxyProtocolTimeoutMillis](./values.yaml#L1079)

     
Optional. Timeout applied while reading for information  through the proxy protocol, when enabled. Note that a reverse proxy or load balancer speaking the proxy protocol is bound to send information immediately after connection start; so the timeout can only apply to  cases of wrong configuration, local network issues or illegal access to  this port. For this reason, the read is performed directly in the `ACCEPT` thread pool and this setting protects that pool against such unlikely events.

**Default:** `1000`
#### [servers.defaultServer.clientIdentification.skipLocalForwards](./values.yaml#L1099)

     
Optional, but nonzero values forbidden if  `enableProxyProtocol` is set to `true`. Number of entries in the  _X-Forwarded-For_ header that are expected to be supplied on each HTTP  request (including Websocket handshake) by the intermediate nodes (e.g. reverse proxies, load balancers) that stand in the local environment. If N entries are expected from local nodes, this means that the Nth-nearest entry corresponds to the node connected to the farthest local intermediate node, hence to the client. So, that entry will be used as the real client address. In particular, it will appear in all log lines that refer to the involved HTTP request or Websocket. If set to `0` or left at the default, all entries in _X-Forwarded-For_ will be considered as written by client-side proxies, hence the connection endpoint address will be used (unless, of course, `enableProxyProtocol` is set to `true`, which overrides the behavior). Note that a similar correction for port and protocol is not applied; hence, when an address corrected through a nonzero setting is reported, any port and protocol associated will still refer to the actual connection.

**Default:** `0`
#### [servers.defaultServer.enableHttps](./values.yaml#L948)

     
Optional. Enabling of the https protocol. HTTPS service is an optional feature, available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at `/dashboard`). See `sslConfig` for general details on TLS/SSL configuration.

**Default:** `false`
#### [servers.defaultServer.enabled](./values.yaml#L931)

     
Optional. Enable this socket configuration.

**Default:** `false`
#### [servers.defaultServer.listeningInterface](./values.yaml#L1017)

     
Optional. Can be used on a multihomed host to specify the IP address to bind the server socket to.

**Default:**

```
accept connections on any/all local addresses
```
#### [servers.defaultServer.name](./values.yaml#L938)

     
Mandatory. The name of the HTTP/S server. Note that it is notified to the client upon connection and it is made available to application code by the Unified Client SDKs through the `serverSocketName` property in the `ConnectionDetails` class. It must be an ASCII string with no control characters and it must be unique among all server configurations. The name must be unique among all server configurations.

**Default:** `"Lightstreamer HTTP Server"`
#### [servers.defaultServer.port](./values.yaml#L940)

     
Mandatory. Listening TCP port.

**Default:** `8080`
#### [servers.defaultServer.portType](./values.yaml#L987)

     
Optional. Provides meta-information on how this listening socket will be used, according with the deployment configuration. This can inform the Server of a restricted set of requests expected on the port, which may improve the internal backpressure mechanisms.  If set to `CREATE_ONLY`, declares that the port is only devoted to `S` connections, according with the provided Clustering.pdf document.  If set to `CONTROL_ONLY`, declares that the port is only devoted to `CR` connections,according with the provided Clustering.pdf document. The Server will enforce the restriction.  If set to `PRIORITY`, requests issued to this port will follow a fast track. In particular, they will be never enqueued to the SERVER thread pool, but only the `ACCEPT` pool; and they will not be subject to any backpressure-related limitation (like `load.acceptPoolMaxQueue`). This should ensure that the requests will be fulfilled as soon as possible, even when the Server is overloaded. Such priority port is, therefore, ideal for opening the Monitoring Dashboard to inspect overload issues in place. It can also be used to open sessions on a custom Adapter Set, but, in that case, any thread pool specifically defined for the Adapters will be entered, with possible enqueueing. Anyway, such port is only meant for internal use and it is recommended not to leave it publicly accessible. Furthermore, in case of HTTPS server socket (`enableHttps` set to `true`) TLS-handshake-related tasks will not be enqueued to the  `TLS-SSL HANDSHAKE` or `TLS-SSL AUTHENTICATION` thread pool, but only to  a dedicated pool. If set to `GENERAL_PURPOSE`, the port can be used for any kind of request. It can always be set in case of doubts. Note that ports can be `CREATE_ONLY` or `CONTROL_ONLY` only depending on client behavior. For  clients based on LS SDK libraries, this is related to the use of the `cluster.controlLinkAddress` setting. Usage examples are provided in the Clustering.pdf document.

**Default:** `"GENERAL_PURPOSE"`
#### [servers.defaultServer.responseHttpHeaders](./values.yaml#L998)

     
Optional. Settings that allow some control over the HTTP headers of the provided responses. Header lines can only be added to those used by the Server, either by specifying their value or by copying them from the request. Multiple rules can be defined; their order is ignored. In any case of replicated header fields, multiple lines will be inserted; it is assumed that multiple occurrences are allowed for those fields. No syntax and consistency checks are performed on the resulting HTTP headers; only custom or non-critical fields should be used. The header names involved are always converted to lower case.

**Default:**

```
{"add":[{"name":"X-Accel-Buffering","value":"no"}],"echo":null}
```
#### [servers.defaultServer.responseHttpHeaders.add](./values.yaml#L1009)

     
Optional. Requests to add to the HTTP response header a line with the specified `name` (mandatory) and `value` (optional). The suggested setting for _X-Accel-Buffering_ may help to enable streaming support when proxies of several types are involved.

**Default:** `[{"name":"X-Accel-Buffering","value":"no"}]`
#### [servers.defaultServer.responseHttpHeaders.echo](./values.yaml#L1003)

     
Optional. Requests to look for any header lines for  the specified field name on the HTTP request header and to copy them to the HTTP response header.

**Default:** `[]`
#### [servers.defaultServer.sslConfig](./values.yaml#L1110)

     
Mandatory if `enableHttps` is `true`. TLS/SSL settings for this socket configuration.

**Default:**

```
{"allowCipherSuites":[],"allowProtocols":[],"enableClientAuth":null,"enableClientHintsForTlsSessionResumption":null,"enableMandatoryClientAuth":null,"enableStatelessTlsSessionResumption":null,"enableTlsRenegotiation":null,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"keyStoreRef":"myServerKeystore","removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"tlsProvider":null,"tlsSessionCacheSize":null,"tlsSessionTimeoutSeconds":null,"trustStoreRef":null}
```
#### [servers.defaultServer.sslConfig.allowCipherSuites](./values.yaml#L1140)

     
Optional, but forbidden if `removeCipherSuites` is used. Specifies all the cipher suites allowed for the TLS/SSL interaction, provided that they are included, with the specified name, in the set of of "supported" cipher suites of the underlying Security Provider. The default set of the "supported" cipher suites is logged at startup by the `lightstreamerLogger.io.ssl` logger at `DEBUG` level. If not used, the `removeCipherSuites` setting is considered; hence, if `removeCipherSuites` is also not used, all cipher suites enabled by the Security Provider will be available. The order in which the cipher suites are specified can be enforced as the server-side preference order (see `enforceServerCipherSuitePreference`).

**Default:** `[]`
#### [servers.defaultServer.sslConfig.allowProtocols](./values.yaml#L1198)

     
Optional, but forbidden if `removeProtocols` is used. Specifies one or more protocols allowed for the TLS/SSL interaction, among the ones supported by the underlying Security Provider. For Oracle JVMs, the available names are the "SSLContext Algorithms" listed here: https://docs.oracle.com/en/java/javase/17/docs/specs/security/standard-names.html#sslcontext-algorithms If not specified, the `removeProtocols` setting is considered; hence,  if `removeProtocols` is also not used, all protocols enabled by the  Security Provider will be available.

**Default:** `[]`
#### [servers.defaultServer.sslConfig.enableClientAuth](./values.yaml#L1275)

     
Optional. Request to provide the Metadata Adapter with the "principal" included in the client TLS/SSL certificate, when available. If set to `true`, upon each client connection, the availability of a client TLS/SSL certificate is checked. If available, the included identification data will be supplied upon calls to notifyUser. If set to `false`, no certificate information is supplied to notifyUser and no check is done on the client certificate. Note that a check on the client certificate can also be requested through `enableMandatoryClientAuth`.

**Default:** `false`
#### [servers.defaultServer.sslConfig.enableClientHintsForTlsSessionResumption](./values.yaml#L1264)

     
Optional. If set to `true`, tries to improve the TLS session resumption feature by providing the underlying Security Provider with information on the client IPs and ports. This makes sense only if client IPs can be determined (see `servers.{}.clientIdentification`).

**Default:** `false`
#### [servers.defaultServer.sslConfig.enableMandatoryClientAuth](./values.yaml#L1285)

     
Optional. Request to only allow clients provided with a valid TLS/SSL certificate. If set to `true`, upon each client connection, a valid TLS/SSL certificate is requested to the client in order to accept the connection. If set to `false`, no check is done on the client certificate. Note that a certificate can also be requested to the client as a consequence of `enableClientAuth`.

**Default:** `false`
#### [servers.defaultServer.sslConfig.enableStatelessTlsSessionResumption](./values.yaml#L1234)

     
Optional. Instructs the underlying Security Provider on whether to use stateless (when `true`) or stateful (when `false`) session resumption on this port, if supported (possibly depending on the protocol version in use). Note that stateful resumption implies the management of a TLS session cache, whereas stateless resumption is slightly more demanding in terms of CPU and bandwidth. Note, however, that this setting is currently supported only if the Conscrypt Security Provider is used. For instance, with the default SunJSSE Security Provider, the use of stateful or stateless resumption can only be configured at global JVM level, through the `jdk.tls.server.enableSessionTicketExtension` JVM property. If not specified, the type of resumption will be decided by the  underlying Security Provider, based on its own configuration.

**Default:**

```
the underlying Security Provider's configuration
```
#### [servers.defaultServer.sslConfig.enableTlsRenegotiation](./values.yaml#L1187)

     
Optional. If set to `false`, causes any client-initiated TLS renegotiation request to be refused by closing the connection. This policy may be evaluated in a trade-off between encryption strength and performance risks. Note that, with the default SunJSSE Security Provider, a better way to achieve the same at a global JVM level is by setting the dedicated `jdk.tls.rejectClientInitiatedRenegotiation` JVM property to `true`.

**Default:** `true`
#### [servers.defaultServer.sslConfig.enforceServerCipherSuitePreference](./values.yaml#L1163)

     
Optional. Determines which side should express the preference when multiple cipher suites are in common between server and client. Note, however, that the underlying Security Provider may ignore this setting. This is the case, for instance, of the Conscrypt provider.

**Default:** `{"enabled":true,"order":"JVM"}`
#### [servers.defaultServer.sslConfig.enforceServerCipherSuitePreference.enabled](./values.yaml#L1170)

     
Optional. If set to `true`, the Server will choose the cipher suite based on its preference order, specified through `order`. If set to `false`, the Server will get a cipher suite based on the preference order specified by the client. For instance, the client might privilege faster, but weaker, suites.

**Default:** `false`
#### [servers.defaultServer.sslConfig.enforceServerCipherSuitePreference.order](./values.yaml#L1178)

     
Optional. Preference order for choosing the cipher suite. If set to `JVM`, ordering is demanded to the underlying Security Provider, which, usually, privileges the strongest suites. If set to `config` (which is allowed only if `allowCipherSuites` is used), the order in which the `allowCipherSuites` elements are specified determines the preference order.

**Default:** `JVM`
#### [servers.defaultServer.sslConfig.keyStoreRef](./values.yaml#L1126)

     
Mandatory. The reference to a keystore configuration (defined in `keyStores`). See the `keyStores.myServerKeystore` settings for general details on keystore configuration.

**Default:** `"myServerKeystore"`
#### [servers.defaultServer.sslConfig.removeCipherSuites](./values.yaml#L1157)

     
Optional, but forbidden if `allowCipherSuites` is used. Pattern to be matched against the names of the enabled cipher suites in order to remove the matching ones from the enabled cipher suites set. Any pattern in java.util.regex.Pattern format can be specified. This allows for customization of the choice of the cipher suites to be used for incoming https connections (note that reducing the set of available cipher suites may cause some client requests to be refused). When this setting is used, the server-side preference order of the cipher suites is determined by the underlying Security Provider. Note that the selection is operated on the default set of the cipher suites "enabled" by the Security Provider, not on the wider set of the "supported" cipher suites. The default set of the "enabled" cipher suites is logged at startup by the `lightstreamerLogger.io.ssl` logger at `DEBUG` level.

**Default:** `[]`
#### [servers.defaultServer.sslConfig.removeProtocols](./values.yaml#L1215)

     
Optional, but forbidden if `allowProtocols` is used. Pattern to be matched against the names of the enabled TLS/SSL  protocols in order to remove the matching ones from the enabled  protocols set. Any pattern in java.util.regex.Pattern format can be specified. This allows for customization of the choice of the TLS/SSL protocols to be used for an incoming https connection (note that reducing the set of available protocols may cause some client requests to be refused). Note that the selection is operated on the default set of the protocols "enabled" by the Security Provider, not on the wider set of the "supported" protocols. The default set of the "enabled" protocols is logged at startup by the `lightstreamerLogger.io.ssl` logger at DEBUG level.

**Default:** `[]`
#### [servers.defaultServer.sslConfig.tlsProvider](./values.yaml#L1121)

     
Optional. If defined, overrides the default JVM's Security Provider configured in the java.security file of the JDK installation. This allows the use of different Security Providers dedicated to single listening ports. When configuring a Security Provider, the related libraries should be added to the Server classpath. This is not needed for the Conscrypt provider, which is already available in the Server distribution (but note that the library includes native code that only targets the main platforms).

**Default:** `the default JVM's Security Provider`
#### [servers.defaultServer.sslConfig.tlsSessionCacheSize](./values.yaml#L1245)

     
Optional. Size of the cache used by the TLS implementation to handle TLS session resumptions when stateful resumption is configured (see `enableStatelessTlsSessionResumption`).  A value of `0` poses no size limit. Note, however, that the underlying Security Provider may ignore this setting (possibly depending on the protocol version in use). If not specified, the cache size is decided by the underlying Security  Provider. For the default SunJSSE, it is `20480` TLS sessions, unless configured through the `javax.net.ssl.sessionCacheSize` JVM property.

**Default:**

```
decided by the underlying Security Provider's configuration
```
#### [servers.defaultServer.sslConfig.tlsSessionTimeoutSeconds](./values.yaml#L1258)

     
Optional. Maximum time in which a TLS session is kept available to the client for resumption. This holds for both stateless and stateful TLS resumption (see `enableStatelessTlsSessionResumption`). In the latter case, the session also has to be kept in a cache. A value of `0` poses no time limit. Note, however, that the underlying Security Provider may ignore this setting (possibly depending of the protocol version in use). If not specified, the maximum time is decided by the underlying  Security Provider. For the default SunJSSE, it is `86400` seconds,  unless configured through the `jdk.tls.server.sessionTicketTimeout` JVM property.

**Default:**

```
decided by the underlying Security Provider's configuration
```
#### [servers.defaultServer.sslConfig.trustStoreRef](./values.yaml#L1298)

     
Mandatory if at least one of `enableClientAuth` and `enableMandatoryClientAuth` is set to `true`. The reference to a keystore to be used by the HTTPS service to accept client certificates. It can be used to supply client certificates that should be accepted, in addition to those with a valid certificate chain, for instance while testing with self-signed certificates. See the `keyStores.myServerKeystore` settings for general details on keystore configuration. Note that the further constraints reported there with regard to accessing the certificates in a JKS keystore don't hold in this case, where the latter is used as a truststore. Moreover, the handling of keystore replacement doesn't apply here.

**Default:** `nil`
### KeyStores configuration
 
#### [keyStores](./values.yaml#L1301)

     
Keystores definition.

**Default:**

```
{"myKafkaConnectorKeystore":null,"myServerKeystore":{"keystoreFileSecretRef":{"key":"myserver.keystore","name":"myserver-keystore-secret"},"keystorePasswordSecretRef":{"key":"myserver.keypass","name":"myserver-keypass-secret"},"type":"JKS"}}
```
#### [keyStores.myKafkaConnectorKeystore](./values.yaml#L1331)

     
Example of Keystore definition used by Kafka connector configurations.

**Default:** `nil`
#### [keyStores.myServerKeystore](./values.yaml#L1309)

     
Keystore definition used by HTTPS server socket configurations. The default values used here reference the JKS keystore file `myserver.keystore`, which is provided out of the box (and stored in the `myserver-keystore-secret` secret, along with the password stored in the `myserver-keypass-secret` secret), and obviously contains an invalid certificate. In order to use it for your experiments, remember to add a security exception to your browser.

**Default:**

```
{"keystoreFileSecretRef":{"key":"myserver.keystore","name":"myserver-keystore-secret"},"keystorePasswordSecretRef":{"key":"myserver.keypass","name":"myserver-keypass-secret"},"type":"JKS"}
```
#### [keyStores.myServerKeystore.keystoreFileSecretRef](./values.yaml#L1322)

     
Mandatory if type is set to `JKS` or `PKCS12`. Secret name and key where the keystore file is stored.

**Default:**

```
{"key":"myserver.keystore","name":"myserver-keystore-secret"}
```
#### [keyStores.myServerKeystore.keystorePasswordSecretRef](./values.yaml#L1327)

     
Mandatory if type is set to `JKS` or `PKCS12`. Secret name and key where keystore password is stored.

**Default:**

```
{"key":"myserver.keypass","name":"myserver-keypass-secret"}
```
#### [keyStores.myServerKeystore.type](./values.yaml#L1319)

     
Optional. The keystore type. The currently supported types are: - `JKS`, which is the Sun/Oracle's custom keystore type, whose support is   made available by every Java installation; - `PKCS12`, which is supported by all recent Java installations; - `PKCS11`, which as a bridge to an external PKCS11 implementation;   this is an experimental extension; contact Lightstreamer Support for   details.

**Default:** `JKS`
### GlobalSocket configuration
 
#### [globalSocket](./values.yaml#L1356)

     
Mandatory. Global socket configuration.

**Default:**

```
{"handshakeTimeoutMillis":null,"readTimeoutMillis":20000,"requestLimit":50000,"useHttpVersion":null,"webSocket":{"enabled":null,"maxClosingWaitMillis":null,"maxOutboundFrameSize":null,"maxPongDelayMillis":null},"writeTimeoutMillis":120000}
```
#### [globalSocket.handshakeTimeoutMillis](./values.yaml#L1374)

     
Optional. Longest inactivity time accepted while waiting for a slow operation during a TLS/SSL handshake. This involves both reads, writes, and encryption tasks managed by the `TLS-SSL HANDSHAKE` or `TLS-SSL AUTHENTICATION` internal pools. If this value is exceeded, the socket is closed. The time actually considered may be approximated and may be a few seconds higher, for internal performance reasons. A `0` value suppresses the check.

**Default:** `4000`
#### [globalSocket.readTimeoutMillis](./values.yaml#L1364)

     
Mandatory. Longest inactivity time accepted while waiting for a slow request to be received. If this value is exceeded, the socket is closed. Reusable HTTP connections are also closed if they are not reused for longer than this time. The time actually considered may be approximated and may be a few seconds higher, for internal performance reasons. A `0` value suppresses the check.

**Default:** `20000`
#### [globalSocket.requestLimit](./values.yaml#L1383)

     
Optional. Maximum length in bytes accepted for a request. For an HTTP GET request, the limit applies to the whole request, including the headers. For an HTTP POST request, the limit applies to the header part and the body part separately. For a request over a WebSocket, the limit applies to the request message payload.

**Default:** `unlimited length`
#### [globalSocket.useHttpVersion](./values.yaml#L1400)

     
Optional. Enabling the use of the full HTTP 1.1 syntax for all the responses, upon HTTP 1.1 requests. If set to `1.1`, HTTP 1.1 is always used, when possible. If set to `1.0`, HTTP 1.0 is always used; this is possible for all HTTP requests, but it will prevent WebSocket support. If set to `AUTO`, HTTP 1.0 is used, unless HTTP 1.1 is required in order to support specific response features.

**Default:** `1.1`
#### [globalSocket.webSocket](./values.yaml#L1402)

     
Optional. WebSocket support configuration.

**Default:**

```
{"enabled":null,"maxClosingWaitMillis":null,"maxOutboundFrameSize":null,"maxPongDelayMillis":null}
```
#### [globalSocket.webSocket.enabled](./values.yaml#L1414)

     
Optional. Enabling of the WebSocket support. If set to `true`, the Server accepts requests for initiating a WebSocket interaction through a custom protocol. If set to `false`, the Server refuses requests for WebSocket interaction. Disabling WebSocket support may be needed when the local network infrastructure (for instance the Load Balancer) does not handle WebSocket communication correctly and the WebSocket transport is not already disabled on the client side through the Lightstreamer Client Library in use. The Client Library, upon the Server refusal, will resort to HTTP streaming without any additional delay to session establishment.

**Default:** `true`
#### [globalSocket.webSocket.maxClosingWaitMillis](./values.yaml#L1426)

     
Optional. Maximum time the Server is allowed to wait for the client "close" frame, in case the Server is sending its own close" frame first, in order to try to close the connection in a clean way.

**Default:**

```
no timeout is set and the global global.readTimeoutMillis applies
```
#### [globalSocket.webSocket.maxOutboundFrameSize](./values.yaml#L1432)

     
Optional.  Maximum payload size allowed for an outbound frame. When larger updates have to be sent, the related WebSocket messages will be split into multiple frames. A lower limit for the setting may be enforced by the Server.

**Default:** `16384`
#### [globalSocket.webSocket.maxPongDelayMillis](./values.yaml#L1421)

     
Optional. Maximum time the Server is allowed to wait before answering to a client "ping" request. In case a client sends very frequent "ping" requests, only the "pong" associated to the most recent request received is sent, while the previous requests will be ignored. Note that the above is possible also when `0` is specified.

**Default:** `0`
#### [globalSocket.writeTimeoutMillis](./values.yaml#L1391)

     
Optional. Longest operation time accepted while writing data on a socket. If this value is exceeded, the socket is closed. Note that this may also affect very slow clients. The time actually considered may be approximated and may be a few seconds higher, for internal performance reasons. If missing or `0`, the check is suppressed.

**Default:** `the check is suppressed`
### Security configuration
 
#### [security](./values.yaml#L1435)

     
Optional. Security configuration.

**Default:**

```
{"allowedDomains":[],"crossDomainPolicy":{"acceptCredentials":true,"acceptExtraHeaders":null,"allowAccessFrom":{"fromEveryWere":{"host":"*","port":"*","scheme":"*"}},"optionsMaxAgeSeconds":3600},"enableCookiesForwarding":false,"enableProtectedJs":false,"serverIdentificationPolicy":null}
```
#### [security.crossDomainPolicy](./values.yaml#L1493)

     
Optional. List of origins to be allowed by the browsers to consume responses to requests sent to this Server through cross-origin XHR or through WebSockets; in fact, when a requesting page asks for streaming data in this way, the browser should specify the page origin through the "Origin" HTTP header, to give the Server a chance to accept or refuse the request. This is the most common way streaming data is requested by the Web (Unified API) Client Library. You can see the Client Guide for the Web (Unified API) Client SDK earlier than 8.0.0 for details on all the possible use cases. If a request origin is not matched against any of the configured rules, a Websocket initiation request will be refused, whereas a HTTP request will not be denied (i.e.: a 200 OK will be returned) but the response body will be left empty, in accordance with the CORS specifications. If no origin is specified by the user-agent, the request will always be accepted. Note that sending the Origin header is a client-side duty. In fact, most modern browsers, upon a request for a cross-origin XHR or WebSocket by a page, will send the Origin header, while older browsers will directly fail to send the request. Non-browser clients usually don't have to perform origin checks; so they don't send the Origin header and thus their requests are always authorized.

**Default:**

```
{"acceptCredentials":true,"acceptExtraHeaders":null,"allowAccessFrom":{"fromEveryWere":{"host":"*","port":"*","scheme":"*"}},"optionsMaxAgeSeconds":3600}
```
#### [security.crossDomainPolicy.acceptCredentials](./values.yaml#L1516)

     
Optional. Specify jf the server should authorize the client to send  its credentials on a CORS request. This setting does not impact the user/password sent over the Lightstreamer protocol, but, if set to `false`, might prevent, or force a fallback connection, on clients sending CORS requests carrying cookies, http-basic-authentication or client-side certificates.

**Default:** `false`
#### [security.crossDomainPolicy.acceptExtraHeaders](./values.yaml#L1508)

     
Optional. In case the client wishes to send custom headers to the server, it requires approval from the server itself. This setting permits to specify a comma separated list of extra headers to be allowed in the client requests. Note that a space is expected after each comma (e.g.: `acceptExtraHeaders: "custom-header1, custom-header2"`).

**Default:** `""`
#### [security.crossDomainPolicy.allowAccessFrom](./values.yaml#L1519)

     
Optional. List of Origin allowed to consume responses to cross-origin requests.

**Default:**

```
{"fromEveryWere":{"host":"*","port":"*","scheme":"*"}}
```
#### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere](./values.yaml#L1522)

     
Optional. Defines a rule against which Origin headers will be checked.

**Default:** `{"host":"*","port":"*","scheme":"*"}`
#### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere.host](./values.yaml#L1534)

     
Mandatory. A valid host name, IPv4 or IPv6 representing, an authorized Origin. Also a `*` is accepted with the meaning of "any host or IP". If a host name is specified it can be prefixed with a wildcard as long as at least the second level domain is explicitly specified (i.e.: `*.my-domain.com` and `*.sites.my-domain.com` are valid  entries while `*.com` is not).

**Default:** `"*"`
#### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere.port](./values.yaml#L1536)

     
Mandatory. A a valid port or `*` to specify any port.

**Default:** `"*"`
#### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere.scheme](./values.yaml#L1526)

     
Mandatory. A valid scheme name (usually http or https) or `*`; the latter matches both http and https scheme, but it doesn't match other schemes.

**Default:** `"*"`
#### [security.crossDomainPolicy.optionsMaxAgeSeconds](./values.yaml#L1501)

     
Optional. In case an HTTP OPTIONS request is sent to authorize future requests, the server allows the client to store the result of such OPTIONS for the specified number of seconds. Thus a previously authorized client may not give up its authorization, even if the related origin is removed from the list and the server is restarted, until its  authorization expires.

**Default:** ``3600``
#### [security.enableCookiesForwarding](./values.yaml#L1471)

     
Optional. Use this setting to enable the forwarding of the cookies to the Metadata Adapter through the `httpHeaders` argument of the `notifyUser` method. Please note that in any case cookies should not be used to authenticate users, otherwise, having `enableProtectedJs` set to `false` and/or a too permissive policy in the `crossDomainPolicy` will expose the server to CSRF attacks. If set to `true`, cookies are forwarded to the Metadata Adapter. If set to `false`, cookies are hidden from the Metadata Adapter.

**Default:** `false`
#### [security.enableProtectedJs](./values.yaml#L1460)

     
Optional. Disabling of the protection for JavaScript pages, supplied by the Server, that carry user data. JavaScript pages can be supplied upon requests by old versions of the Web and Node.js (Unified API) Client Libraries, whereas recent versions no longer make use of this kind of pages. The protection prevents such pages from being imported in a _<script>_ block and, as a consequence, from being directly executed within a hosting page regardless of its origin. This protection allows the Server to fully comply with the prescriptions to prevent the so-called "JavaScript Hijacking". If set to `true`, the protection is enabled. If set to `false`, the protection is disabled. It can be set in order to support communication between the application front-end pages and Lightstreamer Server in specific use cases; see the Client Guide for the Web (Unified API) Client SDK earlier than 8.0.0 for details. It can also be set in order to ensure compatibility with even older Web Client Libraries (version 4.1 build 1308 or previous). Note, however, that basic protection against JavaScript Hijacking can still be granted, simply by ensuring that request authorization is never based on information got from the request cookies. This already holds for any session-related request other than session-creation ones, for which the request URL is always checked against the Server-generated session ID. For session-creation requests, this depends on the Metadata Adapter implementation, but can be enforced by setting `enableForwardCookies` to `false`.

**Default:** `true`
#### [security.serverIdentificationPolicy](./values.yaml#L1594)

     
Optional. Server identification policy to be used for all server responses. Upon any HTTP request, the Server identifies itself through the `Server` HTTP response header. However, omitting version information may make external attacks more difficult. If set to `FULL`, the Server identifies itself as: `Lightstreamer Server/X.Y.Z build BBBB (Lightstreamer Push Server - www.lightstreamer.com) EEEEEE edition`. If set to `MINIMAL`, the Server identifies itself, depending on the Edition: for Enterprise edition, as `Lightstreamer Server`; for Community edition, as `Lightstreamer Server (Lightstreamer Push Server - www.lightstreamer.com) COMMUNITY edition`.

**Default:** `FULL`
### Management configuration
 
#### [management](./values.yaml#L1597)

     
Mandatory. Logging and management configuration.

**Default:**

```
{"asyncProcessingThresholdMillis":60000,"collectorMillis":2000,"dashboard":{"availableOnServers":[{"enableJmxTreeVisibility":null,"serverRef":null}],"credentials":[{"enableJmxTreeVisibility":null,"secretRef":null}],"enableAvailabilityOnAllServers":true,"enableHostnameLookup":null,"enableJmxTree":true,"enablePublicAccess":null,"urlPath":null},"enablePasswordVisibilityOnRequestLog":null,"enableStoppingServiceCheck":null,"healthCheck":{"availableOnServers":[],"enableAvailabilityOnAllServers":true},"jmx":{"enableLongListProperties":false,"jmxmpConnector":{"enabled":null,"port":null},"rmiConnector":{"allowCipherSuites":[],"allowProtocols":[],"credentialsSecrets":null,"dataPort":null,"enablePublicAccess":null,"enableTestPorts":true,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"hostName":null,"keyStoreRef":null,"listeningInterface":null,"port":{"enableSsl":false,"value":8888},"removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"testTimeoutMillis":5000},"sessionMbeanAvailability":null},"maxTaskWaitMillis":null,"noLoggingIpAddresses":[],"unexpectedWaitThresholdMillis":0}
```
#### [management.asyncProcessingThresholdMillis](./values.yaml#L1633)

     
Optional. Threshold time for long asynchronous processing alerts. Data and Metadata Adapter calls, even when performed through asynchronous invocations (where available), should still take a reasonable time to complete. This is especially important if limits to the number of concurrent tasks are set; moreover, tasks forgotten for any reason and never completed may cause a memory leak. Hence, the longest current execution time is periodically sampled by the Server Monitor on each pool and, whenever it exceeds this threshold on a pool, a warning is logged. Note that warning messages can be issued repeatedly. A `0` value disables the check.

**Default:** `10000`
#### [management.collectorMillis](./values.yaml#L1648)

     
Mandatory. Sampling time for internal load statistics (Server Monitor). These statistics are available through the JMX interface; some of these statistics are logged bt the Internal Monitor log or can be subscribed to through the internal Monitoring Adapter Set. Full JMX features is an optional feature, available depending on Edition and License Type.

**Default:** `2000`
#### [management.dashboard](./values.yaml#L1884)

     
Optional. Configuration of the Monitoring Dashboard. The dashboard is a webapp whose pages are embedded in Lightstreamer Server and supplied by the internal web server. The main page has several tabs, which provide basic monitoring statistics in graphical form; the last one shows the newly introduced JMX Tree, which enables JMX data view and management from the browser. The Dashboard leans on an internal Adapter Set, named "MONITOR". The following settings configure access restrictions to Monitoring Dashboard pages. ***IMPORTANT***. The Monitoring Dashboard enables data view and management, including the Server shutdown operation, from a remote browser. We recommend configuring the credentials and protecting them by making the Monitoring Dashboard only available on https server sockets through the settings below. Further restrictions can be applied to the JMX Tree only. See PRODUCTION_SECURITY_NOTES.TXT for a full check-list. Note that basic monitoring statistics are also available to any Lightstreamer application; in fact, an instance of a special internal monitoring Data Adapter can be embedded in any custom Adapter Set, by specifying "MONITOR" in place of the Data Adapter class name. For a listing of the supplied items, see the General Concepts document. The `dashboard.enableHostnameLookup` setting below also affects the monitoring Data Adapter. On the other hand, access restrictions to a monitoring Data Adapter instance embedded in a custom Adapter Set is only managed by the custom Metadata Adapter included.

**Default:**

```
{"availableOnServers":[{"enableJmxTreeVisibility":null,"serverRef":null}],"credentials":[{"enableJmxTreeVisibility":null,"secretRef":null}],"enableAvailabilityOnAllServers":true,"enableHostnameLookup":null,"enableJmxTree":true,"enablePublicAccess":null,"urlPath":null}
```
#### [management.dashboard.availableOnServers](./values.yaml#L1941)

     
Optional, but ineffective if `enableAvailabilityOnAllServers` is set to `true`. List of server socket configurations (defined in `servers.{}`) for which requests to the Monitoring Dashboard will be allowed.

**Default:**

```
[{"enableJmxTreeVisibility":null,"serverRef":null}]
```
#### [management.dashboard.availableOnServers[0].serverRef](./values.yaml#L1944)

     
Mandatory. The reference to the allowed server socket  configuration.

**Default:** `nil`
#### [management.dashboard.credentials](./values.yaml#L1914)

     
Optional, but ineffective if `enablePublicAccess` is set to `true`. Credentials of the users enabled to access the Monitoring Dashboard. If `enablePublicAccess` is set to `false`, at least one set of  credentials should be supplied in order to allow access through the connector.

**Default:** `[]`
#### [management.dashboard.credentials[0].secretRef](./values.yaml#L1918)

     
The reference to the secret containing the credentials of the user enabled to access the Monitoring Dashboard. The secret must contain the keys `user` and `password`.

**Default:** `nil`
#### [management.dashboard.enableAvailabilityOnAllServers](./values.yaml#L1937)

     
Optional. Enabling of the access to the Monitoring Dashboard pages through all server sockets. If set to `true`, requests to the Monitoring Dashboard can be issued through all the defined server sockets. If set to `false`, requests to the Monitoring Dashboard can be issued only through the server sockets specified in the `availableOnServers` setting, if any; otherwise, requests to the dashboard url will get a "page not found" error. If no `availableOnServers` setting is defined, requests to the Monitoring Dashboard will not be possible in any way. Disabling the Dashboard on a server socket causes the internal "MONITOR" Adapter Set to also become unavailable from that socket. This does not affect in any way the special "MONITOR" Data Adapter.

**Default:** `false`
#### [management.dashboard.enableHostnameLookup](./values.yaml#L1964)

     
Optional. Enabling of the reverse lookup on Client IPs and inclusion of the Client hostnames while monitoring client activity. This setting affects the Monitor Console page and also affects any instance of the monitoring Data Adapter embedded in a custom Adapter Set. If set to `true`, the Client hostname is determined on Client activity monitoring; note that the determination of the client hostname may be heavy for some systems. If set to `false`, no reverse lookup is performed and the Client hostname is not included on Client activity monitoring.

**Default:** `false`
#### [management.dashboard.enableJmxTree](./values.yaml#L1896)

     
Optional. Enabling of the requests for the JMX Tree page, which is part of the Monitoring Dashboard. This page, whose implementation is based on the "jminix" library, enables JMX data view and management, including the Server shutdown operation, from the browser. If set to `true`, the Server supports requests for JMX Tree pages, though further fine-grained restrictions may also apply. If set to `false`, the Server ignores requests for JMX Tree pages, regardless of the credentials supplied and the server socket in use; the dashboard tab will just show a "disabled page" notification.

**Default:** `false`
#### [management.dashboard.enablePublicAccess](./values.yaml#L1907)

     
Optional. Enabling of the access to the Monitoring Dashboard pages without credentials. If set to `true`, requests for the Monitoring Dashboard are always accepted. If set to `false`, requests for the Monitoring Dashboard are subject to a check for credentials to be specified through the `credentials` settings; hence, a user credential submission dialog may be presented by the browser. If no `credentials` settings is defined, the Monitoring  Dashboard will not be accessible in any way.

**Default:** `false`
#### [management.dashboard.urlPath](./values.yaml#L1953)

     
Optional. URL path to map the Monitoring Dashboard pages to. An absolute path must be specified.

**Default:** `/dashboard`
#### [management.enablePasswordVisibilityOnRequestLog](./values.yaml#L1611)

     
Optional. Enabling of the inclusion of the user password in the log of the client requests for new sessions, performed by the `lightstreamerLogger.requests` logger at `INFO` level. If set to `true`, the whole request is logged. If set to `false`, the request is logged, but for the value of the `LS_password` request parameter. Note that the whole request may still be logged by some loggers, but only at `DEBUG` level, which is never enabled in the default configuration.

**Default:** `false`
#### [management.enableStoppingServiceCheck](./values.yaml#L1859)

     
Optional. Startup check that the conditions for the correct working of the provided "stop" script are met (see `jmx`). If set to `true`, the startup will wail if the JMX RMI connector is not configured or the `ServerMBean` cannot bet started. This also enforces the check of the JMX port reachability ( see `rmiConnector.enableTestPorts` and the remarks on the test effectiveness); if the test fails, the startup will also fail. If set to `false`, no check is made that the "stop" script should work. This may not be a problem, because the Server can be stopped in other ways. The provided installation scripts also close the Server without resorting to the "stop" script.

**Default:** `false`
#### [management.healthCheck](./values.yaml#L1972)

     
Optional. Configuration of the `/lightstreamer/healthcheck` request url, which allows a load balancer to test for Server responsiveness to external requests. The Server should always answer to the request with the `OK\r\n` content string (unless overridden through e JMX interface). The Server may log further information to the dedicated `lightstreamerHealthCheck` logger. Support for clustering is an optional feature, available depending on Edition and License Type.

**Default:**

```
{"availableOnServers":[],"enableAvailabilityOnAllServers":true}
```
#### [management.healthCheck.availableOnServers](./values.yaml#L1984)

     
Optional, but ineffective if `enableAvailabilityOnAllServers` is set to `false`. List of server socket configurations (defined in  `servers.{}`) for which healthcheck requests can be issued.

**Default:** `[]`
#### [management.healthCheck.enableAvailabilityOnAllServers](./values.yaml#L1979)

     
Optional. Enabling of the healthcheck url on all server sockets. If set to `true`, the healthcheck request can be issued through all the defined server sockets. If set to `false`, the healthcheck request can be issued only through the server sockets specified in the `availableOnServers` setting, if any.

**Default:** `false`
#### [management.jmx](./values.yaml#L1656)

     
Mandatory (if you wish to use the provided "stop" script). JMX preferences and external access configuration. Full JMX features is an optional feature, available depending on Edition and License Type; if not available, only the Server shutdown operation via JMX is allowed. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at `/dashboard`).

**Default:**

```
{"enableLongListProperties":false,"jmxmpConnector":{"enabled":null,"port":null},"rmiConnector":{"allowCipherSuites":[],"allowProtocols":[],"credentialsSecrets":null,"dataPort":null,"enablePublicAccess":null,"enableTestPorts":true,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"hostName":null,"keyStoreRef":null,"listeningInterface":null,"port":{"enableSsl":false,"value":8888},"removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"testTimeoutMillis":5000},"sessionMbeanAvailability":null}
```
#### [management.jmx.enableLongListProperties](./values.yaml#L1846)

     
Optional. Enabling of all properties provided by the various MBeans. This flag could potentially cause MBeans to return extremely long lists. In act, various JMX agents extract the property values from the MBeans altogether; but extremely long values may clutter the agent and prevent also the acquisition of other properties. This issue may also affect the JMX Tree. For all these properties, corresponding operations are also provided. If set to `true`, all list properties are enabled; in some cases, their value may be an extremely long list; consider, for instance, `CurrentSessionList` in the `ResourceMBean`. If set to `false`, properties that can, potentially, return extremely long lists won't yield the correct value, but just a reminder text; for instance, this applies to `CurrentSessionList` in the `ResourceMBean`.

**Default:** `true`
#### [management.jmx.jmxmpConnector](./values.yaml#L1809)

     
Optional. JMXMP connector configuration. The connector is supported by the Server only if Sun/Oracle's JMXMP implementation library is added to the Server classpath; see README.TXT in the JMX SDK for details. The remote server will be accessible through the url: `service:jmx:jmxmp://<host>:<jmxmpConnector.port>`.

**Default:** `{"enabled":null,"port":null}`
#### [management.jmx.jmxmpConnector.enabled](./values.yaml#L1812)

     
Optional. Enables Sun/Oracle's JMXMP connector.

**Default:** `false`
#### [management.jmx.jmxmpConnector.port](./values.yaml#L1816)

     
Mandatory if enabled is set to `true`. TCP port on which Sun/Oracle's JMXMP connector will be listening. This is the port that has to be specified in the client access url.

**Default:** `nil`
#### [management.jmx.rmiConnector](./values.yaml#L1672)

     
Mandatory (if you wish to use the provided "stop" script). Enables the standard RMI connector. The remote MBean server will be accessible through this url: `service:jmx:rmi:///jndi/rmi://<host>:<port>/lsjmx`. If full JMX features is not available, only the `Server` MBean is supplied and only the Server shutdown operation is available. The JVM platform MBean server is also exposed and it is accessible through the url: `service:jmx:rmi:///jndi/rmi://<host>:<port>/jmxrmi`. Note that the configuration of the connector applies to both cases; hence, access to the JVM platform MBean server from this connector is not configured through the `com.sun.management.jmxremote` JVM properties. Also note that TLS/SSL is an optional feature, available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at `/dashboard`).

**Default:**

```
{"allowCipherSuites":[],"allowProtocols":[],"credentialsSecrets":null,"dataPort":null,"enablePublicAccess":null,"enableTestPorts":true,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"hostName":null,"keyStoreRef":null,"listeningInterface":null,"port":{"enableSsl":false,"value":8888},"removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"testTimeoutMillis":5000}
```
#### [management.jmx.rmiConnector.allowCipherSuites](./values.yaml#L1751)

     
Optional, but forbidden if `removeCipherSuites` is used. Specifies all the cipher suites allowed for the interaction, in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.allowCipherSuites`.

**Default:** `[]`
#### [management.jmx.rmiConnector.allowProtocols](./values.yaml#L1773)

     
Optional, but forbidden if `removeProtocols` is used. Specifies one or more protocols allowed for the TLS/SSL interaction, in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.allowProtocols`.

**Default:** `[]`
#### [management.jmx.rmiConnector.credentialsSecrets](./values.yaml#L1802)

     
Optional, but ineffective if `enablePublicAccess` is set to  `true`. The reference to the secrets containing the credentials of the users enabled to access the RMI connector. Every secret must contains the keys `user` and `password`. If `enablePublicAccess` is set to `false`, at least one set of credentials should be supplied in order to allow access through the connector. This is also needed if you wish to use the provided "stop" script; the script will always use the first user supplied.

**Default:** `[]`
#### [management.jmx.rmiConnector.dataPort](./values.yaml#L1689)

     
Optional. TCP port that will be used by the RMI connector for its own communication stuff. The port has not to be specified in the client access url, but it may have to be considered for firewall settings. The optional `enableSsl` setting, when set to `false`, enables TLS/SSL communication by the connector; TLS/SSL at this level is supported by some JMX clients, like jconsole, that don't supportTLS/SSL on the main port.

**Default:**

```
the same as config used in rmiConnector.port
```
#### [management.jmx.rmiConnector.enablePublicAccess](./values.yaml#L1791)

     
Optional. Enabling of the RMI connector access without credentials. If set to `true`, requests to the RMI connector are always allowed. If set to `false`, requests to the RMI connector are subject to user authentication; the allowed users are set in the "user" elements.

**Default:** `false`
#### [management.jmx.rmiConnector.enableTestPorts](./values.yaml#L1712)

     
Optional. Enabling of a preliminary test on the reachability of the  RMI Server through the configured hostname. Note that the reachability  is not needed for the Server itself, so the test is only for the  benefit of other clients, including the "stop" script; but, since other clients may be run in different environments, the outcome of this test may not be significant. If set to `true`, enables the test; if the test fails, the whole Server startup will fail. If successful and the "stop" script is launched in the same environment of the Server, the script should work. If set to `false`, disables the test, but this setting can be overridden by setting jmx.enableStoppingServiceCheck to `true`.

**Default:** `true`
#### [management.jmx.rmiConnector.enforceServerCipherSuitePreference](./values.yaml#L1766)

     
Optional. Determines which side should express the preference when multiple cipher suites are in common between server and client (in case TLS/SSL is enabled for part or all the communication). See notes for `servers.{}.sslConfig.enforceServerCipherSuitePreference`.

**Default:** `{"enabled":true,"order":"JVM"}`
#### [management.jmx.rmiConnector.hostName](./values.yaml#L1699)

     
Optional. A hostname by which the RMI Server can be reached from all the clients. In fact, the RMI Connector, for its own  communication stuff, does not use the hostname specified in the client  access url, but needs an explicit server-side configuration. Note that, if you wish to use the provided "stop" script, the specified hostname has to be visible also from local clients.

**Default:**

```
the value of the java.rmi.server.hostname JVM property
```
#### [management.jmx.rmiConnector.keyStoreRef](./values.yaml#L1745)

     
Mandatory if either `port.enableSsl` or `dataPort.enableSsl` is set  to true. The reference to a keystore configuration (defined in  `keystore`) to be used in case TLS/SSL is enabled for part or all of  the communication. See the `keystores.myServerKeystore` for general details on keystore configuration. These include the runtime replacement of the keystore, with one difference: if the load of the new keystore fails, the RMI Connector may be left unreachable.

**Default:** `nil`
#### [management.jmx.rmiConnector.listeningInterface](./values.yaml#L1736)

     
Optional. Can be used on a multihomed host to specify the IP address to bind the HTTP/HTTPS server sockets to, for all the communication. Note that, when a listening interface is configured and depending on the local network configuration, specifying a suitable `rmiConnector.hostname` setting may be needed to make the connector accessible, even from local clients.

**Default:**

```
accept connections on any/all local addresses
```
#### [management.jmx.rmiConnector.port](./values.yaml#L1678)

     
Mandatory. TCP port on which the RMI connector will be available. This is the port that has to be specified in the client access url. The optional `enableSsl` setting, when set to `true`, enables TLS/SSL communication. Note that this case is not managed by some JMX clients, like jconsole.

**Default:** `{"enableSsl":false,"value":8888}`
#### [management.jmx.rmiConnector.removeCipherSuites](./values.yaml#L1759)

     
Optional, but forbidden if `allowCipherSuites` is used. Pattern to be matched against the names of the enabled cipher suites in order to remove the matching ones from the enabled cipher suites set to be used in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.removeCipherSuites`.

**Default:** `[]`
#### [management.jmx.rmiConnector.removeProtocols](./values.yaml#L1782)

     
Optional, but forbidden if `allowProtocols` is used. Pattern to be matched against the names of the enabled TLS/SSL protocols in order to remove the matching ones from the enabled protocols set to be used in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.removeProtocols`.

**Default:** `["SSL","TLSv1$","TLSv1.1"]`
#### [management.jmx.rmiConnector.testTimeoutMillis](./values.yaml#L1727)

     
Optional. Timeout to be posed on the connection attempts  through the RMI Connector. If `0`, no timeout will be posed. The setting affects: - The reachability test (if enabled through `enableTestPorts`). - The connector setup operation; in fact this operation may involve a   connection attempt, whose failure, however, would not prevent the   setup from being successful. If the configured hostname were not   visible locally, the setup might take long time; by setting a   timeout, the operation would not block the whole Server startup.   However, the RMI Connector (and the "stop" script) might not be   available immediately after the startup, and any late failure   preventing the connector setup would be ignored. On the other hand, the setting is ignored by the "stop" script.

**Default:** `0`
#### [management.jmx.sessionMbeanAvailability](./values.yaml#L1831)

     
Optional. Enabling of the availability of session-related mbeans, the  ones identified by `type="Session"`. If set to `active`, for each active session, a corresponding mbean of type `Session` is available with full functionality. If set to `sampled_statistics_only`, for each active session, a corresponding mbean of type `Session` is available, but all the statistics based on periodic sampling are disabled. If set to `inactive`, no mbeans of type `Session` are generated, but for a fake mbean which acts as a reminder that the option can be enabled. The support for session-related mbeans can pose a significant overload on the Server when many sessions are active and many of them are continuously created and closed. For this reason, the support is disabled by default.

**Default:** `inactive`
#### [management.maxTaskWaitMillis](./values.yaml#L1641)

     
Optional. Threshold wait time for a task enqueued for running on any of the internal thread pools. The current wait time is periodically sampled by the Server Monitor on each pool and, whenever it exceeds this threshold on a pool, a warning is logged. Note that warning messages can be issued repeatedly. A `0` value disables the check.

**Default:** `10000`
#### [management.noLoggingIpAddresses](./values.yaml#L1600)

     
Optional. A set of Clients whose activity is not to be logged.

**Default:** `[]`
#### [management.unexpectedWaitThresholdMillis](./values.yaml#L1621)

     
Optional. Threshold time for long Adapter call alerts. All Data and Metadata Adapter calls should perform as fast as possible, to ensure that client requests are accomplished quickly. Slow methods may also require that proper thread pools are configured. Hence, all invocations to the Adapters (but for the initialization phase) are monitored and a warning is logged whenever their execution takes more than this time. A `0` value disables the check.

**Default:** `1000`
### PushSession configuration
 
#### [pushSession](./values.yaml#L1987)

     
Mandatory. Push session configuration.

**Default:**

```
{"compressionThreshold":null,"contentLength":{"default":4000000,"specialCases":null},"defaultDiffOrders":[],"defaultKeepaliveMillis":{"randomize":false,"value":5000},"enableDeltaDelivery":null,"enableEnrichedContentType":null,"jsonPatchMinLength":null,"maxBufferSize":"1000","maxDelayMillis":30,"maxIdleMillis":{"randomize":false,"value":30000},"maxKeepaliveMillis":30000,"maxPollingMillis":15000,"maxRecoveryLength":null,"maxRecoveryPollLength":null,"maxStreamingMillis":null,"minInterPollMillis":null,"minKeepaliveMillis":1000,"missingMessageTimeoutMillis":null,"preserveUnfilteredCommandOrdering":null,"reusePumpBuffers":null,"sendbuf":null,"serviceUrlPrefixes":[],"sessionRecoveryMillis":13000,"sessionTimeoutMillis":10000,"subscriptionTimeoutMillis":5000,"useChunkedEncoding":null,"useCompression":null}
```
#### [pushSession.compressionThreshold](./values.yaml#L2087)

     
Optional. Size in bytes of the response body below which compression is not applied, regardless of the `useCompression` setting, as we guess that no benefit would come. It is not applied to streaming responses, which are compressed incrementally.

**Default:** `1024`
#### [pushSession.contentLength](./values.yaml#L2020)

     
Mandatory. Maximum size of HTTP streaming responses; when the maximum size is reached, the connection is closed but the session remains active and the Client can continue listening to the item update events by binding the session to another connection. This setting is also used as the maximum length allowed for poll responses; if more data were available, they would be kept for the next poll request. The Setting is not used for streaming responses over WebSockets. The optimal content-length for web clients (i.e. browser user agents) should not be too high, in order to reduce the maximum allocated memory on the client side. Also note that some browsers, in case of a very high content-length, may reduce streaming capabilities (noticed with  IE8 and 4GB). This setting can be overridden by the Clients (some LS client libraries actually set their own default). The lowest possible value for the content-length is decided by the Server, so as to allow the connection to send a minimal amount of data.

**Default:** `{"default":4000000,"specialCases":null}`
#### [pushSession.contentLength.default](./values.yaml#L2023)

     
Mandatory. Define the maximum size of HTTP streaming responses (and the upper limit for polling responses)

**Default:** `4000000`
#### [pushSession.contentLength.specialCases](./values.yaml#L2029)

     
Optional. List of special cases for defining the HTTP content-length to be used for stream/poll response (through `specialCases[].value`) when the user-agent supplied with the request contains all the specified string (through the`specialCases[].userAgentContains`). Special cases are evaluated in sequence, until one is enabled.

**Default:** `nil`
#### [pushSession.defaultDiffOrders](./values.yaml#L2243)

     
Optional. List of algorithms to be tried by default to perform the "delta delivery" of changed fields in terms of difference between previous and new value. This list is applied only on fields of items for which no specific information is provided by the Data Adapter. For each value to be sent to some client, the algorithms are tried in the order specified by this list, until one is found which is compatible with both client capabilities and the involved values. Available names are: - `jsonpatch`: computes the difference in JSON Patch format, provided that the values are valid JSON representations; - `diff_match_patch`: computes the difference with Google's "diff-match-patch" algorithm ( the result is then serialized to the custom "TLCP-diff" format). Note that trying "diff" algorithms on unsuitable data may waste resources. For this reason, the default algorithm list is empty,which means that no algorithm is ever tried by default. The best way to enforce algorithms is to do that on a field-by-field basis through the Data Adapter interface.

**Default:** `[]`
#### [pushSession.defaultKeepaliveMillis](./values.yaml#L2318)

     
Mandatory. Default keep-alive configuration.

**Default:** `{"randomize":false,"value":5000}`
#### [pushSession.defaultKeepaliveMillis.randomize](./values.yaml#L2333)

     
Optional. If set to `true`, causes keepalives immediately following a data event to be sent after a random, shorter interval (possibly even shorter than the `minKeepaliveMillis` setting). This can be useful if many sessions subscribe to the same items and updates for these items are rare, to avoid that also the keepalives for these sessions occur at the same times.

**Default:** `false`
#### [pushSession.defaultKeepaliveMillis.value](./values.yaml#L2325)

     
Mandatory. Longest write inactivity time allowed on the socket. If no updates have been sent after this time, then a small keep-alive message is sent. Note that the Server also tries other types of checks of the availability of current sockets, which don't involve writing data to the sockets. This setting can be overridden by the Client.

**Default:** `5000`
#### [pushSession.enableDeltaDelivery](./values.yaml#L2224)

     
Optional. Configuration of the policy adopted for the delivery of updates to the clients. If set to `true`, the Server is allowed to perform "delta delivery"; it will send special notifications to notify the clients of values that are unchanged with respect to the previous update for the same item; moreover, if supported by the client SDK, it may send the difference between previous and new value for updates which involve a small change. If set to `false`, the Server always sends to the clients the actual values in the updates; note that any missing field in an update from the Data Adapter for an item in `MERGE` mode is just a shortcut for an unchanged value, hence the old value will be resent anyway. Adopting the "delta delivery" is in general more efficient than always sending the values. On the other hand, checking for unchanged values and/or evaluating the difference between values puts heavier memory and processing requirements on the Server. In case "delta delivery" is adopted, the burden of recalling the previous values is left to the clients. This holds for clients based on the "SDK for Generic Client Development". This also holds for clients based on some old versions of the provided SDK libraries, which just forward the special unchanged notifications through the API interface. Old versions of the .NET, Java SE (but for the ls_proxy interface layer), Native Flex and Java ME libraries share this behavior. Forcing a redundant delivery would simplify the client code in all the above cases.

**Default:** `true`
#### [pushSession.enableEnrichedContentType](./values.yaml#L2096)

     
Optional. Configuration of the content-type to be specified in the response headers when answering to session requests issued by native client libraries and custom clients. If set to `true`, the server will specify the `text/enriched` content-type. This setting might be preferable when communicating over certain service providers that may otherwise buffer streaming connections. if set to `false`, the server will specify the `text/plain` content-type.

**Default:** `true`
#### [pushSession.jsonPatchMinLength](./values.yaml#L2257)

     
Optional. Minimum length among two update values (old and new) which enables the use of the JSON Patch format to express the new value as the difference with respect to the old one, when this is possible. If any value is shorter, it will be assumed that the computation of the difference in this way will yield no benefit. The special value `none` is also available. In this case, when the computation of the difference in JSON Patch format is possible, it will always be used, regardless of efficiency reasons. This can be leveraged in special application scenarios, when the clients require to directly retrieve the updates in the form of JSON Patch differences.

**Default:** `50`
#### [pushSession.maxBufferSize](./values.yaml#L2117)

     
Optional. Maximum size for any `ItemEventBuffer`. It applies to `RAW` and `COMMAND` mode and to any other case of unfiltered subscription. For filtered subscriptions, it poses an upper limit on the maximum buffer size that can be granted by the Metadata Adapter or requested through the subscription parameters. Similarly, it poses an upper limit to the length of the snapshot that can be sent in `DISTINCT` mode, regardless of the  value returned by `getDistinctSnapshotLength`. See the General Concepts document for details on when these buffers are used. An excessive use of these buffers may give rise to a significant memory footprint; to prevent this, a lower size limit can be set. Note that the buffer size setting refers to the number of update events that can be kept in the buffer, hence the consequent memory usage also depends on the size of the values carried by the enqueued updates. As lost updates for unfiltered subscriptions are logged on the `lightstreamerLogger.pump` logger at `INFO` level, if a low buffer size limit is set, it is advisable also setting this logger at `WARN` level. Aggregate statistics on lost updates are also provided by the JMX interface (if available) and by the Internal Monitor.

**Default:** `unlimited size`
#### [pushSession.maxDelayMillis](./values.yaml#L2316)

     
Optional. Longest delay that the Server is allowed to apply to outgoing updates to collect more updates in the same packet. This value sets a trade-off between Server scalability and maximum data latency. It also sets an upper bound to the maximum update frequency for items not subscribed with unlimited or unfiltered frequency.

**Default:** `0`
#### [pushSession.maxIdleMillis](./values.yaml#L2353)

     
Mandatory. Max idle configuration.

**Default:** `{"randomize":false,"value":30000}`
#### [pushSession.maxIdleMillis.randomize](./values.yaml#L2367)

     
Optional. If set to `true`, causes polls immediately following a data event to wait for a random, shorter inactivity time. This can be useful if many sessions subscribe to the same items and updates for these items are rare, to avoid that also the following polls for these sessions occur at the same times.

**Default:** `false`
#### [pushSession.maxIdleMillis.value](./values.yaml#L2360)

     
Mandatory. Longest inactivity time allowed on the socket while waiting for updates to be sent to the client through the response to asynchronous poll request. If this time elapses, the request is answered with no data, but the client can still rebind to the session with a new poll request. A shorter inactivity time limit can be requested by the client.

**Default:** `30000`
#### [pushSession.maxKeepaliveMillis](./values.yaml#L2341)

     
Mandatory. Upper bound to the keep-alive time requested by a Client. Must be greater than the `pushSession.defaultKeepaliveMillis` setting.

**Default:** `30000`
#### [pushSession.maxPollingMillis](./values.yaml#L2351)

     
Mandatory. Longest time a client is allowed to wait, after receiving a poll answer, before issuing the next poll request. Note that, on exit from a poll request, a session has to be kept active, while waiting for the next poll request. The session keeping time has to be requested by the Client within a poll request, but the Server, within the response, can notify a shorter time, if limited by this setting. The session keeping time for polling may cumulate with the keeping time upon disconnection, as set by `pushSession.sessionTimeoutMillis`

**Default:** `15000`
#### [pushSession.maxRecoveryLength](./values.yaml#L2156)

     
Optional. Maximum number of bytes of streaming data, already sent or being sent to the Client, that should be kept, in order to allow the Client to recover the session, in case a network issue should interrupt the streaming connection and prevent the client from receiving the latest packets. Note that recovery is available only for some client versions; if any other version were involved, no data would be kept. A `0` value also prevents any accumulation of memory.

**Default:**

```
the value configured for pushSession.sendbuf
```
#### [pushSession.maxRecoveryPollLength](./values.yaml#L2166)

     
Optional. Maximum size supported for keeping a polling response, already sent or being sent to the Client, in order to allow the Client to recover the session, in case a network issue should interrupt the polling connection and prevent the client from receiving the latest response. Note that recovery is available only for some client versions; if any other version were involved, no data would be kept. A `0` value also prevents any accumulation of memory. On the other hand, a value of `-1` relieves any limit.

**Default:** `-1`
#### [pushSession.maxStreamingMillis](./values.yaml#L2046)

     
Optional. Maximum lifetime allowed for single HTTP streaming responses; when this timeout expires, the connection is closed, though the session remains active and the Client can continue listening to the `UpdateEvents` by binding the session to another connection. Setting this timeout is not needed in normal cases; it is provided just in case any user agent or intermediary node turned out to be causing issues on very long-lasting HTTP responses. The setting is not applied to polling responses and to streaming responses over WebSockets. If not specified, only by the `pushSession.contentLength` setting and, at least, by the keep-alive message activity

**Default:**

```
no limit is set; the streaming session duration will be limited
```
#### [pushSession.minInterPollMillis](./values.yaml#L2380)

     
Optional. Shortest time allowed between consecutive polls on a session. If the client issues a new polling request and less than this time has elapsed since the STARTING of the previous polling request, the polling connection is kept waiting until this time has elapsed. In fact, neither a `pushSession.minPollingMillis` nor a `pushSession.maxPollingMillis` setting are provided, hence a client is allowed to request `0` for both, so that the real polling frequency will only be determined by roundtrip times. However, in order to avoid that a similar case causes too much load on the Server, this setting can be used as a protection, to limit the polling frequency.

**Default:** `0`
#### [pushSession.minKeepaliveMillis](./values.yaml#L2337)

     
Mandatory. Lower bound to the keep-alive time requested by a Client. Must be lower than the `pushSession.defaultKeepaliveMillis` setting.

**Default:** `1000`
#### [pushSession.missingMessageTimeoutMillis](./values.yaml#L2198)

     
Optional. Timeout used to ensure the proper ordering of client-sent messages, within the specified message sequence, before sending them to the Metadata Adapter through `notifyUserMessage`. In case a client request is late or does not reach the Server, the next request may be delayed until this timeout expires, while waiting for the late request to be received; then, the next request is forwarded and the missing one is discarded with no further recovery and the client application is notified. Message ordering does not concern the old synchronous interfaces for message submission. Ordering and delaying also does not apply to the special "UNORDERED_MESSAGES" sequence, although, in this case, discarding of late messages is still possible, in order to ensure that the client eventually gets a notification. A high timeout (as the default one) reduces the discarded messages, by allowing the client library to reissue requests that have got lost. A low timeout reduces the delays of subsequent messages in case a request has got lost and can be used if message dropping is acceptable.

**Default:** `30000`
#### [pushSession.preserveUnfilteredCommandOrdering](./values.yaml#L2272)

     
Optional. Configuration of the update management for items subscribed to in `COMMAND` mode with unfiltered dispatching. If set to `true`, the order in which updates are received from the Data Adapter is preserved when sending updates to the clients; in this case, any frequency limits imposed by license limitations are applied to the whole item and may result in a very slow update flow. If set to `false`, provided that no updates are lost, the Server can send enqueued updates in whichever order; it must only ensure that, for updates pertaining to the same key, the order in which updates are received from the Data Adapter is preserved; in this case, any frequency limits imposed by license limitations are applied for each key independently. No item-level choice is possible. However, setting this flag as `true` allows for backward compatibility to versions before 4.0, if needed.

**Default:** `false`
#### [pushSession.reusePumpBuffers](./values.yaml#L2287)

     
Optional. Policy to be adopted for the handling of session-related data when a session is closed. If set to `Y`, internal buffers used for composing and sending updates are kept among session-related data throughout the life of each session; this speeds up update management. If set to `N`, internal buffers used for composing and sending updates are allocated and deallocated on demand; this minimizes the requirements in terms of permanent per-session memory and may be needed in order to handle a very high number of concurrent sessions, provided that the per-session update activity is low from memory when the session is closed. If set to `AUTO`, the current setting of `pushSession.enableDeltaDelivery` is used; in fact, setting `pushSession.enableDeltaDeliver` as `false` may denote  the need for reducing permanent per-session memory.

**Default:** `AUTO`
#### [pushSession.sendbuf](./values.yaml#L2309)

     
Optional. Size to be set for the socket TCP send buffer in case of streaming connections. The ideal setting should be a compromise between throughput, data aging, and memory usage. A large value may increase throughput, particularly in sessions with a high update activity and a high roundtrip time; however, in case of sudden network congestion, the queue of outbound updates would need longer to be cleared and these updates would reach the client with significant delays. On the other hand, with a small buffer, in case of sudden network congestion, most of the ready updates would not be enqueued in the TCP send buffer, but inside the Server, where there would be an opportunity to conflate them with newer updates. The main problem with a small buffer is when a single update is very big, or a big snapshot has to be sent, and the roundtrip time is high; in this case, the delivery could be slow. However, the Server tries to detect these cases and temporarily enlarge the buffer. Hence, the factory setting is very small and it is comparable with a typical packet size. There shouldn't be any need for an even smaller value; also note that the system may force a minimum size. Higher values should make sense only if the expected throughput is high and responsive updates are desired.

**Default:** `1600`
#### [pushSession.serviceUrlPrefixes](./values.yaml#L2003)

     
Optional. If used, defines one or multiple alternative url paths for all requests related to the streaming services, which will be composed by the specified prefix followed by `/lightstreamer`. Then it will be possible to instruct the Unified Client SDKs to use an alternative path by adding its prefix to the supplied Server address. The specified path prefixes must be absolute. Note that, regardless of this setting, the standard path, which is `/lightstreamer`, is always active. By supporting dedicated paths, it becomes possible to address different Server installations with the same hostname, by instructing an intermediate proxy to forward each client request to the proper place based on the prefix, even if the prefix is not stripped off by the proxy. However, this support does not apply to the Internal Web Server and to the Monitoring Dashboard.

**Default:** `[]`
#### [pushSession.sessionRecoveryMillis](./values.yaml#L2146)

     
Optional. Longest time a session can be kept alive, after the interruption of a connection at network level, waiting for the Client to attempt a recovery. Since a disconnection may affect the Client without affecting the Server, this also instructs the Server to keep track of the events already sent for this time duration, to support unexpected recovery requests. The client should try a recovery request immediately after detecting the interruption; but, the request may come later when, for instance: - there is a network outage of a few seconds and the client must retry, - the client detects the interruption because of the stalled timeout. Hence, the optimal value should be tuned according with client-side timeouts to ensure the better coverage of cases. Note that recovery is available only for some client versions; if any other version were involved, the session would be closed immediately. A `0` value also prevents any accumulation of memory.

**Default:** `0`
#### [pushSession.sessionTimeoutMillis](./values.yaml#L2129)

     
Mandatory. Longest time a disconnected session can be kept alive while waiting for the Client to rebind such session to another connection, in order to make up for client or network latencies. Note that the wait is not performed when the session is being closed because of an explicit disconnection by the client. If the client has requested an inactivity check on a streaming connection, the same timeout is also started when no control request or reverse heartbeat) has been received for the agreed time (again, in order to make up for client or network latencies). If it expires, the current streaming connection will be ended and the client will be requested to rebind to the session (which triggers the previous case).

**Default:** `10000`
#### [pushSession.subscriptionTimeoutMillis](./values.yaml#L2179)

     
Optional. Longest time the subscriptions currently in place on a session can be kept active after the session has been closed, in order to prevent unsubscriptions from the Data Adapter that would be immediately followed by new subscriptions in case the client were just refreshing the page. As a consequence of this wait, some items might temporarily appear as being subscribed to, even if no session were using them. If a session is closed after being kept active because of the `pushSession.sessionTimeoutMillis` or `pushSession.sessionRecoveryMillis` setting, the accomplished wait is considered as valid also for the subscription wait purpose.

**Default:**

```
the time configured for pushSession.sessionTimeoutMillis
```
#### [pushSession.useChunkedEncoding](./values.yaml#L2062)

     
Optional. Enabling the use of the "chunked" transfer encoding, as defined by the HTTP 1.1 specifications, for sending the response body on HTTP streaming connections. If set to `Y`, the "chunked" transfer encoding will be used anytime an HTTP 1.1 response is allowed, which will enforce the use of HTTP 1.1 (see `globalSocket.useHttpVersion`). If set to `N`, causes no transfer encoding (that is, the "identity" transfer encoding) to be used for all kinds of responses. If set to `AUTO`, the "chunked" transfer encoding will be used only when an HTTP 1.1 response is being sent (see `globalSocket.useHttpVersion`). Though with "chunked" transfer encoding the content-length header is not needed on the HTTP response header, configuring a content length for the Server is still mandatory and the setting is obeyed in order to put a limit to the response length.

**Default:** `true`
#### [pushSession.useCompression](./values.yaml#L2081)

     
Optional. Enabling the use of the "gzip" content encoding, as defined by the HTTP 1.1 specifications, for sending the resource contents on HTTP responses; compression is currently not supported for responses over WebSockets. If set to `Y`, Gzip compression will be used anytime an HTTP 1.1 response is allowed (for streaming responses, the "chunked" transfer encoding should also be allowed), provided that the client has declared to accept it through the proper http request headers. If set to `N`, causes no specific content encoding to be applied for all kinds of contents. If set to `AUTO`, Gzip compression will not be used, unless using it is recommended in order to handle special cases (and provided that all the conditions for compression are met; see case `Y` above). Streaming responses are compressed incrementally. The use of compression may relieve the network level at the expense of the Server performance. Note that bandwidth control and output statistics are still based on the non-compressed content.

**Default:** `AUTO`
### Mpn configuration
 
#### [mpn](./values.yaml#L2392)

     
Optional. Mobile Push Notification (MPN) module configuration. This module is able to receive updates from an item subscription on behalf of a user, and forward them to a mobile push notification service, such as Apple's APNs or Google's FCM. If not defined, the MPN module will not start in any case, and all requests related to mobile push notifications will be rejected. Mobile Push Notification support is an optional feature, available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at `/dashboard`).

**Default:**

```
{"activationOnStartUp":{"enabled":null,"maxDelayMillis":null},"appleNotifierConfig":{"apps":{"myApp":{"enabled":null,"id":null,"keystoreRef":null,"pushPackageFileRef":null,"serviceLevel":null,"triggerExpressions":[]}},"connectionTimeoutMillis":null,"keyStores":{"myAppKeystore":{"keystoreFileSecretRef":null,"keystorePasswordSecretRef":null}},"maxConcurrentConnections":null,"minSendDelayMillis":null},"appleWebServicePath":null,"collectorPeriodMinutes":null,"deviceHandlerPool":{"maxFree":null,"maxSize":null},"deviceInactivityTimeoutMinutes":null,"enableModuleRecovery":null,"enabled":null,"executorPool":{"maxFree":null,"maxSize":null},"googleNotifierConfig":{"apps":{"myApp":{"enabled":null,"packageName":null,"serviceJsonFileRef":null,"serviceLevel":null,"triggerExpressions":[]}},"messagingPoolSize":null,"minSendDelayMillis":null},"hibernateConfig":{"connection":{"credentialsSecretRef":"hsql-factory-secret","dialect":"org.hibernate.dialect.HSQLDialect","jdbcDriverClass":"org.hsqldb.jdbcDriver","jdbcUrl":"jdbc:hsqldb:hsql://localhost:9001"},"optionalConfiguration":{"cache.provider_class":"org.hibernate.cache.internal.NoCacheProvider","current_session_context_class":"thread","hbm2ddl.auto":"update","hikari.connectionTimeout":"5000","show_sql":"false"}},"internalDataAdapter":null,"moduleCheckPeriodMillis":null,"moduleTimeoutMillis":null,"mpnPumpPoolSize":null,"mpnTimerPoolSize":null,"notifierPoolSize":null,"reactionOnDatabaseFailure":"continue_operation","requestTimeoutMillis":null}
```
#### [mpn.activationOnStartUp](./values.yaml#L2490)

     
Optional. Enabling of the startup of the module upon Server startup. If module startup is prevented, or not yet completed, or completed unsuccessfully, the module is inactive. This means that no subscription processing is performed and any client MPN requests are refused.

**Default:** `all settings at their defaults`
#### [mpn.activationOnStartUp.enabled](./values.yaml#L2500)

     
Optional. If set to `true`, a module startup will be initiated immediately at Server startup through the mechanism set by `maxDelay`. If set to `false`, the Server will start with an inactive module. Note: the initialization of a new module (as well as the deactivation of the current module), can be requested at any time through the JMX interface (full JMX features is an optional feature, available depending on Edition and License Type).

**Default:** `true`
#### [mpn.activationOnStartUp.maxDelayMillis](./values.yaml#L2509)

     
Optional, but effective only if `mpn.enableActivationOnStartUp` is set to `true`. If not specified, or set to `-1`, the Server startup will be blocked until module startup completion; if the module startup fails, the Server startup will fail in turn. Otherwise, the Server startup will be blocked only up to the specified delay. If the delay expires, the Server may start with the module temporarily inactive; moreover, if the module startup eventually fails, the Server will keep running with an inactive module.

**Default:** `nil`
#### [mpn.appleNotifierConfig](./values.yaml#L2608)

     
Optional. Apple platforms notifier configuration.

**Default:**

```
{"apps":{"myApp":{"enabled":null,"id":null,"keystoreRef":null,"pushPackageFileRef":null,"serviceLevel":null,"triggerExpressions":[]}},"connectionTimeoutMillis":null,"keyStores":{"myAppKeystore":{"keystoreFileSecretRef":null,"keystorePasswordSecretRef":null}},"maxConcurrentConnections":null,"minSendDelayMillis":null}
```
#### [mpn.appleNotifierConfig.apps](./values.yaml#L2634)

     
Optional. List of apps that should receive mobile push notifications.

**Default:**

```
{"myApp":{"enabled":null,"id":null,"keystoreRef":null,"pushPackageFileRef":null,"serviceLevel":null,"triggerExpressions":[]}}
```
#### [mpn.appleNotifierConfig.apps.myApp](./values.yaml#L2636)

     
An application configuration.

**Default:**

```
{"enabled":null,"id":null,"keystoreRef":null,"pushPackageFileRef":null,"serviceLevel":null,"triggerExpressions":[]}
```
#### [mpn.appleNotifierConfig.apps.myApp.enabled](./values.yaml#L2639)

     
Optional. Enablement of the application configuration.

**Default:** `false`
#### [mpn.appleNotifierConfig.apps.myApp.id](./values.yaml#L2644)

     
Mandatory if `enabled` is set to `true`. The app ID, which corresponds to the bundle ID of the app's binary. Note that for web apps (i.e. targeting Safari push notification) the ID must begin with `web`, e.g.: `web.com.mydomain.myapp`.

**Default:** `nil`
#### [mpn.appleNotifierConfig.apps.myApp.keystoreRef](./values.yaml#L2664)

     
Mandatory if `serviceLevel` is set to `development` or `production`. The reference to the keystore (defined in `mpn.appleNotifierConfig.keyStores`) where Apple's certificate for the app ID is stored.

**Default:** `nil`
#### [mpn.appleNotifierConfig.apps.myApp.pushPackageFileRef](./values.yaml#L2670)

     
Optional. The configmap name and the key where the push package zip file is stored. This file contains a descriptor of the web app (i.e. targeting Safari push notification), and is mandatory only for web apps (ignore in other cases). See the General Concepts document for more information on how to produce this file.

**Default:** `nil`
#### [mpn.appleNotifierConfig.apps.myApp.serviceLevel](./values.yaml#L2658)

     
Mandatory if `enabled` is set to `true`. Specifies the intended service level for the current app ID, must be one of: `test`, `development`, `production`. If set to `test`, notification will be logged only and no connection will be established with Apple's servers. The corresponding logger is `lightstreamerLogger.mpn.apple`, notifications are logged at `INFO` level (see `logging.loggers.lightstreamerLogger.subLoggers.lightstreamerLogger.mpn.apple`). If set to `development` or `production`, notifications will be sent to, respectively, Apple's development or production servers. Note that for web apps (i.e. targeting Safari push notification) the `development` service level should not be used, as there is no corresponding `development` client environment that can receive notifications. Use either `production` or `test`.

**Default:** `nil`
#### [mpn.appleNotifierConfig.apps.myApp.triggerExpressions](./values.yaml#L2696)

     
Optional. List of trigger expressions that will be accepted. Each each item is a Java-compatible regular expression (see java.util.regex.Pattern): triggers requested via client APIs will be compared with each regular expression, and accepted only if there is at least one match. Remember that the MPN Module supports, as trigger, any Java boolean expression, including use of JDK classes and methods, with the addition of field references syntax (see the iOS Client SDK for more information). Hence, this check is a safety measure required to avoid that clients can request triggers potentially dangerous for the Server, as each trigger may contain arbitrary Java code. If left commented out or empty, no triggers will be accepted. Please note that using an "accept all" regular expression like `.*` is possible, but still leaves the Server exposed to the danger of maliciously crafted triggers. Anyway, the Metadata Adapter has a second chance to check for trigger allowance. The example shown below is for a typical notification on threshold, where a field is compared against a numeric constant. Note: submitted trigger expressions are compared with this list of regular expressions after their named-arguments have been converted to indexed-arguments. Always specify fields with the `$[digits]` format, not the `${name}` format.

**Default:** `[]`
#### [mpn.appleNotifierConfig.connectionTimeoutMillis](./values.yaml#L2632)

     
Optional. Timeout for connecting to APNS services. In case of slow outgoing connectivity, increasing the timeout may be beneficial.

**Default:** `30000`
#### [mpn.appleNotifierConfig.keyStores](./values.yaml#L2699)

     
Optional. Keystores definition.

**Default:**

```
{"myAppKeystore":{"keystoreFileSecretRef":null,"keystorePasswordSecretRef":null}}
```
#### [mpn.appleNotifierConfig.keyStores.myAppKeystore](./values.yaml#L2701)

     
Keystore configuration for the app.

**Default:**

```
{"keystoreFileSecretRef":null,"keystorePasswordSecretRef":null}
```
#### [mpn.appleNotifierConfig.keyStores.myAppKeystore.keystoreFileSecretRef](./values.yaml#L2704)

     
Mandatory. The secret name and the key where the keystore file is stored.

**Default:** `nil`
#### [mpn.appleNotifierConfig.keyStores.myAppKeystore.keystorePasswordSecretRef](./values.yaml#L2709)

     
Mandatory. The secret name and the key where the keystore password is stored.

**Default:** `nil`
#### [mpn.appleNotifierConfig.maxConcurrentConnections](./values.yaml#L2628)

     
Optional. Maximum number of concurrent connections to APNS services. The connection pool starts with 1 connection and grows automatically as the load increases. In case the expected load is very high, increasing the pool maximum size my be beneficial. For apps with development service level, this parameter is ignored.

**Default:** `1`
#### [mpn.appleNotifierConfig.minSendDelayMillis](./values.yaml#L2621)

     
Optional. Minimum delay between successive mobile push notifications for the same app/device pair. Each app/device pair is subject to constraints on the pace mobile push notifications may be sent to it. For this reason, a minimum delay is set and may be altered with this parameter. Lowering it too much, and subsequently sending notifications with a high frequency, may cause Apple's Push Notification Service ("APNs") to close the connection and ban (temporarily or permanently) any successive notification. Mobile push notifications fired by a trigger are not subject to this limit and may be sent at higher pace.

**Default:** `1000`
#### [mpn.appleWebServicePath](./values.yaml#L2410)

     
Optional. Specifies the root path of the web service URL to be invoked by the client application on a Safari browser to enable Web Push Notifications. Currently, the latter is achieved by invoking the `window.safari.pushNotification.requestPermission` method. Only when the MPN module is enabled, the specified path is reserved and the Server identifies these special requests and processes them as required. Enabling the internal web server (`webServer.enabled` set to `true`) is not needed for this; note that if the internal web server is enabled, the processing of this path is different from the processing of the other URLs.

**Default:** `/apple_web_service`
#### [mpn.collectorPeriodMinutes](./values.yaml#L2532)

     
Optional. Periodicity of the device garbage collector. Once every this number of minutes, devices that have been inactive for more than `deviceInactivityTimeoutMinutes` are permanently deleted.

**Default:** `60`
#### [mpn.deviceHandlerPool](./values.yaml#L2556)

     
Optional. Requests the creation of a specific thread pool, `MPN DEVICE HANDLER`, specifically dedicated to the handling of the internal sessions that are used to receive subscription updates to be sent to the devices. In particular, during the startup phase, all the subscriptions needed to handle all the active push notifications are performed in a burst. If defined, the pool should be sized wide enough to support this burst of activity. If the pool is not defined, each "subscribe" call will be managed by the thread pool associated with the involved Data Adapter, similarly to ordinary sessions.

**Default:** `{"maxFree":null,"maxSize":null}`
#### [mpn.deviceHandlerPool.maxFree](./values.yaml#L2564)

     
Optional. Specifies the the maximum number of idle threads the pool may have.

**Default:**

```
0, meaning the pool will not consume resources when idle
```
#### [mpn.deviceHandlerPool.maxSize](./values.yaml#L2560)

     
Optional. Specifies the maximum number of threads the pool may use.

**Default:** `100`
#### [mpn.deviceInactivityTimeoutMinutes](./values.yaml#L2527)

     
Optional. Timeout after which an inactive device is considered abandoned and is permanently deleted. A device is considered inactive if it is suspended (i.e. its device token has been rejected by the MPN service) or it has no active subscriptions. A suspended device may be resumed with a token change (typically, client libraries handle this situation automatically).

**Default:** `10080`
#### [mpn.enableModuleRecovery](./values.yaml#L2519)

     
Optional. Enabling of the automatic initialization of a new module upon upon health check failure. If set to `true`, upon health check failure, the failed module will become inactive and the initialization of a new module will be started; if unsuccessful, the Server will keep running with an inactive module. If set to `false`, upon health check failure, the failed module will become inactive and the Server will keep running with an inactive module. See `mpn.activationOnStartUp` for notes on inactive modules.

**Default:** `true`
#### [mpn.enabled](./values.yaml#L2399)

     
Optional. MPN module master switch. If set to `false`, the MPN module  will not start in any case, and all requests related to mobile push notifications will be rejected. Note that, by enabling the module, the handling of the special URL  configured by `appleWebServicePath` is also enabled.

**Default:** `false`
#### [mpn.executorPool](./values.yaml#L2538)

     
Optional. Sizes of request processor's (`MPN EXECUTOR`) thread pool. The request processor is devoted to process incoming MPN requests, such as subscription activations and deactivations. These requests access the database and may be subject to blocking in case of database disconnection.

**Default:** `all settings at their defaults`
#### [mpn.executorPool.maxFree](./values.yaml#L2546)

     
Optional. Specifies the the maximum number of idle threads the pool may have.

**Default:**

```
0, meaning the pool will not consume resources when idle
```
#### [mpn.executorPool.maxSize](./values.yaml#L2542)

     
Optional. Specifies the maximum number of threads the pool may use.

**Default:** `10`
#### [mpn.googleNotifierConfig](./values.yaml#L2713)

     
Optional. Google platforms notifier configuration.

**Default:**

```
{"apps":{"myApp":{"enabled":null,"packageName":null,"serviceJsonFileRef":null,"serviceLevel":null,"triggerExpressions":[]}},"messagingPoolSize":null,"minSendDelayMillis":null}
```
#### [mpn.googleNotifierConfig.apps](./values.yaml#L2733)

     
Optional. List of apps that should receive mobile push notifications.

**Default:**

```
{"myApp":{"enabled":null,"packageName":null,"serviceJsonFileRef":null,"serviceLevel":null,"triggerExpressions":[]}}
```
#### [mpn.googleNotifierConfig.apps.myApp](./values.yaml#L2735)

     
An application configuration.

**Default:**

```
{"enabled":null,"packageName":null,"serviceJsonFileRef":null,"serviceLevel":null,"triggerExpressions":[]}
```
#### [mpn.googleNotifierConfig.apps.myApp.enabled](./values.yaml#L2738)

     
Optional. Enablement of the application configuration.

**Default:** `false`
#### [mpn.googleNotifierConfig.apps.myApp.packageName](./values.yaml#L2741)

     
Mandatory if `enabled` is set to `true`. The package name of the app.

**Default:** `nil`
#### [mpn.googleNotifierConfig.apps.myApp.serviceJsonFileRef](./values.yaml#L2759)

     
Mandatory if `serviceLevel` is set to `dry_run` or `production`. The configmap name and the key where the JSON descriptor for the service account credentials of this project on Firebase console is stored. See the General Concepts document for more information on how to obtain this file.

**Default:** `nil`
#### [mpn.googleNotifierConfig.apps.myApp.serviceLevel](./values.yaml#L2753)

     
Mandatory if `enabled` is set to `true`. Specifies the intended service level for the current app, must be one of: `test`, `dry_run`,`production`. If set to `test`, notification will be logged only and no connection will be established with Google's servers. The corresponding logger is `lightstreamerLogger.mpn.google`, notifications are logged at `INFO` level (see `logging.loggers.lightstreamerLogger.subLoggers.lightstreamerLogger.mpn.google`). If set to `dry_run` or `production`, notifications will be sent to Google's servers. If set to `dry_run`, notifications will be accepted by Google's servers but not delivered to the user's device.

**Default:** `nil`
#### [mpn.googleNotifierConfig.apps.myApp.triggerExpressions](./values.yaml#L2785)

     
Optional. List of trigger expressions that will be accepted. Each each item is a Java-compatible regular expression (see java.util.regex.Pattern): triggers requested via client APIs will be compared with each regular expression, and accepted only if there is at least one match. Remember that the MPN Module supports, as trigger, any Java boolean expression, including use of JDK classes and methods, with the addition of field references syntax (see the iOS Client SDK for more information). Hence, this check is a safety measure required to avoid that clients can request triggers potentially dangerous for the Server, as each trigger may contain arbitrary Java code. If left commented out or empty, no triggers will be accepted. Please note that using an "accept all" regular expression like `.*` is possible, but still leaves the Server exposed to the danger of maliciously crafted triggers. Anyway, the Metadata Adapter has a second chance to check for trigger allowance. The example shown below is for a typical notification on threshold, where a field is compared against a numeric constant. Note: submitted trigger expressions are compared with this list of regular expressions after their named-arguments have been converted to indexed-arguments. Always specify fields with the `$[digits]` format, not the `${name}` format.

**Default:** `[]`
#### [mpn.googleNotifierConfig.messagingPoolSize](./values.yaml#L2731)

     
Optional. Size of the notifier's `MPN XXX MESSAGING` internal thread pool, which is devoted to sending the notifications payload. Each app has a separate thread pool. On multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:**

```
the number of available total cores, as detected by the JVM
```
#### [mpn.googleNotifierConfig.minSendDelayMillis](./values.yaml#L2725)

     
Optional. Minimum delay between successive mobile push notifications for the same app/device pair. Each app/device pair is subject to constraints on the pace mobile push notifications may be sent to it. For this reason, a minimum delay is set and may be altered with this parameter. Lowering it too much, and subsequently sending notifications with a high frequency, may cause Google's Firebase Cloud Messaging service ("FCM") to close the connection and ban (temporarily or permanently) any successive notification. Mobile push notifications fired by a trigger are not subject to this limit and may be sent at higher pace.

**Default:** `1000`
#### [mpn.hibernateConfig](./values.yaml#L2421)

     
Mandatory. Hibernate configuration. The MPN module uses an Hibernate-mapped database to make the list of devices and subscriptions persistent and let different module instances communicate.

**Default:**

```
{"connection":{"credentialsSecretRef":"hsql-factory-secret","dialect":"org.hibernate.dialect.HSQLDialect","jdbcDriverClass":"org.hsqldb.jdbcDriver","jdbcUrl":"jdbc:hsqldb:hsql://localhost:9001"},"optionalConfiguration":{"cache.provider_class":"org.hibernate.cache.internal.NoCacheProvider","current_session_context_class":"thread","hbm2ddl.auto":"update","hikari.connectionTimeout":"5000","show_sql":"false"}}
```
#### [mpn.hibernateConfig.connection](./values.yaml#L2427)

     
Mandatory. The Hibernate JDBC properties. The provided values are used to show an example of connections settings for HSQL (suitable for testing). The HSQL jar must be included in the `lib/mp/hibernate` folder of the  Docker image.

**Default:**

```
{"credentialsSecretRef":"hsql-factory-secret","dialect":"org.hibernate.dialect.HSQLDialect","jdbcDriverClass":"org.hsqldb.jdbcDriver","jdbcUrl":"jdbc:hsqldb:hsql://localhost:9001"}
```
#### [mpn.hibernateConfig.connection.credentialsSecretRef](./values.yaml#L2436)

     
Mandatory. The name of the secret containing the credentials. The secret must contain the keys `user` and `password`. The `hsql-hibernate-secret` secret is provided out of the box and contains the default `SA` user with empty password.

**Default:** `"hsql-factory-secret"`
#### [mpn.hibernateConfig.connection.dialect](./values.yaml#L2438)

     
Optional. Full class name of the dialect to use.

**Default:** `"org.hibernate.dialect.HSQLDialect"`
#### [mpn.hibernateConfig.connection.jdbcDriverClass](./values.yaml#L2429)

     
Mandatory. JDBC driver class.

**Default:** `"org.hsqldb.jdbcDriver"`
#### [mpn.hibernateConfig.connection.jdbcUrl](./values.yaml#L2431)

     
Mandatory. JDBC URL.

**Default:** `"jdbc:hsqldb:hsql://localhost:9001"`
#### [mpn.hibernateConfig.optionalConfiguration](./values.yaml#L2452)

     
Optional. The Hibernate optional configuration properties. See https://docs.jboss.org/hibernate/orm/3.3/reference/en/html/session-configuration.html#configuration-optional

**Default:**

```
{"cache.provider_class":"org.hibernate.cache.internal.NoCacheProvider","current_session_context_class":"thread","hbm2ddl.auto":"update","hikari.connectionTimeout":"5000","show_sql":"false"}
```
#### [mpn.hibernateConfig.optionalConfiguration."cache.provider_class"](./values.yaml#L2458)

     
Disable the second-level cache.

**Default:**

```
"org.hibernate.cache.internal.NoCacheProvider"
```
#### [mpn.hibernateConfig.optionalConfiguration."hbm2ddl.auto"](./values.yaml#L2460)

     
Automatically create/update the database schema on startup.

**Default:** `"update"`
#### [mpn.hibernateConfig.optionalConfiguration."hikari.connectionTimeout"](./values.yaml#L2454)

     
HikariCP database connection pool configuration.

**Default:** `"5000"`
#### [mpn.hibernateConfig.optionalConfiguration.current_session_context_class](./values.yaml#L2456)

     
Enable Hibernate's automatic session context management.

**Default:** `"thread"`
#### [mpn.hibernateConfig.optionalConfiguration.show_sql](./values.yaml#L2462)

     
Debugging: echo all executed SQL to console.

**Default:** `"false"`
#### [mpn.internalDataAdapter](./values.yaml#L2416)

     
Optional. Specifies the name of the built-in data adapter that client SDKs may subscribe to to obtain the current status of MPN devices and subscriptions. This data adapter is automatically added to all configured Adapter Sets in an MPN-enabled Server.

**Default:** `MPN_INTERNAL_DATA_ADAPTER`
#### [mpn.moduleTimeoutMillis](./values.yaml#L2484)

     
Optional. Timeout for a health check of other modules. If a module fails to do its health check for this period of time, other module instances may consider it dead and takeover its devices and subscriptions. Hence, it must be longer than `moduleCheckPeriodMillis` and it should be long enough to avoid false positives. In case a cluster is in place, the timeout should be longer than all values of `moduleCheckPeriodMillis` configured for the various instances in the cluster.

**Default:** `30000`
#### [mpn.mpnPumpPoolSize](./values.yaml#L2579)

     
Optional. Size of the `MPN PUMP` internal thread pool, which is devoted to integrating the update events pertaining to each MPN device and to creating the update commands that become push notifications, whenever needed. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:**

```
the number of available total cores, as detected by the JVM
```
#### [mpn.mpnTimerPoolSize](./values.yaml#L2586)

     
Optional. Number of threads used to parallelize the implementation of the internal MPN timers. This task does not include blocking operations, but its computation may be heavy under high update activity; hence, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:** `1`
#### [mpn.notifierPoolSize](./values.yaml#L2571)

     
Optional. Size of the notifiers' `MPN XXX NOTIFIER` internal thread pool, which is devoted to composing the notifications payload, sending them to the notification service and processing the response. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:**

```
the number of available total cores, as detected by the JVM
```
#### [mpn.reactionOnDatabaseFailure](./values.yaml#L2606)

     
Mandatory. Specifies what to do in case of database failure. A number of internal operations are bound to the success of a database update. In those (hopefully) rare situations when the database is not available, the MPN module must know what to do: if it is better to abort the operation entirely (thus risking to lose the event) or better to continue anyway (thus risking to duplicate the event). A typical situation is the triggering of a subscription, e.g.: when the price of a stock raises above a threshold, the MPN module must both send the mobile push notification and mark the subscription as triggered on the database. If the database is not available, the MPN module may react by aborting the operation, i.e. no mobile push notification is sent, another one will be sent only when (and if) the price drops and then raises above the threshold again. Alternatively, it may react by continuing with the operation, i.e. the mobile push notification is sent anyway, but (since the database has not been updated) if the price drops and then raises again it may get sent twice. Set to `abort_operation` to abort the ongoing operation. Set to `continue_operation` to continue the ongoing operation.

**Default:** `abort_operation`
#### [mpn.requestTimeoutMillis](./values.yaml#L2468)

     
Optional. Timeout for MPN request processing. As each MPN request interacts with the database, a timeout is applied so that a disconnected database will not result in a hang client. If a timeout occurs during a request processing, the client receives a specific error.

**Default:** `15000`
### KeyStores configuration
 
#### [keyStores](./values.yaml#L1301)

     
Keystores definition.

**Default:**

```
{"myKafkaConnectorKeystore":null,"myServerKeystore":{"keystoreFileSecretRef":{"key":"myserver.keystore","name":"myserver-keystore-secret"},"keystorePasswordSecretRef":{"key":"myserver.keypass","name":"myserver-keypass-secret"},"type":"JKS"}}
```
#### [keyStores.myKafkaConnectorKeystore](./values.yaml#L1331)

     
Example of Keystore definition used by Kafka connector configurations.

**Default:** `nil`
#### [keyStores.myServerKeystore](./values.yaml#L1309)

     
Keystore definition used by HTTPS server socket configurations. The default values used here reference the JKS keystore file `myserver.keystore`, which is provided out of the box (and stored in the `myserver-keystore-secret` secret, along with the password stored in the `myserver-keypass-secret` secret), and obviously contains an invalid certificate. In order to use it for your experiments, remember to add a security exception to your browser.

**Default:**

```
{"keystoreFileSecretRef":{"key":"myserver.keystore","name":"myserver-keystore-secret"},"keystorePasswordSecretRef":{"key":"myserver.keypass","name":"myserver-keypass-secret"},"type":"JKS"}
```
#### [keyStores.myServerKeystore.keystoreFileSecretRef](./values.yaml#L1322)

     
Mandatory if type is set to `JKS` or `PKCS12`. Secret name and key where the keystore file is stored.

**Default:**

```
{"key":"myserver.keystore","name":"myserver-keystore-secret"}
```
#### [keyStores.myServerKeystore.keystorePasswordSecretRef](./values.yaml#L1327)

     
Mandatory if type is set to `JKS` or `PKCS12`. Secret name and key where keystore password is stored.

**Default:**

```
{"key":"myserver.keypass","name":"myserver-keypass-secret"}
```
#### [keyStores.myServerKeystore.type](./values.yaml#L1319)

     
Optional. The keystore type. The currently supported types are: - `JKS`, which is the Sun/Oracle's custom keystore type, whose support is   made available by every Java installation; - `PKCS12`, which is supported by all recent Java installations; - `PKCS11`, which as a bridge to an external PKCS11 implementation;   this is an experimental extension; contact Lightstreamer Support for   details.

**Default:** `JKS`
### WebServer configuration
 
#### [webServer](./values.yaml#L2795)

     
Optional. Internal web server configuration. Note that some of the included settings may also apply to the Monitoring Dashboard pages, which are supplied through the internal web server. In particular, this holds for the `webServer.compressionThreshold` settings. Anyway, this does not hold for the `webServer.enabled` setting, as the Monitoring Dashboard accessibility is only configured through `management.dashboard`.

**Default:**

```
{"compressionThreshold":null,"enableFlexCrossdomain":null,"enableSilverlightAccessPolicy":null,"enabled":true,"errorPageRef":null,"flexCrossdomainPath":null,"mimeTypesConfig":null,"notFoundPage":null,"pagesDir":null,"persistencyMinutes":null,"silverlightAccessPolicyPath":null}
```
#### [webServer.compressionThreshold](./values.yaml#L2842)

     
Optional. Size of the resource contents below which compression is not applied, regardless of the `webServer.compression.default` setting, as we guess that no overall benefit would be reached.

**Default:** `8192`
#### [webServer.enableFlexCrossdomain](./values.yaml#L2864)

     
Optional. Enables the processing of the `/crossdomain.xml` URL, required by the Flash player in order to allow pages from a different host to request data to Lightstreamer Server host. See the "WebSite Controls" section on http://www.adobe.com/devnet/flashplayer/articles/flash_player_9_security.pdf for details on the contents of the document to be returned. If set to `true`, the Server accepts requests for `/crossdomain.xml`; the file configured through the `webServer.flexCrossdomainPath` setting is returned. Enabling internal web server (through `webServer.enabled`) is not needed; note that if the internal web server is enabled, the processing of the `/crossdomain.xml` URL is different than the processing of the other URLs. If set to `false`, no special processing for the `/crossdomain.xml` requests is performed. Note that if the internal web server is enabled, then the processing of the `/crossdomain.xml` URL is performed as for any other URL (i.e. a file named `crossdomain.xml` is looked for in the directory configured as the root for URL path mapping). Note that `/crossdomain.xml` is also used by the Silverlight runtime when `/clientaccesspolicy.xml` is not provided.

**Default:** `false`
#### [webServer.enableSilverlightAccessPolicy](./values.yaml#L2892)

     
Optional. Enables the processing of the `/clientaccesspolicy.xml` URL, required by the Silverlight runtime in order to allow pages from a different host to request data to Lightstreamer Server host. See http://msdn.microsoft.com/en-us/library/cc838250(VS.95).aspx#crossdomain_communication for details on the contents of the document to be returned. If set to `true`, the Server accepts requests for `/clientaccesspolicy.xml`; the file configured through the `webServer.silverlightAccessPolicyPath` setting is returned. Enabling internal web server (through `webServer.enabled`) is not needed; note that if the internal web server is enabled, the processing of the `/clientaccesspolicy.xml` URLis different than the processing of the other URLs. If set to `false`, no special processing for the `/clientaccesspolicy.xml` requests is performed. Note that if the internal web server is enabled, then the processing of the `/clientaccesspolicy.xml` URL is performed as for any other URL (i.e. a file named `clientaccesspolicy.xml` is looked for in the directory  configured as the root for URL path mapping). Note that `/crossdomain.xml` is also used by the Silverlight runtime when `/clientaccesspolicy.xml` is not provided.

**Default:** `false`
#### [webServer.enabled](./values.yaml#L2800)

     
Optional. Enabling of the internal web server. If set to `true`, the Server accepts requests for file resources. If set  to `false`, the Server ignores requests for file resources.

**Default:** `false`
#### [webServer.errorPageRef](./values.yaml#L2809)

     
Optional. The configmap name and the key where an HTML page to be returned upon unexpected request URLs is stored. This applies to URLs in reserved ranges that have no meaning. If the Internal web server is not enabled (`webServer.enabled` set to `false`), this also applies to all non-reserved URLs; otherwise, nonexisting non-reserved URLs will get the HTTP 404 error as usual. The file content should be encoded with the iso-8859-1 charset.

**Default:** `the proper page is provided by the Server`
#### [webServer.flexCrossdomainPath](./values.yaml#L2870)

     
Mandatory if `webServer.enableFlexCrossdomain` is set to `true`. Path of the file to be returned upon requests for the `/crossdomain.xml` URL. It is ignored when `webServer.enableFlexCrossdomain` is false. The file content should be encoded with the iso-8859-1 charset. The file path is relative to the conf directory.

**Default:** `nil`
#### [webServer.mimeTypesConfig](./values.yaml#L2831)

     
Optional. Path of the MIME types configuration property file. The file path is relative to the conf directory.

**Default:** ` ./mime_types.properties`
#### [webServer.notFoundPage](./values.yaml#L2837)

     
Optional. Path of an HTML page to be returned as the body upon a "404 Not Found" answer caused by the request of a nonexistent URL. The file content should be encoded with the iso-8859-1 charset. The file path is relative to the conf directory.

**Default:** `the proper page is provided by the Server`
#### [webServer.pagesDir](./values.yaml#L2821)

     
Optional. Path of the file system directory to be used by the internal web server as the root for URL path mapping. The path is relative to the conf directory. Note that the `/lightstreamer` URL path (as any alternative paths defined through `pushSession.serviceUrlPrefix`) is reserved, as well as the base URL path of the Monitoring Dashboard(see `management.dashboard.urlPath`); hence, subdirectories of the pages directory with conflicting names would be ignored.

**Default:** `../pages`
#### [webServer.persistencyMinutes](./values.yaml#L2827)

     
Optional. Caching time, in minutes, to be allowed to the browser (through the "expires" HTTP header) for all the resources supplied by the internal web server. A zero value disables caching by the browser.

**Default:** `0`
#### [webServer.silverlightAccessPolicyPath](./values.yaml#L2899)

     
Mandatory if `web.enableSilverlightAccessPolicy` is set to `true`. Path of the file to be returned upon requests for the `/clientaccesspolicy.xml` URL. It is ignored when `web.enableSilverlightAccessPolicy` is false. The file content should be encoded with the iso-8859-1 charset. The file path is relative to the conf directory.

**Default:** `nil`
### Cluster configuration
 
#### [cluster](./values.yaml#L2902)

     
Optional. Clustering configuration.

**Default:**

```
{"controlLinkAddress":null,"controlLinkMachineName":null,"maxSessionDurationMinutes":null}
```
#### [cluster.controlLinkAddress](./values.yaml#L2922)

     
Optional. Host address to be used for control/poll/rebind connections. A numeric IP address can be specified as well. The use of non standard, unicode names may not be supported yet by some Client SDKs. This setting can be used in case a cluster of Server instances is in place, to ensure that all client requests pertaining to the same session are issued against the same Server instance. If the Load Balancer can ensure that all requests coming from the same client are always routed to the same Server instance, then this setting is not needed. See the Clustering.pdf document for details. Note: When this setting is used, clients based on any Unified Client SDK that supports the optional `setEarlyWSOpenEnabled` method in the `ConnectionOptions` class should invoke this method with false, to improve startup performances. In case a request comes from a web client and `cluster.controlLinkMachineName` is also specified, the latter setting may be applied instead; see the comment for `cluster.controlLinkMachineName` for details. Support for clustering is an optional feature, available depending on Edition and License Type. When not available, this setting is ignored.

**Default:** `nil`
#### [cluster.controlLinkMachineName](./values.yaml#L2952)

     
Optional. Host name to be used, in addition to the domain name specified on the front-end pages, for control/poll/rebind connections coming from web clients. This only regards clients based on old versions of the Web (Unified API) Client SDK (earlier than 8.0.0). The use of non standard, unicode names may not be supported by old versions of the Web Client SDK. This setting will override the `cluster.controlLinkAddress` setting when the request comes from such Web Client SDKs and the access to Server data pages requires that the latter share a common subdomain with application pages. This was one of the ways used by these SDKs to request streaming data; see the Client Guide in the Web (Unified API) Client SDK for these versions for details on the cases in which this setting will be preferred; note that, in this regard, the behavior will be slightly different when the older HTML Client Library is in use, so as to ensure backward compatibility. This option is useful if the subdomain-name part of the hostname is subject to changes or if the same machine needs to be addressed through multiple subdomain names (e.g. for multihosting purpose). The configured name should contain all the portions of the address except for the subdomain name. For example, assuming the `mycompany.com` subdomain is declared in the front-end pages: - If the full address is `push1.mycompany.com`, the name should be `push`; - If the full address is `push.int2.cnt3.mycompany.com`, the name   should be `push.int2.cnt3`. Refer to `cluster.controlLinkAddress` for other remarks. Support for clustering is an optional feature, available depending on Edition and License Type. When not available, this setting is ignored.

**Default:** `nil`
#### [cluster.maxSessionDurationMinutes](./values.yaml#L2961)

     
Optional. If set and positive, specifies a maximum duration to be enforced on each session. If the limit expires, the session is closed and the client can only establish a new session. This is useful when a cluster of Server instances is in place, as it leaves the Load Balancer the opportunity to migrate the new session to a different instance. See the Clustering document for details on this mechanism and on how rebalancing can be pursued.

**Default:** `unlimited`
### Load configuration
 
#### [load](./values.yaml#L2964)

     
Optional. Load configuration.

**Default:**

```
{"acceptPoolMaxQueue":null,"acceptPoolMaxSize":null,"eventsPoolSize":null,"forceEarlyConversions":null,"handshakePoolMaxQueue":null,"handshakePoolSize":null,"httpsAuthPoolMaxFree":null,"httpsAuthPoolMaxQueue":null,"httpsAuthPoolMaxSize":null,"maxCommonNioBufferAllocation":null,"maxCommonPumpBufferAllocation":null,"maxMpnDevices":null,"maxSessions":null,"prestartedMaxQueue":null,"pumpPoolMaxQueue":null,"pumpPoolSize":null,"selectorMaxLoad":null,"selectorPoolSize":null,"serverPoolMaxFree":null,"serverPoolMaxQueue":null,"serverPoolMaxSize":null,"snapshotPoolSize":null,"timerPoolSize":null}
```
#### [load.acceptPoolMaxQueue](./values.yaml#L3132)

     
Optional. Maximum number of tasks allowed to be queued to enter the `ACCEPT` thread pool before undertaking backpressure actions. The setting only affects the listening sockets with `servers.{}.portType` configured as CREATE_ONLY. As long as the number is exceeded, the accept loops of these sockets will be kept waiting. By suspending the accept loop, some SYN packets from the clients may be discarded; the effect may vary depending on the backlog settings. Note that, in the absence of sockets configured as CREATE_ONLY, no backpressure action will take place. A long queue on the `ACCEPT` pool may be the consequence of a CPU shortage during (or caused by) a high client connection activity. A negative value disables the check.

**Default:** `-1`
#### [load.acceptPoolMaxSize](./values.yaml#L3117)

     
Optional. Maximum number of threads allowed for the `ACCEPT` internal pool, which is devoted to the parsing of the client requests. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial. Only in corner cases, it is possible that some operations turn out to be blocking; in particular: - getHostName, only if banned hostnames are configured; - socket close, only if banned hostnames are configured; - read from the "proxy protocol", only if configured; - service of requests on a "priority port", only available for internal use. A zero value means a potentially unlimited number of threads. which is also the minimum number of threads left in the pool

**Default:**

```
the number of available total cores, as detected by the JVM,
```
#### [load.eventsPoolSize](./values.yaml#L3028)

     
Optional. Size of the `EVENTS` internal thread pool, which is devoted to dispatching the update events received from a Data Adapter to the proper client sessions, according with each session subscriptions. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:**

```
the number of available total cores, as detected by the JVM
```
#### [load.forceEarlyConversions](./values.yaml#L3225)

     
Optional. Policy to be adopted in order to manage the extraction of the field values from the item events and their conversion to If set to `true`, causes field conversion to be performed before the events are dispatched to the various sessions; this may lead to some wasted conversions, in case an event is filtered out later by all interested clients or in case a field is not subscribed to by any client. Note that events which don't provide an iterator (see the Data Adapter interface documentation) cannot be managed in this way. If set to `false`, causes field conversion to be performed only as soon as it is needed; in this case, as the same event object may be shared by many sessions, some synchronization logic is needed and this may lead to poor scaling in case many clients subscribe to the same item.

**Default:** `true`
#### [load.handshakePoolMaxQueue](./values.yaml#L3170)

     
Optional. Maximum number of tasks allowed to be queued to enter the `TLS-SSL HANDSHAKE` thread pool before undertaking backpressure actions. The setting only regards the listening sockets specified through the `servers.{}` configurations (with `enableHttps` set to `true`) that are not configured to request the client certificate. More precisely: - If there are https sockets with `servers.{}.portType` configured as   `CREATE_ONLY`, then, as long as the number is exceeded, the accept loops    of these sockets will be kept waiting.   By suspending the accept loop, some SYN packets from the clients may be   discarded; the effect may vary depending on the backlog settings. - Otherwise, if there are https sockets configured as `CONTROL_ONLY`and    none is configured as the default `GENERAL_PURPOSE`, then, as long as the    number is exceeded, the accept loops of these sockets will be kept    waiting instead.   Additionally, the same action on the accept loops associated to the   `load.acceptPoolMaxQueue` check will be performed (regardless that   `load.acceptPoolMaxQueue` itself is set). Note that the latter action may    affect both http and https sockets. Note that, in the absence of sockets configured as specified above, no backpressure action will take place. A negative value disables the check.

**Default:** `100`
#### [load.handshakePoolSize](./values.yaml#L3145)

     
Optional. Size of the `TLS-SSL HANDSHAKE` internal pool, which is devoted to the management of operations needed to accomplish TLS/SSL handshakes on the listening sockets specified through the `servers.{}` configuration with `enableHttps` set to `true`. In particular, this pool is only used when the socket is not configured to request the client certificate (see servers.{}.sslConfig.enableClientAuth` and `servers.{}.security.enableMandatoryClientAuth`); in this case, the tasks are not expected to be blocking. Note that the operation may be CPU-intensive; hence, it is advisable to set a value smaller than the number of available cores. JVM (obviously, if there is only one core, the default will be 1)

**Default:**

```
half the number of available total cores, as detected by the
```
#### [load.httpsAuthPoolMaxFree](./values.yaml#L3181)

     
Optional. Maximum number of idle threads allowed for the `TLS-SSL AUTHENTICATION` internal pool. It behaves in the same way as the `load.serverPoolMaxFree` setting.

**Default:**

```
the same as configured for the SERVER thread pool
```
#### [load.httpsAuthPoolMaxQueue](./values.yaml#L3191)

     
Optional. Maximum number of tasks allowed to be queued to enter the `TLS-SSL AUTHENTICATION` thread pool before undertaking backpressure actions. The effect is similar to the more common `load.handShakePoolMaxQueue`, with the difference that it regards listening sockets specified through `server.httpsServer` that are configured to request the client certificate (see `useClientAuth` and `forceClientAuth`). A negative value disables the check.

**Default:** `100`
#### [load.httpsAuthPoolMaxSize](./values.yaml#L3176)

     
Optional. Size of the `TLS-SSL AUTHENTICATION` internal pool, which is used instead of the `TLS-SSL HANDSHAKE` pool for listening sockets that are configured to request the client certificate. This kind of task may exhibit a blocking behavior in some cases.

**Default:**

```
the same as configured for the SERVER thread pool
```
#### [load.maxCommonNioBufferAllocation](./values.yaml#L2990)

     
Optional. Limit to the overall size, in bytes, of the buffers devoted to I/O operations that can be kept allocated for reuse. If 0, removes any limit to the allocation (which should remain limited, based on the maximum concurrent buffer needs). If -1, disables buffer reuse at all and causes all allocated buffers to be released immediately.

**Default:** `200000000`
#### [load.maxCommonPumpBufferAllocation](./values.yaml#L2998)

     
Optional. Number of distinct NIO selectors (each one with its own thread) that will share the same operation. Different pools will be prepared for different I/O operations and server sockets, which may give rise to a significant overall number of selectors. Further selectors may be created because of the `load.selectorMaxLoad` setting.

**Default:**

```
the number of available total cores, as detected by the JVM
```
#### [load.maxMpnDevices](./values.yaml#L2982)

     
Optional. Maximum number of concurrent MPN devices sessions allowed. Once this number of devices has been reached, requests to active mobile push notifications will be refused. The limit can be set as a simple, heuristic protection from Server overload from MPN subscriptions.

**Default:**

```
unlimited number of concurrent MPN devices sessions
```
#### [load.maxSessions](./values.yaml#L2974)

     
Optional. Maximum number of concurrent client sessions allowed. Requests for new sessions received when this limit is currently exceeded will be refused; on the other hand, operation on sessions already established is not limited in any way. Note that closing and reopening a session on a client when this limit is currently met may cause the new session request to be refused. The limit can be set as a simple, heuristic protection from Server overload.

**Default:**

```
unlimited number of concurrent client sessions
```
#### [load.prestartedMaxQueue](./values.yaml#L3211)

     
Optional. Maximum number of sessions that can be left in "prestarted" state, that is, waiting for the first bind or control operation, before undertaking backpressure actions. In particular, the same restrictive actions associated to the `load.serverPoolMaxQueue` check will be performed (regardless that `load.serverPoolMaxQueue` itself is set). The setting is meant to be used in configurations which define a CREATE_ONLY port in http and a CONTROL_ONLY port in https. In these cases, and when a massive client reconnection is occurring, the number of pending bind operations can grow so much that the needed TLS handshakes can take arbitrarily long and cause the clients to time-out and restart session establishment from scratch. However, consider that the presence of many clients that don't perform their bind in due time could keep other clients blocked. Note that, if defined, the setting will also inhibit `load.handshakePoolMaxQueue` and `load.httpsAuthPoolMaxQueue` from affecting the accept loop of CONTROL_ONLY ports in https. A negative value disables the check.

**Default:** `-1`
#### [load.pumpPoolMaxQueue](./values.yaml#L3053)

     
Optional. Maximum number of tasks allowed to be queued to enter the `PUMP` thread pool before undertaking backpressure actions. In particular, the same restrictive actions associated to the `load.serverPoolMaxQueue` check will be performed (regardless that `load.serverPoolMaxQueue` itself is set). A steadily long queue on the `PUMP` pool may be the consequence of a CPU shortage due to a huge streaming activity. A negative value disables the check.

**Default:** `-1`
#### [load.pumpPoolSize](./values.yaml#L3043)

     
Optional. Size of the `PUMP` internal thread pool, which is devoted to integrating the update events pertaining to each session and to creating the update commands for the client, whenever needed. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:**

```
the number of available total cores, as detected by the JVM
```
#### [load.selectorMaxLoad](./values.yaml#L3014)

     
Optional. Maximum number of keys allowed for a single NIO selector. If more keys have to be processed, new temporary selectors will be created. If the value is 0, then no limitations are applied and extra selectors will never be created. The base number of selectors is determined by the `load.selectorPoolSize` setting.

**Default:** `0`
#### [load.selectorPoolSize](./values.yaml#L3006)

     
Optional. Number of distinct NIO selectors (each one with its own thread) that will share the same operation. Different pools will be prepared for different I/O operations and server sockets, which may give rise to a significant overall number of selectors. Further selectors may be created because of the `load.selectorMaxLoad` setting.

**Default:**

```
the number of available total cores, as detected by the JVM
```
#### [load.serverPoolMaxFree](./values.yaml#L3090)

     
Optional, but mandatory if `load.serverPoolMaxSize`is set to `0`. Maximum number of idle threads allowed for the `SERVER` internal pool, which is devoted to the management of the client requests. Put in a different way, it is the minimum number of threads that can be present in the pool. To accomplish this setting, at pool initialization, suitable idle threads are created; then, each time a thread becomes idle, it is discarded only if enough threads are already in the pool. It must not be greater than `load.serverPoolMaxSize` (unless the latter is set to `0`, i.e. `unlimited`); however, it may be lower, in case `load.serverPoolMaxSize` is kept high in order to face request bursts; a zero value means no idle threads allowed in the pool, though this is not recommended for performance reasons. same as `load.serverPoolMaxSize`, unless the latter is set to `0`, i.e. `unlimited`, in which case this setting is mandatory

**Default:**

```
10, if load.serverPoolMaxSize is not defined; otherwise, the
```
#### [load.serverPoolMaxQueue](./values.yaml#L3103)

     
Optional. Maximum number of tasks allowed to be queued to enter the `SERVER` thread pool before undertaking backpressure actions. In particular, as long as the number is exceeded, the creation of new sessions will be refused and made to fail; additionally, the same restrictive action on the accept loops associated to the `load.acceptPoolMaxQueue` check will be performed (regardless that `load.acceptPoolMaxQueue` itself is set). On the other hand, if the `MPN DEVICE HANDLER` pool is defined in `mpn` it  also overrides the SERVER or dedicated pools, but its queue is not included in the check. A negative value disables the check.

**Default:** `100`
#### [load.serverPoolMaxSize](./values.yaml#L3074)

     
Optional. Maximum number of threads allowed for the `SERVER` internal pool, which is devoted to the management of the client requests. This kind of tasks includes operations that are potentially blocking: - `getHostName`; - socket close; - calls to a Metadata Adapter that may need to access to some external   resource (i.e. mainly `notifyUser`, `getItems`, `getSchema`; other    methods should be implemented as nonblocking, by leaning on data cached    by `notifyUser`); - calls to a Data Adapter that may need to access to some external resource   (i.e. subscribe and unsubscribe, though it should always be possible to   implement such calls asynchronously); - file access by the internal web server, though it should be used  only in   demo and test scenarios. Note that specific thread pools can optionally be defined in order to handle some of the tasks that, by default, are handled by the `SERVER`  thread pool. They are defined in "adapters.xml"; see the templates provided in the In-Process Adapter SDK for details. A zero value means a potentially unlimited number of threads.

**Default:** `1000`
#### [load.snapshotPoolSize](./values.yaml#L3036)

     
Optional. Size of the `SNAPSHOT` internal thread pool, which is devoted to dispatching the snapshot events upon new subscriptions from client sessions. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial. `10`, if the number of cores is less

**Default:**

```
the number of available total cores, as detected by the JVM, or
```
#### [load.timerPoolSize](./values.yaml#L3021)

     
Optional. Number of threads used to parallelize the implementation of the internal timers. This task does not include blocking operations, but its computation may be heavy under high update activity; hence, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:** `1`
### License configuration
 
#### [license](./values.yaml#L288)

     
Mandatory. Configure the edition, the optional features, and the type of license that should be used to run Lightstreamer Server.

**Default:**

```
{"edition":"ENTERPRISE","enableAutomaticUpdateCheck":null,"enabledCommunityEditionClientApi":"javascript_client","enterprise":{"contractId":"DEMO","enableAutomaticAuditLogUpload":true,"filePathSecretRef":{"key":null,"name":null},"licenseType":"DEMO","licenseValidation":"ONLINE","onlinePasswordSecretRef":{"key":null,"name":null},"optionalFeatures":{"enableRestrictedFeaturesSet":true,"features":{"enableAndroidClient":false,"enableBandwidthControl":false,"enableBlackBerryClient":false,"enableDotNETStandardClient":false,"enableFlashClient":false,"enableFlexClient":false,"enableGenericClient":false,"enableIOSClient":false,"enableJavaMEClient":false,"enableJavaSEClient":false,"enableJavascriptClient":false,"enableJmx":false,"enableMacOSClient":false,"enableMpn":true,"enableNodeJsClient":false,"enablePythonClient":false,"enableSilverlightClient":false,"enableTlsSsl":false,"enableTvOSClient":false,"enableVisionOSClient":false,"enableWatchOSClient":false,"maxDownstreamRate":"1"}}},"proxy":{"enableProxyAutodiscovery":null,"httpProxies":[{"credentialsSecretRef":null,"host":null,"port":null,"scheme":null}],"networkInterface":null,"pacFiles":{"filePaths":[],"fileUrls":[]},"socksProxies":[{"credentialsSecretRef":null,"host":null,"port":null,"version":null}]}}
```
#### [license.edition](./values.yaml#L293)

     
Mandatory. Lightstreamer edition to use. To know full details, open the Welcome Page or the Monitoring Dashboard (Edition tab) of your running Lightstreamer Server. Possible values: `COMMUNITY`, `ENTERPRISE`

**Default:** `"ENTERPRISE"`
#### [license.enableAutomaticUpdateCheck](./values.yaml#L424)

     
Optional. Periodically check whether any Lightstreamer Server update is available. In such case, a notification is written to the log file. If set to true, perform automatic update check. The following host name must be reachable on port 443: https://service.lightstreamer.com/ If set to false, do not perform automatic update check.

**Default:** `true`
#### [license.enabledCommunityEditionClientApi](./values.yaml#L308)

     
Mandatory if edition is set to `COMMUNITY`. The Client API to use with your Lightstreamer free license. Possible values: `javascript_client` (for web browser clients), `nodejs_client` (for Node.js clients), `android_client` (for Android clients), `ios_client` (for iOS clients), `flex_client` (for Flex and AIR clients), `silverlight_client` (for Silverlight clients), `javase_client` (for Java SE clients), `python_client` (for Python clients), `dotnet_standard_client` (for .NET Standard clients), `macos_client` (for macOS clients), `tvos_client` (for tvOS clients), `watchos_client` (for watchOS clients), `visionos_client` (for visionOS clients), `blackberry_client` (for BlackBerry clients), `javame_client` (for Java ME clients), `flash_client` (for Flash clients), `generic_client` (for custom clients based on the Lightstreamer protocol).

**Default:** `javascript_client`
#### [license.enterprise](./values.yaml#L311)

     
Mandatory if `edition` is set to `ENTERPRISE`. Configure the ENTERPRISE edition.

**Default:**

```
{"contractId":"DEMO","enableAutomaticAuditLogUpload":true,"filePathSecretRef":{"key":null,"name":null},"licenseType":"DEMO","licenseValidation":"ONLINE","onlinePasswordSecretRef":{"key":null,"name":null},"optionalFeatures":{"enableRestrictedFeaturesSet":true,"features":{"enableAndroidClient":false,"enableBandwidthControl":false,"enableBlackBerryClient":false,"enableDotNETStandardClient":false,"enableFlashClient":false,"enableFlexClient":false,"enableGenericClient":false,"enableIOSClient":false,"enableJavaMEClient":false,"enableJavaSEClient":false,"enableJavascriptClient":false,"enableJmx":false,"enableMacOSClient":false,"enableMpn":true,"enableNodeJsClient":false,"enablePythonClient":false,"enableSilverlightClient":false,"enableTlsSsl":false,"enableTvOSClient":false,"enableVisionOSClient":false,"enableWatchOSClient":false,"maxDownstreamRate":"1"}}}
```
#### [license.enterprise.contractId](./values.yaml#L318)

     
Mandatory, Identifier of the contract in place. Use `DEMO` to run with the embedded Demo license.

**Default:** `"DEMO"`
#### [license.enterprise.enableAutomaticAuditLogUpload](./values.yaml#L354)

     
In case of file-based license validation, allows to activate periodic automatic upload. This makes it much easier for the systems admins to deliver the logs, as contractually agreed. In case of online license validation, the audit logs are always automatically uploaded to the Online License Manager, irrespective of this setting. If enabled, the host `https://service.lightstreamer.com` must be  reachable on port 443 If not enabled, audit logs must be delivered manually if required by license terms.

**Default:** `true`
#### [license.enterprise.filePathSecretRef](./values.yaml#L340)

     
Used only if `licenseValidation` set to `FILE`. Secret name and key where the license file is stored.

**Default:** `{"key":null,"name":null}`
#### [license.enterprise.licenseType](./values.yaml#L315)

     
Mandatory. The type of the ENTERPRISE edition. Possible values: `DEMO`, `EVALUATION`, `STARTUP`, `NON-PRODUCTION-LIMITED`, `NON-PRODUCTION-FULL`, `PRODUCTION`, `HOT-STANDBY`.

**Default:** `"DEMO"`
#### [license.enterprise.licenseValidation](./values.yaml#L330)

     
Optional. Choose between online (cloud-based) and file-based license validation. If set to `ONLINE`, the following host names below must be reachable on port 443:  - `https://clm1.lightstreamer.com/` - `https://clm2.lightstreamer.com/`. If set to `FILE`, based on `licenseType`, one or both the values are possible. For EVALUATION and STARTUP: ONLINE is mandatory. For PRODUCTION, HOT-STANDBY, NON-PRODUCTION-FULL, and NON-PRODUCTION-LIMITED: you can choose between ONLINE and FILE. For DEMO: the value is ignored, as no validation is done.

**Default:** `"ONLINE"`
#### [license.enterprise.onlinePasswordSecretRef](./values.yaml#L335)

     
Used only if `licenseValidation` set to "ONLINE". Secret name and key where the password used for validation of online licenses is stored. Leave blank if `licenseType` is set to `DEMO` or `licenseValidation` set to `FILE`.

**Default:** `{"key":null,"name":null}`
#### [license.enterprise.optionalFeatures](./values.yaml#L356)

     
Optional. Configure the optional features.

**Default:**

```
{"enableRestrictedFeaturesSet":true,"features":{"enableAndroidClient":false,"enableBandwidthControl":false,"enableBlackBerryClient":false,"enableDotNETStandardClient":false,"enableFlashClient":false,"enableFlexClient":false,"enableGenericClient":false,"enableIOSClient":false,"enableJavaMEClient":false,"enableJavaSEClient":false,"enableJavascriptClient":false,"enableJmx":false,"enableMacOSClient":false,"enableMpn":true,"enableNodeJsClient":false,"enablePythonClient":false,"enableSilverlightClient":false,"enableTlsSsl":false,"enableTvOSClient":false,"enableVisionOSClient":false,"enableWatchOSClient":false,"maxDownstreamRate":"1"}}
```
#### [license.enterprise.optionalFeatures.enableRestrictedFeaturesSet](./values.yaml#L364)

     
Optional. Restrict the feature set with respect to the license in use. If set to `true`, use the feature set detailed in `features`. If a required feature is not allowed by the license in use, the server will not start. If set to `false`, use the feature set specified by the license in use.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features](./values.yaml#L369)

     
Mandatory if `enableRestrictedFeaturesSet` is set to `true`. Set of features to enable. If a required feature is not allowed by the license in use, the server will not start.

**Default:** `{}`
#### [license.enterprise.optionalFeatures.features.enableAndroidClient](./values.yaml#L386)

     
Mandatory. Android Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableBandwidthControl](./values.yaml#L376)

     
Mandatory. Bandwidth control.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableBlackBerryClient](./values.yaml#L411)

     
Mandatory. BlackBerry Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableDotNETStandardClient](./values.yaml#L401)

     
Mandatory. .NET Standard Client API. Includes also the old Windows .NET libraries: .NET PCL Client API, Unity Client API, .NET Client API, WinRT Client API, and Windows Phone Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableFlashClient](./values.yaml#L415)

     
Mandatory. Flash Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableFlexClient](./values.yaml#L390)

     
Mandatory. Flex and AIR Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableGenericClient](./values.yaml#L417)

     
Mandatory. Generic Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableIOSClient](./values.yaml#L388)

     
Mandatory. iOS Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableJavaMEClient](./values.yaml#L413)

     
Mandatory. Java ME Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableJavaSEClient](./values.yaml#L394)

     
Mandatory. Java SE Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableJavascriptClient](./values.yaml#L382)

     
Mandatory. JavaScript Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableJmx](./values.yaml#L380)

     
Mandatory. JMX Management API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableMacOSClient](./values.yaml#L403)

     
Mandatory. macOS Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableMpn](./values.yaml#L371)

     
Mandatory. Mobile Push Notifications.

**Default:** `true`
#### [license.enterprise.optionalFeatures.features.enableNodeJsClient](./values.yaml#L384)

     
Mandatory. Node.js Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enablePythonClient](./values.yaml#L396)

     
Mandatory. Python Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableSilverlightClient](./values.yaml#L392)

     
Mandatory. Silverlight Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableTlsSsl](./values.yaml#L378)

     
Mandatory. TLS/SSL Support.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableTvOSClient](./values.yaml#L405)

     
Mandatory. tvOS Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableVisionOSClient](./values.yaml#L409)

     
Mandatory. visionOS Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.enableWatchOSClient](./values.yaml#L407)

     
Mandatory. watchOS Client API.

**Default:** `false`
#### [license.enterprise.optionalFeatures.features.maxDownstreamRate](./values.yaml#L374)

     
Mandatory. Max message rate (downstream). Possible values: `1`, `3`, `unlimited`.

**Default:** `"1"`
#### [license.proxy](./values.yaml#L436)

     
Optional. Configure a proxy server for outbound Internet access, if necessary. Internet access is needed, depending on the above configuration, to reach the Online License Manager, to upload audit logs, and to check for software updates. The host names below must be reachable from the proxy on port 443: - https://clm1.lightstreamer.com/    (depending on the configuration) - https://clm2.lightstreamer.com/    (depending on the configuration) - https://service.lightstreamer.com/ (regardless of the configuration) Several methods are provided for the proxy configuration, including PAC files, auto-discovery, and direct HTTP and SOCKS configuration.

**Default:**

```
{"enableProxyAutodiscovery":null,"httpProxies":[{"credentialsSecretRef":null,"host":null,"port":null,"scheme":null}],"networkInterface":null,"pacFiles":{"filePaths":[],"fileUrls":[]},"socksProxies":[{"credentialsSecretRef":null,"host":null,"port":null,"version":null}]}
```
#### [license.proxy.enableProxyAutodiscovery](./values.yaml#L497)

     
Optional. In case no proxy configuration is provided or the provided configuration does not work, automatic proxy discovery is attempted (via system environment check and WPAD).

**Default:** `false`
#### [license.proxy.httpProxies](./values.yaml#L441)

     
Optional. List of HTTP Proxy Server configurations. The proxies all checked and the first acceptable one is used. If any SOCKS proxy in `socksProxies` is configured too, it is checked in parallel with the defined HTTP proxies.

**Default:**

```
[{"credentialsSecretRef":null,"host":null,"port":null,"scheme":null}]
```
#### [license.proxy.httpProxies[0].credentialsSecretRef](./values.yaml#L454)

     
Mandatory if proxy authentication is required. The name of the secret containing the credentials. The secret must contain the keys `user` and `password`.

**Default:** `nil`
#### [license.proxy.httpProxies[0].host](./values.yaml#L445)

     
Optional, but empty value are skipped. Host name or IP address of the proxy server. Examples: "proxy.mycompany.com", "192.168.0.5".

**Default:** `nil`
#### [license.proxy.httpProxies[0].port](./values.yaml#L447)

     
Optional. Port number of the proxy server.

**Default:** `nil`
#### [license.proxy.httpProxies[0].scheme](./values.yaml#L450)

     
Optional. Scheme of the proxy server. Possible values: `http`, `https`.

**Default:** `nil`
#### [license.proxy.networkInterface](./values.yaml#L500)

     
Optional. Specifies a NIC to use to access the external services, with or without a proxy.

**Default:** `nil`
#### [license.proxy.pacFiles](./values.yaml#L475)

     
Optional. Configure one or multiple proxy auto-configuration (PAC), files for simpler proxy configuration.

**Default:** `[]`
#### [license.proxy.pacFiles.filePaths](./values.yaml#L486)

     
Optional. List of configmap names and keys where the PAC files are stored.

**Default:** `[]`
#### [license.proxy.pacFiles.fileUrls](./values.yaml#L478)

     
Optional. List of URLs of the PAC files.

**Default:** `[]`
#### [license.proxy.socksProxies](./values.yaml#L459)

     
Optional. List of SOCKS Proxy Server configurations. The proxies are all checked and the first acceptable one is used. If any HTTP proxy is configured in `httpProxies` too, it is checked in parallel with the defined SOCKS proxies.

**Default:**

```
[{"credentialsSecretRef":null,"host":null,"port":null,"version":null}]
```
#### [license.proxy.socksProxies[0].credentialsSecretRef](./values.yaml#L471)

     
Mandatory if proxy authentication is required. The name of the secret containing the credentials. The secret must contain the keys `user` and `password`.

**Default:** `nil`
#### [license.proxy.socksProxies[0].host](./values.yaml#L462)

     
Optional. Host name or IP address of the proxy server. Examples: "socks.mycompany.com", "192.168.0.9"

**Default:** `nil`
#### [license.proxy.socksProxies[0].port](./values.yaml#L464)

     
Mandatory. Port number of the SOCKS server.

**Default:** `nil`
#### [license.proxy.socksProxies[0].version](./values.yaml#L467)

     
Protocol version to use. Possible values: `SOCKS4`, `SOCKS4a`, `SOCKS5`.

**Default:** `nil`
### Logging configuration
 
#### [logging](./values.yaml#L503)

     
Mandatory. Logging configuration for Lightstreamer Server.

**Default:**

```
{"appenders":{"console":{"pattern":"%d{\"dd.MMM.yy HH:mm:ss,SSS\"} <%5.5(%p%marker)> %m%n","type":"Console"},"dailyRolling":{"fileName":"lightstreamer.log","fileNamePattern":"lightstreamer-%d{yyyy-MM-dd}.log","pattern":"%d{\"dd-MMM-yy HH:mm:ss,SSS\"}|%-5.5(%p%marker)|%-19.19c{19}|%-27.27t|%m%n","type":"DailyRollingFile","volumeRef":null}},"extraLoggers":null,"loggers":{"com.github.markusbernhardt.proxy":{"appenders":["console"],"level":"WARN"},"com.google":{"appenders":["console"],"level":"ERROR"},"com.sun.jmx.remote":{"appenders":["console"],"level":"ERROR"},"com.turo":{"appenders":["console"],"level":"ERROR"},"com.zaxxer.hikari":{"appenders":["console"],"level":"INFO"},"common.jmx.velocity":{"appenders":["console"],"level":"ERROR"},"io.grpc":{"appenders":["console"],"level":"WARN"},"io.netty":{"appenders":["console"],"level":"ERROR"},"io.opencensus":{"appenders":["console"],"level":"WARN"},"java.sql":{"appenders":["console"],"level":"WARN"},"javax.management.mbeanserver":{"appenders":["console"],"level":"ERROR"},"javax.management.remote":{"appenders":["console"],"level":"ERROR"},"javax.net.ssl":{"appenders":["console"],"level":"OFF"},"lightstreamerHealthCheck":{"appenders":["console"],"level":"INFO"},"lightstreamerLogger":{"appenders":["console"],"level":"INFO","subLoggers":{"lightstreamerLogger.connections":"WARN","lightstreamerLogger.connections.WS":"WARN","lightstreamerLogger.connections.http":"ERROR","lightstreamerLogger.connections.proxy":"INFO","lightstreamerLogger.connections.ssl":"WARN","lightstreamerLogger.external":"INFO","lightstreamerLogger.init":"INFO","lightstreamerLogger.io":"WARN","lightstreamerLogger.io.ssl":"WARN","lightstreamerLogger.kernel":"INFO","lightstreamerLogger.license":"INFO","lightstreamerLogger.monitoring":"INFO","lightstreamerLogger.mpn":"INFO","lightstreamerLogger.mpn.apple":"WARN","lightstreamerLogger.mpn.database":"WARN","lightstreamerLogger.mpn.database.transactions":"WARN","lightstreamerLogger.mpn.google":"WARN","lightstreamerLogger.mpn.lifecycle":"INFO","lightstreamerLogger.mpn.operations":"INFO","lightstreamerLogger.mpn.pump":"WARN","lightstreamerLogger.mpn.requests":"WARN","lightstreamerLogger.mpn.status_adapters":"WARN","lightstreamerLogger.preprocessor":"INFO","lightstreamerLogger.pump":"INFO","lightstreamerLogger.pump.messages":"INFO","lightstreamerLogger.push":"INFO","lightstreamerLogger.requests":"INFO","lightstreamerLogger.requests.messages":"INFO","lightstreamerLogger.requests.polling":"WARN","lightstreamerLogger.scheduler":"INFO","lightstreamerLogger.subscriptions":"DEBUG","lightstreamerLogger.subscriptions.upd":"DEBUG","lightstreamerLogger.webServer":"WARN","lightstreamerLogger.webServer.appleWebService":"WARN","lightstreamerLogger.webServer.jmxTree":"WARN","lightstreamerLogger.webclient":"DEBUG"}},"lightstreamerMonitorTAB":{"appenders":["console"],"level":"ERROR"},"lightstreamerMonitorText":{"appenders":["console"],"level":"INFO"},"lightstreamerProxyAdapters":{"appenders":["console"],"level":"INFO"},"org.apache.http":{"appenders":["console"],"level":"ERROR"},"org.codehaus.janino":{"appenders":["console"],"level":"WARN"},"org.conscrypt":{"appenders":["console"],"level":"ERROR"},"org.hibernate":{"appenders":["console"],"level":"WARN"},"org.jboss.logging":{"appenders":["console"],"level":"WARN"},"org.jminix":{"appenders":["console"],"level":"ERROR"},"org.restlet":{"appenders":["console"],"level":"ERROR"}}}
```
#### [logging.appenders](./values.yaml#L506)

     
Mandatory. Appenders configuration. Every logger must refer to one or more appenders defined here.

**Default:**

```
{"console":{"pattern":"%d{\"dd.MMM.yy HH:mm:ss,SSS\"} <%5.5(%p%marker)> %m%n","type":"Console"},"dailyRolling":{"fileName":"lightstreamer.log","fileNamePattern":"lightstreamer-%d{yyyy-MM-dd}.log","pattern":"%d{\"dd-MMM-yy HH:mm:ss,SSS\"}|%-5.5(%p%marker)|%-19.19c{19}|%-27.27t|%m%n","type":"DailyRollingFile","volumeRef":null}}
```
#### [logging.appenders.dailyRolling](./values.yaml#L509)

     
At least one must be provided. An appender configuration. Choose whatever key you like, as long as it is unique.

**Default:**

```
{"fileName":"lightstreamer.log","fileNamePattern":"lightstreamer-%d{yyyy-MM-dd}.log","pattern":"%d{\"dd-MMM-yy HH:mm:ss,SSS\"}|%-5.5(%p%marker)|%-19.19c{19}|%-27.27t|%m%n","type":"DailyRollingFile","volumeRef":null}
```
#### [logging.appenders.dailyRolling.fileName](./values.yaml#L518)

     
Mandatory if `type` is set to `DailyRollingFile`. The name of the log file.

**Default:** `"lightstreamer.log"`
#### [logging.appenders.dailyRolling.fileNamePattern](./values.yaml#L521)

     
Mandatory if `type` is set to `DailyRollingFile`. The pattern to use for the log file.

**Default:** `"lightstreamer-%d{yyyy-MM-dd}.log"`
#### [logging.appenders.dailyRolling.pattern](./values.yaml#L515)

     
Mandatory. The conversion pattern. See https://logback.qos.ch/index.html for details.

**Default:**

```
"%d{\"dd-MMM-yy HH:mm:ss,SSS\"}|%-5.5(%p%marker)|%-19.19c{19}|%-27.27t|%m%n"
```
#### [logging.appenders.dailyRolling.type](./values.yaml#L512)

     
Mandatory. The type of appender. Possible values: `DailyRollingFile`, `Console`.

**Default:** `"DailyRollingFile"`
#### [logging.appenders.dailyRolling.volumeRef](./values.yaml#L523)

     
Optional. The reference to a volume to use for the log file.

**Default:** `nil`
#### [logging.loggers](./values.yaml#L534)

     
Optional. Loggers configuration.

**Default:**

```
{"com.github.markusbernhardt.proxy":{"appenders":["console"],"level":"WARN"},"com.google":{"appenders":["console"],"level":"ERROR"},"com.sun.jmx.remote":{"appenders":["console"],"level":"ERROR"},"com.turo":{"appenders":["console"],"level":"ERROR"},"com.zaxxer.hikari":{"appenders":["console"],"level":"INFO"},"common.jmx.velocity":{"appenders":["console"],"level":"ERROR"},"io.grpc":{"appenders":["console"],"level":"WARN"},"io.netty":{"appenders":["console"],"level":"ERROR"},"io.opencensus":{"appenders":["console"],"level":"WARN"},"java.sql":{"appenders":["console"],"level":"WARN"},"javax.management.mbeanserver":{"appenders":["console"],"level":"ERROR"},"javax.management.remote":{"appenders":["console"],"level":"ERROR"},"javax.net.ssl":{"appenders":["console"],"level":"OFF"},"lightstreamerHealthCheck":{"appenders":["console"],"level":"INFO"},"lightstreamerLogger":{"appenders":["console"],"level":"INFO","subLoggers":{"lightstreamerLogger.connections":"WARN","lightstreamerLogger.connections.WS":"WARN","lightstreamerLogger.connections.http":"ERROR","lightstreamerLogger.connections.proxy":"INFO","lightstreamerLogger.connections.ssl":"WARN","lightstreamerLogger.external":"INFO","lightstreamerLogger.init":"INFO","lightstreamerLogger.io":"WARN","lightstreamerLogger.io.ssl":"WARN","lightstreamerLogger.kernel":"INFO","lightstreamerLogger.license":"INFO","lightstreamerLogger.monitoring":"INFO","lightstreamerLogger.mpn":"INFO","lightstreamerLogger.mpn.apple":"WARN","lightstreamerLogger.mpn.database":"WARN","lightstreamerLogger.mpn.database.transactions":"WARN","lightstreamerLogger.mpn.google":"WARN","lightstreamerLogger.mpn.lifecycle":"INFO","lightstreamerLogger.mpn.operations":"INFO","lightstreamerLogger.mpn.pump":"WARN","lightstreamerLogger.mpn.requests":"WARN","lightstreamerLogger.mpn.status_adapters":"WARN","lightstreamerLogger.preprocessor":"INFO","lightstreamerLogger.pump":"INFO","lightstreamerLogger.pump.messages":"INFO","lightstreamerLogger.push":"INFO","lightstreamerLogger.requests":"INFO","lightstreamerLogger.requests.messages":"INFO","lightstreamerLogger.requests.polling":"WARN","lightstreamerLogger.scheduler":"INFO","lightstreamerLogger.subscriptions":"DEBUG","lightstreamerLogger.subscriptions.upd":"DEBUG","lightstreamerLogger.webServer":"WARN","lightstreamerLogger.webServer.appleWebService":"WARN","lightstreamerLogger.webServer.jmxTree":"WARN","lightstreamerLogger.webclient":"DEBUG"}},"lightstreamerMonitorTAB":{"appenders":["console"],"level":"ERROR"},"lightstreamerMonitorText":{"appenders":["console"],"level":"INFO"},"lightstreamerProxyAdapters":{"appenders":["console"],"level":"INFO"},"org.apache.http":{"appenders":["console"],"level":"ERROR"},"org.codehaus.janino":{"appenders":["console"],"level":"WARN"},"org.conscrypt":{"appenders":["console"],"level":"ERROR"},"org.hibernate":{"appenders":["console"],"level":"WARN"},"org.jboss.logging":{"appenders":["console"],"level":"WARN"},"org.jminix":{"appenders":["console"],"level":"ERROR"},"org.restlet":{"appenders":["console"],"level":"ERROR"}}
```
#### [logging.loggers.lightstreamerHealthCheck](./values.yaml#L798)

     
Optional. Logging healthcheck request processing at INFO level. The logger does not inherit from `lightstreamerLogger` in order to simplify sending the log to a dedicated appender. All log from this logger reports the IP and port of the involved connection.

**Default:** `{"appenders":["console"],"level":"INFO"}`
#### [logging.loggers.lightstreamerHealthCheck.appenders](./values.yaml#L801)

     
Optional. List of references to the appenders defined in `.logging.appenders`.

**Default:** `["console"]`
#### [logging.loggers.lightstreamerHealthCheck.level](./values.yaml#L805)

     
Optional. The level of the logger.

**Default:** `DEBUG`
#### [logging.loggers.lightstreamerLogger](./values.yaml#L591)

     
Optional. The following is the base logger of all logging messages printed by Lightstreamer Kernel (with a few exceptions). Messages logged at `INFO` level notify major server activities, like session starting and ending. If these messages are enabled, they are also supplied to the internal MONITOR data adapter, together with `WARN` and `ERROR` messages. Messages logged at `DEBUG` level notify minor operations and all data flow inside the Server. They should not be enabled with production load levels. No useful messages are logged at `TRACE` level. The level is reserved for `DEBUG` versions of the Server. Severe `ERROR` messages are logged with a `FATAL` marker; in fact, a `FATAL` level is not natively supported by logback. Thanks to the marker, these messages can be filtered through logback's MarkerFilter. By the factory pattern configuration, `FATAL` is logged instead of `ERROR` for these messages (note the tricky "%-5.5(%p%marker)" pattern).

**Default:**

```
{"appenders":["console"],"level":"INFO","subLoggers":{"lightstreamerLogger.connections":"WARN","lightstreamerLogger.connections.WS":"WARN","lightstreamerLogger.connections.http":"ERROR","lightstreamerLogger.connections.proxy":"INFO","lightstreamerLogger.connections.ssl":"WARN","lightstreamerLogger.external":"INFO","lightstreamerLogger.init":"INFO","lightstreamerLogger.io":"WARN","lightstreamerLogger.io.ssl":"WARN","lightstreamerLogger.kernel":"INFO","lightstreamerLogger.license":"INFO","lightstreamerLogger.monitoring":"INFO","lightstreamerLogger.mpn":"INFO","lightstreamerLogger.mpn.apple":"WARN","lightstreamerLogger.mpn.database":"WARN","lightstreamerLogger.mpn.database.transactions":"WARN","lightstreamerLogger.mpn.google":"WARN","lightstreamerLogger.mpn.lifecycle":"INFO","lightstreamerLogger.mpn.operations":"INFO","lightstreamerLogger.mpn.pump":"WARN","lightstreamerLogger.mpn.requests":"WARN","lightstreamerLogger.mpn.status_adapters":"WARN","lightstreamerLogger.preprocessor":"INFO","lightstreamerLogger.pump":"INFO","lightstreamerLogger.pump.messages":"INFO","lightstreamerLogger.push":"INFO","lightstreamerLogger.requests":"INFO","lightstreamerLogger.requests.messages":"INFO","lightstreamerLogger.requests.polling":"WARN","lightstreamerLogger.scheduler":"INFO","lightstreamerLogger.subscriptions":"DEBUG","lightstreamerLogger.subscriptions.upd":"DEBUG","lightstreamerLogger.webServer":"WARN","lightstreamerLogger.webServer.appleWebService":"WARN","lightstreamerLogger.webServer.jmxTree":"WARN","lightstreamerLogger.webclient":"DEBUG"}}
```
#### [logging.loggers.lightstreamerLogger.appenders](./values.yaml#L594)

     
Optional. List of references to the appenders defined in `.logging.appenders`.

**Default:** `["console"]`
#### [logging.loggers.lightstreamerLogger.level](./values.yaml#L598)

     
Optional. The level of the logger.

**Default:** `DEBUG`
#### [logging.loggers.lightstreamerLogger.subLoggers](./values.yaml#L601)

     
Optional. The levels of subloggers used to separate logging messages in families. The appenders are inherited from `lightstreamerLogger`.

**Default:**

```
{"lightstreamerLogger.connections":"WARN","lightstreamerLogger.connections.WS":"WARN","lightstreamerLogger.connections.http":"ERROR","lightstreamerLogger.connections.proxy":"INFO","lightstreamerLogger.connections.ssl":"WARN","lightstreamerLogger.external":"INFO","lightstreamerLogger.init":"INFO","lightstreamerLogger.io":"WARN","lightstreamerLogger.io.ssl":"WARN","lightstreamerLogger.kernel":"INFO","lightstreamerLogger.license":"INFO","lightstreamerLogger.monitoring":"INFO","lightstreamerLogger.mpn":"INFO","lightstreamerLogger.mpn.apple":"WARN","lightstreamerLogger.mpn.database":"WARN","lightstreamerLogger.mpn.database.transactions":"WARN","lightstreamerLogger.mpn.google":"WARN","lightstreamerLogger.mpn.lifecycle":"INFO","lightstreamerLogger.mpn.operations":"INFO","lightstreamerLogger.mpn.pump":"WARN","lightstreamerLogger.mpn.requests":"WARN","lightstreamerLogger.mpn.status_adapters":"WARN","lightstreamerLogger.preprocessor":"INFO","lightstreamerLogger.pump":"INFO","lightstreamerLogger.pump.messages":"INFO","lightstreamerLogger.push":"INFO","lightstreamerLogger.requests":"INFO","lightstreamerLogger.requests.messages":"INFO","lightstreamerLogger.requests.polling":"WARN","lightstreamerLogger.scheduler":"INFO","lightstreamerLogger.subscriptions":"DEBUG","lightstreamerLogger.subscriptions.upd":"DEBUG","lightstreamerLogger.webServer":"WARN","lightstreamerLogger.webServer.appleWebService":"WARN","lightstreamerLogger.webServer.jmxTree":"WARN","lightstreamerLogger.webclient":"DEBUG"}
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections"](./values.yaml#L633)

     
Optional. Logging of client request dispatching. At `DEBUG` level, request processing details are reported. All log from this logger and its subloggers reports the IP and port of the involved connection

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.WS"](./values.yaml#L651)

     
Optional. Logging of details for issues related to requests over WebSockets. At `DEBUG` level, details for all requests and responses are reported.

**Default:**

```
inherited from lightstreamerLogger.connections
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.http"](./values.yaml#L646)

     
Optional. Logging of client request interpretation issues. At `WARN` level, each time a request contains an unexpected HTTP header, which the Server refuses or ignores, a notification is reported that an interpretation error is possible. At `INFO` level, details upon request refusals are reported. At `DEBUG` level, details for all requests and responses are reported.

**Default:**

```
inherited from lightstreamerLogger.connections
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.proxy"](./values.yaml#L656)

     
Optional. Logging of issues related to information received via the proxy protocol, when enabled. At `DEBUG` level, details of all information received are reported.

**Default:**

```
inherited from lightstreamerLogger.connections
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.ssl"](./values.yaml#L638)

     
Optional. Logging of issues related to TLS/SSL configuration and handshake management. At `DEBUG` level, details on the cipher suites are report.

**Default:**

```
inherited from lightstreamerLogger.connections
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.external"](./values.yaml#L621)

     
Optional. Logging of external services activity. At `DEBUG` level, details on external services activities and configuration, as well as details on connectivity issues, are reported.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.init"](./values.yaml#L606)

     
Optional. Logging of system components initialization. At `DEBUG` level, initialization details, error details and all configuration settings are reported.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.io"](./values.yaml#L624)

     
Optional. Logging of activity and issues in connection management.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.io.ssl"](./values.yaml#L628)

     
Optional. Logging of activity and issues in TLS configuration. At `DEBUG` level, details on the protocol and cipher suite configuration are reported

**Default:** `inherited from `lightstreamerLogger.io``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.kernel"](./values.yaml#L615)

     
Optional. Logging of background activities and related configuration and issues.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.license"](./values.yaml#L611)

     
Optional. Logging of license check phase. At `DEBUG` level, check details and error details can be found in case of license check failure.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.monitoring"](./values.yaml#L792)

     
Optional. Logging of JMX setup issues; note that full JMX features could be restricted depending on Edition and License Type. At `DEBUG` level, JMX connectors initialization details are logged.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn"](./values.yaml#L722)

     
Optional. Logging of mobile push notifications activity, done through the various subloggers.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.apple"](./values.yaml#L768)

     
Optional. Logging of mobile push notifications activity related to  Apple platforms; for activity related with notification submission, specific subloggers are present for each application, e.g.: `lightstreamerLogger.mpn.apple.com.mydomain.myapp`. At `INFO` level, all push notification payloads are dumped.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.database"](./values.yaml#L754)

     
Optional. Logging of mobile push notifications activity related to database. At `DEBUG` level, all database operation entry and exit points are logged.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.database.transactions"](./values.yaml#L761)

     
Optional. Logging of mobile push notifications activity related to database transactions. At `INFO` level, statistics on the database transactions are logged. At `DEBUG` level, all database transaction entry and exit points are logged.

**Default:**

```
inherited from lightstreamerLogger.mpn.database
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.google"](./values.yaml#L775)

     
Optional. Logging of mobile push notifications activity related to Google platforms; for activity related with notification submission, specific subloggers are present for each application, e.g.: `lightstreamerLogger.mpn.google.com.mydomain.myapp`. At `INFO` level, all push notification payloads are dumped.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.lifecycle"](./values.yaml#L727)

     
Optional. Logging of MPN Module recurrent activity. At `INFO` level, main operation exit points and outcomes are dumped. At `DEBUG` level, the various operation entry entry and exit points are logged.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.operations"](./values.yaml#L733)

     
Optional,. Logging of mobile push notifications activity. At `INFO` level, main operation exit points and outcomes are dumped. At `DEBUG` level, the various operation entry entry and exit points are logged.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.pump"](./values.yaml#L748)

     
Optional. Logging of mobile push notifications activity related to notification gathering. At `INFO` level, all push notifications ready to be sent are dumped.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.requests"](./values.yaml#L743)

     
Optional. Logging of mobile push notifications request processing; requests include those from clients (through the "client" sublogger) and those related with internal operations. At `INFO` level, all request processing exit points and outcomes are dumped. At `DEBUG` level, all request processing entry points are logged. All log related with client requests reports the IP and port of the involved connection.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.status_adapters"](./values.yaml#L779)

     
Optional. Logging of issues related with the special adapters handled by the MPN Module.

**Default:** `inherited from `lightstreamerLogger.mpn``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.preprocessor"](./values.yaml#L698)

     
Optional. Logging of events preprocessing stage. At `DEBUG` level, events dispatched to ItemEventBuffers are dumped.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.pump"](./values.yaml#L707)

     
Optional. Logging of InfoPump and ItemEventBuffers internal activity. At `DEBUG` level, updates to be sent to the clients are dumped.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.pump.messages"](./values.yaml#L713)

     
Optional. Logging of management of messages received from the clients. At `DEBUG` level, details of message processing are logged. All log from this logger reports the IP and port of the involved connection.

**Default:** `inherited from `lightstreamerLogger.pump``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.push"](./values.yaml#L718)

     
Optional. Logging of socket write activity. At `DEBUG` level, all socket writes are dumped. All log from this logger reports the IP and port of the involved connection.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.requests"](./values.yaml#L679)

     
Optional. Logging of parsing and elaboration of client requests At `DEBUG` level, client request details are reported. All log from this logger and its subloggers reports the IP and port of the involved connection.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.requests.messages"](./values.yaml#L686)

     
Optional. Logging of elaboration of client message requests. At `DEBUG` level, details on the message forwarding are reported.

**Default:**

```
inherited from lightstreamerLogger.requests
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.requests.polling"](./values.yaml#L682)

     
Optional. Logging of elaboration of client polling requests.

**Default:**

```
inherited from lightstreamerLogger.requests
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.scheduler"](./values.yaml#L702)

     
Optional. Logging of internal thread management and events dispatching.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.subscriptions"](./values.yaml#L690)

     
Optional. Logging of Data Adapters interactions. At `DEBUG` level, details on subscription operations are reported.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.subscriptions.upd"](./values.yaml#L694)

     
Optional. Logging of events coming from the Data Adapters. At `DEBUG` level, all update events are dumped.

**Default:**

```
inherited from lightstreamerLogger.subscriptions
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webServer"](./values.yaml#L663)

     
Optional. Logging of internal web server activity; it also logs requests of static resources related to push request. At `DEBUG` level, error details are reported. All log from this logger and its subloggers reports the IP and port of the involved connection.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webServer.appleWebService"](./values.yaml#L673)

     
Optional. Logging of handling of special requests from apple clients related to MPN. At `DEBUG` level, error details are reported.

**Default:**

```
inherited from lightstreamerLogger.webServer
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webServer.jmxTree"](./values.yaml#L668)

     
Optional. Logging of request management related to the JMX Tree feature. At `DEBUG` level, error details are reported.

**Default:**

```
inherited from lightstreamerLogger.webServer
```
#### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webclient"](./values.yaml#L787)

     
Optional. Logging of JavaScript client messages. A at `DEBUG` level, log messages sent by the Web and Node.js (Unified API) Client Libraries are logged. Remote logging must be enabled on the client side. All log from this logger reports the IP and port of the involved connection.

**Default:** `inherited from `lightstreamerLogger``
#### [logging.loggers.lightstreamerMonitorTAB](./values.yaml#L566)

     
Optional. Logger used by the internal monitoring system to log load statistics at `INFO` level with a CSV syntax. See `lightstreamerMonitorText` for details.

**Default:** `{"appenders":["console"],"level":"ERROR"}`
#### [logging.loggers.lightstreamerMonitorTAB.appenders](./values.yaml#L569)

     
Optional. List of references to the appenders defined in `.logging.appenders`.

**Default:** `["console"]`
#### [logging.loggers.lightstreamerMonitorTAB.level](./values.yaml#L573)

     
Optional. The level of the logger.

**Default:** `DEBUG`
#### [logging.loggers.lightstreamerMonitorText](./values.yaml#L555)

     
Optional. Logger used by the internal monitoring system to log load statistics at `INFO` level  with a human-readable syntax. The frequency of the samples produced by the internal monitoring system is governed by the `management.collectorMillis` setting. However, a resampling to lower frequencies can be performed, based on the level specified for each logger; in particular:   at `TRACE` level, all samples are logged;   at `DEBUG` level, one sample out of 10 is logged;   at `INFO` level, one sample out of 60 is logged;   at a higher level, no log is produced. The resampling behavior can be changed at runtime, by changing the level; however, if the level is set to `ERROR` on startup, the logger will be disabled throughout the life of the Server, regardless of further changes. When resampling is in place, note that, for each displayed sample, values that are supposed to be averaged over a timeframe still refer to the current sample's timeframe (based on  `management.collectorMillis`); however, values that are supposed to be the maximum over all timeframes refer also to the samples that were not displayed. On the other hand, delta statistics, like "new connections", are always collected starting from the previous logged sample.

**Default:** `{"appenders":["console"],"level":"INFO"}`
#### [logging.loggers.lightstreamerMonitorText.appenders](./values.yaml#L558)

     
Optional. List of references to the appenders defined in `.logging.appenders`.

**Default:** `["console"]`
#### [logging.loggers.lightstreamerMonitorText.level](./values.yaml#L562)

     
Optional. The level of the logger.

**Default:** `DEBUG`
#### [logging.loggers.lightstreamerProxyAdapters](./values.yaml#L813)

     
Optional. Logger only used by the provided Proxy Data and Metadata Adapters, when used. It logs Adapter activity at `INFO`, `WARN`, `ERROR` and `FATAL` level (the latter through the `FATAL` marker). At `DEBUG` level, outcoming request and incoming response messages are also dumped. At `TRACE` level, incoming real-time update messages are also dumped.

**Default:** `{"appenders":["console"],"level":"INFO"}`
#### [logging.loggers.lightstreamerProxyAdapters.appenders](./values.yaml#L816)

     
Optional. List of references to the appenders defined in `.logging.appenders`.

**Default:** `["console"]`
#### [logging.loggers.lightstreamerProxyAdapters.level](./values.yaml#L820)

     
Optional. The level of the logger.

**Default:** `DEBUG`
### Connectors configuration
 
#### [connectors](./values.yaml#L3228)

     
Optional. Connectors configuration.

**Default:**

```
{"kafkaConnector":{"adapterClassName":"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter","adapterSetId":"KafkaConnector","connections":{"quickStart":{"authentication":{"authentication":null,"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":null,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null}},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"keyStoreRef":null,"protocol":null,"trustStoreRef":null}}},"enabled":false,"localSchemaFiles":{"myKeySchema":null,"myValueSchema":null},"logging":{"appenders":{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}},"loggers":{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}},"schemaRegistry":{"mySchemaRegistry":{"basicAuthentication":{"credentialsSecretRef":null,"enabled":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null},"url":"https://schema-registry:8084"}},"version":"1.2.0"}}
```
#### [connectors.kafkaConnector](./values.yaml#L3230)

     
Optional. Lightstreamer Kafka Connector configuration.

**Default:**

```
{"adapterClassName":"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter","adapterSetId":"KafkaConnector","connections":{"quickStart":{"authentication":{"authentication":null,"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":null,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null}},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"keyStoreRef":null,"protocol":null,"trustStoreRef":null}}},"enabled":false,"localSchemaFiles":{"myKeySchema":null,"myValueSchema":null},"logging":{"appenders":{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}},"loggers":{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}},"schemaRegistry":{"mySchemaRegistry":{"basicAuthentication":{"credentialsSecretRef":null,"enabled":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null},"url":"https://schema-registry:8084"}},"version":"1.2.0"}
```
#### [connectors.kafkaConnector.adapterClassName](./values.yaml#L3242)

     
Mandatory. Java class name of the Kafka Connector Metadata Adapter. It is possible to provide a custom implementation by extending the factory class. See https://github.com/Lightstreamer/Lightstreamer-kafka-connector/tree/main?tab=readme-ov-file#customize-the-kafkaconnector-metadata-adapter-class

**Default:**

```
"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter"
```
#### [connectors.kafkaConnector.adapterSetId](./values.yaml#L3237)

     
Mandatory. Define the Kafka Connector Adapter Set and its unique ID.

**Default:** `"KafkaConnector"`
#### [connectors.kafkaConnector.connections](./values.yaml#L3277)

     
Mandatory. Connection configurations.

**Default:**

```
{"quickStart":{"authentication":{"authentication":null,"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":null,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null}},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"keyStoreRef":null,"protocol":null,"trustStoreRef":null}}}
```
#### [connectors.kafkaConnector.connections.quickStart](./values.yaml#L3284)

     
At least one must be provided. Connection configuration. The Kafka Connector allows the configuration of different independent connections to different Kafka broker/clusters. Since the Kafka Connector manages the physical connection to Kafka by wrapping an internal Kafka Consumer, several configuration settings are identical to those required by the usual Kafka Consumer configuration.

**Default:**

```
{"authentication":{"authentication":null,"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":null,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null}},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"keyStoreRef":null,"protocol":null,"trustStoreRef":null}}
```
#### [connectors.kafkaConnector.connections.quickStart.authentication](./values.yaml#L3342)

     
Optional. Authentication settings for the connection.

**Default:**

```
{"authentication":null,"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":null,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null}}
```
#### [connectors.kafkaConnector.connections.quickStart.authentication.credentialsSecretRef](./values.yaml#L3360)

     
Mandatory if `mechanism` is set to `PLAIN`, `SCRAM-SHA-256`, `SCRAM-SHA-512`. The name of the secret containing the  credentials. The secret must contain the keys `user` and `password`.

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.authentication.enabled](./values.yaml#L3346)

     
Optional. Enablement of the authentication of the connection against the Kafka Cluster.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi](./values.yaml#L3363)

     
Mandatory if `mechanism` is set to `GSSAPI`. The GSSAPI authentication settings.

**Default:**

```
{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":null,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null}
```
#### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.enableKeytab](./values.yaml#L3366)

     
Optional. Enablement of the use of a keytab.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.enableStoreKey](./values.yaml#L3374)

     
Optional. Enablement of the storage of the principal key.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.enableTicketCache](./values.yaml#L3382)

     
Optional. Enablement of the use of a ticket cache.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.kerberosServiceName](./values.yaml#L3376)

     
Mandatory. The name of the Kerberos service.

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.keytabFilePathRef](./values.yaml#L3369)

     
Mandatory if `enableKeytab` is set to `true`. The configmap name and key where the the keytab file is stored

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.principal](./values.yaml#L3379)

     
Mandatory if enableTicketCache is set to `true`. The name of the principal to be used.

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.bootstrapServers](./values.yaml#L3300)

     
Mandatory. The Kafka Cluster bootstrap server endpoint expressed as the list of host/port pairs used to establish the initial connect.

**Default:** `"broker:9092"`
#### [connectors.kafkaConnector.connections.quickStart.enabled](./values.yaml#L3296)

     
Enablement of the connection. If set to `false`, the Lightstreamer Server will automatically deny every subscription made to the connection.

**Default:** `true`
#### [connectors.kafkaConnector.connections.quickStart.fields](./values.yaml#L3542)

     
Mandatory. Record mappings configuration.

**Default:**

```
{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}}
```
#### [connectors.kafkaConnector.connections.quickStart.fields.enableSkipFailedMapping](./values.yaml#L3574)

     
Optional. If set to `true`, if a field mapping fails, that specific field's value will simply be omitted from the update sent to the Lightstreamer clients, while other successfully mapped fields from the same record will still be delivered. Can be one of the

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.fields.mappings.timestamp](./values.yaml#L3551)

     
At least one must be provided. A field mapping. Map the value extracted through the "#{extraction_expression}" to the Lightstreamer field name specified by key. The expression is written in the Data Extraction Language. See documentation at: https://github.com/lightstreamer/Lightstreamer-kafka-connector?tab=readme-ov-file#record-mapping-fieldfield_name

**Default:** `"#{VALUE.timestamp}"`
#### [connectors.kafkaConnector.connections.quickStart.groupId](./values.yaml#L3309)

     
Optional. The name of the consumer group this connection belongs to. Sets the value for the "group.id" key used to configure the internal Kafka Consumer. See https://kafka.apache.org/documentation/#consumerconfigs_group.id for details. suffix.

**Default:**

```
kafkaConnector.adapterSetId + name + randomly generated
```
#### [connectors.kafkaConnector.connections.quickStart.logger](./values.yaml#L3576)

     
Optional. Logger configuration for the connection.

**Default:** `{"appenders":["stdout"],"level":"INFO"}`
#### [connectors.kafkaConnector.connections.quickStart.logger.appenders](./values.yaml#L3579)

     
Mandatory. List of references to the appenders defined in `kafkaConnector.logging.appenders`.

**Default:** `["stdout"]`
#### [connectors.kafkaConnector.connections.quickStart.logger.level](./values.yaml#L3582)

     
Mandatory. The logger level.

**Default:** `"INFO"`
#### [connectors.kafkaConnector.connections.quickStart.name](./values.yaml#L3291)

     
Mandatory and unique across all configurations. The connection name. This value will be used by the Clients to request real-time data from this specific Kafka connection through a Subscription object. The connection name is also used to group all logging messages belonging to the same connection.

**Default:** `"K8S-QuickStart"`
#### [connectors.kafkaConnector.connections.quickStart.record](./values.yaml#L3385)

     
Optional. Record evaluation settings.

**Default:** `all settings at their defaults`
#### [connectors.kafkaConnector.connections.quickStart.record.consumeFrom](./values.yaml#L3393)

     
Optional. Specifies where to start consuming events from: - `LATEST`: start consuming events from the end of the topic partition - `EARLIEST`: start consuming events from the beginning of the topic partition Sets the value of the `auto.offset.reset` key to configure the internal Kafka Consumer.

**Default:** `LATEST`
#### [connectors.kafkaConnector.connections.quickStart.record.consumeWithOrderStrategy](./values.yaml#L3410)

     
Optional, but effective only if `consumeWithThreadNumber` is set to a value greater than 1 (which includes the default value). The order strategy to be used for concurrent processing of the incoming deserialized records. If set to `ORDER_BY_PARTITION`, maintain the order of records within each partition. If set to `ORDER_BY_KEY`, maintain the order among the records sharing the same key. If set to `UNORDERED`, provide no ordering guarantees.

**Default:** `ORDER_BY_PARTITION`
#### [connectors.kafkaConnector.connections.quickStart.record.consumeWithThreadNumber](./values.yaml#L3399)

     
Optional. The number of threads to be used for concurrent processing of the incoming deserialized records. If set to `-1`, the number of threads will be automatically determined based on the number of available CPU cores.

**Default:** `1`
#### [connectors.kafkaConnector.connections.quickStart.record.extractionErrorStrategy](./values.yaml#L3471)

     
Optional. The error handling strategy to be used if an error occurs while extracting data from incoming deserialized records. If set to `IGNORE_AND_CONTINUE`, the error is ignored and the processing of the record continues. If set to `FORCE_UNSUBSCRIPTION`, the processing of the record is stopped and the unsubscription of the items requested by all the Lightstreamer clients subscribed to this connection is forced.

**Default:** `IGNORE_AND_CONTINUE`
#### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator](./values.yaml#L3413)

     
Optional. Key evaluator configuration.

**Default:** `all settings at their defaults`
#### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator.enableSchemaRegistry](./values.yaml#L3442)

     
Enablement of the Confluent Schema Registry for  validation of the key. Must be set to `true` when `keyEvaluator.type` is set to `AVRO` and no local schema are specified.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator.localSchemaFilePathRef](./values.yaml#L3436)

     
Mandatory if `type` is set to `AVRO` and `enableSchemaRegistry` is set to `false`. The configmap name and key where the local schema for message validation of the key is stored. The setting takes precedence over `enableSchemaRegistry` if the latter is set to `true`.

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator.type](./values.yaml#L3430)

     
Optional. The format to be used to deserialize the key of a Kafka record. Can be one of the following: - AVRO - JSON - STRING - INTEGER - BOOLEAN - BYTE_ARRAY - BYTE_BUFFER - BYTES - DOUBLE - FLOAT - LONG - SHORT - UUID

**Default:** `STRING`
#### [connectors.kafkaConnector.connections.quickStart.record.schemaRegistryRef](./values.yaml#L3474)

     
Optional. The reference to Schema Registry configuration defined in `connectors.kafkaConnector.schemaRegistry`.

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator](./values.yaml#L3445)

     
Optional. Value evaluator configuration.

**Default:** `all settings at their defaults`
#### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator.enableSchemaRegistry](./values.yaml#L3462)

     
Enablement of the Confluent Schema Registry for validation of the value. Must be set to `true` when `valueEvaluator.type` is set to `AVRO` and no local schema are specified.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator.localSchemaFilePathRef](./values.yaml#L3456)

     
Mandatory if `type` is set to `AVRO` and `enableSchemaRegistry` is set to `false`. The configmap name and key where the local schema for message validation of the value is stored. The setting takes precedence over `enableSchemaRegistry` if the latter is set to `true`.

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator.type](./values.yaml#L3450)

     
Optional. The format to be used to deserialize the value of a Kafka record. See `record.keyEvaluator.type` for the list of supported formats.

**Default:** `STRING`
#### [connectors.kafkaConnector.connections.quickStart.routing](./values.yaml#L3476)

     
Mandatory. Record routings configuration.

**Default:**

```
{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}}
```
#### [connectors.kafkaConnector.connections.quickStart.routing.enableTopicRegEx](./values.yaml#L3540)

     
Optional. Enable `connectors.kafkaConnector.routing.topicMappings.{}.topic` to be treated as a regular expression rather than of a literal topic name.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.routing.itemTemplates](./values.yaml#L3483)

     
Optional. Maps of item template expressions. An expressions is made of: - ITEM_PREFIX: the prefix of the item name - BINDABLE_EXPRESSIONS: a sequence of bindable extraction expressions. See https://lightstreamer.com/api/ls-kafka-connector/latest/ls-kafka-connector/record-extraction.html

**Default:** `{}`
#### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings](./values.yaml#L3486)

     
Mandatory. Kafka topic mappings.

**Default:**

```
{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}
```
#### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock](./values.yaml#L3519)

     
At least one must be provided. A Kafka topic mappings. Map a Kafka topic to: - one or more simple items - one or more item templates - any combination of the above  Examples:  topicMappingSample1:   topic: "aTopicName"   items:     - "item1"     - "item2"     - "itemN"  topicMappingSample2:   topic: "anotherTopicName"   itemTemplateRefs:     - "itemTemplate1"     - "itemTemplate2"     - "itemTemplateN"  topicMappingSample3   topic: "yetAnotherTopicName"   items:     - "item1"     - "item2"     - "itemN"   itemTemplateRefs:     - "itemTemplate1"     - "itemTemplate2"     - "itemTemplateN"

**Default:**

```
{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}
```
#### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock.itemTemplateRefs](./values.yaml#L3533)

     
Mandatory if `items` is empty. List of item template to which the topic must be mapped.

**Default:** `[]`
#### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock.items](./values.yaml#L3526)

     
Mandatory if `itemTemplateRefs` is empty. List of simple items to which the topic must be mapped.

**Default:** `[]`
#### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock.topic](./values.yaml#L3522)

     
Mandatory and unique across all topic mappings. The Kafka topic name.

**Default:** `"stock"`
#### [connectors.kafkaConnector.connections.quickStart.sslConfig](./values.yaml#L3312)

     
Optional. TLS/SSL settings for the connection.

**Default:** `all settings at their defaults`
#### [connectors.kafkaConnector.connections.quickStart.sslConfig.allowedCipherSuites](./values.yaml#L3327)

     
Optional. List of enabled secure cipher suites.

**Default:**

```
all the available cipher suites in the running JVM
```
#### [connectors.kafkaConnector.connections.quickStart.sslConfig.allowedProtocols](./values.yaml#L3324)

     
Optional. List of enabled secure communication protocols TLSv1.2 otherwise.

**Default:**

```
[TLSv1.2, TLSv1.3] when running on Java 11 or newer,
```
#### [connectors.kafkaConnector.connections.quickStart.sslConfig.enableHostnameVerification](./values.yaml#L3330)

     
Optional. Enablement of the hostname verification.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.sslConfig.enabled](./values.yaml#L3315)

     
Optional. Enablement of the encryption.

**Default:** `false`
#### [connectors.kafkaConnector.connections.quickStart.sslConfig.keyStoreRef](./values.yaml#L3340)

     
Optional. The reference to a keystore used if mutual TLS is enabled on Kafka brokers. See the `keyStores.myKafkaConnectorKeystore` settings for general details on keystore configuration for the Kafka Connector.

**Default:** `nil`
#### [connectors.kafkaConnector.connections.quickStart.sslConfig.protocol](./values.yaml#L3320)

     
Optional. The SSL protocol to be used. Can be one of the following: `TLSv1.2`,  `TLSv1.3`. otherwise

**Default:**

```
TLSv1.3 when running on Java 11 or newer, TLSv1.2
```
#### [connectors.kafkaConnector.connections.quickStart.sslConfig.trustStoreRef](./values.yaml#L3335)

     
Optional. The reference to a keystore used to validate the certificates provided by the Kafka brokers. See the `keyStores.myKafkaConnectorKeystore` settings for general details on keystore configuration for the Kafka Connector.

**Default:** `nil`
#### [connectors.kafkaConnector.enabled](./values.yaml#L3233)

     
Optional. Enablement of the Lightstreamer Kafka Connector.

**Default:** `false`
#### [connectors.kafkaConnector.localSchemaFiles](./values.yaml#L3584)

     
Optional. Local schema files used for message validation.

**Default:** `{"myKeySchema":null,"myValueSchema":null}`
#### [connectors.kafkaConnector.localSchemaFiles.myKeySchema](./values.yaml#L3587)

     
Optional. The configmap name and key where the local schema file is stored.

**Default:** `nil`
#### [connectors.kafkaConnector.logging](./values.yaml#L3244)

     
Mandatory. Kafka Connector global Logging configuration.

**Default:**

```
{"appenders":{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}},"loggers":{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}}
```
#### [connectors.kafkaConnector.logging.appenders](./values.yaml#L3247)

     
Mandatory. Appenders configuration. Every logger must refer to one or more appenders defined here.

**Default:**

```
{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}}
```
#### [connectors.kafkaConnector.logging.appenders.stdout](./values.yaml#L3249)

     
At least one must be provided. An appender configuration.

**Default:**

```
{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}
```
#### [connectors.kafkaConnector.logging.appenders.stdout.pattern](./values.yaml#L3254)

     
Mandatory. The appender layout.

**Default:** `"[%d] [%-10c{1}] %-5p %m%n"`
#### [connectors.kafkaConnector.logging.appenders.stdout.type](./values.yaml#L3252)

     
Mandatory. The appender type. Currently, only the `Console` type is supported.

**Default:** `"Console"`
#### [connectors.kafkaConnector.logging.loggers](./values.yaml#L3256)

     
Optional. Global loggers configuration.

**Default:**

```
{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}
```
#### [connectors.kafkaConnector.logging.loggers."com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter"](./values.yaml#L3267)

     
Logger for the Kafka Connector Metadata Adapter. Replace the name with the one of the custom Metadata Adapter class.

**Default:** `{"appenders":["stdout"],"level":"INFO"}`
#### [connectors.kafkaConnector.logging.loggers."org.apache.kafka"](./values.yaml#L3258)

     
The logger name

**Default:** `{"appenders":["stdout"],"level":"WARN"}`
#### [connectors.kafkaConnector.logging.loggers."org.apache.kafka".appenders](./values.yaml#L3261)

     
Mandatory. List of references to the appenders to be used by the logger.

**Default:** `["stdout"]`
#### [connectors.kafkaConnector.logging.loggers."org.apache.kafka".level](./values.yaml#L3264)

     
Mandatory. The logger level.

**Default:** `"WARN"`
#### [connectors.kafkaConnector.schemaRegistry](./values.yaml#L3595)

     
Optional. Set of Schema Registry configurations.

**Default:**

```
{"mySchemaRegistry":{"basicAuthentication":{"credentialsSecretRef":null,"enabled":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null},"url":"https://schema-registry:8084"}}
```
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry](./values.yaml#L3599)

     
Mandatory if either `connections.{}.keyEvaluator.type` or is `connections.{}.valueEvaluator.type` set to `AVRO` and no local schema paths are specified. Schema Registry configuration.

**Default:**

```
{"basicAuthentication":{"credentialsSecretRef":null,"enabled":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null},"url":"https://schema-registry:8084"}
```
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.basicAuthentication](./values.yaml#L3605)

     
Optional. Basic HTTP authentication of a connection against the Schema Registry.

**Default:**

```
{"credentialsSecretRef":null,"enabled":null}
```
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.basicAuthentication.credentialsSecretRef](./values.yaml#L3612)

     
Mandatory if `enable` is set to `true`. The name of the secret containing the credentials. The secret must contain the keys `user` and `password`.

**Default:** `nil`
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.basicAuthentication.enabled](./values.yaml#L3608)

     
Optional. Enablement of the Basic HTTP authentication.

**Default:** `false`
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig](./values.yaml#L3615)

     
Mandatory if the https protocol is specified in `url`. TLS/SSL settings.

**Default:**

```
{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null}
```
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.allowCipherSuites](./values.yaml#L3624)

     
Optional. List of enabled secure cipher suites.

**Default:**

```
all the available cipher suites in the running JVM
```
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.allowProtocols](./values.yaml#L3619)

     
Optional. List of enabled secure communication protocols TLSv1.2 otherwise.

**Default:**

```
[TLSv1.2, TLSv1.3] when running on Java 11 or newer,
```
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.enableHostnameVerification](./values.yaml#L3628)

     
Optional. Enablement of the hostname verification.

**Default:** `false`
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.keyStoreRef](./values.yaml#L3638)

     
Optional. The reference to a keystore used if mutual TLS is enabled on the Schema Registry. See the `keyStores.myKafkaConnectorKeystore` settings for general details on keystore configuration for the Kafka Connector.

**Default:** `nil`
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.trustStoreRef](./values.yaml#L3633)

     
Optional. The reference to a keystore used to validate the certificates provided by the Schema Registry. See the `keyStores.myKafkaConnectorKeystore` settings for general details on keystore configuration for the Kafka Connector.

**Default:** `nil`
#### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.url](./values.yaml#L3602)

     
Mandatory. The URL of the Confluent Schema Registry. An encrypted connection is enabled by specifying the "https" protocol.

**Default:** `"https://schema-registry:8084"`
#### [connectors.kafkaConnector.version](./values.yaml#L3235)

     
Mandatory. The Lightstreamer Kafka Connector version to install.

**Default:** `"1.2.0"`

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)