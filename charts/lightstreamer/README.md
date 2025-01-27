

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 7.4.5](https://img.shields.io/badge/AppVersion-7.4.5-informational?style=flat-square)

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

## Values

### [additionalLabels]

Additional labels to apply to all resources

**Default:** `{}`

### [autoscaling.enabled]

**Default:** `true`

### [autoscaling.maxReplicas]

**Default:** `100`

### [autoscaling.minReplicas]

**Default:** `1`

### [autoscaling.targetCPUUtilizationPercentage]

**Default:** `80`

### [cluster]

Optional. Clustering configuration

**Default:**

```
{"controlLinkAddress":null,"controlLinkMachineName":null,"maxSessionDurationMinutes":null}
```

### [cluster.maxSessionDurationMinutes]

Optional. If set and positive, specifies a maximum duration to be enforced on each session. If the limit expires, the session is closed and the client can only establish a new session. This is useful when a cluster of Server instances is in place, as it leaves the Load Balancer the opportunity to migrate the new session to a different instance. See the Clustering document for details on this mechanism and on how rebalancing can be pursued.

**Default:** unlimited

### [connectors]

Optional. Connectors configuration.

**Default:**

```
{"kafkaConnector":{"adapterClassName":"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter","adapterSetId":"KafkaConnector","connections":{"quickStart":{"authentication":{"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":false,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null},"mechanism":null},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"protocol":null,"trustStoreRef":null}}},"enabled":false,"localSchemaFiles":{"myKeySchema":null,"myValueSchema":null},"logging":{"appenders":{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}},"loggers":{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}},"schemaRegistry":{"mySchemaRegistry":{"basicAuthentication":{"credentialsSecretRef":null,"enabled":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null},"url":"https://schema-registry:8084"}},"version":"1.2.0"}}
```

### [connectors.kafkaConnector]

Optional. Lightstreamer Kafka Connector configuration.

**Default:**

```
{"adapterClassName":"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter","adapterSetId":"KafkaConnector","connections":{"quickStart":{"authentication":{"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":false,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null},"mechanism":null},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"protocol":null,"trustStoreRef":null}}},"enabled":false,"localSchemaFiles":{"myKeySchema":null,"myValueSchema":null},"logging":{"appenders":{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}},"loggers":{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}},"schemaRegistry":{"mySchemaRegistry":{"basicAuthentication":{"credentialsSecretRef":null,"enabled":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null},"url":"https://schema-registry:8084"}},"version":"1.2.0"}
```

### [connectors.kafkaConnector.adapterClassName]

Mandatory. Java class name of the Kafka Connector Metadata  Adapter. It is possible to provide a custom implementation by extending the factory class. See https://github.com/Lightstreamer/Lightstreamer-kafka-connector/tree/main?tab=readme-ov-file#customize-the-kafkaconnector-metadata-adapter-class

**Default:**

```
"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter"
```

### [connectors.kafkaConnector.adapterSetId]

Mandatory. Define the Kafka Connector Adapter Set and its unique ID.

**Default:** `"KafkaConnector"`

### [connectors.kafkaConnector.connections]

Mandatory. Connection configurations.

**Default:**

```
{"quickStart":{"authentication":{"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":false,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null},"mechanism":null},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"protocol":null,"trustStoreRef":null}}}
```

### [connectors.kafkaConnector.connections.quickStart]

At least one must be provided. Connection configuration. The Kafka Connector allows the configuration of different independent connections to different Kafka broker/clusters. Since the Kafka Connector manages the physical connection to Kafka by wrapping an internal Kafka Consumer, several configuration settings are identical to those required by the usual Kafka Consumer configuration.

**Default:**

```
{"authentication":{"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":false,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null},"mechanism":null},"bootstrapServers":"broker:9092","enabled":true,"fields":{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}},"groupId":"quickstart","logger":{"appenders":["stdout"],"level":"INFO"},"name":"K8S-QuickStart","record":{"consumeFrom":"EARLIEST","consumeWithOrderStrategy":null,"consumeWithThreadNumber":null,"extractionErrorStrategy":null,"keyEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"INTEGER"},"schemaRegistryRef":null,"valueEvaluator":{"enableSchemaRegistry":null,"localSchemaFilePathRef":null,"type":"JSON"}},"routing":{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}},"sslConfig":{"allowedCipherSuites":[],"allowedProtocols":[],"enableHostnameVerification":null,"enabled":true,"protocol":null,"trustStoreRef":null}}
```

### [connectors.kafkaConnector.connections.quickStart.authentication]

Optional. Authentication settings for the connection.

**Default:**

```
{"credentialsSecretRef":null,"enabled":false,"gssapi":{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":false,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null},"mechanism":null}
```

### [connectors.kafkaConnector.connections.quickStart.authentication.credentialsSecretRef]

Mandatory if `mechanism` is set to `PLAIN`, `SCRAM-SHA-256`,  `SCRAM-SHA-512`. The name of the secret containing the  credentials.The secret must contain the keys `user` and `password`.

**Default:** `nil`

### [connectors.kafkaConnector.connections.quickStart.authentication.enabled]

Optional. Enablement of the authentication of the connection  against the Kafka Cluster.

**Default:** `false`

### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi]

Mandatory if `mechanism` is set to `GSSAPI`. The GSSAPI  authentication settings.

**Default:**

```
{"enableKeytab":null,"enableStoreKey":null,"enableTicketCache":false,"kerberosServiceName":null,"keytabFilePathRef":null,"principal":null}
```

### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.enableKeytab]

Optional. Enablement of the use of a keytab.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.enableStoreKey]

Optional. Enablement of the storage of the principal key.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.enableTicketCache]

Optional. Enablement of the use of a ticket cache.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.kerberosServiceName]

Mandatory. The name of the Kerberos service.

**Default:** `nil`

### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.keytabFilePathRef]

Mandatory if `enableKeytab` is set to `true`. The configmap name and key where the the keytab file is stored

**Default:** `nil`

### [connectors.kafkaConnector.connections.quickStart.authentication.gssapi.principal]

Mandatory if enableTicketCache is set to `true`.  The name of the principal to be used.

**Default:** `nil`

### [connectors.kafkaConnector.connections.quickStart.bootstrapServers]

Mandatory. The Kafka Cluster bootstrap server endpoint  expressed as the list of host/port pairs used to establish the  initial connect.

**Default:** `"broker:9092"`

### [connectors.kafkaConnector.connections.quickStart.enabled]

Enablement of the connection. If set to `false`, the Lightstreamer Server will automatically deny every subscription made to the connection.

**Default:** true

### [connectors.kafkaConnector.connections.quickStart.fields]

Mandatory. Record mappings configuration.

**Default:**

```
{"enableSkipFailedMapping":null,"mappings":{"ask":"#{VALUE.ask}","ask_quantity":"#{VALUE.ask_quantity}","bid":"#{VALUE.bid}","bid_quantity":"#{VALUE.bid_quantity}","item_status":"#{VALUE.item_status}","last_price":"#{VALUE.last_price}","max":"#{VALUE.max}","min":"#{VALUE.min}","offset":"#{OFFSET}","open_price":"#{VALUE.open_price}","partition":"#{PARTITION}","pct_change":"#{VALUE.pct_change}","ref_price":"#{VALUE.ref_price}","stock_name":"#{VALUE.name}","time":"#{VALUE.time}","timestamp":"#{VALUE.timestamp}","topic":"#{TOPIC}","ts":"#{TIMESTAMP}"}}
```

### [connectors.kafkaConnector.connections.quickStart.fields.enableSkipFailedMapping]

Optional. If set to `true`, if a field mapping fails, that specific field's value will simply be omitted from the update sent to the Lightstreamer clients, while other successfully mapped fields from the same record will still be delivered. Can be one of the

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.fields.mappings.timestamp]

At least one must be provided. A field mapping. Map the value extracted through the "#{extraction_expression}" to the Lightstreamer field name specified by key. The expression is written in the Data Extraction Language. See documentation at: https://github.com/lightstreamer/Lightstreamer-kafka-connector?tab=readme-ov-file#record-mapping-fieldfield_name

**Default:** `"#{VALUE.timestamp}"`

### [connectors.kafkaConnector.connections.quickStart.groupId]

Optional. The name of the consumer group this connection  belongs to. Sets the value for the "group.id" key used to configure the internal Kafka Consumer. See https://kafka.apache.org/documentation/#consumerconfigs_group.id for more details. generated suffix.

**Default:**

```
kafkaConnector.adapterSetId + name + randomly
```

### [connectors.kafkaConnector.connections.quickStart.logger]

Optional. Logger configuration for the connection.

**Default:**

```
{"appenders":["stdout"],"level":"INFO"}
```

### [connectors.kafkaConnector.connections.quickStart.logger.appenders]

Mandatory. List of references to the appenders defined in  `kafkaConnector.logging.appenders`.

**Default:** `["stdout"]`

### [connectors.kafkaConnector.connections.quickStart.logger.level]

Mandatory. The logger level.

**Default:** `"INFO"`

### [connectors.kafkaConnector.connections.quickStart.name]

Mandatory and unique across all configurations. The  connection name. This value will be used by the Clients to request real-time data from this specific Kafka connection through a Subscription object. The connection name is also used to group all logging messages belonging to the same connection.

**Default:** `"K8S-QuickStart"`

### [connectors.kafkaConnector.connections.quickStart.record]

Optional. Record evaluation settings.

**Default:** all settings at their defaults

### [connectors.kafkaConnector.connections.quickStart.record.consumeFrom]

Optional. Specifies where to start consuming events from: - `LATEST`: start consuming events from the end of the topic partition - `EARLIEST`: start consuming events from the beginning of the topic partition Sets the value of the `auto.offset.reset` key to configure the internal Kafka Consumer.

**Default:** `LATEST`

### [connectors.kafkaConnector.connections.quickStart.record.consumeWithOrderStrategy]

Optional, but effective only if `consumeWithThreadNumber` is set to a value greater than 1 (which includes the default value). The order strategy to be used for concurrent processing of the incoming deserialized records. If set to `ORDER_BY_PARTITION`, maintain the order of records within each partition. If set to `ORDER_BY_KEY`, maintain the order among the records sharing the same key. If set to `UNORDERED`, provide no ordering guarantees.

**Default:** `ORDER_BY_PARTITION`

### [connectors.kafkaConnector.connections.quickStart.record.consumeWithThreadNumber]

Optional. The number of threads to be used for concurrent processing of the incoming deserialized records. If set to `-1`, the number of threads will be automatically determined based on the number of available CPU cores.

**Default:** `1`

### [connectors.kafkaConnector.connections.quickStart.record.extractionErrorStrategy]

Optional. The error handling strategy to be used if an error occurs while extracting data from incoming deserialized records. If set to `IGNORE_AND_CONTINUE`, the error is ignored and the processing of the record continues. If set to `FORCE_UNSUBSCRIPTION`, the processing of the record is stopped and the unsubscription of the items requested by all the Lightstreamer clients subscribed to this connection is forced.

**Default:** `IGNORE_AND_CONTINUE`

### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator]

Optional. Key evaluator configuration.

**Default:** all settings at their defaults

### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator.enableSchemaRegistry]

Enablement of the Confluent Schema Registry for  validation of the key. Must be set to `true` when `keyEvaluator.type` is set to `AVRO` and no local schema are specified.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator.localSchemaFilePathRef]

Mandatory if `type` is set to `AVRO` and `enableSchemaRegistry` is set to `false`. The configmap name and key where the local schema for message validation of the key is stored. The setting takes precedence over `enableSchemaRegistry` if the latter is set to `true`.

**Default:** `nil`

### [connectors.kafkaConnector.connections.quickStart.record.keyEvaluator.type]

Optional. The format to be used to deserialize the key of a Kafka record. Can be one of the following: - AVRO - JSON - STRING - INTEGER - BOOLEAN - BYTE_ARRAY - BYTE_BUFFER - BYTES - DOUBLE - FLOAT - LONG - SHORT - UUID

**Default:** `STRING`

### [connectors.kafkaConnector.connections.quickStart.record.schemaRegistryRef]

Optional. The reference to Schema Registry configuration.

**Default:** `nil`

### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator]

Optional. Value evaluator configuration.

**Default:** all settings at their defaults

### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator.enableSchemaRegistry]

Enablement of the Confluent Schema Registry for validation of the value. Must be set to `true` when `valueEvaluator.type` is set to `AVRO` and no local schema are specified.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator.localSchemaFilePathRef]

Mandatory if `type` is set to `AVRO` and `enableSchemaRegistry` is set to `false`. The configmap name and key where the local schema for message validation of the value is stored. The setting takes precedence over `enableSchemaRegistry` if the latter is set to `true`.

**Default:** `nil`

### [connectors.kafkaConnector.connections.quickStart.record.valueEvaluator.type]

Optional. The format to be used to deserialize the value of a Kafka record. See `record.keyEvaluator.type` for the list of supported formats.

**Default:** `STRING`

### [connectors.kafkaConnector.connections.quickStart.routing]

Mandatory. Record routings configuration.

**Default:**

```
{"enableTopicRegEx":null,"itemTemplates":{"stockTemplate":"stock-#{index=KEY}"},"topicMappings":{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}}
```

### [connectors.kafkaConnector.connections.quickStart.routing.enableTopicRegEx]

Optional. Enable `routing.topicMappings.{}.topic` to be treated as a regular expression rather than of a literal topic name.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.routing.itemTemplates]

Optional. Maps of item template expressions. An expressions is made of: - ITEM_PREFIX: the prefix of the item name - BINDABLE_EXPRESSIONS: a sequence of bindable extraction expressions. See https://lightstreamer.com/api/ls-kafka-connector/latest/ls-kafka-connector/record-extraction.html

**Default:**

```
{"stockTemplate":"stock-#{index=KEY}"}
```

### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings]

Mandatory. Kafka topic mappings.

**Default:**

```
{"stock":{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}}
```

### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock]

At least one must be provided. A Kafka topic mappings. Map a Kafka topic to: - one or more simple items - one or more item templates - any combination of the above  Examples:  topicMappingSample1:   topic: "aTopicName"   items:     - "item1"     - "item2"     - "itemN"  topicMappingSample2:   topic: "anotherTopicName"   itemTemplateRefs:     - "itemTemplate1"     - "itemTemplate2"     - "itemTemplateN"  topicMappingSample3   topic: "yetAnotherTopicName"   items:     - "item1"     - "item2"     - "itemN"   itemTemplateRefs:     - "itemTemplate1"     - "itemTemplate2"     - "itemTemplateN"

**Default:**

```
{"itemTemplateRefs":["stockTemplate"],"items":[],"topic":"stock"}
```

### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock.itemTemplateRefs]

Mandatory if `items` is empty. List of item template to which the topic must be mapped.

**Default:** []

### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock.items]

Mandatory if `itemTemplateRefs` is empty. List of simple items to which the topic must be mapped.

**Default:** []

### [connectors.kafkaConnector.connections.quickStart.routing.topicMappings.stock.topic]

Mandatory and unique across all topic mappings. The Kafka  topic name.

**Default:** `"stock"`

### [connectors.kafkaConnector.connections.quickStart.sslConfig]

Optional. TLS/SSL settings for the connection.

**Default:** all settings at their defaults

### [connectors.kafkaConnector.connections.quickStart.sslConfig.allowedCipherSuites]

Optional. List of enabled secure cipher suites.

**Default:**

```
all the available cipher suites in the running JVM
```

### [connectors.kafkaConnector.connections.quickStart.sslConfig.allowedProtocols]

Optional. List of enabled secure communication protocols TLSv1.2 otherwise.

**Default:**

```
[TLSv1.2, TLSv1.3] when running on Java 11 or newer,
```

### [connectors.kafkaConnector.connections.quickStart.sslConfig.enableHostnameVerification]

Optional. Enablement of the hostname verification.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.sslConfig.enabled]

Optional. Enablement of the encryption.

**Default:** false

### [connectors.kafkaConnector.connections.quickStart.sslConfig.protocol]

