# Changelog

## [1.2.0] - Unreleased

### Changed

- Updated Lightstreamer Broker to 7.4.9. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- **Breaking:** Cross-origin rules under `security.crossDomainPolicy.allowAccessFrom` are now applied only if their new `enabled` flag is `true`; existing rules without it are silently ignored. The default `fromEveryWhere` rule is disabled, so no cross-origin access is granted by default. See the migration notes below. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Hardened the default client and security settings: `servers.*.clientIdentification.enablePrivate` and `security.enableProtectedJs` now default to `true`, and `security.serverIdentificationPolicy` now defaults to `MINIMAL`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Hardened the default Monitoring Dashboard settings: `management.dashboard.enableJmxTree`, `enablePublicAccess`, and `enableAvailabilityOnAllServers` now default to `false`, and `availableOnServers` no longer references `defaultServer`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Disabled the internal web server by default (`webServer.enabled: false`). ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Removed the default `servers.defaultServer.sslConfig.keystoreRef` (`myServerKeystore`); set it explicitly when enabling HTTPS on `defaultServer`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Made `management.dashboard.credentials[].secretRef` and `management.dashboard.availableOnServers[].serverRef` optional; entries without a value are skipped, and the Dashboard credential environment variables are injected only if the Dashboard is enabled. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Moved `management.jmx.rmiConnector.enablePublicAccess` and `credentialSecrets` right after `enabled` in `values.yaml`, with no functional change. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Bumped Kafka Connector version references (`values.yaml` comments and `examples/kafka-connector`) to `2.1.1`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Made server sockets that don't set `responseHttpHeaders.add` add `X-Accel-Buffering: no`, like `defaultServer`; set `responseHttpHeaders.add: []` to opt out. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Updated the examples to enable the internal web server and allow `http://127.0.0.1:8080` as a cross-origin rule, so the test pages keep working through `kubectl port-forward`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Reworked `DEPLOYMENT.md` (Security, TLS/SSL hardening, information sent to clients, RMI Connector access, and JMX network access) and aligned the example READMEs; regenerated the chart `README.md`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))

#### Migration

Add `enabled: true` to every custom cross-origin rule:

```yaml
security:
  crossDomainPolicy:
    allowAccessFrom:
      myRule:
        enabled: true    # add
        scheme: https
        host: "www.my-domain.com"
        port: 443
```

The following defaults changed; set the previous value explicitly in your values file to restore the old behavior:

| Setting | Previous default | New default |
| --- | --- | --- |
| `servers.*.clientIdentification.enablePrivate` | `false` | `true` |
| `security.enableProtectedJs` | `false` | `true` |
| `security.serverIdentificationPolicy` | `FULL` | `MINIMAL` |
| `security.crossDomainPolicy.allowAccessFrom.fromEveryWhere.enabled` | not present (rule applied) | `false` |
| `management.dashboard.enableJmxTree` | `true` | `false` |
| `management.dashboard.enablePublicAccess` | `true` | `false` |
| `management.dashboard.enableAvailabilityOnAllServers` | `true` | `false` |
| `management.dashboard.availableOnServers[0].serverRef` | `defaultServer` | unset |
| `webServer.enabled` | `true` | `false` |
| `servers.defaultServer.sslConfig.keystoreRef` | `myServerKeystore` | unset |

### Added

- Added a validation that fails rendering if both `servers.*.sslConfig.allowProtocols` and `servers.*.sslConfig.removeProtocols` are set, since the two settings are mutually exclusive. The default `removeProtocols` value is taken into account, so `removeProtocols: []` must be set when using `allowProtocols`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Added validation of `truststoreRef` references: rendering fails if the referenced keystore is not defined in `keystores` or has an invalid `type`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))

### Deprecated

- Deprecated `management.jmx.service`, the dedicated Kubernetes Service for the JMX connectors; it will be removed in the next major release. `NOTES.txt` now prints a warning if it is enabled; see the Network access section of `DEPLOYMENT.md` for the alternatives. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))

### Removed

- **Breaking:** Removed the `dashboard-user-secret` Secret, which contained hardcoded default Monitoring Dashboard credentials. Create your own Secret and reference it in `management.dashboard.credentials[].secretRef`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))

### Fixed

- Fixed the `com.sun.jmx.remote` logger, whose level was not resolved through the common log-level handling used by the other loggers. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Fixed `service.ports[].name`, which was incorrectly mandatory (rendering failed if unset); it is now optional. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Fixed validation error messages that referenced wrong keys (`server.*` instead of `servers.*`, `allowsAccess` instead of `allowAccessFrom`, `deployment.probes.<probe>.healthCheck.serverRef` instead of `deployment.probes.<probe>.serverRef`), corrected the wording of the error for references to disabled server sockets, and made the `allowProtocols` and `removeProtocols` errors report the offending index. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))
- Fixed HTTPS server sockets that don't set `sslConfig.removeProtocols`, which kept the legacy protocols enabled; they now remove `SSL`, `TLSv1$`, and `TLSv1.1`, like `defaultServer`. ([#8](https://github.com/Lightstreamer/helm-charts/pull/8))

