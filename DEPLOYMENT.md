# Deploying Lightstreamer Broker to Kubernetes

This guide provides step-by-step instructions on how to deploy the Lightstreamer Broker to a Kubernetes cluster using the Lightstreamer Helm Chart.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Customize Lightstreamer Broker](#customize-lightstreamer-broker)
  - [License](#license)
    - [Community Edition](#community-edition)
    - [Enterprise Edition](#enterprise-edition)
  - [Configure a New Server Socket Configuration](#configure-a-new-server-socket-configuration)
  - [Multiple Servers](#multiple-servers)
  - [TLS/SSL](#config-tlsssl)
  - [Logging](#logging)
    - [Primary Loggers](#primary-loggers)
    - [Subloggers](#subloggers)
    - [Other Loggers](#other-loggers)
    - [Extra Loggers](#extra-loggers)
    - [Appenders](#appenders)
      - [Log to Persistent Storage](#log-to-persistent-storage)
  - [Monitoring](#monitoring)
    - [Dashboard](#dashboard-configuration)
    - [JMX](#jmx-configuration)
    - [Health Checks](#health-check-configuration)

## Prerequisites

Before you begin, ensure that you have the following prerequisites:

- **Kubernetes**
  
  Access to a running Kubernetes cluster version 1.23.5 or newer. [Install Kubernetes](https://kubernetes.io/docs/setup/)

- **Helm**
  
  Helm client version 3.8.0 or newer installed on your local machine. [Install Helm](https://helm.sh/docs/intro/install/)

- **kubectl**
  
  kubectl version 1.23.5 or newer, compatible with your cluster version. kubectl is needed to interact with your Kubernetes cluster. [Install kubectl](https://kubernetes.io/docs/tasks/tools/)

## Deployment Steps

Follow these steps to deploy the Lightstreamer Broker to your Kubernetes cluser:

1. **Add the Lightstreamer Helm repository:**

    ```sh
    helm repo add lightstreamer https://lightstreamer.github.io/helm-charts
    ```

2. **Update your Helm repositories:**

    ```sh
    helm repo update
    ```

3. **Install the Lightstreamer Helm Chart:**

    ```sh
    helm install lightstreamer lightstreamer/lightstreamer \
        --namespace <namespace> \
        --create-namespace
    ```

4. **Wait for the Lightstreamer Broker to be ready:**

    ```sh
    kubectl rollout status deployment lightstreamer --namespace <namespace> --watch
    ```

    Expected output upon the broker is ready:
    
    ```sh
    deployment "lightstreamer" successfully rolled out
    ```


This will deploy the Lightstreamer Broker and other related components with the default configuration.

For more detailed configuration options, refer to the [Lightstreamer Helm Chart Specification](https://github.com/Lightstreamer/helm-charts/tree/main/charts/lightstreamer).

## Customize Lightstreamer Broker

You can customize the deployment by overriding the default values in two different ways:

1. Use the `--set` option to specify overrides on the command line:
  
   ```sh
   helm install lightstreamer lightstreamer/lightstreamer \
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
     helm install lightstreamer lightstreamer/lightstreamer \
       --values default-server.yaml \
       --namespace lightstreamer \
       --create-namespace
     ```

For more details about general chart customization, refer to the [official Helm documentation](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

In the following sections, we will guide you on how to customize the values of the Lightstreamer Helm chart to configure the most critical aspects of deploying a Lightstreamer Broker to Kubernetes.

### License

The [`license`](README.md#license) section configures the edition and license type for the Lightstreamer Broker.

Two editions are available:

- **Community**: Free edition with feature restrictions
- **Enterprise**: Full-featured commercial edition

#### Community Edition

The Community edition can be used for free but has the following limitations:

- No TLS/SSL support
- Maximum downstream message rate of 1 message/sec
- Limited features compared to Enterprise edition

See the [Software License Agreement](https://lightstreamer.com/distros/ls-server/7.4.6/Lightstreamer%20Software%20License%20Agreement.pdf) for complete details.

To configure the Community edition:

1. Set `license.edition` to `COMMUNITY`
2. Set `license.enabledCommunityEditionClientApi` with the Client API to use with the free license

#### Enterprise Edition

The default configuration uses the Enterprise edition with a _Demo_ license that:

* Can be used for evaluation, development and testing (not production)
* Has a limit of 20 concurrent user sessions

Contact *_info@lightstreamer.com_* for evaluation without session limits or for production licenses

To configure the `ENTERPRISE` edition with a customer license:

1. Set [`license.edition`](README.md#licenseedition) to `ENTERPRISE`
2. Set [`license.enterprise.licenseType`](README.md#licenseenterpriselicensetype) to specify license type
3. Set [`license.enterprise.contractId`](README.md#licenseenterprisecontractid) with your contract identifier
4. Configure license validation using one of these methods:

   **Online Validation**
   
   For license types: `EVALUATION`, `STARTUP`, `PRODUCTION`, `HOT-STANDBY`, `NON-PRODUCTION-FULL`, `NON-PRODUCTION-LIMITED`

   1. Create password secret:
   ```sh
   kubectl create secret generic <online-password-secret-name> \
     --from-literal=online-password=<online-password> \
     --namespace <namespace>
   ```

   2. Configure [`license.enterprise.onlinePasswordSecretRef`](README.md#licenseenterpriseonlinepasswordsecretref):
   ```yaml
   license:
     enterprise:
       ...
       onlinePasswordSecretRef:
         name: <online-password-secret-name>  # Secret name from step 1
         key: online-password                 # Secret key from step 1
   ...
   ```

   **File-based Validation**
   
   For license types: `PRODUCTION`, `HOT-STANDBY`, `NON-PRODUCTION-FULL`, `NON-PRODUCTION-LIMITED`

   1. Create license file secret:
   ```sh
   kubectl create secret generic <license-secret-name> \
     --from-file=license.lic=<path/to/license/file> \
     --namespace <namespace> 
   ```

   2. Configure [`license.enterprise.filePathSecretRef`](README.md#licenseenterprisefilepathsecretref):
   ```yaml
   license:
     enterprise:
       ...
       filePathSecretRef:
         name: <license-secret-name>  # Secret name from step 1
         key: license.lic            # Secret key from step 1
   ...
   ```

See the [License settings](README.md#license) section for additional configuration options. 

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

> [IMPORTANT!]: If you do not want to include the default server socket configuration (`defaultServer`) in the deployment, explicitly disable it as follows:
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

> [TIP!] Ensure that any unused server configurations are explicitly disabled by setting their `enabled` flag to `false`. For example:
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

The default configuration includes loggers for third-party libraries used by the Broker. These loggers typically do not require modification. Refer to the comments in the [values.yaml](charts/lightstreamer/values.yaml#L1039) file for more details.

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

To define additional loggers, add entries to the `extraLoggers` section. This is useful for custom logging requirements.

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

- [`dailyRolling`](charts/lightstreamer/values.yaml#L660): A daily rolling file appender.
- [`console`](charts/lightstreamer/values.yaml#L681): A console appender.

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
````

