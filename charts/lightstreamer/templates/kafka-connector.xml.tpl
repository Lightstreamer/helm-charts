{{/* Render the truststore settings for the Lightstreamer Kafka Connector configuration file */}}
{{- define "lightstreamer.kafka-connector.configuration.truststore" -}}
{{- $prefix := index . 0 -}}
{{- $top := index . 1 -}}
{{- $key := index . 2 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}

<param name="{{ $prefix }}.path">../../conf/keystores/{{ $key }}/{{ required (printf "keystores.%s.keystoreFileSecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

<!-- Optional. The password of the trust store.

      If not set, checking the integrity of the trust store file configured will not
      be possible. -->
<param name="{{ $prefix }}.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

{{- if not (quote $keyStore.type | empty) }}
<param name="{{ $prefix }}.type">{{ $keyStore.type }}</param>
{{- end -}}
{{- end -}}

{{/* Render the keystore settings for the Lightstreamer Kafka Connector configuration file */}}
{{- define "lightstreamer.kafka-connector.configuration.keystore" -}}
{{- $prefix := index . 0 -}}
{{- $top := index . 1 -}}
{{- $key := index . 2 -}}
{{- $keyStore := required (printf "keystores.%s not defined" $key) (get $top $key) -}}
<!-- Optional. Enable a key store. Can be one of the following:
      - true
      - false

     A key store is required if the mutual TLS is enabled on Kafka.

     If enabled, the following parameters configure the key store settings:
     - encryption.keystore.path
     - encryption.keystore.password
     - encryption.keystore.key.password

     Defalt value: false. -->
<param name="{{ $prefix }}.enable">true</param>

<!-- Mandatory if key store is enabled. The path of the key store file, relative to
     the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>). -->
<param name="{{ $prefix }}.path">../../conf/keystores/{{ $key }}/{{ required (printf "keystores.%s.keystoreFilesecretRef.key must be set" $key) ($keyStore.keystoreFileSecretRef).key }}</param>

<!-- Optional. The password of the key store.

     If not set, checking the integrity of the key store file configured
     will not be possible. -->
<param name="{{ $prefix }}.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_PASSWORD</param>

<!-- Optional. The password of the private key in the key store file. -->
{{- if $keyStore.keyPasswordSecretRef }}
<param name="{{ $prefix }}.key.password">$env.LS_KEYSTORE_{{ $key | upper |replace "-" "_" }}_KEY_PASSWORD</param>
{{- else }}
<!--
<param name="{{ $prefix }}.key.password">kafka-connector-private-key-password</param>
-->
{{- end }}

{{- if not (quote $keyStore.type | empty) }}
<param name="{{ $prefix }}.keystore.type">{{ $keyStore.type }}</param>
{{- end -}}
{{- end -}}

{{/* Create the Lightstreamer Kafka Connector configuration file */}}
{{- define "lightstreamer.kafka-connector.configuration" -}}
<?xml version="1.0"?>

<!--
    This is the configuration file of the Lightstreamer Kafka Connector pluggable into Lightstreamer Server.

    A very simple variable-expansion feature is available; see
    <enable_expansion_for_adapters_config> in the Server's main configuration file.
-->

<!-- Mandatory. Define the Kafka Connector Adapter Set and its unique ID. -->
{{- with .Values.connectors.kafkaConnector }}
<adapters_conf id={{ required "connectors.kafkaConnector.adapterSetId must be set" .adapterSetId | quote }}>
    <metadata_provider>
        <!-- Mandatory. Java class name of the Kafka Connector Metadata Adapter. It is possible to provide a
             custom implementation by extending this class. -->
        <adapter_class>{{ required "connectors.kafkaConnector.adapterClassName must be set" .adapterClassName }}</adapter_class>

        <!-- Mandatory. The path of the reload4j configuration file, relative to the deployment folder
             (LS_HOME/adapters/lightstreamer-kafka-connector). -->
        <param name="logging.configuration.path">log4j.properties</param>
    </metadata_provider>

    <!-- Mandatory. The Kafka Connector allows the configuration of different independent connections to different Kafka
         broker/clusters.

         Every single connection is configured via the definition of its own Lightstreamer Data Adapter. At least one connection
         configuration must be provided.

         Since the Kafka Connector manages the physical connection to Kafka by wrapping an internal Kafka Consumer, several
         configuration settings in the Data Adapter are identical to those required by the usual Kafka Consumer
         configuration.

         The Kafka Connector leverages the "name" attribute of the <data_provider> tag as the connection name, which will
         be used by the Clients to request real-time data from this specific Kafka connection through a Subscription object.

         The connection name is also used to group all logging messages belonging to the same connection.

         Its default value is "DEFAULT", but only one "DEFAULT" configuration is permitted. -->
    {{- range $key, $connection := .connections }}
    <data_provider name={{ required (printf "connectors.kafkaConnector.connections.%s.name must be set" $key) $connection.name | quote }}>
        <!-- ##### GENERAL PARAMETERS ##### -->

        <!-- Java class name of the Kafka Connector Data Adapter. DO NOT EDIT IT. -->
        <adapter_class>com.lightstreamer.kafka.adapters.KafkaConnectorDataAdapter</adapter_class>

        <!-- Optional. Enable this connection configuration. Can be one of the following:
             - true
             - false

             If disabled, Lightstreamer Server will automatically deny every subscription made to this connection.

             Default value: true. -->
        {{- if $connection.enabled }}
        <param name="enable">true</param>
        {{- else }}
        <!--
        <param name="enable">false</param>
        -->
        {{- end }} {{/* of .enabled */}}

        <!-- Mandatory. The Kafka Cluster bootstrap server endpoint expressed as the list of host/port pairs used to
             establish the initial connection.

             The parameter sets the value of the "bootstrap.servers" key to configure the internal Kafka Consumer.
             See https://kafka.apache.org/documentation/#consumerconfigs_bootstrap.servers for more details.
         -->
        <param name="bootstrap.servers">{{ required (printf "connectors.kafkaConnector.connections.%s.bootstrapServers must be set" $key) $connection.bootstrapServers }}</param>

        <!-- Optional. The name of the consumer group this connection belongs to.

             The parameter sets the value for the "group.id" key used to configure the internal
             Kafka Consumer. See https://kafka.apache.org/documentation/#consumerconfigs_group.id for more details.

             Default value: Adapter Set id + the Data Adapter name + randomly generated suffix. -->
      {{- if $connection.groupId }}
        <param name="group.id">{{ required (printf "connectors.kafkaConnector.connections.%s.groupId must be set" $key) $connection.groupId }}</param>
      {{- else }}
        <!--
        param name="group.id">kafka-connector-group</param>
        -->
      {{- end }} {{/* of .groupId */}}

        <!-- ##### ENCRYPTION SETTINGS ##### -->
      {{- with $connection.sslConfig }}

        <!-- A TCP secure connection to Kafka is configured through parameters with
             the `encryption` prefix. -->

        <!-- Optional. Enable encryption of this connection. Can be one of the following:
             - true
             - false

             Default value: false. -->
        {{- if .enable }}
        <param name="encryption.enable">true</param>
        {{- else }}
        <!--
        <param name="encryption.enable">true</param>
        -->
        {{- end }} {{/* of .enable */}}

        <!-- Optional. The SSL protocol to be used. Can be one of the following:
             - TLSv1.2
             - TLSv1.3

             Default value: TLSv1.3 when running on Java 11 or newer, TLSv1.2 otherwise. -->
        {{- if .protocol }}
          {{- if not (mustHas .protocol (list "TLSv1.2" "TLSv1.3")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.sslConfig.protocol must be one of \"TLSv1.2\", \"TLSv1.3\"" $key) }}
          {{- end }}
        <param name="encryption.protocol">{{ .protocol }}</param>
        {{- else }}
        <!--
        <param name="encryption.protocol">TLSv1.2</param>
        -->
        {{- end }} {{/* of .protocol */}}

        <!-- Optional. The list of enabled secure communication protocols.

             Default value: TLSv1.2,TLSv1.3 when running on Java 11 or newer, `TLSv1.2` otherwise. -->
        {{- if .allowedProtocols }}
          {{- range $protocol := .allowedProtocols}}
            {{- if not (mustHas $protocol (list "TLSv1.2" "TLSv1.3")) }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.sslConfig.allowedProtocols must be a list of \"TLSv1.2\", \"TLSv1.3\"" $key) }}
            {{- end }}
          {{- end }}
        <param name="encryption.enabled.protocols">{{ join "," .allowedProtocols }}</param>
        {{- else }}
        <!--
        <param name="encryption.enabled.protocols">TLSv1.3</param>
        -->
        {{- end }} {{/* of .allowedProtocols */}}

        <!--Optional. The list of enabled secure cipher suites.

            Default value: all the available cipher suites in the running JVM. -->
        {{- if .allowedCipherSuites }}
          {{- range $cipherSuite := .allowedCipherSuites}}
            {{- if $cipherSuite | empty }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.sslConfig.allowedCipherSuites must be a list of valid values" $key) }}
            {{- end }}
          {{- end }}
        <param name="encryption.cipher.suites">{{ join "," .allowedCipherSuites }}</param>
        {{- else }}
        <!--
        <param name="encryption.cipher.suites">TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA</param>
        -->
        {{- end }} {{/* of .allowedCipherSuites */}}

        <!-- Optional. Enable hostname verification. Can be one of the following:
             - true
             - false

             Default value: false. -->
        {{- if .enableHostnameVerification }}
        <param name="encryption.hostname.verification.enable">true</param>
        {{- else }}
        <!--
        <param name="encryption.hostname.verification.enable">true</param>
        -->
        {{- end }} {{/* of .enableHostnameVerification */}}

        <!-- Optional. The path of the trust store file, relative to the deployment folder
             (LS_HOME/adapters/lightstreamer-kafka-connector-<version>). -->
        {{- if .trustStoreRef}}
          {{- include "lightstreamer.kafka-connector.configuration.truststore" (list "encryption.truststore" $.Values.keyStores .trustStoreRef)  | nindent 8 }}
        {{- else }}
        <!--
        <param name="encryption.truststore.path">secrets/kafka-connector.truststore.jks</param>
        -->

        <!-- Optional. The password of the trust store.

             If not set, checking the integrity of the trust store file configured will not
             be possible. -->
        <!--
        <param name="encryption.truststore.password">kafka-connector-truststore-password</param>
        -->
        {{- end }} {{/* of .trustStoreRef */}}

        {{- if .keyStoreRef }}
          {{- include "lightstreamer.kafka-connector.configuration.keystore" (list "encryption.keystore" $.Values.keyStores .keyStoreRef)  | nindent 8 }}
        {{- else }}
        <!-- Optional. Enable a key store. Can be one of the following:
             - true
             - false

            A key store is required if the mutual TLS is enabled on Kafka.

            If enabled, the following parameters configure the key store settings:
            - encryption.keystore.path
            - encryption.keystore.password
            - encryption.keystore.key.password

            Defalt value: false. -->
        <!--
        <param name="encryption.keystore.enable">true</param>
        -->

        <!-- Mandatory if key store is enabled. The path of the key store file, relative to
             the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>). -->
        <!--
        <param name="encryption.keystore.path">secrets/kafka-connector.keystore.jks</param>
        -->

        <!-- Optional. The password of the key store.

             If not set, checking the integrity of the key store file configured
             will not be possible. -->
        <!--
        <param name="encryption.keystore.password">kafka-connector-password</param>
        -->

        <!-- Optional. The password of the private key in the key store file. -->
        <!--
        <param name="encryption.keystore.key.password">kafka-connector-private-key-password</param>
        -->
        {{- end }} {{/* of .enableKeyStore */}}
      {{- end }} {{/* of .sslConfig */}}

        <!-- ##### AUTHENTICATION SETTINGS ##### -->
      {{- with $connection.authentication }}

        <!-- Broker authentication is configured through parameters with the
             `authentication` prefix. -->

        <!-- Optional. Enable the authentication of this connection against the Kafka Cluster.
             Can be one of the following:
             - true
             - false

             Default value: false. -->
        {{- if .enabled }}
        <param name="authentication.enable">true</param>

        <!-- Mandatory if authentication is enabled. The SASL mechanism type.
             The Kafka Connector accepts the following authentication mechanisms:

             - PLAIN
             - SCRAM-SHA-256
             - SCRAM-SHA-512
             - GSSAPI

             Default value: PLAIN.-->
          {{- if not (quote .mechanism | empty )}}
            {{- if not (mustHas .mechanism (list "PLAIN" "SCRAM-SHA-256" "SCRAM-SHA-512" "GSSAPI")) }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.authentication.mechanism must be one of \"PLAIN\", \"SCRAM-SHA-256\", \"SCRAM-SHA-512\", \"GSSAPI\"" $key) }}
            {{- end }}
        <param name="authentication.mechanism">{{ .mechanism }}</param>
          {{- else }}
        <!--
        <param name="authentication.mechanism">PLAIN</param>
        -->
          {{- end }} {{/* of .mechanism */}}

        <!-- Mandatory if authentication.mechanism is one of PLAIN, SCRAM-SHA-256, SCRAM-SHA-512. The credentials. -->
          {{- if has (.mechanism | default "PLAIN") (list "PLAIN" "SCRAM-SHA-256" "SCRAM-SHA-512") }}
        <param name="authentication.username">$env.LS_KAFKA_PLAIN_AUTH_{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.credentialsSecretRef must be set" $key) .credentialsSecretRef | upper | replace "-" "_" }}_USERNAME</param>
        <param name="authentication.password">$env.LS_KAFKA_PLAIN_AUTH_{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.credentialsSecretRef must be set" $key) .credentialsSecretRef | upper | replace "-" "_" }}_PASSWORD</param>
          {{- else }}
        <!--
        <param name="authentication.username">authorized-kafka-user</param>
        <param name="authentication.password">authorized-kafka-user-password</param>
        -->
          {{- end }} {{/* of .mechanism */}}

        <!-- ##### GSSAPI AUTHENTICATION SETTINGS ##### -->
          {{- if eq .mechanism "GSSAPI"}}
            {{- with required "connectors.kafkaConnector.connections.%s.authentication.gssapi must be set" .gssapi }}

        <!-- In the case of GSSAPI authentication mechanism, the following parameters will be part of
             the authentication configuration. -->

        <!-- Optional. Enable the use of a keytab. Can be one of the following:
            - true
            - false

             Default value: false. -->
              {{- if .enableKeytab }}
        <param name="authentication.gssapi.key.tab.enable">true</param>
              {{- else }}
        <!--
        <param name="authentication.gssapi.key.tab.enable">true</param>
        -->
              {{- end }} {{/* of .enableKeytab */}}

        <!-- Mandatory if keytab is enabled. The path to the kaytab file, relative to
             the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>). -->
              {{- if .keytabFilePathRef }}
        <param name="authentication.gssapi.key.tab.path">./keytabs/{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.gssapi.keytabFilePathRef.key must be set" $key) .keytabFilePathRef.key }}</param>
              {{- else }}
                {{- if .enableKeytab }}
                  {{- fail (printf "connectors.kafkaConnector.connections.%s.authentication.gssapi.keytabRef must be set" $key) }}
                {{- end }}
        <!--
        <param name="authentication.gssapi.key.tab.path">gssapi/kafka-connector.keytab</param>
        -->
              {{- end }} {{/* of .keytabRef */}}

        <!--  Optional. Enable storage of the principal key. Can be one of the following:
            - true
            - false

            Default value: false- -->
              {{- if .enableStoreKey }}
        <param name="authentication.gssapi.store.key.enable">true</param>
              {{- else }}
        <!--
        <param name="authentication.gssapi.store.key.enable">true</param>
        -->
              {{- end }} {{/* of .enableStoreKey */}}

        <!-- Mandatory. The name of the Kerberos service. -->
        <param name="authentication.gssapi.kerberos.service.name">{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.gssapi.kerberosServiceName must be set" $key) .kerberosServiceName }}</param>

        <!-- Mandatory. if ticket cache is disabled. The name of the principal to be used. -->
              {{- if .principal }}
        <param name="authentication.gssapi.principal">{{ .principal }}</param>
              {{- else }}
                {{- if .enableTicketCache }}
                  {{- fail (printf "Either set connectors.kafkaConnector.connections.%s.authentication.gssapi.principal or disable connectors.kafkaConnector.connections.%s.authentication.gssapi.enableTicketCache" $key $key) }}
                {{- end }}
        <!--
        <param name="authentication.gssapi.principal">kafka-connector-1@LIGHTSTREAMER.COM</param>
        -->
              {{- end }} {{/* of .principal */}}

        <!-- Optional. Enable the use of a ticket cache. Can be one of the following:
             - true
             - false

             Default value: false. -->
              {{- if .enableTicketCache }}
        <param name="authentication.gssapi.ticket.cache.enable">true</param>
              {{- else }}
        <!--
        <param name="authentication.gssapi.ticket.cache.enable">true</param>
        -->
              {{- end }} {{/* of .enableTicketCache */}}
            {{- end }} {{/* of .gssapi */}}
          {{- end }}
        {{- else }}
        <!--
        <param name="authentication.enable">true</param>
        -->
        {{- end }} {{/* of .authentication.enable */}}
      {{- end }} {{/* of .authentication */}}

        <!-- ##### RECORD EVALUATION SETTINGS ##### -->

      {{- with $connection.record }}
        <!-- Optional. Specifies where to start consuming events from:
             - LATEST: start consuming events from the end of the topic partition
             - EARLIEST: start consuming events from the beginning of the topic partition

             Default value: LATEST. -->
        {{- if .consumeFrom }}
          {{- if not (mustHas .consumeFrom (list "EARLIEST" "LATEST")) }}
             {{- fail (printf "connectors.kafkaConnector.connections.%s.record.consumeFrom must be one of \"EARLIEST\", \"LATEST\"" $key) }}
          {{- end }}
        <param name="record.consume.from">{{ .consumeFrom }}</param>
        {{- else }}
        <!--
        <param name="record.consume.from">EARLIEST</param>
        -->
        {{- end }} {{/* of .consumeFrom */}}

        <!-- Optional. The number of threads to be used for concurrent processing of the
             incoming deserialized records. If set to `-1`, the number of threads will be automatically
             determined based on the number of available CPU cores.

             Default value: 1. -->
        {{- if not ( quote .consumeWithThreadNumber | empty) }}
          {{- if or ( eq (int .consumeWithThreadNumber) -1 ) (gt (int .consumeWithThreadNumber) 0) }}
        <param name="record.consume.with.num.threads">{{ .consumeWithThreadNumber }}</param>
          {{- else }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.record.consumeWithThreadNumber must be set with a valid value" $key) }}
          {{- end }}
        {{- else }}
        <!--
        <param name="record.consume.with.num.threads">4</param>
        -->
        {{- end }} {{/* of .consumeWithThreadNumber */}}

        <!-- Optional but only effective if "record.consume.with.num.threads" is set to a value greater than 1 (which includes hte default value).
             The order strategy to be used for concurrent processing of the incoming
             deserialized records. Can be one of the following:

             - ORDER_BY_PARTITION: maintain the order of records within each partition
             - ORDER_BY_KEY: maintain the order among the records sharing the same key
             - UNORDERED: provide no ordering guarantees

             Default value: ORDER_BY_PARTITION. -->
        {{- if .consumeWithOrderStrategy }}
          {{- if not (mustHas .consumeWithOrderStrategy (list "ORDER_BY_PARTITION" "ORDER_BY_KEY" "UNORDERED")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.record.consumeWithOrderStrategy must be one of \"ORDER_BY_PARTITION\", \"ORDER_BY_KEY\", \"UNORDERED\"" $key) }}
          {{- else }}
        <param name="record.consume.with.order.strategy">{{ .consumeWithOrderStrategy }}</param>
          {{- end }}
        {{- else }}
        <!--
        <param name="record.consume.with.order.strategy">ORDER_BY_KEY</param>
        -->
        {{- end }} {{/* of .consumeWithOrderStrategy */}}

        <!-- Optional. The format to be used to deserialize the key a Kafka record.
             Can be one of the following:
             - AVRO
             - JSON
             - STRING
             - INTEGER
             - BOOLEAN
             - BYTE_ARRAY
             - BYTE_BUFFER
             - BYTES
             - DOUBLE
             - FLOAT
             - LONG
             - SHORT
             - UUID

             Default: STRING -->
        {{- with .keyEvaluator }}
          {{- if .type }}
            {{- if not (mustHas .type (list "AVRO" "JSON" "STRING" "INTEGER" "BOOLEAN" "BYTE_ARRAY" "BYTE_BUFFER" "BYTES" "DOUBLE" "FLOAT" "LONG" "SHORT" "UUID")) }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.record.keyEvaluator.type must be one of \"AVRO\", \"JSON\", \"STRING\", \"INTEGER\", \"BOOLEAN\", \"BYTE_ARRAY\", \"BYTE_BUFFER\", \"BYTES\", \"DOUBLE\", \"FLOAT\", \"LONG\", \"SHORT\", \"UUID\"" $key) }}
            {{- else }}
        <param name="record.key.evaluator.type">{{ .type }}</param>
            {{- end }}
          {{- else }}
        <!--
        <param name="record.key.evaluator.type">INTEGER</param>
        -->
          {{- end }} {{/* of .type */}}

        <!-- Mandatory if evaluator type is AVRO and the Confluent Schema Registry is disabled. The path of the local schema
             file relative to the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>) for
             message validation of the key. -->
          {{- with .localSchemaFilePathRef }}
            {{ $localSchema := required (printf "localSchemaFiles.%s not defined" . ) (get ($.Values.connectors.kafkaConnector.localSchemaFiles | default dict) .) }}
        <param name="record.key.evaluator.schema.path">schemas/{{ . }}/{{ required (printf "connectors.kafkaConnector.localSchemaFiles.%s.key must be set" .) $localSchema.key }}</param>
          {{- else }}
            {{- if and (eq .type "AVRO") (not .enableSchemaRegistry) }}
              {{- fail (printf "Either set connectors.kafkaConnector.connections.%s.record.keyEvaluator.localSchemaFilePathRef.key or enable connectors.kafkaConnector.connections.%s.record.keyEvaluator.enableSchemaRegistry" $key $key) }}
            {{- else }}
        <!--
        <param name="record.key.evaluator.schema.path">schema/record_key.avsc</param>
        -->
            {{- end }}
          {{- end }} {{/* of .localSchemaFilePathRef */}}

        <!-- Mandatory if evaluator type is AVRO and no local schema paths are specified. Enable the use of the Confluent Schema Registry for validation respectively of the key.
             Can be one of the following:
             - true
             - false

             Default value: false. -->
          {{- if and .enableSchemaRegistry (not (.localSchemaFilePathRef)) }}
        <param name="record.key.evaluator.schema.registry.enable">true</param>
          {{- else }}
        <!--
        <param name="record.key.evaluator.schema.registry.enable">true</param>
        -->
          {{- end }} {{/* of .enableSchemaRegistry */}}
        {{- end }} {{/* of .keyEvaluator */}}

        <!-- Optional. The format to be used to deserialize the key of a Kafka record.
             Can be one of the following:
             - AVRO
             - JSON
             - STRING
             - INTEGER
             - BOOLEAN
             - BYTE_ARRAY
             - BYTE_BUFFER
             - BYTES
             - DOUBLE
             - FLOAT
             - LONG
             - SHORT
             - UUID

             Default: STRING -->
        {{- with .valueEvaluator }}
          {{- if .type }}
            {{- if not (mustHas .type (list "AVRO" "JSON" "STRING" "INTEGER" "BOOLEAN" "BYTE_ARRAY" "BYTE_BUFFER" "BYTES" "DOUBLE" "FLOAT" "LONG" "SHORT" "UUID")) }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.record.valueEvaluator.type must be one of \"AVRO\", \"JSON\", \"STRING\", \"INTEGER\", \"BOOLEAN\", \"BYTE_ARRAY\", \"BYTE_BUFFER\", \"BYTES\", \"DOUBLE\", \"FLOAT\", \"LONG\", \"SHORT\", \"UUID\"" $key) }}
            {{- else }}
        <param name="record.value.evaluator.type">{{ .type }}</param>
            {{- end }}
          {{- else }}
        <!--
        <param name="record.value.evaluator.type">STRING</param>
        -->
          {{- end }} {{/* of .type */}}

        <!-- Mandatory if evaluator type is AVRO and the Confluent Schema Registry is disabled. The path of the local schema
             file relative to the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>) for
             message validation of the the value. -->
          {{- with .localSchemaFilePathRef }}
            {{ $localSchema := required (printf "kafkaConnector.localSchemaFiles.%s not defined" . ) (get ($.Values.connectors.kafkaConnector.localSchemaFiles | default dict) .) }}
        <param name="record.value.evaluator.schema.path">schemas/{{ . }}/{{ required (printf "connectors.kafkaConnector.localSchemaFiles.%s.key must be set" .) $localSchema.key }}</param>
          {{- else }}
            {{- if and (eq .type "AVRO") (not .enableSchemaRegistry) }}
              {{- fail (printf "Either set connectors.kafkaConnector.connections.%s.record.keyEvaluator.localSchemaFilePathRef.key or enable connectors.kafkaConnector.connections.%s.record.keyEvaluator.enableSchemaRegistry" $key $key) }}
            {{- else }}
        <!--
        <param name="record.value.evaluator.schema.path">schema/record_value.avsc</param>
        -->
            {{- end }}
          {{- end }} {{/* of .localSchemaFilePathRef */}}

        <!-- Mandatory if evaluator type is AVRO and no local schema paths are specified. Enable the use of the Confluent Schema Registry for validation respectively of the value.
             Can be one of the following:
             - true
             - false

             Default value: false. -->
          {{- if and .enableSchemaRegistry (not (.localSchemaFilePathRef)) }}
        <param name="record.value.evaluator.schema.registry.enable">true</param>
          {{- else }}
        <!--
        <param name="record.value.evaluator.schema.registry.enable">true</param>
        -->
          {{- end }} {{/* of .enableSchemaRegistry */}}
        {{- end }} {{/* of .valueEvaluator */}}

        <!-- Optional. The error handling strategy to be used if an error occurs while extracting data from incoming
             deserialized records.
             Can be one of the following:
             - IGNORE_AND_CONTINUE: ignore the error and continue to process the next record
             - FORCE_UNSUBSCRIPTION: stop processing records and force unsubscription of the items
                                     requested by all the Lightstreamer clients subscribed to this connection

             Default: "IGNORE_AND_CONTINUE". -->
        {{- if .extractionErrorStrategy }}
          {{- if not (mustHas .extractionErrorStrategy (list "IGNORE_AND_CONTINUE" "FORCE_UNSUBSCRIPTION")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.record.extractionErrorStrategy must be one of \"IGNORE_AND_CONTINUE\", \"FORCE_UNSUBSCRIPTION\"" $key) }}
          {{- end }}
        <param name="record.extraction.error.strategy">{{ .extractionErrorStrategy }}</param>
        {{- else }}
        <!--
        <param name="record.extraction.error.strategy">FORCE_UNSUBSCRIPTION</param>
        -->
        {{- end }} {{/* of .extractionErrorStrategy */}}
      {{- end }} {{/* of .record */}}

        <!-- ##### RECORD ROUTING SETTINGS ##### -->

      {{- with $connection.routing }}
        <!-- Multiple and Optional. Define an item template expression, which is made of:
             - ITEM_PREFIX: the prefix of the item name
             - BINDABLE_EXPRESSIONS: a sequence of bindable extraction expressions. See documentation at:
             https://github.com/lightstreamer/Lightstreamer-kafka-connector?tab=readme-ov-file#filtered-record-routing-item-templatetemplate_name
        -->
        {{- range $key, $itemTemplate := .itemTemplates }}
          {{- if not ( quote $itemTemplate | empty) }}
        <param name="item-template.{{ $key }}">{{ $itemTemplate }}</param>
          {{- else }}
        <!--
        <param name="item-template.TEMPLATE_NAME">ITEM_PREFIX-BINDABLE_EXPRESSIONS</param>
        -->
        <param name="item-template.stock">stock-#{index=KEY}</param>
          {{- end }}
        {{- end }} {{/* of .itemTemplates */}}

        <!-- Multiple and mandatory. Map the Kafka topic TOPIC_NAME to:
             - one or more simple items
             - one or more item templates
             - any combination of the above

             At least one mapping must be provided. -->
        <!-- Example 1:
        <param name="map.aTopicName.to">item1,item2,itemN,...</param>
        -->
        <!-- Example 2:
        <param name="map.aTopicName.to">item-itemplate.template-name1,item-template.template-name2...</param>
        -->
        <!-- Example 3:
        <param name="map.aTopicName.to">item-itemplate.template-name1,item1,item-template.template-name2,item2,...</param>
        -->
        {{- $itemTemplates := .itemTemplates }}
        {{- range $key, $mapping := .topicMappings }}
          {{ $templateRefs := list }}
          {{- if $mapping.itemTemplateRefs}}
            {{- range $mapping.itemTemplateRefs }}
              {{- if not (hasKey $itemTemplates .)}}
                {{- fail (printf "Item template %s not defined" .) }}
              {{- end }}
             {{- $templateRefs = append $templateRefs (printf "item-template.%s" .) }}
            {{- end }}
          {{- else }}
            {{- required (printf "%s.itemTemplateRegs or %s.items must be set" $key $key) $mapping.items }}
          {{- end }}
        <param name="map.{{ $mapping.topic }}.to">{{ join "," (concat ($templateRefs) ($mapping.items | default list)) }}</param>
        {{- else }}
          {{- fail (printf "connectors.kafkaConnector.connections.%s.routing.topicMappings must be set" $key) }}
        {{- end }} {{/* of .topicMappings */}}

        <!-- Optional. Enable the "TOPIC_NAME" part of the "map.TOPIC_NAME.to" parameter to be treated as a regular expression
             rather than of a literal topic name.
        -->
        {{- if .enableTopicRegEx }}
        <param name="map.regex.enable">true</param>
        {{- else }}
        <!--
        <parm name="map.regex.enable">true</param>
        -->
        {{- end }} {{/* of .enableTopicRegEx */}}
      {{- end }} {{/* of .routing */}}

        <!-- ##### RECORD MAPPING SETTINGS ##### -->
      {{- with required (printf "connectors.kafkaConnector.connections.%s.fields must be set" $key) $connection.fields }}

        <!-- Multiple and Mandatory. Map the value extracted through "extraction_expression" to
             field FIELD_NAME. The expression is written in the Data Extraction Language. See documentation at:
             https://github.com/lightstreamer/Lightstreamer-kafka-connector?tab=readme-ov-file#record-mapping-fieldfield_name

             At least one mapping must be provided. -->
        <!--
        <param name="field.FIELD_NAME">extraction_expression</param>
        -->
        {{- range $fieldName, $extractionExpression := required (printf "connectors.kafkaConnector.connections.%s.fields.mapping must be set" $key) .mappings }}
        <param name="field.{{ $fieldName }}">{{ $extractionExpression }}</param>
        {{- end }} {{/* of .mappings */}}

        <!-- Optional. By enabling the parameter, if a field mapping fails, that specific field's value will simply be omitted from the update sent to
             Lightstreamer clients, while other successfully mapped fields from the same record will still be delivered. Can be one of the following:
             - true
             - false

             Default value: false. -->
        {{- if .enableSkipFailedMapping }}
        <param name="fields.skip.failed.mapping.enable">{{ .enableSkipFailedMapping }}</param>
        {{- else }}
        <!--
        <param name="fields.skip.failed.mapping.enable">true</param>
        -->
        {{- end }} {{/* of .enableSkipFailedMapping */}}
      {{- end }} {{/* of .mappingsfields */}}

        <!-- ##### SCHEMA REGISTRY SETTINGS ##### -->
      {{- if ($connection.record).schemaRegistryRef }}
        {{- $schemaRegistryRef := $connection.record.schemaRegistryRef }}
        {{- $schemaRegistry := required (printf "kafkaConnector.schemaRegistry.%s not defined" $schemaRegistryRef) (get ($.Values.connectors.kafkaConnector.schemaRegistry | default dict) $connection.record.schemaRegistryRef) }}

        <!-- Mandatory if the Confluent Schema Registry is enabled. The URL of the Confluent Schema Registry.
             An encrypted connection is enabled by specifying the "https" protocol. -->
        <param name="schema.registry.url">{{ required (printf "kafkaConnector.schemaRegistry.%s.url must be set" $schemaRegistryRef) $schemaRegistry.url }}</param>

        <!-- Optional. Enable Basic HTTP authentication of this connection against the Schema Registry. Can be one of the following:
             - true
             - false

             Default value: false. -->
        {{- if ($schemaRegistry.basicAuthentication).enabled }}
          {{- with $schemaRegistry.basicAuthentication }}
        <param name="schema.registry.basic.authentication.enable">true</param>
            {{- with required (printf "kafkaConnector.schemaRegistry.%s.basicAuthentication.credentialsSecretRef must be set" $schemaRegistryRef) .credentialsSecretRef }}
        <param name="schema.registry.basic.authentication.username">$env.LS_KAFKA_SCHEMA_REGISTRY_{{ . | upper | replace "-" "_" }}_USERNAME</param>
        <param name="schema.registry.basic.authentication.password">$env.LS_KAFKA_SCHEMA_REGISTRY_{{ . | upper | replace "-" "_" }}_PASSWORD</param>
            {{- end }} {{/* of .basicAuthentication */}}
          {{- end }} {{/* of .basicAuthentication.enabled */}}
        {{- else }}
        <!--
        <param name="schema.registry.basic.authentication.enable">true</param>
        -->

        <!-- Mandatory if Basic HTTP authentication is enabled. The credentials. -->
        <!--
        <param name="schema.registry.basic.authentication.username">authorized-schema-registry-user</param>
        <param name="schema.registry.basic.authentication.password">authorized-schema-registry-user-password</param>
        -->
        {{- end }} {{/* of .basicAuthentication.enabled */}}

        <!-- The following parameters have the same meaning as the homologous ones defined in
             the ENCRYPTION SETTINGS section. -->

        <!-- Set general encryption settings -->
        {{- with $schemaRegistry.sslConfig }}
          {{- if .allowedProtocols }}
            {{- range $protocol := .allowedProtocols}}
              {{- if not (mustHas $protocol (list "TLSv1.2" "TLSv1.3")) }}
                {{- fail (printf "kafkaConnector.schemaRegistry.%s.sslConfig.allowedProtocols must be a list of \"TLSv1.2\", \"TLSv1.3\"" $schemaRegistryRef) }}
              {{- end }}
            {{- end }}
        <param name="schema.registry.encryption.enabled.protocols">{{ join "," .allowedProtocols }}</param>
          {{- else }}
        <!--
        <param name="schema.registry.encryption.enabled.protocols">TLSv1.3</param>
        -->
          {{- end }} {{/* of .allowedProtocols */}}

          {{- if .allowedCipherSuites }}
            {{- range $cipherSuite := .allowedCipherSuites}}
              {{- if $cipherSuite | empty }}
                {{- fail (printf "kafkaConnector.schemaRegistry.%s.sslConfig.allowedCipherSuites must be a list of valid values" $schemaRegistryRef) }}
              {{- end }}
            {{- end }}
        <param name="schema.registry.encryption.cipher.suites">{{ join "," .allowedCipherSuites }}</param>
          {{- else }}
        <!--
        <param name="schema.registry.encryption.cipher.suites">TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA</param>
        -->
          {{- end }} {{/* of .allowedCipherSuites */}}

          {{- if .enableHostnameVerification }}
        <param name="schema.registry.encryption.hostname.verification.enable">true</param>
          {{- else }}
        <!--
        <param name="schema.registry.encryption.hostname.verification.enable">true</param>
        -->
          {{- end }} {{/* of .enableHostnameVerification */}}

        <!-- If required, configure the trust store to trust the Confluent Schema Registry certificates -->
          {{- if .trustStoreRef}}
            {{- include "lightstreamer.kafka-connector.configuration.truststore" (list "schema.registry.truststore" $.Values.keyStores .trustStoreRef)  | nindent 8 }}
          {{- else }}        
        <!--
        <param name="schema.registry.encryption.truststore.path">secrets/kafka-connector.truststore.jks</param>
        <param name="schema.registry.encryption.truststore.password">kafka-connector-truststore-password</param>
        -->
          {{- end }} {{/* of .trustStoreRef */}}

          {{- if .keyStoreRef }}
            {{- include "lightstreamer.kafka-connector.configuration.keystore" (list "schema.registry.keystore" $.Values.keyStores .keyStoreRef)  | nindent 8 }}
          {{- else }}
        <!-- If mutual TLS is enabled on the Confluent Schema Registry, enable and configure the key store -->
        <!--
        <param name="schema.registry.encryption.keystore.enable">true</param>
        <param name="schema.registry.encryption.keystore.path">secrets/kafka-connector.keystore.jks</param>
        <param name="schema.registry.encryption.keystore.password">kafka-connector-password</param>
        <param name="schema.registry.encryption.keystore.key.password">kafka-connector-private-key-password</param>
        -->
          {{- end }} {{/* of .keyStoreRef */}}
        {{- end }} {{/* of .sslConfig */}}
      {{- end }} {{/* of .schemaRegistryRef */}}

    </data_provider>
    {{- end }} {{/* of .connections */}}

</adapters_conf>
{{- end }} {{/* of .Values.connectors.kafkaConnector */}}
{{- end }}
