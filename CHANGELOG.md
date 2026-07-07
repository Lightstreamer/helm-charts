# Changelog

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
