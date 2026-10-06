# Changelog

## [1.1.1] - 2026-10-06

### Changed

- Restructured the `lightstreamer_edition_conf.xml` template: edition-aware guards around license validation, `restricted_feature_set` now driven by `license.enterprise.optionalFeatures.enableRestrictedFeaturesSet`, explicit empty defaults for `online_password` and `file_path`, and clearer `required` errors for the optional-feature flags. Bumped the edition_conf file tag to `edition_conf-APV-7.4.7`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Clarified and standardized numerous `values.yaml` documentation comments and regenerated the `README.md` and `DEPLOYMENT.md` documentation accordingly. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))

### Fixed

- Fixed `license.enabledCommunityEditionClientApi`, which was incorrectly mandatory; it is now optional (and effective only when `license.edition` is `COMMUNITY`). ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default TLS settings so that `sslConfig.removeProtocols` now correctly removes `SSL`, `TLSv1$`, and `TLSv1.1` on both the server and management SSL configurations. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed `sslConfig.removeCipherSuites` so that the configured cipher suites are now correctly removed on both the server and management SSL configurations. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the validation of `sslConfig.enforceServerCipherSuitePreference`, whose error message failed to render, and made it require `allowCipherSuites` to be set when `order` is `config`, on both the server and management SSL configurations. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default `servers.*.clientIdentification.enablePrivate`, which was incorrectly set to `true`; it is now `false`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default startup logging level (`logging.loggers.lightstreamerLogger.subLoggers.init`), which was incorrectly set to `DEBUG`; it is now `INFO`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default `timerPoolSize`, which was incorrectly set to `-1`; it is now `1`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Restored the missing `cpp_client` value for `license.enabledCommunityEditionClientApi`, which should have been available since the previous release, exposing the C++ client API to COMMUNITY edition deployments. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Made both `name` and `value` mandatory for `servers.*.responseHttpHeaders.add` entries, with clearer error messages. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Added validation of `keystores.*.type`, which must now be one of `JKS`, `PKCS12`, or `PKCS11`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Clarified that `keystores.*.keyPasswordSecretRef` is effective only when the keystore is referenced by the Kafka Connector configuration. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Added validation for the `ingress` configuration: `rules` entries are required, `paths.*.pathType` must be one of `Prefix`, `Exact`, or `ImplementationSpecific`, and `paths.*.path` must begin with `/` when `pathType` is `Prefix` or `Exact`; empty TLS hosts are now skipped. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed ServiceAccount handling: the ServiceAccount is now created by default unless `serviceAccount.create` is `false`, `automountServiceAccountToken` defaults to `true` unless `serviceAccount.automount` is `false`, and `serviceAccount` is now required. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the post-install notes (`NOTES.txt`) to safely handle an unset `ingress` configuration. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the autoscaling configuration: `autoscaling.enabled` is now handled safely when the `autoscaling` block is unset, `autoscaling.maxReplicas` is now mandatory when autoscaling is enabled, and `autoscaling.minReplicas` now defaults to `1`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed Kafka Connector GSSAPI/Kerberos authentication: the keytab file referenced by `connectors.kafkaConnector.connections.*.authentication.gssapi.keytabFilePathRef` is now mounted into the container, so keytab-based authentication works. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default Kafka Connector TLS settings so that `encryption.protocol` now defaults to `TLSv1.3` and `encryption.allowProtocols` to `[TLSv1.2, TLSv1.3]`, for both Kafka connections and Schema Registry connections. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed `connectors.kafkaConnector.connections.*.authentication.mechanism`, which was incorrectly mandatory when authentication was enabled; it is now optional. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the Schema Registry `sslConfig`, which was incorrectly mandatory; it is now optional and effective only when the Schema Registry `url` uses HTTPS. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the GSSAPI `principal` requirement, whose condition was inverted; it is now mandatory when `enableTicketCache` is `false`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default proxy-adapter `closeNotificationsRecovery`, which is now `pessimistic`. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))
- Improved reliability of the license and proxy configuration handling. ([#5](https://github.com/Lightstreamer/helm-charts/pull/6))

## [1.1.0] - 2026-29-07

### Added

- Support for Lightstreamer Kafka Connector 2.1.0. ([#4](https://github.com/Lightstreamer/helm-charts/pull/4))
- New `connectors.kafkaConnector.connections.*.consumerMode` setting exposing the connector's consumer mode feature:
  - `GROUP`: The internal Kafka Consumer joins a consumer group and uses the group coordination protocol.
  - `MANUAL`: The internal Kafka Consumer operates independently, using manual partition assignment without joining any consumer group and  without persisting offsets to Kafka.

  The default remains `GROUP`, so this is a fully backward-compatible addition. ([#4](https://github.com/Lightstreamer/helm-charts/pull/4))
- New `connectors.kafkaConnector.connections.*.routing.topicMappings.*.fromPartitions` setting: lists the partitions of the topic to be manually assigned to the consumer. ([#4](https://github.com/Lightstreamer/helm-charts/pull/4))

### Changed

- Rewrote the Kafka Connector adapter template to emit the Kafka Connector 2.1.0 configuration schema. ([#4](https://github.com/Lightstreamer/helm-charts/pull/4))
- Documentation updates in `DEPLOYMENT.md` for the new consumer mode and partitions assignment. ([#4](https://github.com/Lightstreamer/helm-charts/pull/4))
- Bumped Kafka Connector version references (`examples/kafka-connector`, `chart/values.yaml`, and `DEPLOYMENT.md`) to `2.1.0`. ([#4](https://github.com/Lightstreamer/helm-charts/pull/4))
- Cleans up and aligns the three example READMEs on a common structure, and fixes a few issues that blocked the kafka-connector example on OpenShift. ([#3](https://github.com/Lightstreamer/helm-charts/pull/3))

## [1.0.0] - 2026-07-07

### Added

- Support for Lightstreamer Kafka Connector 2.0.0. ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))
- New `connectors.kafkaConnector.connections.*.snapshot` block (`mode`, `distinctLength`, `maxIdleSeconds`) exposing the connector's item snapshot feature. `mode` selects the subscription mode (`NONE`, `MERGE`, `DISTINCT`, `COMMAND`). ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))

### Changed

- Rewrote the Kafka Connector adapter template to emit the Kafka Connector 2.0 configuration schema. ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))
- Documentation updates in `DEPLOYMENT.md` for the new snapshot configuration and clarified wording of Kafka Connector settings. ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))
- Bumped Kafka Connector example version references (`examples/kafka-connector` and `DEPLOYMENT.md`) to `2.0.0`. ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))

### Removed (breaking)

- `connectors.kafkaConnector.connections.*.record.keyEvaluator.enableEvaluationAsCommand` and `enableAutoCommandMode` (and their `valueEvaluator` counterparts) — superseded by `snapshot.mode: COMMAND`. ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))

#### Migration

If your `values.yaml` uses the removed command-mode flags, replace them with the new `snapshot` block:

```yaml
# Before
connectors:
  kafkaConnector:
    connections:
      myConn:
        record:
          keyEvaluator:
            enableEvaluationAsCommand: true    # remove
            enableAutoCommandMode: true        # remove

# After
connectors:
  kafkaConnector:
    connections:
      myConn:
        snapshot:
          mode: COMMAND
```

### Fixed

- Schema Registry credentials secrets (Confluent basic auth and Azure) are now collected on every Kafka connection that references a Schema Registry, not only on connections that also enable Kafka authentication. Previously, a connection using a Schema Registry without Kafka authentication would fail to mount its Schema Registry credentials. ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))
- Schema Registry URL no longer leaks into the rendered Kafka Connector configuration as stray text. ([#2](https://github.com/Lightstreamer/helm-charts/pull/2))

## [0.9.0] - 2026-06-15

### Changed

- Updated Lightstreamer Broker to 7.4.8.

## [0.8.0] - 2025-04-14

### Added

- First public release of the Lightstreamer Helm Chart.