Optional. The SSL protocol to be used. Can be one of  the following: `TLSv1.2`,  `TLSv1.3`. otherwise

**Default:**

```
TLSv1.3 when running on Java 11 or newer, TLSv1.2
```

### [connectors.kafkaConnector.connections.quickStart.sslConfig.trustStoreRef]

Optional. The reference to a keystore used to validate the  certificates provided by the Kafka brokers. See the `keyStores.myKafkaConnectorKeystore` settings for general details on keystore configuration for the Kafka Connector.

**Default:** `nil`

### [connectors.kafkaConnector.enabled]

Optional. Enablement of the Lightstreamer Kafka Connector.

**Default:** false

### [connectors.kafkaConnector.localSchemaFiles]

Optional. Local schema files used for message validation.

**Default:**

```
{"myKeySchema":null,"myValueSchema":null}
```

### [connectors.kafkaConnector.localSchemaFiles.myKeySchema]

Optional. The configmap name and key where the local schema file is stored

**Default:** `nil`

### [connectors.kafkaConnector.logging]

Mandatory. Kafka Connector global Logging configuration.

**Default:**

```
{"appenders":{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}},"loggers":{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}}
```

### [connectors.kafkaConnector.logging.appenders]

Mandatory. Appenders configuration. Every logger must refer to one or more appenders defined here.

**Default:**

```
{"stdout":{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}}
```

### [connectors.kafkaConnector.logging.appenders.stdout]

At least one must be provided. An appender configuration.

**Default:**

```
{"pattern":"[%d] [%-10c{1}] %-5p %m%n","type":"Console"}
```

### [connectors.kafkaConnector.logging.appenders.stdout.pattern]

Mandatory. The appender layout.

**Default:** `"[%d] [%-10c{1}] %-5p %m%n"`

### [connectors.kafkaConnector.logging.appenders.stdout.type]

Mandatory. The appender type. Currently, on the `Console` type is supported.

**Default:** `"Console"`

### [connectors.kafkaConnector.logging.loggers]

Optional. Global loggers configuration.

**Default:**

```
{"com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter":{"appenders":["stdout"],"level":"INFO"},"org.apache.kafka":{"appenders":["stdout"],"level":"WARN"}}
```

### [connectors.kafkaConnector.logging.loggers."com.lightstreamer.kafka.adapters.pub.KafkaConnectorMetadataAdapter"]

Logger for the Kafka Connector Metadata Adapter. Replace the name with the one of the custom Metadata Adapter class.

**Default:**

```
{"appenders":["stdout"],"level":"INFO"}
```

### [connectors.kafkaConnector.logging.loggers."org.apache.kafka"]

The logger name

**Default:**

```
{"appenders":["stdout"],"level":"WARN"}
```

### [connectors.kafkaConnector.logging.loggers."org.apache.kafka".appenders]

Mandatory. List of references to the appenders to be used by   the logger.

**Default:** `["stdout"]`

### [connectors.kafkaConnector.logging.loggers."org.apache.kafka".level]

Mandatory. The logger level.

**Default:** `"WARN"`

### [connectors.kafkaConnector.schemaRegistry]

Mandatory if `connections.{}.keyEvaluator.type` is set to `AVRO` and no local schema paths are specified. Schema Registry configuration.

**Default:**

```
{"mySchemaRegistry":{"basicAuthentication":{"credentialsSecretRef":null,"enabled":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null},"url":"https://schema-registry:8084"}}
```

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.basicAuthentication]

Optional. Basic HTTP authentication of a connection against the Schema Registry.

**Default:**

```
{"credentialsSecretRef":null,"enabled":null}
```

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.basicAuthentication.credentialsSecretRef]

Mandatory if `enable` is set to `true`. The name of the secret containing the credentials. The secret must contain the keys `user` and `password`.

**Default:** ""

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.basicAuthentication.enabled]

Optional. Enablement of the Basic HTTP authentication.

**Default:** false

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig]

Mandatory if the https protocol is specified in `url`. TLS/SSL  settings.

**Default:**

```
{"allowCipherSuites":[],"allowProtocols":[],"enableHostnameVerification":null,"keyStoreRef":null,"trustStoreRef":null}
```

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.allowCipherSuites]

Optional. List of enabled secure cipher suites.

**Default:**

```
all the available cipher suites in the running JVM
```

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.allowProtocols]

Optional. List of enabled secure communication protocols TLSv1.2 otherwise.

**Default:**

```
[TLSv1.2, TLSv1.3] when running on Java 11 or newer,
```

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.enableHostnameVerification]

Optional. Enablement of the hostname verification.

**Default:** false

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.keyStoreRef]

Optional. The reference to a keystore used if mutual TLS is enabled on the Schema Registry. See the `keyStores.myKafkaConnectorKeystore` settings for general details on keystore configuration for the Kafka Connector.

**Default:** `nil`

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.sslConfig.trustStoreRef]

Optional. The reference to a keystore used to validate the  certificates provided by the Schema Registry. See the `keyStores.myKafkaConnectorKeystore` settings for general details on keystore configuration for the Kafka Connector.

**Default:** `nil`

### [connectors.kafkaConnector.schemaRegistry.mySchemaRegistry.url]

Mandatory. The URL of the Confluent Schema Registry. An encrypted  connection is enabled by specifying the "https" protocol.

**Default:**

```
"https://schema-registry:8084"
```

### [connectors.kafkaConnector.version]

Optional. The Lightstreamer Kafka Connector version to install.

**Default:** `"1.2.0"`

### [deployment]

Mandatory. Lightstreamer Deployment configuration.

**Default:**

```
{"additionalSelectors":{},"affinity":{},"annotations":[],"dnsPolicy":null,"extraEnv":[],"extraVolumeMounts":[],"extraVolumes":[],"hostNetwork":null,"hostname":null,"initContainers":{},"labels":{},"lifecycle":null,"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{},"priorityClassName":null,"probes":{"liveness":{"default":null,"healthCheck":{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","terminationGracePeriodSeconds":null,"timeoutSeconds":null}},"readiness":{"default":null,"healthCheck":{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","timeoutSeconds":null}},"startup":{"default":null,"healthCheck":{"enabled":true,"failureThreshold":6,"initialDelaySeconds":2,"periodSeconds":4,"serverRef":"http-server","terminationGracePeriodSeconds":10,"timeoutSeconds":8}}},"replicas":null,"resources":{},"securityContext":{},"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":1},"type":"RollingUpdate"},"terminationGracePeriodSeconds":5,"tolerations":[],"topologySpreadConstraints":{}}
```

### [deployment.additionalSelectors]

Additional selectors

**Default:** `{}`

### [deployment.affinity]

Affinity settings for the Pod (https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity)

**Default:** `{}`

### [deployment.annotations]

Additional Deployment annotations

**Default:** `[]`

### [deployment.dnsPolicy]

The DNS policy for the Pods (https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy)

**Default:** `nil`

### [deployment.extraEnv]

Additional environment variables

**Default:** `[]`

### [deployment.extraVolumeMounts]

Additional volume mounts

**Default:** `[]`

### [deployment.extraVolumes]

Additional volumes

**Default:** `[]`

### [deployment.hostNetwork]

Host networking setting for the Pods

**Default:** `nil`

### [deployment.hostname]

The hostname for the Pods (https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-hostname-and-subdomain-fields)

**Default:** `nil`

### [deployment.initContainers]

Init containers configuration (https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)

**Default:** `{}`

### [deployment.labels]

Additional Deployment labels

**Default:** `{}`

### [deployment.lifecycle]

