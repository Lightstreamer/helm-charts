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
Render the Lightstreamer Kafka Connector configuration file.
*/}}
{{- define "lightstreamer.kafka-connector.configuration" -}}
<?xml version="1.0"?>

<!--
    This is the configuration file of the Lightstreamer Kafka Connector pluggable into Lightstreamer Server.

    A very simple variable-expansion feature is available; see
    <enable_expansion_for_adapters_config> in the Server{{"'"}}s main configuration file.
-->

<!-- Mandatory. Define the Kafka Connector Adapter Set and its unique ID. -->
{{- with .Values.connectors.kafkaConnector }}
<adapters_conf id={{ required "connectors.kafkaConnector.adapterSetId must be set" .adapterSetId | quote }}>
    <metadata_provider>
        <!-- Mandatory. Java class name of the Kafka Connector Metadata Adapter. It is possible to
             provide a custom implementation by extending this class. -->
        <adapter_class>{{ required "connectors.kafkaConnector.adapterClassName must be set" .adapterClassName }}</adapter_class>

        <!-- Mandatory. The path of the reload4j configuration file, relative to the deployment
             folder (LS_HOME/adapters/lightstreamer-kafka-connector), or as an absolute path. -->
        <param name="logging.configuration.path">log4j.properties</param>

    </metadata_provider>
    {{ range $key, $connection := required "kafkaConnectors.connections must be set" .connections }}
      {{- if $connection.enabled }}
    <!-- Mandatory. The Kafka Connector allows the configuration of different independent
         connections to different Kafka broker/clusters.

         Every single connection is configured via the definition of its own Lightstreamer Data
         Adapter. At least one connection configuration must be provided.

         Since the Kafka Connector manages the physical connection to Kafka by wrapping an internal
         Kafka Consumer, several configuration settings in the Data Adapter are identical to those
         required by the usual Kafka Consumer configuration.

         The Kafka Connector leverages the "name" attribute of the <data_provider> tag as the
         connection name, which will be used by the Clients to request real-time data from this
         specific Kafka connection through a Subscription object.

         The connection name is also used to group all logging messages belonging to the same
         connection.

         Its default value is "DEFAULT", but only one "DEFAULT" configuration is permitted. -->
    <data_provider name={{ $connection.name | quote }}>
        <!-- ##### GENERAL PARAMETERS ##### -->

        <!-- Java class name of the Kafka Connector Data Adapter. DO NOT EDIT IT. -->
        <adapter_class>com.lightstreamer.kafka.adapters.KafkaConnectorDataAdapter</adapter_class>

        <!-- Optional. Enables this connection configuration. Can be one of the following:

             - true
             - false

             If disabled, Lightstreamer Server will automatically deny every subscription made to
             this connection.

             Default value: true. -->
        <param name="enable">true</param>

        <!-- Mandatory. The Kafka Cluster bootstrap server endpoint expressed as the list of
             host/port pairs used to establish the initial connection.

             The parameter sets the value of the "bootstrap.servers" key to configure the internal
             Kafka Consumer.
             See https://kafka.apache.org/41/configuration/consumer-configs/#consumerconfigs_bootstrap.servers
             for more details.
        -->
        <param name="bootstrap.servers">{{ required (printf "connectors.kafkaConnector.connections.%s.bootstrapServers must be set" $key) $connection.bootstrapServers }}</param>

        <!-- Optional. The consumer mode for this connection. Can be one of the following:

             - GROUP:  The internal Kafka Consumer joins a consumer group and uses the group
                       coordination protocol (partition assignment, offset commits via
                       __consumer_offsets). The consumer group is identified by the "group.id"
                       parameter.
             - MANUAL: The internal Kafka Consumer operates independently, using manual partition
                       assignment without joining any consumer group and without persisting offsets
                       to Kafka. The "group.id" parameter is ignored.

             Default value: GROUP. -->
        {{- $consumerMode := $connection.consumerMode | default "GROUP" }}
        {{- if not (quote $connection.consumerMode | empty )}}
          {{- if not (mustHas $consumerMode (list "GROUP" "MANUAL")) }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.consumerMode must be one of: \"GROUP\", \"MANUAL\"" $key) }}
          {{- end }}
        <param name="consumer.mode">{{ $consumerMode }}</param>
        {{- else }}
        <!--
        <param name="consumer.mode">MANUAL</param>
        -->
        {{- end }}

        <!-- Optional but only effective if "consumer.mode" is set to "GROUP" (the default). The
             name of the consumer group this connection belongs to.

             The parameter sets the value of the "group.id" key to configure the internal Kafka
             Consumer.
             See https://kafka.apache.org/41/configuration/consumer-configs/#consumerconfigs_group.id
             for more details.

             Default value: Adapter Set id + the Data Adapter name + randomly generated suffix. -->
        {{- if and (eq $consumerMode "GROUP") (not (quote $connection.groupId | empty )) }}
        <param name="group.id">{{ required (printf "connectors.kafkaConnector.connections.%s.groupId must be set" $key) $connection.groupId }}</param>
        {{- else }}
        <!--
        <param name="group.id">kafka-connector-group</param>
        -->
        {{- end }}

        <!-- ##### ENCRYPTION SETTINGS ##### -->

        <!-- A TCP secure connection to Kafka is configured through parameters with the "encryption"
             prefix. -->

        {{- $sslConfig := ($connection.sslConfig).enabled | default false | ternary $connection.sslConfig dict }}

        <!-- Optional. Enables encryption of this connection. Can be one of the following:

             - true
             - false

             Default value: false. -->
        {{- if $sslConfig.enabled }}
        <param name="encryption.enable">true</param>
        {{- else }}
        <!--
        <param name="encryption.enable">true</param>
        -->
        {{- end }}

        <!-- Optional. The SSL protocol to be used. Can be one of the following:

             - TLSv1.2
             - TLSv1.3

             Default value: TLSv1.3. -->
        {{- if not (quote $sslConfig.protocol | empty) }}
          {{- if not (mustHas $sslConfig.protocol (list "TLSv1.2" "TLSv1.3")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.sslConfig.protocol must be one of: \"TLSv1.2\", \"TLSv1.3\"" $key) }}
          {{- end }}
        <param name="encryption.protocol">{{ $sslConfig.protocol }}</param>
        {{- else }}
        <!--
        <param name="encryption.protocol">TLSv1.2</param>
        -->
        {{- end }}

        <!-- Optional. The list of enabled secure communication protocols.

             Default value: TLSv1.2,TLSv1.3. -->
        {{- range $protocol := $sslConfig.allowProtocols}}
          {{- if not (mustHas $protocol (list "TLSv1.2" "TLSv1.3")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.sslConfig.allowProtocols must be a list of \"TLSv1.2\", \"TLSv1.3\"" $key) }}
          {{- end }}
        {{- end }}
        {{- if $sslConfig.allowProtocols }}
        <param name="encryption.enabled.protocols">{{ join "," $sslConfig.allowProtocols }}</param>
        {{- else }}
        <!--
        <param name="encryption.enabled.protocols">TLSv1.3</param>
        -->
        {{- end }}

        <!-- Optional. The list of enabled secure cipher suites.

             Default value: all the available cipher suites in the running JVM. -->
        {{- range $cipherSuite := $sslConfig.allowCipherSuites}}
          {{- if $cipherSuite | empty }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.sslConfig.allowCipherSuites must be a list of valid values" $key) }}
          {{- end }}
        {{- end }}
        {{- if $sslConfig.allowCipherSuites }}
        <param name="encryption.cipher.suites">{{ join "," $sslConfig.allowCipherSuites }}</param>
        {{- else }}
        <!--
        <param name="encryption.cipher.suites">TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA</param>
        -->
        {{- end }}

        <!-- Optional. Enables hostname verification. Can be one of the following:

             - true
             - false

             Default value: false. -->
        {{- if not (quote $sslConfig.enableHostnameVerification | empty) }}
        <param name="encryption.hostname.verification.enable">{{ $sslConfig.enableHostnameVerification | ternary "true" "false" }}</param>
        {{- else }}
        <!--
        <param name="encryption.hostname.verification.enable">true</param>
        -->
        {{- end }}

        {{- include "lightstreamer.kafka-connector.configuration.truststore" (list $.Values.keystores $sslConfig)  | nindent 8 }}
        {{- include "lightstreamer.kafka-connector.configuration.keystore" (list $.Values.keystores $sslConfig)  | nindent 8 }}

        {{- $authentication := ($connection.authentication).enabled | default false | ternary $connection.authentication dict }}

        <!-- ##### AUTHENTICATION SETTINGS ##### -->

        <!-- Broker authentication is configured through parameters with the "authentication"
             prefix. -->

        <!-- Optional. Enables the authentication of this connection against the Kafka Cluster.
             Can be one of the following:

             - true
             - false

             Default value: false. -->
        {{- if $authentication.enabled }}
        <param name="authentication.enable">true</param>
        {{- else }}
        <!--
        <param name="authentication.enable">true</param>
        -->
        {{- end }}

        <!-- Optional. The SASL mechanism type.
             The Kafka Connector accepts the following authentication mechanisms:

             - PLAIN
             - SCRAM-SHA-256
             - SCRAM-SHA-512
             - GSSAPI
             - AWS_MSK_IAM

             Default value: PLAIN.-->
        {{- $mechanism := $authentication.mechanism }}
        {{- if and $authentication.enabled (not (quote $authentication.mechanism | empty)) }}
          {{- if not (mustHas $authentication.mechanism (list "PLAIN" "SCRAM-SHA-256" "SCRAM-SHA-512" "GSSAPI" "AWS_MSK_IAM")) }}
             {{- fail (printf "connectors.kafkaConnector.connections.%s.authentication.mechanism must be one of: \"PLAIN\", \"SCRAM-SHA-256\", \"SCRAM-SHA-512\", \"GSSAPI\", \"AWS_MSK_IAM\"" $key) }}
          {{- end }}
        <param name="authentication.mechanism">{{ $authentication.mechanism }}</param>
        {{- else }}
        <!--
        <param name="authentication.mechanism">SCRAM-SHA-256</param>
        -->
        {{- end }}

        <!-- In the case of "PLAIN", "SCRAM-SHA-256", and "SCRAM-SHA-512" mechanisms, the
             credentials must be configured through the following mandatory parameters:
        {{- if has ($authentication.mechanism | default "PLAIN") (list "PLAIN" "SCRAM-SHA-256" "SCRAM-SHA-512") -}}-->
        <param name="authentication.username">$env.LS_KAFKA_PLAIN_AUTH_{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.credentialsSecretRef must be set" $key) $authentication.credentialsSecretRef | upper | replace "-" "_" }}_USERNAME</param>
        <param name="authentication.password">$env.LS_KAFKA_PLAIN_AUTH_{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.credentialsSecretRef must be set" $key) $authentication.credentialsSecretRef | upper | replace "-" "_" }}_PASSWORD</param>
        {{- else }}

        <param name="authentication.username">authorized-kafka-user</param>
        <param name="authentication.password">authorized-kafka-user-password</param>
        -->
        {{- end }}

        <!-- ##### GSSAPI Authentication settings ##### -->

        <!-- If this mechanism is specified, you can configure the following authentication
             parameters: -->

        {{- $isGssapi := eq $authentication.mechanism "GSSAPI" }}

        <!-- Optional. Enables the use of a keytab. Can be one of the following:

             - true
             - false

             Default value: false. -->
        {{- if and $isGssapi (not (quote ($authentication.gssapi).enableKeytab | empty )) }}
        <param name="authentication.gssapi.key.tab.enable">{{ $authentication.gssapi.enableKeytab | ternary "true" "false" }}</param>
        {{- else }}
        <!--
        <param name="authentication.gssapi.key.tab.enable">true</param>
        -->
        {{- end }}

        <!-- Mandatory if keytab is enabled. The path to the keytab file, relative to
             the deployment folder (LS_HOME/adapters/lightstreamer-kafka-connector-<version>), or as
             an absolute path. -->
        {{- if and $isGssapi ($authentication.gssapi).enableKeytab }}
          {{- $keytabSubpath := (required (printf "connectors.kafkaConnector.connections.%s.authentication.gssapi.keytabFilePathRef.name must be set" $key) ($authentication.gssapi.keytabFilePathRef).name) | lower | replace "_" "-" }}
          {{- $keytabKey := required (printf "connectors.kafkaConnector.connections.%s.authentication.gssapi.keytabFilePathRef.key must be set" $key) ($authentication.gssapi.keytabFilePathRef).key }}
        <param name="authentication.gssapi.key.tab.path">{{ include "lightstreamer.kafka-connector.keytabs.dir.name" . }}/{{ $keytabSubpath }}/{{ $keytabKey }}</param>
        {{- else }}
        <!--
        <param name="authentication.gssapi.key.tab.path">gssapi/kafka-connector.keytab</param>
        -->
        {{- end }}

        <!-- Optional. Enables storage of the principal key. Can be one of the following:

             - true
             - false

             Default value: false. -->
        {{- if and $isGssapi (not (quote ($authentication.gssapi).enableStoreKey | empty)) }}
        <param name="authentication.gssapi.store.key.enable">{{ $authentication.gssapi.enableStoreKey | ternary "true" "false" }}</param>
        {{- else }}
        <!--
        <param name="authentication.gssapi.store.key.enable">true</param>
        -->
        {{- end }}

        <!-- Mandatory. The name of the Kerberos service. -->
        {{- if $isGssapi }}
        <param name="authentication.gssapi.kerberos.service.name">{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.gssapi.kerberosServiceName must be set" $key) ($authentication.gssapi).kerberosServiceName }}</param>
        {{- else }}
        <!--
        <param name="authentication.gssapi.kerberos.service.name">kafka</param>
        -->
        {{- end }}

        <!-- Mandatory if ticket cache is disabled. The name of the principal to be used. -->
        {{- if and $isGssapi (not ($authentication.gssapi).enableTicketCache) }}
        <param name="authentication.gssapi.principal">{{ required (printf "connectors.kafkaConnector.connections.%s.authentication.gssapi.principal must be set" $key) $authentication.gssapi.principal }}</param>
        {{- else }}
        <!--
        <param name="authentication.gssapi.principal">kafka-connector-1@LIGHTSTREAMER.COM</param>
        -->
        {{- end }}

        <!-- Optional. Enables the use of a ticket cache. Can be one of the following:

             - true
             - false

             Default value: false. -->
        {{- if and $isGssapi (not (quote ($authentication.gssapi).enableTicketCache | empty )) }}
        <param name="authentication.gssapi.ticket.cache.enable">{{ $authentication.gssapi.enableTicketCache | ternary "true" "false" }}</param>
        {{- else }}
        <!--
        <param name="authentication.gssapi.ticket.cache.enable">true</param>
        -->
        {{- end }}

        <!-- ##### IAM Authentication settings ##### -->

        {{- $isAwsMskIam := eq $authentication.mechanism "AWS_MSK_IAM" }}

        <!-- The AWS_MSK_IAM authentication mechanism enables access to Amazon Managed Streaming for
             Apache Kafka (MSK) clusters through IAM access control.

             If specified, the following parameters will be part of the authentication
             configuration:
        -->

        <!-- Optional. The name of the AWS credential profile to use for authentication. These
             profiles are defined in the AWS shared credentials file.
        -->

        {{- if and $isAwsMskIam (not (quote ($authentication.iam).credentialProfileName | empty) ) }}
        <param name="authentication.iam.credential.profile.name">{{ $authentication.iam.credentialProfileName }}</param>
        {{- else }}
        <!--
        <param name="authentication.iam.credential.profile.name">msk_client<param>
        -->
        {{- end }}

        <!-- Optional. The Amazon Resource Name (ARN) of the IAM role that the Kafka Connector
             should assume for authentication with MSK. Use this when you want the connector to
             assume a specific role with temporary credentials.
        -->
        {{- if and $isAwsMskIam (not (quote ($authentication.iam).roleArn | empty) ) }}
        <param name="authentication.iam.role.arn">{{ $authentication.iam.roleArn }}</param>
        {{- else }}
        <!--
        <param name="authentication.iam.role.arn">arn:aws:iam::123456789012:role/msk_client_role</param>
        -->
        {{- end }}

        <!-- Optional but only effective if "authentication.iam.role.arn" is set. The name of the
             session for the assumed IAM role.
        -->
        {{- if and $isAwsMskIam (not (quote ($authentication.iam).roleSessionName | empty) ) }}
        <param name="authentication.iam.role.session.name">{{ $authentication.iam.roleSessionName }}</param>
        {{- else }}
        <!--
        <param name="authentication.iam.role.session.name">consumer</param>
        -->
        {{- end }}

        <!-- Optional but only effective if "authentication.iam.role.arn" is set. Specifies the AWS
             region of the STS endpoint to use when assuming the IAM role.
        -->
        {{- if and $isAwsMskIam (not (quote ($authentication.iam).stsRegion | empty) ) }}
        <param name="authentication.iam.sts.region">{{ $authentication.iam.stsRegion }}</param>
        {{- else }}
        <!--
        <param name="authentication.iam.sts.region">us-west-1</param>
        -->
        {{- end }}

        <!-- ##### RECORD PROCESSING SETTINGS ##### -->

        {{- $record := $connection.record | default dict }}

        <!-- Optional but ineffective if "item.snapshot.enabled.mode" is set to any value other than
             "NONE" (see the "Snapshot Management" section in the README for the partition-position
             behavior in that case). Specifies where to start consuming events. Can be one of the
             following:

             - EARLIEST: Start consuming events from the beginning of the topic partition.
             - LATEST:   Start consuming events from the end of the topic partition.

             How this parameter is applied depends on the consumer mode:

             - In GROUP mode, it sets the value of the "auto.offset.reset" key on the internal Kafka
               Consumer and therefore only takes effect for partitions that have no committed offset
               yet; partitions with a committed offset resume from there.
               See https://kafka.apache.org/41/configuration/consumer-configs/#consumerconfigs_auto.offset.reset
               for more details.
             - In MANUAL mode, since offsets are never committed, the connector seeks every assigned
               partition to the requested position on every startup. The setting therefore applies
               uniformly to all assigned partitions on every restart.

             Default value: LATEST. -->
        {{- if not (quote $record.consumeFrom | empty) }}
          {{- if not (mustHas $record.consumeFrom (list "EARLIEST" "LATEST")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.record.consumeFrom must be one of: \"EARLIEST\", \"LATEST\"" $key) }}
          {{- end }}
        <param name="record.consume.from">{{ $record.consumeFrom }}</param>
        {{- else }}
        <!--
        <param name="record.consume.from">EARLIEST</param>
        -->
        {{- end }}

        <!-- Optional. The maximum number of records fetched in each polling cycle.

             The parameter sets the value of the "max.poll.records" key to configure the internal
             Kafka Consumer.
             See https://kafka.apache.org/41/configuration/consumer-configs/#consumerconfigs_max.poll.records
             for more details.

             Default value: 500. -->
        {{- if not (quote $record.consumeWithMaxPollRecords | empty) }}
        <param name="record.consume.with.max.poll.records">{{ $record.consumeWithMaxPollRecords }}</param>
        {{- else }}
        <!--
        <param name="record.consume.with.max.poll.records">200</param>
        -->
        {{- end }}

        <!-- Optional. The timeout used to detect client failures when using Kafka{{"'"}}s group
             management facility.

             The parameter sets the value of the "session.timeout.ms" key to configure the internal
             Kafka Consumer.
             See https://kafka.apache.org/41/configuration/consumer-configs/#consumerconfigs_session.timeout.ms
             for more details.

             Default value: 45000. -->
        {{- if not (quote $record.consumeWithMaxSessionTimeoutMillis | empty) }}
        <param name="record.consume.with.session.timeout.ms">{{ $record.consumeWithMaxSessionTimeoutMillis }}</param>
        {{- else }}
        <!--
        <param name="record.consume.with.session.timeout.ms">30000</param>
        -->
        {{- end }}

        <!-- Optional. The maximum delay between invocations of poll() when using consumer group
             management. This places an upper bound on the amount of time that the consumer can be
             idle before fetching more records.

             The parameter sets the value of the "max.poll.interval.ms" key to configure the
             internal Kafka Consumer.
             See https://kafka.apache.org/41/configuration/consumer-configs/#consumerconfigs_max.poll.interval.ms
             for more details.

             Default value: 30000. -->
        {{- if not (quote $record.consumeWithMaxPollIntervalMillis | empty) }}
        <param name="record.consume.with.max.poll.interval.ms">{{ $record.consumeWithMaxPollIntervalMillis }}</param>
        {{- else }}
        <!--
        <param name="record.consume.with.max.poll.interval.ms">50000</param>
        -->
        {{- end }}

        <!-- Optional. The number of threads to be used for concurrent processing of the incoming
             deserialized records. If set to -1, the number of threads will be  automatically
             determined based on the number of available CPU cores.

             Default value: 1. -->
        {{- if not (quote $record.consumeWithThreadNumber | empty) }}
          {{- if or (eq (int $record.consumeWithThreadNumber) -1) (gt (int $record.consumeWithThreadNumber) 0) }}
        <param name="record.consume.with.num.threads">{{ $record.consumeWithThreadNumber }}</param>
          {{- else }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.record.consumeWithThreadNumber must be set with a valid value" $key) }}
          {{- end }}
        {{- else }}
        <!--
        <param name="record.consume.with.num.threads">4</param>
        -->
        {{- end }}

        <!-- Optional but only effective if "record.consume.with.num.threads" is set to a value
             greater than 1 (which includes the default value). The order strategy to be used for
             concurrent processing of the incoming deserialized records. Can be one of the
             following:

             - ORDER_BY_PARTITION: Maintain the order of records within each partition.
             - ORDER_BY_KEY:       Maintain the order among the records sharing the same key.
             - UNORDERED:          Provide no ordering guarantees.

             Default value: ORDER_BY_PARTITION. -->
        {{- if not (quote $record.consumeWithOrderStrategy | empty) }}
          {{- if not (mustHas $record.consumeWithOrderStrategy (list "ORDER_BY_PARTITION" "ORDER_BY_KEY" "UNORDERED")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.record.consumeWithOrderStrategy must be one of: \"ORDER_BY_PARTITION\", \"ORDER_BY_KEY\", \"UNORDERED\"" $key) }}
          {{- else }}
        <param name="record.consume.with.order.strategy">{{ $record.consumeWithOrderStrategy }}</param>
          {{- end }}
        {{- else }}
        <!--
        <param name="record.consume.with.order.strategy">ORDER_BY_KEY</param>
        -->
        {{- end }}

        {{- include "lightstreamer.kafka-connector.configuration.record.evaluator" (list $ $connection.record "key" $key) | nindent 8 }}
        {{- include "lightstreamer.kafka-connector.configuration.record.evaluator" (list $ $connection.record "value" $key) | nindent 8 }}

        <!-- Optional but forced to "IGNORE_AND_CONTINUE" when "item.snapshot.enabled.mode" is set
             to any value other than "NONE". The error handling strategy to be used if an error
             occurs while extracting data from incoming deserialized records. Can be one of the
             following:

             - IGNORE_AND_CONTINUE:  Ignore the error and continue to process the next record.
             - FORCE_UNSUBSCRIPTION: Stop processing records and force unsubscription of the items
                                     requested by all the Lightstreamer clients subscribed to this
                                     connection.

             See the "Snapshot Management" section in the README for the rationale of the override.

             Default: "IGNORE_AND_CONTINUE". -->
        {{- if not (quote $record.extractionErrorStrategy) | empty }}
          {{- if not (mustHas $record.extractionErrorStrategy (list "IGNORE_AND_CONTINUE" "FORCE_UNSUBSCRIPTION")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.record.extractionErrorStrategy must be one of: \"IGNORE_AND_CONTINUE\", \"FORCE_UNSUBSCRIPTION\"" $key) }}
          {{- end }}
        <param name="record.extraction.error.strategy">{{ $record.extractionErrorStrategy }}</param>
        {{- else}}
        <!--
        <param name="record.extraction.error.strategy">FORCE_UNSUBSCRIPTION</param>
        -->
        {{- end }}

        <!-- ##### RECORD ROUTING SETTINGS ##### -->

        {{- with required (printf "connectors.kafkaConnector.connections.%s.routing must be set" $key) $connection.routing }}

        <!-- Multiple and optional. Define an item template expression, which is made of:

             - ITEM_PREFIX: the prefix of the item name
             - BINDABLE_EXPRESSIONS: a sequence of bindable extraction expressions. See
               documentation at: https://github.com/lightstreamer/Lightstreamer-kafka-connector?tab=readme-ov-file#filtered-record-routing-item-templatetemplate_name
        -->
          {{- range $key, $itemTemplate := .itemTemplates }}
            {{- if not (quote $itemTemplate | empty) }}
        <param name="item-template.{{ $key }}">{{ $itemTemplate }}</param>
            {{- end }}
          {{- else }}
        <!--
        <param name="item-template.TEMPLATE_NAME">ITEM_PREFIX-BINDABLE_EXPRESSIONS</param>
        -->
          {{- end }}

        <!-- Multiple and mandatory. Maps the Kafka topic TOPIC_NAME to:

             - one or more simple items
             - one or more item templates
             - any combination of the above

             The general format is:

             <param name="map.TOPIC_NAME.to">item1,item2,itemN,...</param>

             At least one mapping must be provided. -->
        <!-- Example 1:
        <param name="map.aTopicName.to">item1,item2,itemN,...</param>
        -->
        <!-- Example 2:
        <param name="map.aTopicName.to">item-template.template-name1,item-template.template-name2...</param>
        -->
        <!-- Example 3:
        <param name="map.aTopicName.to">item-template.template-name1,item1,item-template.template-name2,item2,...</param>
        -->
          {{- $itemTemplates := .itemTemplates }}
          {{- $usedTopicNames := list }}
          {{- $alreadyCommentedPartitions := false }}
          {{- range $mappingKey, $mapping := .topicMappings }}
            {{- if not $mapping }}
              {{- printf "connectors.kafkaConnector.connections.%s.routing.topicMappings.%s must be set" $key $mappingKey | fail }}
            {{- end }}
            {{- $topic := required (printf "connectors.kafkaConnector.connections.%s.routing.topicMappings.%s.topic must be set" $key $mappingKey) $mapping.topic}}
            {{- if has $topic $usedTopicNames }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.routing.topicMappings.%s.topic %s already mapped" $key $mappingKey $topic) }}
            {{- end }}
            {{- $usedTopicNames = append $usedTopicNames $topic }}
            {{- $templateRefs := list }}
            {{- $itemsList := list }}
            {{- range $mapping.itemTemplateRefs }}
              {{- if not (hasKey $itemTemplates .) }}
                {{- fail (printf "Item template %s not defined" .) }}
              {{- end }}
              {{- $templateRefs = append $templateRefs (printf "item-template.%s" .) }}
            {{- else }}
              {{- $itemsList = required (printf "Either specify %s.itemTemplateRefs or %s.items" $mappingKey $mappingKey) $mapping.items }}
            {{- end }}
            {{- if $alreadyCommentedPartitions }}
            {{- "\n" }}
            {{- end }}
        <param name="map.{{ $topic }}.to">{{ join "," (concat ($templateRefs) $itemsList) }}</param>

            {{- if not $alreadyCommentedPartitions}}
              {{- $alreadyCommentedPartitions = true }}

        <!-- Optional but only effective if "consumer.mode" is set to "MANUAL". Lists the partitions
             of the topic TOPIC_NAME to be manually assigned to this consumer.

             The value is a comma-separated list of non-negative partition numbers and inclusive
             ranges (e.g. "0,2,4-6").

             If omitted, all partitions of the topic are assigned. -->
        <!-- Example 1:
        <param name="map.aTopicName.from.partitions">0,1,2,3</param>
        -->
        <!-- Example 2:
        <param name="map.aTopicName.from.partitions">0-3,4-6,9</param>
        -->
            {{- end}} 
            {{- $partitions := join "," $mapping.fromPartitions }}
            {{- if and (eq $consumerMode "MANUAL") $partitions }}
        <param name="map.{{ $topic }}.from.partitions">{{ $partitions }}</param>
            {{- end }}
          {{- else }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.routing.topicMappings must be set" $key) }}
          {{- end }}

        <!-- Optional. Enables the "TOPIC_NAME" part of the "map.TOPIC_NAME.to" parameter to be
             treated as a regular expression rather than of a literal topic name.

             Not supported if "consumer.mode" is set to "MANUAL"; the setting will be rejected at
             startup.
        -->
          {{- if not (quote .enableTopicRegEx | empty) }}
            {{- if and .enableTopicRegEx (eq $consumerMode "MANUAL") }}
              {{ fail (printf "connectors.kafkaConnector.connections.%s.routing.enableTopicRegEx must be set to 'false' if consumerMode is MANUAL" $key)}}
            {{- end }}
        <param name="map.regex.enable">{{ .enableTopicRegEx | ternary "true" "false" }}</param>
          {{- else }}
        <!--
        <param name="map.regex.enable">true</param>
        -->
          {{- end }}
        {{- end }}

        <!-- ##### RECORD MAPPING SETTINGS ##### -->
        {{- with required (printf "connectors.kafkaConnector.connections.%s.fields must be set" $key) $connection.fields }}

        <!-- Multiple and mandatory. Maps the value extracted through "extraction_expression" to
             field FIELD_NAME. The expression is written in the Data Extraction Language. See
             documentation at: https://github.com/lightstreamer/Lightstreamer-kafka-connector?tab=readme-ov-file#record-mapping-fieldfield_name

             Dynamic Field Discovery: Use wildcards in both parameter name (field.*) and extraction
             expression to automatically discover and map field names at runtime from the record
             structure. For example:

             <param name="field.*">#{VALUE.*}</param>
             <param name="field.*">#{KEY.*}</param>
             <param name="field.*">#{HEADERS.*}</param>
             <param name="field.*">#{VALUE.nested.*}</param>
             <param name="field.*">#{VALUE.items.*}</param>

             Static field.fieldName mappings take precedence over field.* wildcards.

             At least one mapping must be provided. -->
        <!--
        <param name="field.FIELD_NAME">extraction_expression</param>
        -->
          {{- range $fieldName, $extractionExpression := required (printf "connectors.kafkaConnector.connections.%s.fields.mapping must be set" $key) .mappings }}
        <param name="field.{{ $fieldName }}">{{ $extractionExpression }}</param>
          {{- end }}

        <!-- Optional. By enabling the parameter, if a field mapping fails, that specific field{{"'"}}s
             value will simply be omitted from the update sent to Lightstreamer clients, while other
             successfully mapped fields from the same record will still be delivered. Can be one of
             the following:

             - true
             - false

             Default value: false. -->
          {{- if not (quote .enableSkipFailedMapping | empty) }}
        <param name="fields.skip.failed.mapping.enable">{{ .enableSkipFailedMapping | ternary "true" "false" }}</param>
          {{- else }}
        <!--
        <param name="fields.skip.failed.mapping.enable">true</param>
        -->
          {{- end }}

        <!-- Optional. Enabling this parameter allows mapping of non-scalar values to Lightstreamer
             fields.
             For example, in the following mapping:

             <param name="field.structured">#{VALUE.complexAttribute}</param>

             the value of "complexAttribute" will be mapped as generic text (e.g. JSON string) to
             the "structured" Lightstreamer field.

             Can be one of the following:

             - true
             - false

             Default value: false. -->
          {{- if not (quote .enableNonScalarValuesMapping | empty) }}
        <param name="fields.map.non.scalar.values.enable">{{ .enableNonScalarValuesMapping }}</param>
          {{- else }}
        <!--
        <param name="fields.map.non.scalar.values.enable">true</param>
        -->
          {{- end }}
        {{- end }}

        <!-- ##### ITEM SNAPSHOT SETTINGS ##### -->

        {{- $snapshot := $connection.snapshot | default dict }}

        <!-- Optional. Selects the snapshot behavior for subscribed items and, when not set to
             "NONE", pins the Lightstreamer subscription Mode the connector is willing to serve. Any
             non-"NONE" value activates the eager pipeline: the consumer starts at adapter
             initialization, replays the topic from the beginning to seed the Server{{"'"}}s item store,
             then transitions to realtime tailing. Can be one of the following:

             - NONE:     Snapshot disabled. The consumer starts on the first client subscription and
                         every record is delivered as a realtime update. The subscription Mode is
                         not constrained by the adapter.
             - MERGE:    Snapshot enabled; subscription Mode pinned to MERGE. A new subscriber
                         receives a single snapshot event per item (the current value), followed by
                         realtime updates.
             - DISTINCT: Snapshot enabled; subscription Mode pinned to DISTINCT. A new subscriber
                         receives up to "item.snapshot.distinct.length" snapshot events per item
                         (the most recent ones), followed by realtime updates.
             - COMMAND:  Snapshot enabled; subscription Mode pinned to COMMAND. A new subscriber
                         receives all rows currently in the per-item table. The connector
                         synthesises the "command" field from each record; you only map "field.key".

             Any non-"NONE" value also bypasses "record.consume.from" and forces
             "record.extraction.error.strategy" to "IGNORE_AND_CONTINUE", overriding the configured
             values.

             Default value: NONE. -->
        {{- if not (quote $snapshot.mode) | empty }}
          {{- if not (mustHas $snapshot.mode (list "NONE" "MERGE" "COMMAND" "DISTINCT")) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.snapshot.mode must be one of: \"NONE\", \"MERGE\", \"DISTINCT\", \"COMMAND\"" $key) }}
          {{- end }}
          {{- if and (eq $snapshot.mode "COMMAND") (not $connection.fields.mappings.key) }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.snapshot.mode is COMMAND but no key mapping is defined" $key) }}
          {{- end }}
        <param name="item.snapshot.enabled.mode">{{ $snapshot.mode }}</param>
        {{- else }}
        <!--
        <param name="item.snapshot.enabled.mode">MERGE</param>
        -->
        {{- end }}

        <!-- Optional but only effective if "item.snapshot.enabled.mode" is set to "DISTINCT". The
             maximum allowed length for the snapshot of an item that has been requested with
             publishing Mode DISTINCT. Must be a positive integer.

             Default value: 10. -->
        {{- if eq $snapshot.mode "DISTINCT" }}
          {{- if not (quote $snapshot.distinctLength | empty) }}
            {{- if lt (int $snapshot.distinctLength) 0 }}
              {{- fail (printf "connectors.kafkaConnector.connections.%s.snapshot.distinctLength must be non-negative" $key) }}
            {{- end }}
          {{- end }}
        <param name="item.snapshot.distinct.length">{{ int $snapshot.distinctLength }}</param>
        {{- else }}
        <!--
        <param name="item.snapshot.distinct.length">100</param>
        -->
        {{- end }}

        <!-- Optional but only effective if "item.snapshot.enabled.mode" is set to any value other
             than "NONE". The maximum idle time in seconds after which the snapshot of an item is
             discarded, so that the next incoming record starts a fresh one. Must be a non-negative
             integer; a value of 0 disables the idle check.

             Default value: 0. -->
        {{- if and (ne $snapshot.mode "NONE") (not (quote $snapshot.maxIdleSeconds | empty)) }}
          {{- if lt (int $snapshot.maxIdleSeconds) 0 }}
            {{- fail (printf "connectors.kafkaConnector.connections.%s.snapshot.maxIdleSeconds must be non-negative" $key) }}
          {{- end }}
        <param name="item.snapshot.max.idle.seconds">{{ int $snapshot.maxIdleSeconds }}</param>
        {{- else }}
        <!--
        <param name="item.snapshot.max.idle.seconds">30</param>
        -->
        {{- end }}

        <!-- ##### SCHEMA REGISTRY SETTINGS ##### -->

        {{- $schemaRegistryRef := ($connection.record).schemaRegistryRef  }}
        {{- $schemaRegistry := ($connection.record).schemaRegistry }}
        {{- $isConfluent := eq ($schemaRegistry.provider | default "CONFLUENT") "CONFLUENT" }}

        <!-- Optional. Specifies the Schema Registry provider to use. Can be one of the following:

             - CONFLUENT: Use the Confluent Schema Registry.
             - AZURE:     Use the Azure Schema Registry.

             Default value: CONFLUENT. -->
        {{- /* Flag set by the "lightstreamer.kafka-connector.configuration.record.evaluator" function */ -}}
        {{- if and ($connection.record).renderSchemaRegistry (not (quote $schemaRegistry.provider | empty) )}}
        <param name="schema.registry.provider">{{ $schemaRegistry.provider }}</param>
        {{- else }}
        <!--
        <param name="schema.registry.provider">AZURE</param>
        -->
        {{- end }}

        <!-- Mandatory if a Schema Registry is enabled. The URL of the Schema Registry endpoint
             (either Confluent Schema Registry or Azure Schema Registry).

             An encrypted connection is enabled by specifying the "https" protocol. -->
        {{- if ($connection.record).renderSchemaRegistry }}
        <param name="schema.registry.url">{{ $schemaRegistry.url }}</param>
        {{- else }}
        <!-- Example for the Confluent Schema Registry:
        <param name="schema.registry.url">https://schema-registry:8084</param>
        -->
        <!-- Example for the Azure Schema Registry:
        <param name="schema.registry.url">https://my-namespace.servicebus.windows.net</param>
        -->
        {{- end }}

        <!-- ##### Confluent Schema Registry settings ##### -->
        {{- $confluent := $isConfluent | ternary $schemaRegistry.confluent dict }}
        {{- $confluentAuthentication := dict }}
        {{- if $isConfluent }}
          {{- $confluentAuthentication = $confluent.basicAuthentication | default dict }}
        {{- end}}

        <!-- Optional. Enables Basic HTTP authentication of this connection against the Schema
             Registry. Can be one of the following:

             - true
             - false

             Default value: false. -->
        {{- if not (quote $confluentAuthentication.enabled | empty ) }}
        <param name="schema.registry.confluent.basic.authentication.enable">{{ $confluentAuthentication.enabled | ternary "true" "false" }}</param>
        {{- else }}
        <!--
        <param name="schema.registry.confluent.basic.authentication.enable">true</param>
        -->
        {{- end }}

        <!-- Mandatory if Basic HTTP authentication is enabled. The credentials. -->
        {{- if $confluentAuthentication.enabled }}
          {{- with required (printf "connectors.kafkaConnector.schemaRegistries.%s.basicAuthentication.credentialsSecretRef must be set" $schemaRegistryRef) $confluentAuthentication.credentialsSecretRef }}
        <param name="schema.registry.confluent.basic.authentication.username">$env.LS_KAFKA_CONFLUENT_SCHEMA_REGISTRY_{{ . | upper | replace "-" "_" }}_USERNAME</param>
        <param name="schema.registry.confluent.basic.authentication.password">$env.LS_KAFKA_CONFLUENT_SCHEMA_REGISTRY_{{ . | upper | replace "-" "_" }}_PASSWORD</param>
          {{- end }}
        {{- else }}
        <!--
        <param name="schema.registry.confluent.basic.authentication.username">authorized-schema-registry-user</param>
        <param name="schema.registry.confluent.basic.authentication.password">authorized-schema-registry-user-password</param>
        -->
        {{- end }}

        <!-- The following parameters have the same meaning as the homologous ones defined in the
             ENCRYPTION SETTINGS section. -->
        {{- $sslConfig := $isConfluent | ternary $confluent.sslConfig dict }}

        <!-- Set general encryption settings -->
        {{- $renderedSslConfigComments := dict "protocol" "TLSv1.2" "enabled.protocols" "TLSv1.3" "cipher.suites" "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA" "hostname.verification.enable" "true" }}

        {{- if not (quote $sslConfig.protocol | empty ) }}
          {{- $_ := unset $renderedSslConfigComments "protocol" }}
          {{- if not (mustHas $sslConfig.protocol (list "TLSv1.2" "TLSv1.3")) }}
            {{- fail (printf "connectors.kafkaConnector.schemaRegistries.%s.sslConfig.protocol must be one of: \"TLSv1.2\", \"TLSv1.3\"" $schemaRegistryRef) }}
          {{- end }}
        <param name="schema.registry.confluent.encryption.protocol">{{ $sslConfig.protocol }}</param>
        {{- end }}

        {{- if $sslConfig.allowProtocols }}
          {{- $_ := unset $renderedSslConfigComments "enabled.protocols" }}
          {{- range $protocol := $sslConfig.allowProtocols}}
            {{- if not (mustHas $protocol (list "TLSv1.2" "TLSv1.3")) }}
              {{- fail (printf "connectors.kafkaConnector.schemaRegistries.%s.sslConfig.allowProtocols must be a list of \"TLSv1.2\", \"TLSv1.3\"" $schemaRegistryRef) }}
            {{- end }}
          {{- end }}
        <param name="schema.registry.confluent.encryption.enabled.protocols">{{ join "," $sslConfig.allowProtocols }}</param>
        {{- end }}

        {{- if $sslConfig.allowCipherSuites }}
          {{- $_ := unset $renderedSslConfigComments "cipher.suites" }}
          {{- range $cipherSuite := $sslConfig.allowCipherSuites}}
            {{- if $cipherSuite | empty }}
              {{- fail (printf "connectors.kafkaConnector.schemaRegistries.%s.sslConfig.allowCipherSuites must be a list of valid values" $schemaRegistryRef) }}
            {{- end }}
          {{- end }}
        <param name="schema.registry.confluent.encryption.cipher.suites">{{ join "," $sslConfig.allowCipherSuites }}</param>
            {{- end }}

        {{- if $sslConfig.enableHostnameVerification }}
          {{- $_ := unset $renderedSslConfigComments "hostname.verification.enable" }}
        <param name="schema.registry.confluent.encryption.hostname.verification.enable">true</param>
        {{- end }}

        {{- if $renderedSslConfigComments }}
        <!--
          {{- if hasKey $renderedSslConfigComments "protocol" }}
        <param name="schema.registry.confluent.encryption.protocol">{{ $renderedSslConfigComments.protocol }}</param>
          {{- end }}
          {{- if hasKey $renderedSslConfigComments "enabled.protocols" }}
        <param name="schema.registry.confluent.encryption.enabled.protocols">{{ get $renderedSslConfigComments "enabled.protocols" }}</param>
          {{- end }}
          {{- if hasKey $renderedSslConfigComments "cipher.suites" }}
        <param name="schema.registry.confluent.encryption.cipher.suites">{{ get $renderedSslConfigComments "cipher.suites" }}</param>
          {{- end }}
          {{- if hasKey $renderedSslConfigComments "hostname.verification.enable" }}
        <param name="schema.registry.confluent.encryption.hostname.verification.enable">{{ get $renderedSslConfigComments "hostname.verification.enable" }}</param>
          {{- end }}
        -->
        {{- end }}

        {{- include "lightstreamer.kafka-connector.configuration.schema-registry.confluent.truststore" (list $.Values.keystores $sslConfig) | nindent 8 }}
        {{- include "lightstreamer.kafka-connector.configuration.schema-registry.confluent.keystore" (list $.Values.keystores $sslConfig) | nindent 8 }}

        <!-- ##### Azure Schema Registry settings ##### -->
        {{- $azureCredentials := "" -}}
        {{- if not $isConfluent }}
          {{- $azureCredentials = required (printf "1connectors.kafkaConnector.schemaRegistries.%s.azure.credentialsSecretRef must be set " $schemaRegistryRef) ($schemaRegistry.azure).credentialsSecretRef -}}
        {{- end }}

        <!-- Mandatory if the Azure Schema Registry is enabled. The Application (client) ID assigned
             to the application registered in Microsoft Entra ID with appropriate permissions to
             access the Schema Registry. -->
        {{- if $azureCredentials }}
        <param name="schema.registry.azure.client.id">$env.LS_KAFKA_AZURE_SCHEMA_REGISTRY_{{ $azureCredentials | upper | replace "-" "_" }}_CLIENT_ID</param>
        {{- else }}
        <!--
        <param name="schema.registry.azure.client.id">11111111-2222-3333-4444-555555555555</param>
        -->
        {{- end }}

        <!-- Mandatory if the Azure Schema Registry is enabled. The Directory (tenant) ID of the
             Microsoft Entra ID tenant where the application is registered. -->
        {{- if $azureCredentials }}
        <param name="schema.registry.azure.tenant.id">$env.LS_KAFKA_AZURE_SCHEMA_REGISTRY_{{ $azureCredentials | upper | replace "-" "_" }}_TENANT_ID</param>
        {{- else}}
        <!--
        <param name="schema.registry.azure.tenant.id">aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee</param>
        -->
        {{- end }}

        <!-- Mandatory if the Azure Schema Registry is enabled. The client secret value of the
             application registered in Microsoft Entra ID. -->
        {{- if $azureCredentials }}
        <param name="schema.registry.azure.client.secret">$env.LS_KAFKA_AZURE_SCHEMA_REGISTRY_{{ $azureCredentials | upper | replace "-" "_" }}_CLIENT_SECRET</param>
        {{- else }}
        <!--
        <param name="schema.registry.azure.client.secret">your-azure-client-secret-value</param>
        -->
        {{- end }}

    </data_provider>
      {{- end }}
    {{- end }}

</adapters_conf>
{{- end }}
{{- end }}