## [1.1.2] - 2026-10-12

### Fixed

- Fixed the Kafka Connector PLAIN/SCRAM credentials, which were rendered (with `credentialsSecretRef` required) even when `connectors.kafkaConnector.connections.*.authentication.enabled` was `false` or unset; they are now rendered only when authentication is enabled. ([#7](https://github.com/Lightstreamer/helm-charts/pull/7))

## [1.1.1] - 2026-10-06

### Changed

- Restructured the `lightstreamer_edition_conf.xml` template: edition-aware guards around license validation, `restricted_feature_set` now driven by `license.enterprise.optionalFeatures.enableRestrictedFeaturesSet`, explicit empty defaults for `online_password` and `file_path`, and clearer `required` errors for the optional-feature flags. Bumped the edition_conf file tag to `edition_conf-APV-7.4.7`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Clarified and standardized numerous `values.yaml` documentation comments and regenerated the `README.md` and `DEPLOYMENT.md` documentation accordingly. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))

### Fixed

- Fixed `license.enabledCommunityEditionClientApi`, which was incorrectly mandatory; it is now optional (and effective only when `license.edition` is `COMMUNITY`). ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default TLS settings so that `sslConfig.removeProtocols` now correctly removes `SSL`, `TLSv1$`, and `TLSv1.1` on both the server and management SSL configurations. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed `servers.*.sslConfig.removeCipherSuites`, whose configured cipher suites were rendered as allowed instead of removed. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the validation of `sslConfig.enforceServerCipherSuitePreference`, whose error message failed to render, and made it require `allowCipherSuites` to be set when `order` is `config`, on both the server and management SSL configurations. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default `servers.*.clientIdentification.enablePrivate`, which was incorrectly set to `true`; it is now `false`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default startup logging level (`logging.loggers.lightstreamerLogger.subLoggers.init`), which was incorrectly set to `DEBUG`; it is now `INFO`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default `timerPoolSize`, which was incorrectly set to `-1`; it is now `1`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Restored the missing `cpp_client` value for `license.enabledCommunityEditionClientApi`, which should have been available since the previous release, exposing the C++ client API to COMMUNITY edition deployments. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Made both `name` and `value` mandatory for `servers.*.responseHttpHeaders.add` entries, with clearer error messages. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Added validation of `keystores.*.type`, which must now be one of `JKS`, `PKCS12`, or `PKCS11`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Clarified that `keystores.*.keyPasswordSecretRef` is effective only when the keystore is referenced by the Kafka Connector configuration. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Added validation for the `ingress` configuration: `rules` entries are required, `paths.*.pathType` must be one of `Prefix`, `Exact`, or `ImplementationSpecific`, and `paths.*.path` must begin with `/` when `pathType` is `Prefix` or `Exact`; empty TLS hosts are now skipped. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed ServiceAccount handling: the ServiceAccount is now created by default unless `serviceAccount.create` is `false`, `automountServiceAccountToken` defaults to `true` unless `serviceAccount.automount` is `false`, and `serviceAccount` is now required. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the post-install notes (`NOTES.txt`) to safely handle an unset `ingress` configuration. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the autoscaling configuration: `autoscaling.enabled` is now handled safely when the `autoscaling` block is unset, `autoscaling.maxReplicas` is now mandatory when autoscaling is enabled, and `autoscaling.minReplicas` now defaults to `1`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed Kafka Connector GSSAPI/Kerberos authentication: the keytab file referenced by `connectors.kafkaConnector.connections.*.authentication.gssapi.keytabFilePathRef` is now mounted into the container, so keytab-based authentication works. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default Kafka Connector TLS settings so that `encryption.protocol` now defaults to `TLSv1.3` and `encryption.allowProtocols` to `[TLSv1.2, TLSv1.3]`, for both Kafka connections and Schema Registry connections. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed `connectors.kafkaConnector.connections.*.authentication.mechanism`, which was incorrectly mandatory when authentication was enabled; it is now optional. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the Schema Registry `sslConfig`, which was incorrectly mandatory; it is now optional and effective only when the Schema Registry `url` uses HTTPS. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the GSSAPI `principal` requirement, whose condition was inverted; it is now mandatory when `enableTicketCache` is `false`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Fixed the default proxy-adapter `closeNotificationsRecovery`, which is now `pessimistic`. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))
- Improved reliability of the license and proxy configuration handling. ([#6](https://github.com/Lightstreamer/helm-charts/pull/6))

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