Pod lifecyle configuration (https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

**Default:** `nil`

### [deployment.nodeSelector]

Node selector setting for the Pod (https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)

**Default:** `{}`

### [deployment.podAnnotations]

The Pod annotations (https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)

**Default:** `{}`

### [deployment.podLabels]

Additional Pod labels (https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

**Default:** `{}`

### [deployment.podSecurityContext]

The security context for the Pods (https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod)

**Default:** `{}`

### [deployment.priorityClassName]

The name of the PriorityClass for Pods

**Default:** `nil`

### [deployment.probes]

Probes configuration

**Default:**

```
{"liveness":{"default":null,"healthCheck":{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","terminationGracePeriodSeconds":null,"timeoutSeconds":null}},"readiness":{"default":null,"healthCheck":{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","timeoutSeconds":null}},"startup":{"default":null,"healthCheck":{"enabled":true,"failureThreshold":6,"initialDelaySeconds":2,"periodSeconds":4,"serverRef":"http-server","terminationGracePeriodSeconds":10,"timeoutSeconds":8}}}
```

### [deployment.probes.liveness]

Liveness probe configuration

**Default:**

```
{"default":null,"healthCheck":{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","terminationGracePeriodSeconds":null,"timeoutSeconds":null}}
```

### [deployment.probes.liveness.default]

Liveness probe configuration to be used if `probes.liveness.healthCheck.enabled` is set to false. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

**Default:** `nil`

### [deployment.probes.liveness.healthCheck]

Optional. Liveness probe based on the default Lightstreamer healthcheck.

**Default:**

```
{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","terminationGracePeriodSeconds":null,"timeoutSeconds":null}
```

### [deployment.probes.liveness.healthCheck.enabled]

Enablement of the liveness probe

**Default:** `true`

### [deployment.probes.liveness.healthCheck.serverRef]

Mandatory if `enabled` is set to `true`. The reference to a server socket configuration (see `servers` section below)

**Default:** `"http-server"`

### [deployment.probes.readiness]

Readiness probe configuration

**Default:**

```
{"default":null,"healthCheck":{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","timeoutSeconds":null}}
```

### [deployment.probes.readiness.default]

Readiness probe configuration to be used if `probes.readiness.healthCheck.enabled` is set to false. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

**Default:** `nil`

### [deployment.probes.readiness.healthCheck]

Readiness probe configuration based on the default Lightstreamer healthcheck

**Default:**

```
{"enabled":true,"failureThreshold":null,"initialDelaySeconds":null,"periodSeconds":null,"serverRef":"http-server","timeoutSeconds":null}
```

### [deployment.probes.readiness.healthCheck.enabled]

Enablement of the readiness probe

**Default:** `true`

### [deployment.probes.readiness.healthCheck.serverRef]

Mandatory if `enabled` is set to `true`. The reference to a server socket configuration (see `servers` section below)

**Default:** `"http-server"`

### [deployment.probes.startup]

Startup probe configuration

**Default:**

```
{"default":null,"healthCheck":{"enabled":true,"failureThreshold":6,"initialDelaySeconds":2,"periodSeconds":4,"serverRef":"http-server","terminationGracePeriodSeconds":10,"timeoutSeconds":8}}
```

### [deployment.probes.startup.default]

Startup probe configuration to be used if `probes.startup.healthCheck.enabled` is set to false. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

**Default:** `nil`

### [deployment.probes.startup.healthCheck]

Startup probe configuration based on the default Lightstreamer healthcheck

**Default:**

```
{"enabled":true,"failureThreshold":6,"initialDelaySeconds":2,"periodSeconds":4,"serverRef":"http-server","terminationGracePeriodSeconds":10,"timeoutSeconds":8}
```

### [deployment.probes.startup.healthCheck.enabled]

Enablement of the startup probe

**Default:** `true`

### [deployment.probes.startup.healthCheck.serverRef]

Mandatory if `enabled` is set to `true`. The reference to a server socket configuration (see `servers` section below)

**Default:** `"http-server"`

### [deployment.replicas]

Number of replicas (https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

**Default:** 1

### [deployment.resources]

Resource management for Pod and the container (https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

**Default:** `{}`

### [deployment.securityContext]

The security context for the container (https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container)

**Default:** `{}`

### [deployment.strategy]

The strategy used to replace old Pods by new one (see https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy)

**Default:**

```
{"rollingUpdate":{"maxSurge":1,"maxUnavailable":1},"type":"RollingUpdate"}
```

### [deployment.terminationGracePeriodSeconds]

Termination grace period configuration for Pod (https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution)

**Default:** `5`

### [deployment.tolerations]

Tolerations settings for the Pod (https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

**Default:** `[]`

### [deployment.topologySpreadConstraints]

Topology spread constraints configuration for the Pod (https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/)

**Default:** `{}`

### [errorPageRef]

Optional. The configmap name and the key where an HTML page to be returned upon unexpected request URLs is stored. This applies to URLs in reserved ranges that have no meaning. If the Internal web server is not enabled, this also applies to all non-reserved URLs; otherwise, nonexisting non-reserved URLs will get the HTTP 404 error as usual. The file content should be encoded with the iso-8859-1 charset. The file path is relative to the conf directory.

**Default:**

```
the proper page is provided by the Server
```

### [fullnameOverride]

Replace the chart's default resource naming convention

**Default:** `""`

### [globalSocket]

Mandatory. Global socket configuration

**Default:**

```
{"handshakeTimeoutMillis":null,"readTimeoutMillis":20000,"requestLimit":50000,"useHttpVersion":null,"webSocket":{"enabled":null,"maxClosingWaitMillis":null,"maxOutboundFrameSize":0,"maxPongDelayMillis":null},"writeTimeoutMillis":120000}
```

### [globalSocket.handshakeTimeoutMillis]

Optional. Longest inactivity time accepted while waiting for a slow operation during a TLS/SSL handshake. This involves both reads, writes, and encryption tasks managed by the "TLS-SSL HANDSHAKE" or "TLS-SSL AUTHENTICATION" internal pools. If this value is exceeded, the socket is closed. The time actually considered may be approximated and may be a few seconds higher, for internal performance reasons. A 0 value suppresses the check.

**Default:** 4000

### [globalSocket.readTimeoutMillis]

(Mandatory) Longest inactivity time accepted while waiting for a slow request to be received. If this value is exceeded, the socket is closed. Reusable HTTP connections are also closed if they are not reused for longer than this time. The time actually considered may be approximated and may be a few seconds higher, for internal performance reasons. A 0 value suppresses the check.

**Default:** `20000`

### [globalSocket.requestLimit]

Optional. Maximum length in bytes accepted for a request. For an HTTP GET request, the limit applies to the whole request, including the headers. For an HTTP POST request, the limit applies to the header part and the body part separately. For a request over a WebSocket, the limit applies to the request message payload.

**Default:** unlimited length

### [globalSocket.useHttpVersion]

Optional. Enabling the use of the full HTTP 1.1 syntax for all the responses, upon HTTP 1.1 requests. If set to `1.1`, HTTP 1.1 is always used, when possible. If set to `1.0`, HTTP 1.0 is always used; this is possible for all HTTP requests, but it will prevent WebSocket support. If set to `AUTO`, HTTP 1.0 is used, unless HTTP 1.1 is required in order to support specific response features.

**Default:** "1.1"

### [globalSocket.webSocket]

Optional. WebSocket support configuration

**Default:**

```
{"enabled":null,"maxClosingWaitMillis":null,"maxOutboundFrameSize":0,"maxPongDelayMillis":null}
```

### [globalSocket.webSocket.enabled]

Optional. Enabling of the WebSocket support. If set to `true`, the Server accepts requests for initiating a WebSocket interaction through a custom protocol. If set to `false`, the Server refuses requests for WebSocket interaction. Disabling WebSocket support may be needed when the local network infrastructure (for instance the Load Balancer) does not handle WebSocket communication correctly and the WebSocket transport is not already disabled on the client side through the Lightstreamer Client Library in use. The Client Library, upon the Server refusal, will resort to HTTP streaming without any additional delay to session establishment.

**Default:** true

### [globalSocket.webSocket.maxClosingWaitMillis]

Optional. Maximum time the Server is allowed to wait for the client "close" frame, in case the Server is sending its own close" frame first, in order to try to close the connection in a clean way.

**Default:**

```
no timeout is set and the global global.readTimeoutMillis applies
```

### [globalSocket.webSocket.maxOutboundFrameSize]

Optional.  Maximum payload size allowed for an outbound frame. When larger updates have to be sent, the related WebSocket messages will be split into multiple frames. A lower limit for the setting may be enforced by the Server.

**Default:** 16384

### [globalSocket.webSocket.maxPongDelayMillis]

Optional. Maximum time the Server is allowed to wait before answering to a client "ping" request. In case a client sends very frequent "ping" requests, only the "pong" associated to the most recent request received is sent, while the previous requests will be ignored. Note that the above is possible also when 0 is specified.

**Default:** 0

### [globalSocket.writeTimeoutMillis]

Optional. Longest operation time accepted while writing data on a socket. If this value is exceeded, the socket is closed. Note that this may also affect very slow clients. The time actually considered may be approximated and may be a few seconds higher, for internal performance reasons. If missing or 0, the check is suppressed.

**Default:** the check is suppressed

### [image]

Lightstreamer Docker Image settings

**Default:**

```
{"pullPolicy":"IfNotPresent","repository":"lightstreamer","tag":"latest"}
```

### [image.pullPolicy]

The pull policy for the images

**Default:** `"IfNotPresent"`

### [image.repository]

Remote registry from which to pull the Lightstreamer Docker image

**Default:** `"lightstreamer"`

### [image.tag]

The tag of the image to pull

**Default:** .Chart.appVersion

### [imagePullSecrets]

**Default:** `[]`

### [ingress]

Lightstreamer Ingress configuration (https://kubernetes.io/docs/concepts/services-networking/ingress/)

**Default:**

```
{"annotations":{},"className":null,"enabled":true,"hosts":null,"labels":{},"tls":[]}
```

### [ingress.annotations]

Additional Ingress annotations

**Default:** `{}`

### [ingress.className]

The name of Ingress class

**Default:** `nil`

### [ingress.enabled]

Enablement of the Ingress

**Default:** `true`

### [ingress.hosts]

List of Ingress rules. if not set, the ingress will be backed by the service.

**Default:** `nil`

### [ingress.labels]

Additional Ingress labels

**Default:** `{}`

### [ingress.tls]

TLS configuration for the Ingress (https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)

**Default:** `[]`

### [keyStores]

Keystores definition.

**Default:**

```
{"myKafkaConnectorKeystore":null,"myServerKeystore":{"keystoreFileSecretRef":{"key":"myserver.keystore","name":"myserver-keystore-secret"},"keystorePasswordSecretRef":{"key":"myserver.keypass","name":"myserver-keypass-secret"}}}
```

### [keyStores.myKafkaConnectorKeystore]

Example of Keystore definition used by Kafka connector configurations.

**Default:** `nil`

### [keyStores.myServerKeystore]

Keystore definition used by HTTPS server socket configurations. The default values used here reference the JKS keystore file "myserver.keystore", which is provided out of the box (and stored in the `myserver-keystore-secret` secret, along with the password stored in the `myserver-keypass-secret` secret), and obviously contains an invalid certificate. In order to use it for your experiments, remember to add a security exception to your browser.

**Default:**

```
{"keystoreFileSecretRef":{"key":"myserver.keystore","name":"myserver-keystore-secret"},"keystorePasswordSecretRef":{"key":"myserver.keypass","name":"myserver-keypass-secret"}}
```

### [keyStores.myServerKeystore.keystoreFileSecretRef]

Mandatory if type is set to `JKS` or `PKCS12`. Secret name and key where the keystore file is stored.

**Default:**

```
{"key":"myserver.keystore","name":"myserver-keystore-secret"}
```

### [keyStores.myServerKeystore.keystorePasswordSecretRef]

Mandatory if type is set to `JKS` or `PKCS12`. Secret name and key where keystore password is stored.

**Default:**

```
{"key":"myserver.keypass","name":"myserver-keypass-secret"}
```

### [license]

Configure the edition, the optional features, and the type of license that should be used to run Lightstreamer Server.

**Default:**

```
{"edition":"ENTERPRISE","enableAutomaticUpdateCheck":true,"enabledCommunityEditionClientApi":"javascript_client","enterprise":{"contractId":"DEMO","enableAutomaticAuditLogUpload":false,"enableRestrictedFeaturesSet":false,"filePathSecretRef":{"key":null,"name":null},"licenseType":"DEMO","licenseValidation":null,"onlinePasswordSecretRef":null,"optionalFeatures":{"enableAndroidClient":false,"enableBandwidthControl":false,"enableBlackBerryClient":false,"enableDotNETStandardClient":false,"enableFlashClient":false,"enableFlexClient":false,"enableGenericClient":false,"enableIOSClient":false,"enableJavaMEClient":false,"enableJavaSEClient":false,"enableJavascriptClient":false,"enableJmx":false,"enableMacOSClient":false,"enableMpn":false,"enableNodeJsClient":false,"enablePythonClient":false,"enableSilverlightClient":false,"enableTlsSsl":true,"enableTvOSClient":false,"enableWatchOSClient":false,"maxDownstreamRate":2}}}
```

### [license.edition]

Lightstreamer edition to use. To know full details, open the Welcome Page or the Monitoring Dashboard (Edition tab) of your running Lightstreamer Server. Can be one of the following:  - COMMUNITY  - ENTERPRISE

**Default:** `"ENTERPRISE"`

### [license.enabledCommunityEditionClientApi]

If you chose COMMUNITY edition, you can set the following options:

**Default:** `"javascript_client"`

### [license.enterprise]

Configure the ENTERPRISE edition

**Default:**

```
{"contractId":"DEMO","enableAutomaticAuditLogUpload":false,"enableRestrictedFeaturesSet":false,"filePathSecretRef":{"key":null,"name":null},"licenseType":"DEMO","licenseValidation":null,"onlinePasswordSecretRef":null,"optionalFeatures":{"enableAndroidClient":false,"enableBandwidthControl":false,"enableBlackBerryClient":false,"enableDotNETStandardClient":false,"enableFlashClient":false,"enableFlexClient":false,"enableGenericClient":false,"enableIOSClient":false,"enableJavaMEClient":false,"enableJavaSEClient":false,"enableJavascriptClient":false,"enableJmx":false,"enableMacOSClient":false,"enableMpn":false,"enableNodeJsClient":false,"enablePythonClient":false,"enableSilverlightClient":false,"enableTlsSsl":true,"enableTvOSClient":false,"enableWatchOSClient":false,"maxDownstreamRate":2}}
```

### [license.enterprise.contractId]

Identifier of the contract in place. Use "DEMO" to run with the embedded Demo license. contractId: EXXXXXXXXX

**Default:** `"DEMO"`

### [license.enterprise.enableAutomaticAuditLogUpload]

In case of file-based license validation, this element allows to activate periodic automatic upload. This makes it much easier for the systems admins to deliver the logs, as contractually agreed. In case of online license validation, the audit logs are always automatically uploaded to the Online License Manager, irrespective of this element. If enabled, the th following host name must be reachable on port 443:      - https://service.lightstreamer.com/ If not enabled, audit logs myst be delivered manually if required by license terms.

**Default:** `false`

### [license.enterprise.enableRestrictedFeaturesSet]

Restrict the feature set with respect to the license in use. If enabled, use the feature set detailed in the "optional_features" key. If a required feature is not allowed by the license in use, the server will not start. If not enabled, use the feature set specified by the license in use.

**Default:** `false`

### [license.enterprise.filePathSecretRef]

Used only if `licenseValidation` set to "FILE". Secret name and key where the license file is stored.

**Default:** `{"key":null,"name":null}`

### [license.enterprise.licenseType]

The type of the ENTERPRISE edition.  Can be one of the following:  - DEMO  - EVALUATION  - STARTUP  - NON-PRODUCTION-LIMITED  - NON-PRODUCTION-FULL  - PRODUCTION  - HOT-STANDBY licenseType: EVALUATION

**Default:** `"DEMO"`

### [license.enterprise.licenseValidation]

Choose between online (cloud-based) and file-based license validation. Can be one of the following: - ONLINE   The host names below must be reachable on port 443:   - https://clm1.lightstreamer.com/   - https://clm2.lightstreamer.com/ - FILE   Based on `licenseType`, one or both the values are possible.   For EVALUATION and STARTUP: ONLINE is mandatory.   For PRODUCTION, HOT-STANDBY, NON-PRODUCTION-FULL, and NON-PRODUCTION-LIMITED:   you can choose between ONLINE and FILE.   For DEMO: the value is ignored, as no validation is done.

**Default:** `nil`

### [license.enterprise.onlinePasswordSecretRef]

Used only if `licenseValidation` set to "ONLINE". Secret name and key where the password used for validation of online licenses is stored. Leave blank if `licenseType` is set to "DEMO" or `licenseValidation` set to "FILE".

**Default:** `nil`

### [load]

Optional. Load configuration

**Default:**

```
{"acceptPoolMaxQueue":null,"acceptPoolMaxSize":null,"eventsPoolSize":null,"forceEarlyConversions":null,"handshakePoolMaxQueue":null,"handshakePoolSize":null,"httpsAuthPoolMaxFree":null,"httpsAuthPoolMaxQueue":null,"httpsAuthPoolMaxSize":null,"maxCommonNioBufferAllocation":null,"maxCommonPumpBufferAllocation":null,"maxMpnDevices":null,"maxSessions":null,"prestartedMaxQueue":null,"pumpPoolMaxQueue":null,"pumpPoolSize":null,"selectorMaxLoad":null,"selectorPoolSize":null,"serverPoolMaxFree":null,"serverPoolMaxQueue":null,"serverPoolMaxSize":null,"snapshotPoolSize":null,"timerPoolSize":null}
```

### [load.acceptPoolMaxSize]

Optional. Maximum number of threads allowed for the "ACCEPT" internal pool, which is devoted to the parsing of the client requests. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial. Only in corner cases, it is possible that some operations turn out to be blocking; in particular: - getHostName, only if banned hostnames are configured; - socket close, only if banned hostnames are configured; - read from the "proxy protocol", only if configured; - service of requests on a "priority port", only available for internal use. A zero value means a potentially unlimited number of threads. which is also the minimum number of threads left in the pool

**Default:**

```
the number of available total cores, as detected by the JVM,
```

### [load.eventsPoolSize]

Optional. Size of the "EVENTS" internal thread pool, which is devoted to dispatching the update events received from a Data Adapter to the proper client sessions, according with each session subscriptions. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:**

```
the number of available total cores, as detected by the JVM
```

### [load.forceEarlyConversions]

Optional. Policy to be adopted in order to manage the extraction of the field values from the item events and their conversion to If set to `true`, causes field conversion to be performed before the events are dispatched to the various sessions; this may lead to some wasted conversions, in case an event is filtered out later by all interested clients or in case a field is not subscribed to by any client. Note that events which don't provide an iterator (see the Data Adapter interface documentation) cannot be managed in this way. If set to `false`, causes field conversion to be performed only as soon as it is needed; in this case, as the same event object may be shared by many sessions, some synchronization logic is needed and this may lead to poor scaling in case many clients subscribe to the same item.

**Default:** true

### [load.handshakePoolMaxQueue]

Optional. Maximum number of tasks allowed to be queued to enter the "TLS-SSL HANDSHAKE" thread pool before undertaking backpressure actions. The setting only regards the listening sockets specified through the `servers.{}` configurations (with `enableHttps` set to `true`) that are not configured to request the client certificate. More precisely: - If there are https sockets with `servers.{}.portType` configured as    CREATE_ONLY, then, as long as the number is exceeded, the accept loops of   these sockets will be kept waiting.   By suspending the accept loop, some SYN packets from the clients may be   discarded; the effect may vary depending on the backlog settings. - Otherwise, if there are https sockets configured as CONTROL_ONLY and none   is configured as the default GENERAL_PURPOSE, then, as long as the number   is exceeded, the accept loops of these sockets will be kept waiting   instead.   Additionally, the same action on the accept loops associated to the   `load.acceptPoolMaxQueue` check will be performed (regardless that   `load.acceptPoolMaxQueue` itself is set). Note that the latter action may    affect both http and https sockets. Note that, in the absence of sockets configured as specified above, no backpressure action will take place. A negative value disables the check.

**Default:** 100

### [load.handshakePoolSize]

Optional. Size of the "TLS-SSL HANDSHAKE" internal pool, which is devoted to the management of operations needed to accomplish TLS/SSL handshakes on the listening sockets specified through  the `servers.{}` configuration with `enableHttps` set to `true`. In particular, this pool is only used when the socket is not configured to request the client certificate (see servers.{}.sslConfig.enableClientAuth`  and `servers.{}.security.enableMandatoryClientAuth`); in this case, the  tasks are not expected to be blocking. Note that the operation may be CPU-intensive; hence, it is advisable to set a value smaller than the number of available cores. (obviously, if there is only one core, the default will be 1)

**Default:**

```
half the number of available total cores, as detected by the JVM
```

### [load.httpsAuthPoolMaxFree]

Optional. Maximum number of idle threads allowed for the "TLS-SSL AUTHENTICATION" internal pool. It behaves in the same way as the `load.serverPoolMaxFree` setting.

**Default:**

```
the same as configured for the SERVER thread pool
```

### [load.httpsAuthPoolMaxQueue]

Optional. Maximum number of tasks allowed to be queued to enter the "TLS-SSL AUTHENTICATION" thread pool before undertaking backpressure actions. The effect is similar to the more common `load.handShakePoolMaxQueue`, with the difference that it regards listening sockets specified through `server.httpsServer` that are configured to request the client certificate (see `useClientAuth` and `forceClientAuth`). A negative value disables the check.

**Default:** 100

### [load.httpsAuthPoolMaxSize]

Optional. Size of the "TLS-SSL AUTHENTICATION" internal pool, which is used instead of the "TLS-SSL HANDSHAKE" pool for listening sockets that are configured to request the client certificate. This kind of task may exhibit a blocking behavior in some cases.

**Default:**

```
the same as configured for the SERVER thread pool
```

### [load.maxCommonNioBufferAllocation]

Optional. Limit to the overall size, in bytes, of the buffers devoted to I/O operations that can be kept allocated for reuse. If 0, removes any limit to the allocation (which should remain limited, based on the maximum concurrent buffer needs). If -1, disables buffer reuse at all and causes all allocated buffers to be released immediately.

**Default:** 200000000

### [load.maxCommonPumpBufferAllocation]

Optional. Number of distinct NIO selectors (each one with its own thread) that will share the same operation. Different pools will be prepared for different I/O operations and server sockets, which may give rise to a significant overall number of selectors. Further selectors may be created because of the `load.selectorMaxLoad` setting.

**Default:**

```
the number of available total cores, as detected by the JVM
```

### [load.maxMpnDevices]

Optional. Maximum number of concurrent MPN devices sessions allowed. Once this number of devices has been reached, requests to active mobile push notifications will be refused. The limit can be set as a simple, heuristic protection from Server overload from MPN subscriptions.

**Default:**

```
unlimited number of concurrent MPN devices sessions
```

### [load.maxSessions]

Optional. Maximum number of concurrent client sessions allowed. Requests for new sessions received when this limit is currently exceeded will be refused; on the other hand, operation on sessions already established is not limited in any way. Note that closing and reopening a session on a client when this limit is currently met may cause the new session request to be refused. The limit can be set as a simple, heuristic protection from Server overload.

**Default:**

```
unlimited number of concurrent client sessions
```

### [load.prestartedMaxQueue]

Optional. Maximum number of sessions that can be left in "prestarted" state, that is, waiting for the first bind or control operation, before undertaking backpressure actions. In particular, the same restrictive actions associated to the `load.serverPoolMaxQueue` check will be performed (regardless that `load.serverPoolMaxQueue` itself is set). The setting is meant to be used in configurations which define a CREATE_ONLY port in http and a CONTROL_ONLY port in https. In these cases, and when a massive client reconnection is occurring, the number of pending bind operations can grow so much that the needed TLS handshakes can take arbitrarily long and cause the clients to time-out and restart session establishment from scratch. However, consider that the presence of many clients that don't perform their bind in due time could keep other clients blocked. Note that, if defined, the setting will also inhibit `load.handshakePoolMaxQueue` and `load.httpsAuthPoolMaxQueue` from affecting the accept loop of CONTROL_ONLY ports in https. A negative value disables the check.

**Default:** -1

### [load.pumpPoolMaxQueue]

Optional. Maximum number of tasks allowed to be queued to enter the "PUMP" thread pool before undertaking backpressure actions. In particular, the same restrictive actions associated to the `load.serverPoolMaxQueue` check will be performed (regardless that `load.serverPoolMaxQueue` itself is set). A steadily long queue on the PUMP pool may be the consequence of a CPU shortage due to a huge streaming activity. A negative value disables the check.

**Default:** -1

### [load.pumpPoolSize]

Optional. Size of the "PUMP" internal thread pool, which is devoted to integrating the update events pertaining to each session and to creating the update commands for the client, whenever needed. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:**

```
the number of available total cores, as detected by the JVM
```

### [load.selectorMaxLoad]

Optional. Maximum number of keys allowed for a single NIO selector. If more keys have to be processed, new temporary selectors will be created. If the value is 0, then no limitations are applied and extra selectors will never be created. The base number of selectors is determined by the `load.selectorPoolSize` setting.

**Default:** 0

### [load.selectorPoolSize]

Optional. Number of distinct NIO selectors (each one with its own thread) that will share the same operation. Different pools will be prepared for different I/O operations and server sockets, which may give rise to a significant overall number of selectors. Further selectors may be created because of the `load.selectorMaxLoad` setting.

**Default:**

```
the number of available total cores, as detected by the JVM
```

### [load.serverPoolMaxFree]

Optional, but mandatory if `load.serverPoolMaxSize`is set to 0. Maximum number of idle threads allowed for the "SERVER" internal pool, which is devoted to the management of the client requests. Put in a different way, it is the minimum number of threads that can be present in the pool. To accomplish this setting, at pool initialization, suitable idle threads are created; then, each time a thread becomes idle, it is discarded only if enough threads are already in the pool. It must not be greater than `load.serverPoolMaxSize` (unless the latter is set to 0, i.e. unlimited); however, it may be lower, in case `load.serverPoolMaxSize` is kept high in order to face request bursts; a zero value means no idle threads allowed in the pool, though this is not recommended for performance reasons. same as `load.serverPoolMaxSize`, unless the latter is set to 0, i.e. unlimited, in which case this setting is mandatory

**Default:**

```
10, if load.serverPoolMaxSize is not defined; otherwise, the
```

### [load.serverPoolMaxQueue]

Optional. Maximum number of tasks allowed to be queued to enter the "SERVER" thread pool before undertaking backpressure actions. In particular, as long as the number is exceeded, the creation of new sessions will be refused and made to fail; additionally, the same r restrictive action on the accept loops associated to the `load.acceptPoolMaxQueue` check will be performed (regardless that `load.acceptPoolMaxQueue` itself is set). On the other hand, if the MPN DEVICE HANDLER pool is defined in the `mpn` block, it also overrides the SERVER or dedicated pools, but its queue is not included in the check. A negative value disables the check.

**Default:** 100

### [load.serverPoolMaxSize]

Optional. Maximum number of threads allowed for the "SERVER" internal pool, which is devoted to the management of the client requests. This kind of tasks includes operations that are potentially blocking: - getHostName; - socket close; - calls to a Metadata Adapter that may need to access to some external   resource (i.e. mainly notifyUser, getItems, getSchema; other methods   should be implemented as nonblocking, by leaning on data cached by   notifyUser); - calls to a Data Adapter that may need to access to some external resource   (i.e. subscribe and unsubscribe, though it should always be possible to   implement such calls asynchronously); - file access by the internal web server, though it should be used  only in   demo and test scenarios. Note that specific thread pools can optionally be defined in order to handle some of the tasks that, by default, are handled by the SERVER thread pool. They are defined in "adapters.xml"; see the templates provided in the In-Process Adapter SDK for details. A zero value means a potentially unlimited number of threads.

**Default:** 1000

### [load.snapshotPoolSize]

Optional. Size of the "SNAPSHOT" internal thread pool, which is devoted to dispatching the snapshot events upon new subscriptions from client sessions. This task does not include blocking operations; however, on multiprocessor machines, allocating multiple threads for this task may be beneficial. 10, if the number of cores is less

**Default:**

```
the number of available total cores, as detected by the JVM, or
```

### [load.timerPoolSize]

Optional. Number of threads used to parallelize the implementation of the internal timers. This task does not include blocking operations, but its computation may be heavy under high update activity; hence, on multiprocessor machines, allocating multiple threads for this task may be beneficial.

**Default:** 1

### [logging.appenders.console.pattern]

**Default:**

```
"%d{\"dd.MMM.yy HH:mm:ss,SSS\"} <%5.5(%p%marker)> %m%n"
```

### [logging.appenders.console.type]

**Default:** `"Console"`

### [logging.appenders.dailyRolling.pattern]

**Default:**

```
"%d{\"dd-MMM-yy HH:mm:ss,SSS\"}|%-5.5(%p%marker)|%-19.19c{19}|%-27.27t|%m%n"
```

### [logging.appenders.dailyRolling.type]

**Default:** `"DailyRollingFile"`

### [logging.loggers."com.github.markusbernhardt.proxy".appenders[0]]

**Default:** `"console"`

### [logging.loggers."com.github.markusbernhardt.proxy".level]

**Default:** `"WARN"`

### [logging.loggers."com.google".appenders[0]]

**Default:** `"console"`

### [logging.loggers."com.google".level]

**Default:** `"ERROR"`

### [logging.loggers."com.sun.jmx.remote".appenders[0]]

**Default:** `"console"`

### [logging.loggers."com.sun.jmx.remote".level]

**Default:** `"ERROR"`

### [logging.loggers."com.turo".appenders[0]]

**Default:** `"console"`

### [logging.loggers."com.turo".level]

**Default:** `"ERROR"`

### [logging.loggers."com.zaxxer.hikari".appenders[0]]

**Default:** `"console"`

### [logging.loggers."com.zaxxer.hikari".level]

**Default:** `"INFO"`

### [logging.loggers."common.jmx.velocity".appenders[0]]

**Default:** `"console"`

### [logging.loggers."common.jmx.velocity".level]

**Default:** `"ERROR"`

### [logging.loggers."io.grpc".appenders[0]]

**Default:** `"console"`

### [logging.loggers."io.grpc".level]

**Default:** `"WARN"`

### [logging.loggers."io.netty".appenders[0]]

**Default:** `"console"`

### [logging.loggers."io.netty".level]

**Default:** `"ERROR"`

### [logging.loggers."io.opencensus".appenders[0]]

**Default:** `"console"`

### [logging.loggers."io.opencensus".level]

**Default:** `"WARN"`

### [logging.loggers."java.sql".appenders[0]]

**Default:** `"console"`

### [logging.loggers."java.sql".level]

**Default:** `"WARN"`

### [logging.loggers."javax.management.mbeanserver".appenders[0]]

**Default:** `"console"`

### [logging.loggers."javax.management.mbeanserver".level]

**Default:** `"ERROR"`

### [logging.loggers."javax.management.remote".appenders[0]]

**Default:** `"console"`

### [logging.loggers."javax.management.remote".level]

**Default:** `"ERROR"`

### [logging.loggers."javax.net.ssl".appenders[0]]

**Default:** `"console"`

### [logging.loggers."javax.net.ssl".level]

**Default:** `"OFF"`

### [logging.loggers."org.apache.http".appenders[0]]

**Default:** `"console"`

### [logging.loggers."org.apache.http".level]

**Default:** `"ERROR"`

### [logging.loggers."org.codehaus.janino".appenders[0]]

**Default:** `"console"`

### [logging.loggers."org.codehaus.janino".level]

**Default:** `"WARN"`

### [logging.loggers."org.conscrypt".appenders[0]]

**Default:** `"console"`

### [logging.loggers."org.conscrypt".level]

**Default:** `"ERROR"`

### [logging.loggers."org.hibernate".appenders[0]]

**Default:** `"console"`

### [logging.loggers."org.hibernate".level]

**Default:** `"WARN"`

### [logging.loggers."org.jboss.logging".appenders[0]]

**Default:** `"console"`

### [logging.loggers."org.jboss.logging".level]

**Default:** `"WARN"`

### [logging.loggers."org.jminix".appenders[0]]

**Default:** `"console"`

### [logging.loggers."org.jminix".level]

**Default:** `"ERROR"`

### [logging.loggers."org.restlet".appenders[0]]

**Default:** `"console"`

### [logging.loggers."org.restlet".level]

**Default:** `"ERROR"`

### [logging.loggers.lightstreamerHealthCheck.appenders[0]]

**Default:** `"console"`

### [logging.loggers.lightstreamerHealthCheck.level]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.appenders[0]]

**Default:** `"console"`

### [logging.loggers.lightstreamerLogger.level]

**Default:** `"TRACE"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.WS"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.http"]

**Default:** `"ERROR"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.proxy"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.connections.ssl"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.external"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.init"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.io"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.io.ssl"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.kernel"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.license"]

**Default:** `"TRACE"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.monitoring"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.apple"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.database"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.database.transactions"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.google"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.lifecycle"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.operations"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.pump"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.requests"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.mpn.status_adapters"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.preprocessor"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.pump"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.pump.messages"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.push"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.requests"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.requests.messages"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.requests.polling"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.scheduler"]

**Default:** `"INFO"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.subscriptions"]

**Default:** `"DEBUG"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.subscriptions.upd"]

**Default:** `"DEBUG"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webServer"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webServer.appleWebService"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webServer.jmxTree"]

**Default:** `"WARN"`

### [logging.loggers.lightstreamerLogger.subLoggers."lightstreamerLogger.webclient"]

**Default:** `"DEBUG"`

### [logging.loggers.lightstreamerMonitorTAB.appenders[0]]

**Default:** `"console"`

### [logging.loggers.lightstreamerMonitorTAB.level]

**Default:** `"ERROR"`

### [logging.loggers.lightstreamerMonitorText]

These two loggers are used by the internal monitoring system to log load statistics at INFO level. LightstreamerMonitorText logs statistics with a human-readable syntax; LightstreamerMonitorTAB logs statistics with a CSV syntax. The frequency of the samples produced by the internal monitoring system is governed by the <collector_millis> configuration element. However, a resampling to lower frequencies can be performed, based on the level specified for each logger; in particular:   at TRACE level, all samples are logged;   at DEBUG level, one sample out of 10 is logged;   at INFO level, one sample out of 60 is logged;   at a higher level, no log is produced. The resampling behavior can be changed at runtime, by changing the level; however, if the level is set to ERROR on startup, the logger will be disabled throughout the life of the Server, regardless of further changes. When resampling is in place, note that, for each displayed sample, values that are supposed to be averaged over a timeframe still refer to the current sample's timeframe (based on <collector_millis>); however, values that are supposed to be the maximum over all timeframes refer also to the samples that were not displayed. On the other hand, delta statistics, like "new connections", are always collected starting from the previous logged sample.

**Default:**

```
{"appenders":["console"],"level":"INFO"}
```

### [logging.loggers.lightstreamerProxyAdapters.appenders[0]]

**Default:** `"console"`

### [logging.loggers.lightstreamerProxyAdapters.level]

**Default:** `"DEBUG"`

### [management]

Logging and management configuration

**Default:**

```
{"asyncProcessingThresholdMillis":60000,"collectorMillis":2000,"dashboard":{"availableOnServers":[{"enableJmxTreeVisibility":false,"serverRef":"http-server"}],"credentials":[{"enableJmxTreeVisibility":null,"secretRef":null}],"enableAvailabilityOnAllServers":false,"enableHostnameLookup":null,"enableJmxTree":true,"enablePublicAccess":true,"urlPath":null},"enablePasswordVisibilityOnRequestLog":null,"enableStoppingServiceCheck":null,"healthCheck":{"availableOnServers":["http-server"],"enableAvailabilityOnAllServers":false},"jmx":{"enableLongListProperties":false,"jmxmpConnector":{"enabled":null,"port":null},"rmiConnector":{"allowCipherSuites":[],"allowProtocols":[],"credentialSecrets":[],"dataPort":{},"enablePublicAccess":false,"enableTestPorts":true,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"hostName":null,"keyStoreRef":null,"listeningInterface":null,"port":{"enableSsl":false,"value":8888},"removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"testTimeoutMillis":5000},"sessionMbeanAvailability":"inactive"},"maxTaskWaitMillis":null,"noLoggingIpAddresses":[],"unexpectedWaitThresholdMillis":0}
```

### [management.asyncProcessingThresholdMillis]

Optional. Threshold time for long asynchronous processing alerts. Data and Metadata Adapter calls, even when performed through asynchronous invocations (where available), should still take a reasonable time to complete. This is especially important if limits to the number of concurrent tasks are set; moreover, tasks forgotten for any reason and never completed may cause a memory leak. Hence, the longest current execution time is periodically sampled by the Server Monitor on each pool and, whenever it exceeds this threshold on a pool, a warning is logged. Note that warning messages can be issued repeatedly. A 0 value disables the check.

**Default:** 10000

### [management.collectorMillis]

Mandatory. Sampling time for internal load statistics (Server Monitor). These statistics are available through the JMX interface; some of these statistics are logged bt the Internal Monitor log or can be subscribed to through the internal Monitoring Adapter Set. Full JMX features is an optional feature, available depending on Edition and License Type.

**Default:** `2000`

### [management.dashboard]

Optional. Configuration of the Monitoring Dashboard. The dashboard is a webapp whose pages are embedded in Lightstreamer Server and supplied by the internal web server. The main page has several tabs, which provide basic monitoring statistics in graphical form; the last one shows the newly introduced JMX Tree, which enables JMX data view and management from the browser. The Dashboard leans on an internal Adapter Set, named "MONITOR". The following settings configure access restrictions to Monitoring Dashboard pages. *** IMPORTANT *** The Monitoring Dashboard enables data view and management, including the Server shutdown operation, from a remote browser. We recommend configuring the credentials and protecting them by making the Monitoring Dashboard only available on https server sockets through the settings below. Further restrictions can be applied to the JMX Tree only. See PRODUCTION_SECURITY_NOTES.TXT for a full check-list. Note that basic monitoring statistics are also available to any Lightstreamer application; in fact, an instance of a special internal monitoring Data Adapter can be embedded in any custom Adapter Set, by specifying "MONITOR" in place of the Data Adapter class name. For a listing of the supplied items, see the General Concepts document. The `dashboard.enableHostnameLookup` setting below also affects the monitoring Data Adapter. On the other hand, access restrictions to a monitoring Data Adapter instance embedded in a custom Adapter Set is only managed by the custom Metadata Adapter included.

**Default:**

```
{"availableOnServers":[{"enableJmxTreeVisibility":false,"serverRef":"http-server"}],"credentials":[{"enableJmxTreeVisibility":null,"secretRef":null}],"enableAvailabilityOnAllServers":false,"enableHostnameLookup":null,"enableJmxTree":true,"enablePublicAccess":true,"urlPath":null}
```

### [management.dashboard.availableOnServers]

Optional, but ineffective if `enableAvailabilityOnAllServers` is set to `false`. List of server socket configurations for which requests to the Monitoring Dashboard will be allowed.

**Default:**

```
[{"enableJmxTreeVisibility":false,"serverRef":"http-server"}]
```

### [management.dashboard.availableOnServers[0].serverRef]

Mandatory. Allowed server socket configuration.

**Default:** `"http-server"`

### [management.dashboard.credentials]

Optional, but ineffective if `enablePublicAccess` is set to `true`. Credentials of the users enabled to access the Monitoring Dashboard. enabled to access the Monitoring Dashboard. If `enablePublicAccess` is set to `false`, at least one set of credentials should be supplied in order to allow access through the connector.

**Default:** []

### [management.dashboard.credentials[0].secretRef]

The reference to the secret containing the credentials of the user enabled to access the Monitoring Dashboard. The secret must contain the keys `user` and `password`.

**Default:** `nil`

### [management.dashboard.enableAvailabilityOnAllServers]

Optional. Enabling of the access to the Monitoring Dashboard pages through all server sockets. If set to `true`, requests to the Monitoring Dashboard can be issued through all the defined server sockets. If set to `false`, requests to the Monitoring Dashboard can be issued only through the server sockets specified in the `availableOnServers` setting, if any; otherwise, requests to the dashboard url will get a "page not found" error. If no `availableOnServers` setting is defined, requests to the Monitoring Dashboard will not be possible in any way. Disabling the Dashboard on a server socket causes the internal "MONITOR" Adapter Set to also become unavailable from that socket. This does not affect in any way the special "MONITOR" Data Adapter.

**Default:** false

### [management.dashboard.enableHostnameLookup]

Optional. Enabling of the reverse lookup on Client IPs and inclusion of the Client hostnames while monitoring client activity. This setting affects the Monitor Console page and also affects any instance of the monitoring Data Adapter embedded in a custom Adapter Set. If set to `true`, the Client hostname is determined on Client activity monitoring; note that the determination of the client hostname may be heavy for some systems. If set to `false`, no reverse lookup is performed and the Client hostname is not included on Client activity monitoring.

**Default:** false

### [management.dashboard.enableJmxTree]

Optional. Enabling of the requests for the JMX Tree page, which is part of the Monitoring Dashboard. This page, whose implementation is based on the "jminix" library, enables JMX data view and management, including the Server shutdown operation, from the browser. If set to `true`, the Server supports requests for JMX Tree pages, though further fine-grained restrictions may also apply. If set to `false`, the Server ignores requests for JMX Tree pages, regardless of the credentials supplied and the server socket in use; the dashboard tab will just show a "disabled page" notification.

**Default:** false

### [management.dashboard.enablePublicAccess]

Optional. Enabling of the access to the Monitoring Dashboard pages without credentials. If set to `true`, requests for the Monitoring Dashboard are always accepted. If set to `false`, requests for the Monitoring Dashboard are subject to a check for credentials to be specified through the `users` settings; hence, a user credential submission dialog may be presented by the browser. If no "users" settings is defined, the Monitoring Dashboard will not be accessible in any way.

**Default:** false

### [management.dashboard.urlPath]

Optional. URL path to map the Monitoring Dashboard pages to. An absolute path must be specified.

**Default:** "/dashboard"

### [management.enablePasswordVisibilityOnRequestLog]

Optional. Enabling of the inclusion of the user password in the log of the client requests for new sessions, performed by the `lightstreamerLogger.requests` logger at INFO level. If set to `true`, the whole request is logged. If set to `false`, the request is logged, but for the value of the `LS_password` request parameter. Note that the whole request may still be logged by some loggers, but only at DEBUG level, which is never enabled in the default configuration.

**Default:** false

### [management.enableStoppingServiceCheck]

Optional. Startup check that the conditions for the correct working of the provided "stop" script are met (see the <jmx> block). If set to `true`, the startup will wail if the JMX RMI connector is not configured or the ServerMBean cannot bet started. This also enforces the check of the JMX port reachability ( see `rmiConnector.enableTestPorts` and the remarks on the test effectiveness); if the test fails, the startup will also fail. If set to `false`, no check is made that the "stop" script should work. This may not be a problem, because the Server can be stopped in other ways. The provided installation scripts also close the Server without resorting to the "stop" script.

**Default:** false

### [management.healthCheck]

Optional. Configuration of the "/lightstreamer/healthcheck" request url, which allows a load balancer to test for Server responsiveness to external requests. The Server should always answer to the request with the `OK\r\n` content string (unless overridden through e JMX interface). The Server may log further information to the dedicated `lightstreamerHealthCheck` logger. Support for clustering is an optional feature, available depending on Edition and License Type.

**Default:**

```
{"availableOnServers":["http-server"],"enableAvailabilityOnAllServers":false}
```

### [management.healthCheck.availableOnServers]

Optional, but ineffective if `enableAvailabilityOnAllServers` is set to `false`. List of server socket configurations for which healthcheck requests can be issued.

**Default:** []

### [management.healthCheck.enableAvailabilityOnAllServers]

Optional. Enabling of the healthcheck url on all server sockets. If set to `true`, the healthcheck request can be issued through all the defined server sockets. If set to `false`, the healthcheck request can be issued only through the server sockets specified in the "availableOnServers" setting, if any.

**Default:** false

### [management.jmx]

Mandatory (if you wish to use the provided "stop" script). JMX preferences and external access configuration. Full JMX features is an optional feature, available depending on Edition and License Type; if not available, only the Server shutdown operation via JMX is allowed. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).

**Default:**

```
{"enableLongListProperties":false,"jmxmpConnector":{"enabled":null,"port":null},"rmiConnector":{"allowCipherSuites":[],"allowProtocols":[],"credentialSecrets":[],"dataPort":{},"enablePublicAccess":false,"enableTestPorts":true,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"hostName":null,"keyStoreRef":null,"listeningInterface":null,"port":{"enableSsl":false,"value":8888},"removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"testTimeoutMillis":5000},"sessionMbeanAvailability":"inactive"}
```

### [management.jmx.enableLongListProperties]

Optional. Enabling of all properties provided by the various MBeans. This flag could potentially cause MBeans to return extremely long lists. In act, various JMX agents extract the property values from the MBeans altogether; but extremely long values may clutter the agent and prevent also the acquisition of other properties. This issue may also affect the JMX Tree. For all these properties, corresponding operations are also provided. If set to `true`, all list properties are enabled; in some cases, their value may be an extremely long list; consider, for instance, 'CurrentSessionList' in the ResourceMBean. If set to `false`, properties that can, potentially, return extremely long lists won't yield the correct value, but just a reminder text; for instance, this applies to 'CurrentSessionList' in the ResourceMBean.

**Default:** true

### [management.jmx.jmxmpConnector]

Optional. JMXMP connector configuration. The connector is supported by the Server only if Sun/Oracle's JMXMP implementation library is added to the Server classpath; see README.TXT in the JMX SDK for details. The remote server will be accessible through the url: "service:jmx:jmxmp://<host>:<jmxmpConnector.port>".

**Default:** `{"enabled":null,"port":null}`

### [management.jmx.jmxmpConnector.enabled]

Optional. Enables Sun/Oracle's JMXMP connector.

**Default:** false

### [management.jmx.jmxmpConnector.port]

Mandatory if enabled is set to `true`. TCP port on which Sun/Oracle's JMXMP connector will be listening. This is the port that has to be specified in the client access url.

**Default:** `nil`

### [management.jmx.rmiConnector]

Mandatory (if you wish to use the provided "stop" script). Enables the standard RMI connector. The remote MBean server will be accessible through this url: "service:jmx:rmi:///jndi/rmi://<host>:<port>/lsjmx". If full JMX features is not available, only the "Server" MBean is supplied and only the Server shutdown operation is available. The JVM platform MBean server is also exposed and it is accessible through the url: "service:jmx:rmi:///jndi/rmi://<host>:<port>/jmxrmi". Note that the configuration of the connector applies to both cases; hence, access to the JVM platform MBean server from this connector is not configured through the "com.sun.management.jmxremote" JVM properties. Also note that TLS/SSL is an optional feature, available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).

**Default:**

```
{"allowCipherSuites":[],"allowProtocols":[],"credentialSecrets":[],"dataPort":{},"enablePublicAccess":false,"enableTestPorts":true,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"hostName":null,"keyStoreRef":null,"listeningInterface":null,"port":{"enableSsl":false,"value":8888},"removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"testTimeoutMillis":5000}
```

### [management.jmx.rmiConnector.allowCipherSuites]

Optional, but forbidden if `removeCipherSuites` is used. Specifies all the cipher suites allowed for the interaction, in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.allowCipherSuites`.

**Default:** []

### [management.jmx.rmiConnector.allowProtocols]

Optional, but forbidden if `removeProtocols` is used. Specifies one or more protocols allowed for the TLS/SSL interaction, in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.allowProtocols`.

**Default:** `[]`

### [management.jmx.rmiConnector.credentialSecrets]

Optional, but ineffective if `enablePublicAccess` is set to `true`. The reference to the list of secrets containing the credentials of the  users enabled to access the RMI connector. Every secret must contains the keys `user` and `password`. If `enablePublicAccess` is set to `false`, at least one set of credentials should be supplied in order to allow access through the connector. This is also needed if you wish to use the provided "stop" script; the script will always use the first user supplied.

**Default:** []

### [management.jmx.rmiConnector.dataPort]

Optional. TCP port that will be used by the RMI connector for its own communication stuff. The port has not to be specified in the client access url, but it may have to be considered for firewall settings. The optional `enableSsl` setting, when set to `false`, enables TLS/SSL communication by the connector; TLS/SSL at this level is supported by some JMX clients, like jconsole, that don't supportTLS/SSL on the main port.

**Default:**

```
the same as configured in rmiConnector.port
```

### [management.jmx.rmiConnector.enablePublicAccess]

Optional. Enabling of the RMI connector access without credentials. If set to `true`, requests to the RMI connector are always allowed. If set to `false`, requests to the RMI connector are subject to user authentication; the allowed users are set in the "user" elements.

**Default:** false

### [management.jmx.rmiConnector.enableTestPorts]

Optional. Enabling of a preliminary test on the reachability of the RMI Server through the configured hostname. Note that the reachability is not needed for the Server itself, so the test is only for the benefit of other clients, including the "stop" script; but, since other clients may be run in different environments, the outcome of this test may not be significant. If set to `true`, enables the test; if the test fails, the whole Server startup will fail. If successful and the "stop" script is launched in the same environment of the Server, the script should work. If set to `false`, disables the test, but this setting can be overridden by setting jmx.enableStoppingServiceCheck to `true`.

**Default:** true

### [management.jmx.rmiConnector.enforceServerCipherSuitePreference]

Optional. Determines which side should express the preference when multiple cipher suites are in common between server and client (in case TLS/SSL is enabled for part or all the communication). See notes for servers.{}.sslConfig.enforceServerCipherSuitePreference`.

**Default:**

```
{"enabled":true,"order":"JVM"}
```

### [management.jmx.rmiConnector.hostName]

Optional. A hostname by which the RMI Server can be reached from all the clients. In fact, the RMI Connector, for its own communication stuff, does not use the hostname specified in the client access url, but needs an explicit server-side configuration. Note that, if you wish to use the provided "stop" script, the specified hostname has to be visible also from local clients. property

**Default:**

```
any setting provided to the "java.rmi.server.hostname" JVM
```

### [management.jmx.rmiConnector.keyStoreRef]

Optional. The reference a keystore to be used in case TLS/SSL is is enabled for part or all the communication. See the `keystores.myServerKeystore` for general details on keystore configuration. These include the runtime replacement of the keystore, with one difference: if the load of the new keystore fails, the RMI Connector may be left unreachable. "javax.net.ssl.keyStorePassword" JVM properties will apply

**Default:**

```
any settings provided to the "javax.net.ssl.keyStore" and
```

### [management.jmx.rmiConnector.listeningInterface]

Optional. Can be used on a multihomed host to specify the IP address to bind the HTTP/HTTPS server sockets to, for all the communication. Note that, when a listening interface is configured and depending on the local network configuration, specifying a suitable `rmiConnector.hostname` setting may be needed to make the connector accessible, even from local clients.

**Default:**

```
accept connections on any/all local addresses
```

### [management.jmx.rmiConnector.port]

Mandatory. TCP port on which the RMI connector will be available. This is the port that has to be specified in the client access url. The optional `enableSsl` setting, when set to `true`, enables TLS/SSL communication. Note that this case is not managed by some JMX clients, like jconsole.

**Default:**

```
{"enableSsl":false,"value":8888}
```

### [management.jmx.rmiConnector.removeCipherSuites]

Optional, but forbidden if `allowCipherSuites` is used. Pattern to be matched against the names of the enabled cipher suites in order to remove the matching ones from the enabled cipher suites set to be used in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.removeCipherSuites`.

**Default:** []

### [management.jmx.rmiConnector.removeProtocols]

Optional, but forbidden if `allowProtocols` is used. Pattern to be matched against the names of the enabled TLS/SSL protocols in order to remove the matching ones from the enabled protocols set to be used in case TLS/SSL is enabled for part or all the communication. See notes for `servers.{}.sslConfig.removeProtocols.

**Default:** `["SSL","TLSv1$","TLSv1.1"]`

### [management.jmx.rmiConnector.testTimeoutMillis]

Optional. Timeout to be posed on the connection attempts through the RMI Connector. If 0, no timeout will be posed. The setting affects: - The reachability test (if enabled through <test_ports>). - The connector setup operation; in fact this operation may involve a   connection attempt, whose failure, however, would not prevent the   setup from being successful. If the configured hostname were not   visible locally, the setup might take long time; by setting a   timeout, the operation would not block the whole Server startup.   However, the RMI Connector (and the "stop" script) might not be   available immediately after the startup, and any late failure   preventing the connector setup would be ignored. On the other hand, the setting is ignored by the "stop" script.

**Default:** 0

### [management.jmx.sessionMbeanAvailability]

Optional. Enabling of the availability of session-related mbeans, the  ones identified by type="Session". If set to "active", for each active session, a corresponding mbean of type "Session" is available with full functionality. If set to "sampled_statistics_only", for each active session, a corresponding mbean of type "Session" is available, but all the statistics based on periodic sampling are disabled. If set to "inactive", no mbeans of type "Session" are generated, but for a fake mbean which acts as a reminder that the option can be enabled. The support for session-related mbeans can pose a significant overload on the Server when many sessions are active and many of them are continuously created and closed. For this reason, the support is disabled by default.

**Default:** inactive

### [management.maxTaskWaitMillis]

Optional. Threshold wait time for a task enqueued for running on any of the internal thread pools. The current wait time is periodically sampled by the Server Monitor on each pool and, whenever it exceeds this threshold on a pool, a warning is logged. Note that warning messages can be issued repeatedly. A 0 value disables the check.

**Default:** 10000.

### [management.noLoggingIpAddresses]

Optional. A set of Clients whose activity is not to be logged.

**Default:** []

### [management.unexpectedWaitThresholdMillis]

Optional. Threshold time for long Adapter call alerts. All Data and Metadata Adapter calls should perform as fast as possible, to ensure that client requests are accomplished quickly. Slow methods may also require that proper thread pools are configured. Hence, all invocations to the Adapters (but for the initialization phase) are monitored and a warning is logged whenever their execution takes more than this time. A 0 value disables the check.

**Default:** 1000

### [nameOverride]

Override the default name of the chart

**Default:** `""`

### [proxy]

Configure a proxy server for outbound Internet access, if necessary. Internet access is needed, depending on the above configuration, to reach the Online License Manager, to upload audit logs, and to check for software updates. The host names below must be reachable from the proxy on port 443: - https://clm1.lightstreamer.com/    (depending on the configuration) - https://clm2.lightstreamer.com/    (depending on the configuration) - https://service.lightstreamer.com/ (regardless of the configuration) Several methods are provided for the proxy configuration, including PAC files, auto-discovery, and direct HTTP and SOCKS configuration.

**Default:**

```
{"enableProxyAutodiscovery":false,"httpProxy":null,"networkInterface":null,"pacFiles":{"filePath":null,"fileUrl":null}}
```

### [proxy.enableProxyAutodiscovery]

In case no proxy configuration is provided or the provided configuration does not work, automatic proxy discovery is attempted (via system environment check and WPAD).

**Default:** `false`

### [proxy.networkInterface]

Specifies a NIC to use to access the external services, with or without a proxy.

**Default:** `nil`

### [pushSession]

Mandatory. Push session configuration

**Default:**

```
{"compressionThreshold":null,"contentLength":{"default":4000000,"specialCases":null},"defaultDiffOrders":[],"defaultKeepaliveMillis":{"randomize":false,"value":5000},"enableDeltaDelivery":null,"enableEnrichedContentType":null,"jsonPatchMinLength":null,"maxBufferSize":1000,"maxDelayMillis":30,"maxIdleMillis":{"randomize":false,"value":30000},"maxKeepaliveMillis":30000,"maxPollingMillis":15000,"maxRecoveryLength":null,"maxRecoveryPollLength":null,"maxStreamingMillis":null,"minInterPollMillis":null,"minKeepaliveMillis":1000,"missingMessageTimeoutMillis":null,"preserveUnfilteredCommandOrdering":null,"reusePumpBuffers":null,"sendbuf":null,"serviceUrlPrefixes":[],"sessionRecoveryMillis":13000,"sessionTimeoutMillis":10000,"subscriptionTimeoutMillis":5000,"useChunkedEncoding":"AUTO","useCompression":null}
```

### [pushSession.compressionThreshold]

Optional. Size in bytes of the response body below which compression is not applied, regardless of the "use_compression" setting, as we guess that no benefit would come. It is not applied to streaming responses, which are compressed incrementally.

**Default:** 1024

### [pushSession.contentLength]

Mandatory. Maximum size of HTTP streaming responses; when the maximum size is reached, the connection is closed but the session remains active and the Client can continue listening to the item update events by binding the session to another connection. This setting is also used as the maximum length allowed for poll responses; if more data were available, they would be kept for the next poll request. The Setting is not used for streaming responses over WebSockets. The optimal content-length for web clients (i.e. browser user agents) should not be too high, in order to reduce the maximum allocated memory on the client side. Also note that some browsers, in case of a very high content-length, may reduce streaming capabilities (noticed with  IE8 and 4GB). This setting can be overridden by the Clients (some LS client libraries actually set their own default). The lowest possible value for the content-length is decided by the Server, so as to allow the connection to send a minimal amount of data.

**Default:**

```
{"default":4000000,"specialCases":null}
```

### [pushSession.contentLength.default]

Mandatory. Define the maximum size of HTTP streaming responses (and the upper limit for polling responses)

**Default:** `4000000`

### [pushSession.contentLength.specialCases]

Optional. List of special cases for defining the HTTP content-length to be used for stream/poll response (through `specialCases[].value`) when the user-agent supplied with the request contains all the specified string (through the`specialCases[].userAgentContains`). Special cases are evaluated in sequence, until one is enabled.

**Default:** `nil`

### [pushSession.defaultDiffOrders]

Optional. List of algorithms to be tried by default to perform the "delta delivery" of changed fields in terms of difference between previous and new value. This list is applied only on fields of items for which no specific information is provided by the Data Adapter. For each value to be sent to some client, the algorithms are tried in the order specified by this list, until one is found which is compatible with both client capabilities and the involved values. Available names are: - jsonpatch: computes the difference in JSON Patch format, provided that the values are valid JSON representations; - diff_match_patch: computes the difference with Google's "diff-match-patch" algorithm ( the result is then serialized to the custom "TLCP-diff" format). Note that trying "diff" algorithms on unsuitable data may waste resources. For this reason, the default algorithm list is empty,which means that no algorithm is ever tried by default. The best way to enforce algorithms is to do that on a field-by-field basis through the Data Adapter interface.

**Default:** []

### [pushSession.defaultKeepaliveMillis]

Mandatory. Default keep-alive configuration.

**Default:**

```
{"randomize":false,"value":5000}
```

### [pushSession.defaultKeepaliveMillis.randomize]

Optional. If set to `true`, causes keepalives immediately following a data event to be sent after a random, shorter interval (possibly even shorter than the "min_keepalive_millis" setting). This can be useful if many sessions subscribe to the same items and updates for these items are rare, to avoid that also the keepalives for these sessions occur at the same times.

**Default:** false

### [pushSession.defaultKeepaliveMillis.value]

Mandatory. Longest write inactivity time allowed on the socket. If no updates have been sent after this time, then a small keep-alive message is sent. Note that the Server also tries other types of checks of the availability of current sockets, which don't involve writing data to the sockets. This setting can be overridden by the Client.

**Default:** `5000`

### [pushSession.enableDeltaDelivery]

Optional. Configuration of the policy adopted for the delivery of updates to the clients. If set to `true`, the Server is allowed to perform "delta delivery"; it will send special notifications to notify the clients of values that are unchanged with respect to the previous update for the same item; moreover, if supported by the client SDK, it may send the difference between previous and new value for updates which involve a small change. If set to `false`, the Server always sends to the clients the actual values in the updates; note that any missing field in an update from the Data Adapter for an item in MERGE mode is just a shortcut for an unchanged value, hence the old value will be resent anyway. Adopting the "delta delivery" is in general more efficient than always sending the values. On the other hand, checking for unchanged values and/or evaluating the difference between values puts heavier memory and processing requirements on the Server. In case "delta delivery" is adopted, the burden of recalling the previous values is left to the clients. This holds for clients based on the "SDK for Generic Client Development". This also holds for clients based on some old versions of the provided SDK libraries, which just forward the special unchanged notifications through the API interface. Old versions of the .NET, Java SE (but for the ls_proxy interface layer), Native Flex and Java ME libraries share this behavior. Forcing a redundant delivery would simplify the client code in all the above cases.

**Default:** true

### [pushSession.enableEnrichedContentType]

Optional. Configuration of the content-type to be specified in the response headers when answering to session requests issued by native client libraries and custom clients. If set to `true`, the server will specify the text/enriched content-type. This setting might be preferable when communicating over certain service providers that may otherwise buffer streaming connections. if set to `false`, the server will specify the text/plain content-type.

**Default:** true

### [pushSession.jsonPatchMinLength]

Optional. Minimum length among two update values (old and new) which enables the use of the JSON Patch format to express the new value as the difference with respect to the old one, when this is possible. If any value is shorter, it will be assumed that the computation of the difference in this way will yield no benefit. The special value `none` is also available. In this case, when the computation of the difference in JSON Patch format is possible, it will always be used, regardless of efficiency reasons. This can be leveraged in special application scenarios, when the clients require to directly retrieve the updates in the form of JSON Patch differences.

**Default:** 50

### [pushSession.maxBufferSize]

Optional. Maximum size for any ItemEventBuffer. It applies to RAW and COMMAND mode and to any other case of unfiltered subscription. For filtered subscriptions, it poses an upper limit on the maximum buffer size that can be granted by the Metadata Adapter or requested through the subscription parameters. Similarly, it poses an upper limit to the length of the snapshot that can be sent in DISTINCT mode, regardless of the value returned by getDistinctSnapshotLength. See the General Concepts document for details on when these buffers are used. An excessive use of these buffers may give rise to a significant memory footprint; to prevent this, a lower size limit can be set. Note that the buffer size setting refers to the number of update events that can be kept in the buffer, hence the consequent memory usage also depends on the size of the values carried by the enqueued updates. As lost updates for unfiltered subscriptions are logged on the `lightstreamerLogger.pump` logger at INFO level, if a low buffer size limit is set, it is advisable also setting this logger at WARN level. Aggregate statistics on lost updates are also provided by the JMX interface (if available) and by the Internal Monitor.

**Default:** unlimited size

### [pushSession.maxDelayMillis]

Optional. Longest delay that the Server is allowed to apply to outgoing updates to collect more updates in the same packet. This value sets a trade-off between Server scalability and maximum data latency. It also sets an upper bound to the maximum update frequency for items not subscribed with unlimited or unfiltered frequency.

**Default:** 0.

### [pushSession.maxIdleMillis]

Mandatory. Max idle configuration.

**Default:**

```
{"randomize":false,"value":30000}
```

### [pushSession.maxIdleMillis.randomize]

Optional. If set to `true`, causes polls immediately following a data event to wait for a random, shorter inactivity time. This can be useful if many sessions subscribe to the same items and updates for these items are rare, to avoid that also the following polls for these sessions occur at the same times.

**Default:** `false`

### [pushSession.maxIdleMillis.value]

Mandatory. Longest inactivity time allowed on the socket while waiting for updates to be sent to the client through the response to asynchronous poll request. If this time elapses, the request is answered with no data, but the client can still rebind to the session with a new poll request. A shorter inactivity time limit can be requested by the client.

**Default:** `30000`

### [pushSession.maxKeepaliveMillis]

Mandatory. Upper bound to the keep-alive time requested by a Client. Must be greater than the `pushSession.defaultKeepaliveMillis` setting.

**Default:** `30000`

### [pushSession.maxPollingMillis]

Mandatory. Longest time a client is allowed to wait, after receiving a poll answer, before issuing the next poll request. Note that, on exit from a poll request, a session has to be kept active, while waiting for the next poll request. The session keeping time has to be requested by the Client within a poll request, but the Server, within the response, can notify a shorter time, if limited by this setting. The session keeping time for polling may cumulate with the keeping time upon disconnection, as set by `pushSession.sessionTimeoutMillis`

**Default:** `15000`

### [pushSession.maxRecoveryPollLength]

Optional. Maximum size supported for keeping a polling response, already sent or being sent to the Client, in order to allow the Client to recover the session, in case a network issue should interrupt the polling connection and prevent the client from receiving the latest response. Note that recovery is available only for some client versions; if any other version were involved, no data would be kept. A 0 value also prevents any accumulation of memory. On the other hand, a value of -1 relieves any limit.

**Default:** -1

### [pushSession.maxStreamingMillis]

Optional. Maximum lifetime allowed for single HTTP streaming responses; when this timeout expires, the connection is closed, though the session remains active and the Client can continue listening to the UpdateEvents by binding the session to another connection. Setting this timeout is not needed in normal cases; it is provided just in case any user agent or intermediary node turned out to be causing issues on very long-lasting HTTP responses. The Setting is not applied to polling responses and to streaming responses over WebSockets. If not specified, only by the `pushSession.contentLength` setting and, at least, by the keep-alive message activity

**Default:**

```
no limit is set; the streaming session duration will be limited
```

### [pushSession.minInterPollMillis]

Optional. Shortest time allowed between consecutive polls on a session. If the client issues a new polling request and less than this time has elapsed since the STARTING of the previous polling request, the polling connection is kept waiting until this time has elapsed. In fact, neither a `pushSession.minPollingMillis` nor a `pushSession.maxPollingMillis` setting are provided, hence a client is allowed to request 0 for both, so that the real polling frequency will only be determined by roundtrip times. However, in order to avoid that a similar case causes too much load on the Server, this setting can be used as a protection, to limit the polling frequency.

**Default:** 0

### [pushSession.minKeepaliveMillis]

Mandatory. Lower bound to the keep-alive time requested by a Client. Must be lower than the `pushSession.defaultKeepaliveMillis` setting.

**Default:** `1000`

### [pushSession.preserveUnfilteredCommandOrdering]

Optional. Configuration of the update management for items subscribed to in COMMAND mode with unfiltered dispatching. If set to `true`, the order in which updates are received from the Data Adapter is preserved when sending updates to the clients; in this case, any frequency limits imposed by license limitations are applied to the whole item and may result in a very slow update flow. If set to `false`, provided that no updates are lost, the Server can send enqueued updates in whichever order; it must only ensure that, for updates pertaining to the same key, the order in which updates are received from the Data Adapter is preserved; in this case, any frequency limits imposed by license limitations are applied for each key independently. No item-level choice is possible. However, setting this flag as `true` allows for backward compatibility to versions before 4.0, if needed.

**Default:** false.

### [pushSession.reusePumpBuffers]

Optional. Policy to be adopted for the handling of session-related data when a session is closed. If set to `Y`, internal buffers used for composing and sending updates are kept among session-related data throughout the life of each session; this speeds up update management. If set to `N`, internal buffers used for composing and sending updates are allocated and deallocated on demand; this minimizes the requirements in terms of permanent per-session memory and may be needed in order to handle a very high number of concurrent sessions, provided that the per-session update activity is low from memory when the session is closed. If set to `AUTO`, the current setting of `pushSession.enableDeltaDelivery` is used; in fact, setting `pushSession.enableDeltaDeliver` as `false` may denote  the need for reducing permanent per-session memory.

**Default:** AUTO

### [pushSession.sendbuf]

Optional. Size to be set for the socket TCP send buffer in case of streaming connections. The ideal setting should be a compromise between throughput, data aging, and memory usage. A large value may increase throughput, particularly in sessions with a high update activity and a high roundtrip time; however, in case of sudden network congestion, the queue of outbound updates would need longer to be cleared and these updates would reach the client with significant delays. On the other hand, with a small buffer, in case of sudden network congestion, most of the ready updates would not be enqueued in the TCP send buffer, but inside the Server, where there would be an opportunity to conflate them with newer updates. The main problem with a small buffer is when a single update is very big, or a big snapshot has to be sent, and the roundtrip time is high; in this case, the delivery could be slow. However, the Server tries to detect these cases and temporarily enlarge the buffer. Hence, the factory setting is very small and it is comparable with a typical packet size. There shouldn't be any need for an even smaller value; also note that the system may force a minimum size. Higher values should make sense only if the expected throughput is high and responsive updates are desired.

**Default:** 1600.

### [pushSession.serviceUrlPrefixes]

Optional. If used, defines one or multiple alternative url paths for all requests related to the streaming services, which will be composed by the specified prefix followed by /lightstreamer. Then it will be possible to instruct the Unified Client SDKs to use an alternative path by adding its prefix to the supplied Server address. The specified path prefixes must be absolute. Note that, regardless of this setting, the standard path, which is /lightstreamer, is always active. By supporting dedicated paths, it becomes possible to address different Server installations with the same hostname, by instructing an intermediate proxy to forward each client request to the proper place based on the prefix, even if the prefix is not stripped off by the proxy. However, this support does not apply to the Internal Web Server and to the Monitoring Dashboard.

**Default:** []

### [pushSession.subscriptionTimeoutMillis]

Optional. Longest time the subscriptions currently in place on a session can be kept active after the session has been closed, in order to prevent unsubscriptions from the Data Adapter that would be immediately followed by new subscriptions in case the client were just refreshing the page. As a consequence of this wait, some items might temporarily appear as being subscribed to, even if no session were using them. If a session is closed after being kept active because of the `pushSession.sessionTimeoutMillis` or "pushSession.sessionRecoveryMillis` setting, the accomplished wait is considered as valid also for the subscription wait purpose. @default - the time configured for `pushSession.sessionTimeoutMillis`.

**Default:** `5000`

### [pushSession.useChunkedEncoding]

Optional. Enabling the use of the "chunked" transfer encoding, as defined by the HTTP 1.1 specifications, for sending the response body on HTTP streaming connections. If set to `Y`, the "chunked" transfer encoding will be used anytime an HTTP 1.1 response is allowed, which will enforce the use of HTTP 1.1 (see `globalSocket.useHttpVersion`). If set to `N`, causes no transfer encoding (that is, the "identity" transfer encoding) to be used for all kinds of responses. If set to `AUTO`, the "chunked" transfer encoding will be used only when an HTTP 1.1 response is being sent (see `globalSocket.useHttpVersion`). Though with "chunked" transfer encoding the content-length header is not needed on the HTTP response header, configuring a content length for the Server is still mandatory and the setting is obeyed in order to put a limit to the response length. Default: Y

**Default:** `"AUTO"`

### [pushSession.useCompression]

Optional. Enabling the use of the "gzip" content encoding, as defined by the HTTP 1.1 specifications, for sending the resource contents on HTTP responses; compression is currently not supported for responses over WebSockets. If set to `Y`, Gzip compression will be used anytime an HTTP 1.1 response is allowed (for streaming responses, the "chunked" transfer encoding should also be allowed), provided that the client has declared to accept it through the proper http request headers. If set to `N`, causes no specific content encoding to be applied for all kinds of contents. If set to `AUTO`, Gzip compression will not be used, unless using it is recommended in order to handle special cases (and provided that all the conditions for compression are met; see case Y above). Streaming responses are compressed incrementally. The use of compression may relieve the network level at the expense of the Server performance. Note that bandwidth control and output statistics are still based on the non-compressed content.

**Default:** AUTO

### [security]

Security configuration

**Default:**

```
{"allowedDomains":[],"crossDomainPolicy":{"acceptCredentials":true,"acceptExtraHeaders":null,"allowAccessFrom":{"fromEveryWere":{"host":"*","port":"*","scheme":"*"}},"optionsMaxAgeSeconds":3600},"enableCookiesForwarding":false,"enableProtectedJs":true,"serverIdentificationPolicy":null}
```

### [security.crossDomainPolicy]

Optional. List of origins to be allowed by the browsers to consume responses to requests sent to this Server through cross-origin XHR or through WebSockets; in fact, when a requesting page asks for streaming data in this way, the browser should specify the page origin through the "Origin" HTTP header, to give the Server a chance to accept or refuse the request. This is the most common way streaming data is requested by the Web (Unified API) Client Library. You can see the Client Guide for the Web (Unified API) Client SDK earlier than 8.0.0 for details on all the possible use cases. If a request origin is not matched against any of the configured rules, a Websocket initiation request will be refused, whereas a HTTP request will not be denied (i.e.: a 200 OK will be returned) but the response body will be left empty, in accordance with the CORS specifications. If no origin is specified by the user-agent, the request will always be accepted. Note that sending the Origin header is a client-side duty. In fact, most modern browsers, upon a request for a cross-origin XHR or WebSocket by a page, will send the Origin header, while older browsers will directly fail to send the request. Non-browser clients usually don't have to perform origin checks; so they don't send the Origin header and thus their requests are always authorized.

**Default:**

```
{"acceptCredentials":true,"acceptExtraHeaders":null,"allowAccessFrom":{"fromEveryWere":{"host":"*","port":"*","scheme":"*"}},"optionsMaxAgeSeconds":3600}
```

### [security.crossDomainPolicy.acceptCredentials]

Optional. Specify f the server should authorize the client to send its credentials on a CORS request. This setting does not impact the user/password sent over the Lightstreamer protocol,but, if set to `false`, might prevent, or force a fallback connection, on clients sending CORS requests carrying cookies, http-basic-authentication or client-side certificates.

**Default:** false

### [security.crossDomainPolicy.acceptExtraHeaders]

Optional. In case the client wishes to send custom headers to the server, it requires approval from the server itself. This setting permits to specify a comma separated list of extra headers to be allowed in the client requests. Note that a space is expected after each comma (e.g.: `acceptExtraHeaders: "custom-header1, custom-header2"`).

**Default:** ""

### [security.crossDomainPolicy.allowAccessFrom]

Optional. List of Origin allowed to consume responses to cross-origin requests.

**Default:**

```
{"fromEveryWere":{"host":"*","port":"*","scheme":"*"}}
```

### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere]

Optional. Defines a rule against which Origin headers will be checked.

**Default:**

```
{"host":"*","port":"*","scheme":"*"}
```

### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere.host]

Mandatory. A valid host name, IPv4 or IPv6 representing, an authorized Origin. Also a `*` is accepted with the meaning of "any host or IP". If a host name is specified it can be prefixed with a wildcard as long as at least the second level domain is explicitly specified (i.e.:*.my-domain.com and *.sites.my-domain.com are valid entries while *.com is not)

**Default:** `"*"`

### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere.port]

Mandatory. A a valid port or `*` to specify any port.

**Default:** `"*"`

### [security.crossDomainPolicy.allowAccessFrom.fromEveryWere.scheme]

Mandatory. A valid scheme name (usually http or https) or `*`; the latter matches both http and https scheme, but it doesn't match other schemes.

**Default:** `"*"`

### [security.crossDomainPolicy.optionsMaxAgeSeconds]

Optional. In case an HTTP OPTIONS request is sent to authorize future requests, the server allows the client to store the result of such OPTIONS for the specified number of seconds. Thus a previously authorized client may not give up its authorization, even if the related origin is removed from the list and the server is restarted, until its authorization expires. @default 3600

**Default:** `3600`

### [security.enableCookiesForwarding]

Optional. Use this setting to enable the forwarding of the cookies to the Metadata Adapter through the httpHeaders argument of the "notifyUser" method. Please note that in any case cookies should not be used to authenticate users, otherwise, having `enableProtectedJs` set to `false` and/or a too permissive policy in the `crossDomainPolicy` will expose the server to CSRF attacks. If set to `true`, cookies are forwarded to the Metadata Adapter. If set to `false`, cookies are hidden from the Metadata Adapter.

**Default:** false

### [security.enableProtectedJs]

Optional. Disabling of the protection for JavaScript pages, supplied by the Server, that carry user data. JavaScript pages can be supplied upon requests by old versions of the Web and Node.js (Unified API) Client Libraries, whereas recent versions no longer make use of this kind of pages. The protection prevents such pages from being imported in a <script> block and, as a consequence, from being directly executed within a hosting page regardless of its origin. This protection allows the Server to fully comply with the prescriptions to prevent the so-called "JavaScript Hijacking". If set to `true`, the protection is enabled. If set to `false`, the protection is disabled. It can be set in order to support communication between the application front-end pages and Lightstreamer Server in specific use cases; see the Client Guide for the Web (Unified API) Client SDK earlier than 8.0.0 for details. It can also be set in order to ensure compatibility with even older Web Client Libraries (version 4.1 build 1308 or previous). Note, however, that basic protection against JavaScript Hijacking can still be granted, simply by ensuring that request authorization is never based on information got from the request cookies. This already holds for any session-related request other than session-creation ones, for which the request URL is always checked against the Server-generated session ID. For session-creation requests, this depends on the Metadata Adapter implementation, but can be enforced by setting `enableForwardCookies` to `false`.

**Default:** true

### [security.serverIdentificationPolicy]

Optional. Server identification policy to be used for all server responses. Upon any HTTP request, the Server identifies itself through the "Server" HTTP response header. However, omitting version information may make external attacks more difficult. If set to `FULL`, the Server identifies itself as: Lightstreamer Server/X.Y.Z build BBBB (Lightstreamer Push Server - www.lightstreamer.com) EEEEEE edition. If set to `MINIMAL`, the Server identifies itself, depending on the Edition: for Enterprise edition, as Lightstreamer Server; for Community edition, as Lightstreamer Server (Lightstreamer Push Server - www.lightstreamer.com) COMMUNITY edition.

**Default:** "FULL"

### [servers]

Mandatory. Map of HTTP/S server socket configurations. Every key in the map defines a specific listening socket configuration, which can then be referenced through the whole configuration. Defining multiple listening socket allows the coexistence of private and public ports. This allows the use of multiple address for accessing the Server via TLS/SSL, because different HTTPS sockets can use different keystores. In particular this is the case when the Server is behind load load balancer and the `cluster.controlLinkAddress` setting is leveraged to ensure that all Requests issued by the same client are dispatched to the same Server instance.

**Default:**

```
{"http-server":{"backlog":null,"clientIdentification":{"enableForwardsLogging":null,"enablePrivate":null,"enableProxyProtocol":null,"proxyProtocolTimeoutMillis":null,"skipLocalForwards":null},"enableHttps":null,"enabled":true,"listeningInterface":null,"name":"Lightstreamer HTTP Server","port":8080,"portType":null,"responseHttpHeaders":{"add":[{"name":"X-Accel-Buffering","value":"no"}],"echo":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableClientAuth":null,"enableClientHintsForTlsSessionResumption":null,"enableMandatoryClientAuth":null,"enableStatelessTlsSessionResumption":null,"enableTlsRenegotiation":null,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"keyStoreRef":"myServerKeystore","removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"tlsProvider":null,"tlsSessionCacheSize":null,"tlsSessionTimeoutSeconds":null,"trustStoreRef":null}}}
```

### [servers.http-server]

An HTTP server socket configuration.

**Default:**

```
{"backlog":null,"clientIdentification":{"enableForwardsLogging":null,"enablePrivate":null,"enableProxyProtocol":null,"proxyProtocolTimeoutMillis":null,"skipLocalForwards":null},"enableHttps":null,"enabled":true,"listeningInterface":null,"name":"Lightstreamer HTTP Server","port":8080,"portType":null,"responseHttpHeaders":{"add":[{"name":"X-Accel-Buffering","value":"no"}],"echo":null},"sslConfig":{"allowCipherSuites":[],"allowProtocols":[],"enableClientAuth":null,"enableClientHintsForTlsSessionResumption":null,"enableMandatoryClientAuth":null,"enableStatelessTlsSessionResumption":null,"enableTlsRenegotiation":null,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"keyStoreRef":"myServerKeystore","removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"tlsProvider":null,"tlsSessionCacheSize":null,"tlsSessionTimeoutSeconds":null,"trustStoreRef":null}}
```

### [servers.http-server.backlog]

Optional. Size of the system buffer for incoming TCP connections Overrides the default system setting

**Default:** the system setting

### [servers.http-server.clientIdentification]

Optional. Settings that allow for better recognition of the remote address of the connected clients. This can be done in two ways: - by taking advantage of the X-Forwarded-For HTTP header, that   intermediate HTTP proxies and level-7 Load Balancers usually set to   supply connection routing information in an incremental way (this is   done through the "skip_local_forwards" subelement); - by receiving the routed address directly from a TCP reverse proxy or   level-4 Load Balancer through the Proxy Protocol, when the proxy is   configured to do so (this is done through the `enableProxyProtocol`   setting). The two techniques can also coexist, but, in that case, the address through the proxy protocol would always be considered as the real client address and all addresses in the chain specified in X-Forwarded-For would be considered as written by client-side proxies. The address determined in this way will be used in all cases in which the client address is reported or checked. For logging purposes, the connection endpoint will still be written, but the real remote address, if available and different, will be added. The determined address may also be sent to the clients, depending on the Client SDK in use.

**Default:** all settings at their defaults

### [servers.http-server.clientIdentification.enableForwardsLogging]

Optional. If set to `true`, causes the list of entries of the X-Forwarded-For header, when available, to be added to log lines related to the involved HTTP request or Websocket. If `skipLocalForwards` is nonzero, only the entries farther than the determined "real" remote address are included. These entries are expected to be written by client-side proxies.

**Default:** false

### [servers.http-server.clientIdentification.enablePrivate]

Optional.  If set to `true`, prevents the determined address from being sent to the clients. In fact, the address is notified to the client upon connection and it is made available to application code by the most recent Unified Client SDKs through the clientIp property in the ConnectionDetails class. For instance, the flag can and should be set to `true` in case the identification of the remote address is not properly tuned and the determined address may be a local one.

**Default:** false

### [servers.http-server.clientIdentification.enableProxyProtocol]

Optional. If set to `true`, instructs the Server that the connection endpoint is a reverse proxy or load balancer that sends client address information through the Proxy Protocol. The received address and port will be used as the real client address and port. In particular, they will appear in all log lines for this client (but for the `lightstreamerLogger.connections` logger). On the other hand, the reported protocol will always refer to the actual connection. There is no dynamic detection of the proxy protocol; hence, if enabled, all connections to this port must speak the proxy protocol (for instance, any healthcheck requests should be configured properly on the proxy) and, if not, no connection can speak the proxy protocol, otherwise the outcome would be unspecified. On the other hand, if enabled, both proxy protocol version 1 and 2 are handled; only information for normal TCP connections is considered.

**Default:** false

### [servers.http-server.clientIdentification.proxyProtocolTimeoutMillis]

Optional. Optional. Timeout applied while reading for information through the proxy protocol, when enabled. Note that a reverse proxy or load balancer speaking the proxy protocol is bound to send information immediately after connection start; so the timeout can only apply to cases of wrong configuration, local network issues or illegal access to this port. For this reason, the read is performed directly in the ACCEPT thread pool and this setting protects that pool against such unlikely events.

**Default:** 1000

### [servers.http-server.clientIdentification.skipLocalForwards]

Optional, but nonzero values forbidden if `enableProxyProtocol` is `true`. Number of entries in the X-Forwarded-For header that are expected to be supplied on each HTTP request (including Websocket handshake) by the intermediate nodes (e.g. reverse proxies, load balancers) that stand in the local environment. If N entries are expected from local nodes, this means that the Nth-nearest entry corresponds to the node connected to the farthest local intermediate node, hence to the client. So, that entry will be used as the real client address. In particular, it will appear in all log lines that refer to the involved HTTP request or Websocket. If set to `0` or left at the default, all entries in X-Forwarded-For will be considered as written by client-side proxies, hence the connection endpoint address will be used (unless, of course, `enableProxyProtocol` is set to `true`, which overrides the behavior). Note that a similar correction for port and protocol is not applied; hence, when an address corrected through a nonzero setting is reported, any port and protocol associated will still refer to the actual connection.

**Default:** 0

### [servers.http-server.enableHttps]

Optional. Enabling of the https protocol. HTTPS service is an optional feature, available depending on Edition and License Type. To know what features are enabled by your license, please see the License tab of the Monitoring Dashboard (by default, available at /dashboard).  See `sslConfig` for general details on TLS/SSL configuration.

**Default:** false

### [servers.http-server.enabled]

Optional. Enable this socket configuration.

**Default:** false

### [servers.http-server.listeningInterface]

Optional. Can be used on a multihomed host to specify the IP address to bind the server socket to.

**Default:**

```
accept connections on any/all local addresses
```

### [servers.http-server.name]

Mandatory. The name of the HTTP/S server. Note that it is notified to  the client upon connection and it is made available to application code  by the Unified Client SDKs through the serverSocketName property in the ConnectionDetails class. It must be an ASCII string with no control characters and it must be unique among all server configurations.

**Default:** `"Lightstreamer HTTP Server"`

### [servers.http-server.port]

Mandatory. Listening TCP port.

**Default:** `8080`

### [servers.http-server.portType]

Optional. Provides meta-information on how this listening socket will be used, according with the deployment configuration. This can inform the Server of a restricted set of requests expected on the port, which may improve the internal backpressure mechanisms. If set to `CREATE_ONLY`, declares that the port is only devoted to "S" connections, according with the provided Clustering.pdf document.  If set to `CONTROL_ONLY`, declares that the port is only devoted to "CR" connections,according with the provided Clustering.pdf document. The Server will enforce the restriction.  If set to `PRIORITY`, requests issued to this port will follow a fast track. In particular, they will be never enqueued to the SERVER thread pool, but only the ACCEPT pool; and they will not be subject to any backpressure-related limitation (like `load.acceptPoolMaxQueue`). This should ensure that the requests will be fulfilled as soon as possible, even when the Server is overloaded. Such priority port is, therefore, ideal for opening the Monitoring Dashboard to inspect overload issues in place. It can also be used to open sessions on a custom Adapter Set, but, in that case, any thread pool specifically defined for the Adapters will be entered, with possible enqueueing. Anyway, such port is only meant for internal use and it is recommended not to leave it publicly accessible. Furthermore, in case of HTTPS server socket (`enableHttps` set to `true`) TLS-handshake-related tasks will not be enqueued to the TLS-SSL HANDSHAKE or TLS-SSL AUTHENTICATION thread pool, but only to a dedicated pool.  If set to `GENERAL_PURPOSE`, the port can be used for any kind of request. It can always be set in case of doubts. Note that ports can be CREATE_ONLY or CONTROL_ONLY only depending on client behavior. For clients based on LS SDK libraries, this is related to the use of the `cluster.controlLinkAddress` setting. Usage examples are provided in the Clustering.pdf document.

**Default:** "GENERAL_PURPOSE"

### [servers.http-server.responseHttpHeaders]

Optional. Settings that allow some control over the HTTP headers of the provided responses. Header lines can only be added to those used by the Server, either by specifying their value or by copying them from the request. Multiple rules can be defined; their order is ignored. In any case of replicated header fields, multiple lines will be inserted; it is assumed that multiple occurrences are allowed for those fields. No syntax and consistency checks are performed on the resulting HTTP headers; only custom or non-critical fields should be used. The header names involved are always converted to lower case.

**Default:**

```
{"add":[{"name":"X-Accel-Buffering","value":"no"}],"echo":null}
```

### [servers.http-server.responseHttpHeaders.add]

Optional. Requests to add to the HTTP response header a line with the specified `name` (mandatory) and `value` (optional). The suggested setting for "X-Accel-Buffering" may help to enable streaming support when proxies of several types are involved.

**Default:**

```
[{"name":"X-Accel-Buffering","value":"no"}]
```

### [servers.http-server.responseHttpHeaders.echo]

Optional. Requests to look for any header lines for  the specified field name on the HTTP request header and to copy them to the HTTP response header.

**Default:** []

### [servers.http-server.sslConfig]

Mandatory if `enableHttps` is `true`. TLS/SSL settings for this socket configuration

**Default:**

```
{"allowCipherSuites":[],"allowProtocols":[],"enableClientAuth":null,"enableClientHintsForTlsSessionResumption":null,"enableMandatoryClientAuth":null,"enableStatelessTlsSessionResumption":null,"enableTlsRenegotiation":null,"enforceServerCipherSuitePreference":{"enabled":true,"order":"JVM"},"keyStoreRef":"myServerKeystore","removeCipherSuites":[],"removeProtocols":["SSL","TLSv1$","TLSv1.1"],"tlsProvider":null,"tlsSessionCacheSize":null,"tlsSessionTimeoutSeconds":null,"trustStoreRef":null}
```

### [servers.http-server.sslConfig.allowCipherSuites]

Optional, but forbidden if `removeCipherSuites` is used. Specifies all the cipher suites allowed for the TLS/SSL interaction, provided that they are included, with the specified name, in the set of of "supported" cipher suites of the underlying Security Provider. The default set of the "supported" cipher suites is logged at startup by the `lightstreamerLogger.io.ssl` logger at DEBUG level. If not used, the `removeCipherSuites` setting is considered; hence, if `removeCipherSuites` is also not used, all cipher suites enabled by the Security Provider will be available. The order in which the cipher suites are specified can be enforced as the server-side preference order (see `enforceServerCipherSuitePreference`).

**Default:** []

### [servers.http-server.sslConfig.allowProtocols]

Optional, but forbidden if `removeProtocols` is used. Specifies one or more protocols allowed for the TLS/SSL interaction, among the ones supported by the underlying Security Provider. For Oracle JVMs, the available names are the "SSLContext Algorithms" listed here: https://docs.oracle.com/en/java/javase/17/docs/specs/security/standard-names.html#sslcontext-algorithms `removeProtocols` is also not used, all protocols enabled by the Security Provider will be available.

**Default:**

```
the removeProtocols setting is considered; hence, if
```

### [servers.http-server.sslConfig.enableClientAuth]

Optional. Request to provide the Metadata Adapter with the "principal" included in the client TLS/SSL certificate, when available. If set to `true`, upon each client connection, the availability of a client TLS/SSL certificate is checked. If available, the included identification data will be supplied upon calls to notifyUser. If set to `false`, no certificate information is supplied to notifyUser and no check is done on the client certificate. Note that a check on the client certificate can also be requested through `enableMandatoryClientAuth`.

**Default:** false

### [servers.http-server.sslConfig.enableClientHintsForTlsSessionResumption]

Optional. If set to `true`, tries to improve the TLS session resumption feature by providing the underlying Security Provider with information on the client IPs and ports. This makes sense only if client IPs can be determined (see the <client_identification> block).

**Default:** false

### [servers.http-server.sslConfig.enableMandatoryClientAuth]

Optional. Request to only allow clients provided with a valid TLS/SSL certificate. If set to `true`, upon each client connection, a valid TLS/SSL certificate is requested to the client in order to accept the connection. If set to `false`, no check is done on the client certificate. Note that a certificate can also be requested to the client as a consequence of `enableClientAuth`.

**Default:** false

### [servers.http-server.sslConfig.enableStatelessTlsSessionResumption]

Optional. Instructs the underlying Security Provider on whether to use stateless (when `true`) or stateful (when `false`) session resumption on this port, if supported (possibly depending on the protocol version in use). Note that stateful resumption implies the management of a TLS session cache, whereas stateless resumption is slightly more demanding in terms of CPU and bandwidth. Note, however, that this setting is currently supported only if the Conscrypt Security Provider is used. For instance, with the default SunJSSE Security Provider, the use of stateful or stateless resumption can only be configured at global JVM level, through the "jdk.tls.server.enableSessionTicketExtension" JVM property. Security Provider, based on its own configuration.

**Default:**

```
the type of resumption will be  decided by the underlying
```

### [servers.http-server.sslConfig.enableTlsRenegotiation]

Optional. If set to `false`, causes any client-initiated TLS  renegotiation request to be refused by closing the connection. This policy may be evaluated in a trade-off between encryption strength and performance risks. Note that, with the default SunJSSE Security Provider, a better way to achieve the same at a global JVM level is by setting the dedicated "jdk.tls.rejectClientInitiatedRenegotiation" JVM property to `true`.

**Default:** true

### [servers.http-server.sslConfig.enforceServerCipherSuitePreference]

Optional. Determines which side should express the preference when multiple cipher suites are in common between server and client. Note, however, that the underlying Security Provider may ignore this setting. This is the case, for instance, of the Conscrypt provider.

**Default:**

```
{"enabled":true,"order":"JVM"}
```

### [servers.http-server.sslConfig.enforceServerCipherSuitePreference.enabled]

Optional. If set to `true`, the Server will choose the cipher suite based on its preference order, specified through `order`. If set to `false`, the Server will get a cipher suite based on the preference order specified by the client. For instance, the client might privilege faster, but weaker, suites.

**Default:** false

### [servers.http-server.sslConfig.enforceServerCipherSuitePreference.order]

@default "JVM"

**Default:** `"JVM"`

### [servers.http-server.sslConfig.keyStoreRef]

Mandatory. The reference to a keystore configuration. See the `keyStores.myServerKeystore` settings for general details on keystore configuration.

**Default:** `"myServerKeystore"`

### [servers.http-server.sslConfig.removeCipherSuites]

Optional, but forbidden if `allowCipherSuites` is used. Pattern to be matched against the names of the enabled cipher suites in order to remove the matching ones from the enabled cipher suites set. Any pattern in java.util.regex.Pattern format can be specified. This allows for customization of the choice of the cipher suites to be used for incoming https connections (note that reducing the set of available cipher suites may cause some client requests to be refused). When this setting is used, the server-side preference order of the cipher suites is determined by the underlying Security Provider. Note that the selection is operated on the default set of the cipher suites "enabled" by the Security Provider, not on the wider set of the "supported" cipher suites. The default set of the "enabled" cipher suites is logged at startup by the `lightstreamerLogger.io.ssl` logger at DEBUG level. -->

**Default:** []

### [servers.http-server.sslConfig.removeProtocols]

Optional, but forbidden if `allowProtocols` is used. Pattern to be matched against the names of the enabled TLS/SSL protocols in order to remove the matching ones from the enabled protocols set. Any pattern in java.util.regex.Pattern format can be specified. This allows for customization of the choice of the TLS/SSL protocols to be used for an incoming https connection (note that reducing the set of available protocols may cause some client requests to be refused). Note that the selection is operated on the default set of the protocols "enabled" by the Security Provider, not on the wider set of the "supported" protocols. The default set of the "enabled" protocols is logged at startup by the `lightstreamerLogger.io.ssl` logger at DEBUG level.

**Default:** []

### [servers.http-server.sslConfig.tlsProvider]

Optional. If defined, overrides the default JVM's Security Provider configured in the java.security file of the JDK installation. This allows the use of different Security Providers dedicated to single listening ports. When configuring a Security Provider, the related libraries should be added to the Server classpath. This is not needed for the Conscrypt provider, which is already available in the Server distribution (but note that the library includes native code that only targets the main platforms). java.security file of the JDK installation.

**Default:**

```
the default JVM's Security Provider configured in the
```

### [servers.http-server.sslConfig.tlsSessionCacheSize]

Optional. Size of the cache used by the TLS implementation to handle TLS session resumptions when stateful resumption is configured (see `enableStatelessTlsSessionResumption`). A value of 0 poses no size limit. Note, however, that the underlying Security Provider may ignore this setting (possibly depending on the protocol version in use). Provider. For the default SunJSSE, it is 20480 TLS sessions, unless configured through the "javax.net.ssl.sessionCacheSize" JVM property.

**Default:**

```
the cache size is decided by the underlying Security
```

### [servers.http-server.sslConfig.tlsSessionTimeoutSeconds]

Optional. Maximum time in which a TLS session is kept available to the client for resumption. This holds for both stateless and stateful TLS resumption (see `enableStatelessTlsSessionResumption`). In the latter case, the session also has to be kept in a cache. A value of 0 poses no time limit. Note, however, that the underlying Security Provider may ignore this setting (possibly depending of the protocol version in use). Provider. For the default SunJSSE, it is 86400 seconds, unless configured through the "jdk.tls.server.sessionTicketTimeout" JVM property

**Default:**

```
the maximum time is decided by the underlying Security
```

### [servers.http-server.sslConfig.trustStoreRef]

Mandatory when at least one of `enableClientAuth` and `enableMandatoryClientAuth` is set to `true`. The reference to a  keystore to be used by the HTTPS service to accept client certificates. It can be used to supply client certificates that should be accepted, in addition to those with a valid certificate chain, for instance while testing with self-signed certificates. See the `keyStores.myServerKeystore` settings for general details on keystore configuration. Note that the further constraints reported there with regard to accessing the certificates in a JKS keystore don't hold in this case, where the latter is used as a truststore. Moreover, the handling of keystore replacement doesn't apply here.

**Default:** `nil`

### [service]

Mandatory. Lightstreamer Service configuration (https://kubernetes.io/docs/concepts/services-networking/service/).

**Default:**

```
{"additionalSelectors":{"mode":"active"},"annotations":{},"labels":{},"loadBalancerClass":null,"name":"lightstreamer-service","nodePort":null,"port":8080,"targetPort":"http-server","type":null}
```

### [service.additionalSelectors]

Additional selectors

**Default:** `{"mode":"active"}`

### [service.annotations]

Additional Service annotations

**Default:** `{}`

### [service.labels]

Additional Service labels

**Default:** `{}`

### [service.loadBalancerClass]

The load balancer implementation when the `type` is set to `LoadBalancer` (https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-class)

**Default:** `nil`

### [service.name]

The name of the service port

**Default:** `"lightstreamer-service"`

### [service.nodePort]

The node port when the `type` is set to `NodePort` or 'LoadBalancer' (https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport)

**Default:** `nil`

### [service.port]

The port exposed by the service  (https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports)

**Default:** `8080`

### [service.targetPort]

The reference to a server socket configuration (see `servers` section  below)

**Default:** `"http-server"`

### [service.type]

The service type (https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)

**Default:** `nil`

### [serviceAccount]

Service Account settings (https://kubernetes.io/docs/concepts/security/service-accounts/)

**Default:**

```
{"annotations":{},"automount":true,"create":false,"name":""}
```

### [serviceAccount.annotations]

Annotations to add to the service account

**Default:** `{}`

### [serviceAccount.automount]

Specifies whether a service account should automatically mount a ServiceAccount's API credentials

**Default:** `true`

### [serviceAccount.create]

Specifies whether a service account should be created

**Default:** `false`

### [serviceAccount.name]

The name of the service account to use. If not set and `create` is true, a name is generated using the fullname template.

**Default:** `""`

### [webServer]

Optional. Internal web server configuration. Note that some of the included settings may also apply to the Monitoring Dashboard pages, which are supplied through the internal web server. In particular, this holds for the `webServer.compressionThreshold` settings. Anyway, this does not hold for the `webServer.enabled` setting, as the Monitoring Dashboard accessibility is only configured through `management.dashboard`.

**Default:**

```
{"compressionThreshold":null,"enableFlexCrossdomain":false,"enableSilverlightAccessPolicy":null,"enabled":true,"flexCrossdomainPath":null,"mimeTypesConfig":null,"notFoundPage":null,"pagesDir":null,"persistencyMinutes":null,"silverlightAccessPolicyPath":null}
```

### [webServer.compressionThreshold]

Optional. Size of the resource contents below which compression is not applied, regardless of the `webServer.compression.default` setting, as we guess that no overall benefit would be reached.

**Default:** 8192

### [webServer.enableFlexCrossdomain]

Optional. Enables the processing of the "/crossdomain.xml" URL, required by the Flash player in order to allow pages from a different host to request data to Lightstreamer Server host. See the "WebSite Controls" section on http://www.adobe.com/devnet/flashplayer/articles/flash_player_9_security.pdf for details on the contents of the document to be returned. If set to `true`, the Server accepts requests for "/crossdomain.xml"; the file configured through the `webServer.flexCrossdomainPath` setting is returned. Enabling internal web server (through `webServer.enabled`) is not needed; note that if the internal web server is enabled, the processing of the "/crossdomain.xml" URL is different than the processing of the other URLs. If set to `false`, no special processing for the "/crossdomain.xml" requests is performed. Note that if the internal web server is enabled, then the processing of the "/crossdomain.xml" URL is performed as for any other URL (i.e. a file named "crossdomain.xml" is looked for in the directory configured as the root for URL path mapping). Note that "/crossdomain.xml" is also used by the Silverlight runtime when "/clientaccesspolicy.xml" is not provided.

**Default:** false

### [webServer.enableSilverlightAccessPolicy]

Optional. Enables the processing of the "/clientaccesspolicy.xml" URL, required by the Silverlight runtime in order to allow pages from a different host to request data to Lightstreamer Server host. See http://msdn.microsoft.com/en-us/library/cc838250(VS.95).aspx#crossdomain_communication for details on the contents of the document to be returned. If set to `true`, the Server accepts requests for "/clientaccesspolicy.xml"; the file configured through the `webServer.silverlightAccessPolicyPath` setting is returned. Enabling internal web server (through `webServer.enabled`) is not needed; note that if the internal web server is enabled, the processing of the  "/clientaccesspolicy.xml" URLis different than the processing of the other URLs. If set to `false`, no special processing for the "/clientaccesspolicy.xml" requests is performed. Note that if the internal web server is enabled, then the processing of the  "/clientaccesspolicy.xml" URL is performed as for any other URL (i.e. a file named "clientaccesspolicy.xml" is looked for in the directory configured as the root for URL path mapping). Note that "/crossdomain.xml" is also used by the Silverlight runtime when "/clientaccesspolicy.xml" is not provided.

**Default:** false

### [webServer.enabled]

Optional. Enabling of the internal web server. If set to `true`, the Server accepts requests for file resources. If set  to `false`, the Server ignores requests for file resources.

**Default:** false

### [webServer.flexCrossdomainPath]

Mandatory when `webServer.enableFlexCrossdomain` is true. Path of the file to be returned upon requests for the "/crossdomain.xml" URL. It is ignored when `webServer.enableFlexCrossdomain` is false. The file content should be encoded with the iso-8859-1 charset. The file path is relative to the conf directory.

**Default:** `nil`

### [webServer.mimeTypesConfig]

Optional. Path of the MIME types configuration property file. The file path is relative to the conf directory.

**Default:**  ./mime_types.properties

### [webServer.notFoundPage]

Optional. Path of an HTML page to be returned as the body upon a "404 Not Found" answer caused by the request of a nonexistent URL. The file content should be encoded with the iso-8859-1 charset. The file path is relative to the conf directory.

**Default:**

```
the proper page is provided by the Server
```

### [webServer.pagesDir]

Optional. Path of the file system directory to be used by the internal web server as the root for URL path mapping. The path is relative to the conf directory. Note that the /lightstreamer URL path (as any alternative paths defined through `pushSession.serviceUrlPrefix`) is reserved, as well as the base URL path of the Monitoring Dashboard(see `management.dashboard.urlPath`); hence, subdirectories of the pages directory with conflicting names would be ignored.

**Default:** ../pages

### [webServer.persistencyMinutes]

Optional. Caching time, in minutes, to be allowed to the browser (through the "expires" HTTP header) for all the resources supplied by the internal web server. A zero value disables caching by the browser.

**Default:** 0

### [webServer.silverlightAccessPolicyPath]

Mandatory when `web.enableSilverlightAccessPolicy` is `true`. Path of the file to be returned upon requests for the "/clientaccesspolicy.xml" URL. It is ignored when `web.enableSilverlightAccessPolicy` is false. The file content should be encoded with the iso-8859-1 charset. The file path is relative to the conf directory.

**Default:** `nil`

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)