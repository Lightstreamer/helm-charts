# Deploying Lightstreamer Broker to Kubernetes

This guide provides step-by-step instructions on how to deploy the Lightstreamer Broker to a Kubernetes cluster using the Lightstreamer Helm Chart.

## Prerequisites

Before you begin, ensure that you have the following prerequisites:

- A running Kubernetes cluster
- Helm installed on your local machine
- Access to the Lightstreamer Helm Chart repository

## Installation Steps

Follow these steps to deploy the Lightstreamer Broker:

1. **Add the Lightstreamer Helm repository:**
    ```sh
    $ helm repo add lightstreamer https://lightstreamer.github.io/helm-charts
    ```

2. **Update your Helm repositories:**
    ```sh
    $ helm repo update
    ```

3. **Install the Lightstreamer Helm Chart:**
    ```sh
    $ helm install lightstreamer-app lightstreamer/lightstreamer --namespace lightstreamer --create-namespace
    ```

This will deploy the Lightstreamer Broker to your Kubernetes cluster with the default configuration.

For more detailed configuration options, refer to the [Lightstreamer Helm Chart documentation](https://github.com/Lightstreamer/helm-charts/tree/main/charts/lightstreamer).

## Customize Lightstreamer Broker

You can customize the deployment by overriding the default values in two different ways:

1. Use the `--set` option to specify overrides on the command line:
  
   ```sh
   $ helm install lightstreamer lightstreamer/lightstreamer \
     --set servers.defaultServer.name="My Lightstreamer HTTP Server" \
     --namespace lightstreamer \
     --create-namespace
   ```

2. Use the `--values` to specify one or more YAMLs file with overrides. For example:
   
   - Edit the file `default-server.yaml` as follows:
  
     ```yaml
     servers:
       defaultServer:
         name: "My Lightstreamer HTTP Server"
     ```
   
   - Run the helm command:

     ```sh
     $ helm install lightstreamer lightstreamer/lightstreamer \
       --values default-server.yaml \
       --namespace lightstreamer \
       --create-namespace
     ```

For more details about general chart customization, refer to the [official Helm documentation](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

In the following sections, we will guide you on how to customize the values of the Lightstreamer Helm chart to configure the most critical aspects of deploying a Lightstreamer Broker to Kubernetes.

### Configure a New Server Socket Configuration

To configure a new server socket, add a new entry to the [`servers`](README.md#servers) section with the following mandatory settings:

- [`name`](README.md#serversdefaultservername): A unique name for the server socket.
- [`port`](README.md#serversdefaultserverport): The port number the server socket will listen on.

Moreover, set the [`enabled`](README.md#serversdefaultserverenabled) flag to `true` to include the server socket in the deployment.

Example configuration:

```yaml
servers:
  myServerConfiguration:
    enabled: true
    name: "My Lightstreamer server"
    port: 8080
```

> [!IMPORTANT]: If you do not want to include the default server socket configuration (`defaultServer`) in the deployment, explicitly disable it as follows:
> ```yaml
> servers:
>   defaultServer:
>     enabled: false
> ...
> ```

### Multiple Servers

Lightstreamer Broker supports managing multiple server sockets. You can define multiple server socket configurations by adding entries under the `servers` section in your values file.
Each configuration must specify a unique name and port.

Example configuration:

```yaml
# Multiple server socket configurations
servers:

  # Server socket listening on port 8081
  httpServer1:
    enabled: true
    name: "HTTP Server 1"
    port: 8081

  # Server socket listening on port 8082
  httpServer2:
    enabled: true
    name: "HTTP Server 2"
    port: 8082   

  # Server socket listening on port 8083
  httpServer3:
    enabled: true
    name: "HTTP Server 3"
    port: 8083
```

> [!TIP] Ensure that any unused server configurations are explicitly disabled by setting their `enabled` flag to `false`. For example:
> ```yaml
> servers:
>   unusedServer:
>     enabled: false
> ```

### TLS/SSL

To configure TLS/SSL settings for a server socket configuration, perform the following actions:

- Set the [`enableHttps`](README.md#serversdefaultserverenablehttps) flag of the target server configuration to `true`
  
  ```yaml
  servers:
    defaultServer:
      enableHttps: true
      ...
  ```

- Configure a keystore:
  
  1. Create a secret containing the keystore:

     ```sh
     $ kubectl create secret generic <keystore-secret-name> --from-file=server.keystore=<path/to/keystore> --namespace <namespace>
     ```

  2. Create a secret containing the keystore password:

     ```sh
     $ kubectl create secret generic <keystore-password-secret-name> --from-literal=password=<keystore-password> --namespace <namespace>
     ```

  3. Define a new keystore in the [`keystores`](README.md#keystores) section:

     ```yaml
     keystores:
       ...

       serverKeystore:
         # The keystore type, here we assume JKS
         type: JKS
        
         keystoreFileSecretRef:
           name: <keystore-secret-name> # The name used at step 1
           key: server.keystore         # The secret key as specified at step 1

         keystorePasswordSecretRef:
           name: <keystore-password-secret-name> # The name used at step 2
           key: password                         # The secret key as specified at step 2
     ```
    
- If required, configure a truststore by repeating similar actions of the previous section:

  1. Create the truststore secrets:
  
     ```sh
     $ kubectl create secret generic <truststore-secret-name> --from-file=server.truststore=<path/to/truststore> --namespace <namespace>
     $ kubectl create secret generic <truststore-password-secret-name> --from-literal=password=<truststore-password> --namespace <namespace>
     ```

  2. Define a truststore:

     ```yaml
     keystores:
       serverTruststore:
         # The truststore type, here we assume JKS
         type: JKS
      
         keystoreFileSecretRef:
           name: <truststore-secret-name> 
           key: server.truststore          

         keystorePasswordSecretRef:
           name: <truststore-password-secret-name> 
           key: password                           
     ```

- Configure the [`sslConfig`](README.md#serversdefaultserversslconfig) section:
  
  ```yaml
  servers:
    defaultServer:
      ...
      sslConfig:
        # The reference to the keystore definition
        keystoreRef: serverKeyStore

        # If required, the reference to the truststore definition
        truststoreRef: serverTruststore

        # Other settings
        ...
  ```

### Logging

The provided logging settings are designed to meet the needs of most production environments. However, you can customize the configuration to suit specific requirements.

#### Primary Loggers

The [`logging.loggers`](README.md#loggingloggers) section defines the primary loggers used by the Lightstreamer Broker:

- [`lightstreamerLogger`](README.md#loggingloggerslightstreamerlogger): Logs major activities of the Lightstreamer Broker.
- [`lightstreamerMonitorText`](README.md#loggingloggerslightstreamermonitortext) and [`lightstreamerMonitorTAB`](README.md#loggingloggerslightstreamermonitortab): Log load statistics in text and tabular formats, respectively.
- [`lightstreamerHealthCheck`](README.md#loggingloggerslightstreamerhealthcheck): Logs health check requests.
- [`lightstreamerProxyAdapters`](README.md#loggingloggerslightstreamerproxyadapters): Logs activities of Proxy Data and Metadata Adapters.

For each logger, you can configure the following settings:

- `level`: Specifies the logging level. Available levels are `OFF`, `FATAL`, `ERROR`, `WARN`, `INFO`, `DEBUG`, and `TRACE`.
- `appenders`: Lists the appenders used to log messages. Each entry must reference an appender defined in the [`logging.appenders`](README.md#loggingappenders) section.

Example configuration:
```yaml
logging:
  loggers:
    lightstreamerMonitorText:
      appenders:
        - dailyRolling
      level: DEBUG

    lightstreamerLogger:
      level: TRACE
...
```

#### Subloggers

The [`logging.loggers.lightstreamerLogger.subLoggers`](README.md#loggingloggerslightstreamerloggersubloggers) section allows you to define logging levels for subloggers of `lightstreamerLogger`. Subloggers inherit appenders from their parent logger.

Example configuration:
```yaml
logging:
  loggers:
    lightstreamerLogger:
      level: INFO
      subLoggers:
        lightstreamerLogger.io: DEBUG
        lightstreamerLogger.io.ssl: DEBUG
...
```

#### Other Loggers

The default configuration includes loggers for third-party libraries used by the Lightstreamer Broker. These loggers are pre-configured to handle typical scenarios and generally do not require modification. However, you can adjust their settings if specific logging behavior is needed.

Refer to the comments in the [values.yaml](charts/lightstreamer/values.yaml#L1039) file for more details about these loggers and their default configurations.

Example configuration:
```yaml
logging:
  loggers:
    java.sql:
      appenders:
        - console
      level: WARN

    org.jboss.logging:
      appenders:
        - console
      level: WARN
...
```

#### Extra Loggers

To accommodate custom logging requirements, you can define additional loggers in the `extraLoggers` section. This is particularly useful for logging activities specific to your deployment or application.

Each custom logger can specify its own appenders and logging level, allowing for fine-grained control over logging behavior.

Example configuration:
```yaml
extraLoggers:
  myLogger:
    appenders:
      - console
    level: INFO
...
```

#### Appenders

The [`logging.appenders`](README.md#loggingappenders) section defines the appenders available for use by loggers. The default configuration includes:

- [`dailyRolling`](charts/lightstreamer/values.yaml#L660): A daily rolling file appender, which uses the `DailyRollingFile` type.
- [`console`](charts/lightstreamer/values.yaml#L681): A console appender, which sues the `Console` type.

You can customize these appenders or define new ones.

Example of defining a new appender:
```yaml
logging:
  appenders:
    ...
    anotherConsoleAppender:
      type: Console
      pattern: "[My Custom Appender]|%-27.27t|%m%"
...
```

To use the new appender, reference it in a logger configuration:
```yaml
logging:
  loggers:
    lightstreamerLogger:
      level: INFO
      appenders:
        - anotherConsoleAppender
...
```

##### Log to Persistent Storage

To persist log files, you can configure the `DailyRollingFile` appender to write to a Kubernetes volume. Here's how to set it up:

1. **Define a Volume**
  
   Configure a volume in the `deployment.extraVolumes` section. You can use various volume types:

   ```yaml
   deployment:
     extraVolumes:
       # Using emptyDir (temporary storage)
       - name: log-volume
         emptyDir: {}
       
       # Or using PersistentVolumeClaim (permanent storage)
       - name: log-volume
         persistentVolumeClaim:
           claimName: lightstreamer-logs-pvc
   ```

2. **Configure the Appender**
   
   Configure your logging appender to use the volume:

   ```yaml
   logging:
     appenders:
       dailyRollingAppender:
         type: DailyRollingFile
         # Log file format
         pattern: "%d{ISO8601}|%-5p|%-20.20c{1}|%m%n"
         
         # Log file settings
         fileName: "lightstreamer.log"
         fileNamePattern: "lightstreamer-%d{yyyy-MM-dd}.log"
         
         # Volume reference
         volumeRef: log-volume
         
         # Retention settings (optional)
         maxHistory: 30
         totalSizeCap: "3GB"
   ```

### Dashboard Configuration

The Lightstreamer Dashboard provides a web interface for monitoring and managing your Lightstreamer instance. To configure the dashboard:

```yaml
dashboard:
  enabled: true
  # Configure authentication
  auth:
    username: admin
    passwordSecretRef:
      name: dashboard-password
      key: password
  # Configure access restrictions
  allowedAddresses:
    - "10.0.0.0/8"
    - "172.16.0.0/12"
```

### JMX Configuration

Enable JMX monitoring and configure connection settings:

```yaml
jmx:
  enabled: true
  port: 7777
  # Optional SSL configuration
  ssl:
    enabled: true
    keystoreRef: jmxKeystore

  # Access control
  auth:
    enabled: true
    passwordSecretRef:
      name: jmx-password
      key: password
```

### Health Check Configuration

Configure readiness and liveness probes for Kubernetes health checks:

```yaml
healthcheck:
  # Readiness probe
  readiness:
    enabled: true
    path: "/health/readiness"
    port: 8080
    initialDelaySeconds: 30
    periodSeconds: 10

  # Liveness probe
  liveness:
    enabled: true
    path: "/health/liveness"
    port: 8080
    initialDelaySeconds: 60
    periodSeconds: 20
```

## Configure Licensing




