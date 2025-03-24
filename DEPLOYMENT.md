# Deploying Lightstreamer Broker to Kubernetes

This guide provides step-by-step instructions on how to deploy the Lightstreamer Broker to a Kubernetes cluster using the Lightstreamer Helm Chart.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Customize Lightstreamer Broker](#customize-lightstreamer-broker)
  - [License](#license)
    - [Community Edition](#community-edition)
    - [Enterprise Edition](#enterprise-edition)
  - [Server Socket](#server-socket)
    - [Multiple Servers](#multiple-servers)
    - [TLS/SSL](#tlsssl)
  - [Logging](#logging)
    - [Primary Loggers](#primary-loggers)
    - [Subloggers](#subloggers)
    - [Other Loggers](#other-loggers)
    - [Extra Loggers](#extra-loggers)
    - [Appenders](#appenders)
      - [Log to Persistent Storage](#log-to-persistent-storage)
  - [JMX](#jmx)
    - [RMI Connector](#rmi-connector)
      - [TLS/SSL](#tlsssl-1)
      - [Authentication](#authentication)
  - [Monitoring Dashboard](#monitoring-dashboard)
    - [Authentication](#authentication-1)
    - [Availability on specific server](#availability-on-specific-server)
    - [Custom Dashboard URL path](#custom-dashboard-url-path)
    - [Hands-on example](#hands-on-example)
  - [Adapters](#adapter-set)
    - [In-process Adapters](#in-process-adapters)
      - [`common` ClassLoader](#common-classloader)
      - [`dedicated` ClassLoader](#dedicated-classloader)
      - [`log-enabled` ClassLoader](#log-enabled-classloader)
      - [Summary of ClassLoader types](#summary-of-classloader-types)

## Prerequisites

Before you begin, ensure that you have the following prerequisites:

- **Kubernetes**

  Access to a running Kubernetes cluster version 1.23.5 or newer. [Install Kubernetes](https://kubernetes.io/docs/setup/)

- **Helm**

  Helm client version 3.8.0 or newer installed on your local machine. [Install Helm](https://helm.sh/docs/intro/install/)

- **kubectl**

  kubectl version 1.23.5 or newer, compatible with your cluster version. kubectl is needed to interact with your Kubernetes cluster. [Install kubectl](https://kubernetes.io/docs/tasks/tools/)

## Deployment steps

Follow these steps to deploy the Lightstreamer Broker to your Kubernetes cluster:

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

#### Community edition

The Community edition can be used for free but has the following limitations:

- No TLS/SSL support
- Maximum downstream message rate of 1 message/sec
- Limited features compared to Enterprise edition

See the [Software License Agreement](https://lightstreamer.com/distros/ls-server/7.4.6/Lightstreamer%20Software%20License%20Agreement.pdf) for complete details.

To configure the Community edition:

1. Set `license.edition` to `COMMUNITY`
2. Set `license.enabledCommunityEditionClientApi` with the Client API to use with the free license

Example:

```yaml
license:
  edition: COMMUNITY
  enabledCommunityEditionClientApi:  "javascript_client"
```

#### Enterprise edition

The default configuration uses the Enterprise edition with a _Demo_ license that:

* Can be used for evaluation, development and testing (not production)
* Has a limit of 20 concurrent user sessions

Contact *_info@lightstreamer.com_* for evaluation without session limits or for production licenses

To configure the `ENTERPRISE` edition with a customer license:

1. Set [`license.edition`](README.md#licenseedition) to `ENTERPRISE`.
2. Set [`license.enterprise.licenseType`](README.md#licenseenterpriselicensetype) to specify license type.
3. Set [`license.enterprise.contractId`](README.md#licenseenterprisecontractid) with your contract identifier.
4. Configure license validation using one of these methods:

   **Online Validation**

   For license types: `EVALUATION`, `STARTUP`, `PRODUCTION`, `HOT-STANDBY`, `NON-PRODUCTION-FULL`, `NON-PRODUCTION-LIMITED`

   1. Create password secret:
   ```sh
   kubectl create secret generic <online-password-secret-name> \
     --from-literal=online-password=<online-password> \
     --namespace <namespace>
   ```

   2. Set [`license.enterprise.licenseValidation`](README.md#licenseenterpriselicensevalidation) to `ONLINE`.
   
   3. Configure [`license.enterprise.onlinePasswordSecretRef`](README.md#licenseenterpriseonlinepasswordsecretref) with the name and the key of the secret generated at step 1.

   Example configuration:
   ```yaml
   license:
     edition: ENTERPRISE
     enterprise:
       licenseType: <license-type>
       contractId: <contract-id>
       licenseValidation: ONLINE              # Use the online-based validation
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

   2. Set [`license.enterprise.licenseValidation`](README.md#licenseenterpriselicensevalidation) to `FILE`. 

   3. Configure [`license.enterprise.filePathSecretRef`](README.md#licenseenterprisefilepathsecretref) with the name and the key of the secret generated at step 1.

   Example configuration:
   ```yaml
   license:
     edition: ENTERPRISE
     enterprise:
       licenseType: <license-type>
       contractId: <contract-id>
       licenseValidation: FILE        # Use the file-based validation
       filePathSecretRef:
         name: <license-secret-name>  # Secret name from step 1
         key: license.lic             # Secret key from step 1
   ...
   ```

See the [License settings](README.md#license) section of the _Lightstreamer Helm Chart specification_ for additional license configuration options.

### Server socket

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

> [!IMPORTANT]
> If you do not want to include the default server socket configuration (`defaultServer`) in the deployment, explicitly disable it as follows:
> ```yaml
> servers:
>   defaultServer:
>     enabled: false
> ...
> ```

#### Multiple servers

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

> [!TIP]
>Ensure that any unused server configurations are explicitly disabled by setting their `enabled` flag to `false`. For example:
> ```yaml
> servers:
>   unusedServer:
>     enabled: false
> ```

#### TLS/SSL

To configure TLS/SSL settings for a server socket configuration, perform the following actions:

- Set the [`enableHttps`](README.md#serversdefaultserverenablehttps) flag of the target server configuration to `true`:

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
See the [`servers.defaultServer.sslConfig`](README.md#serversdefaultserversslconfig) section of the _Lightstreamer Helm Chart specification_ for additional TLS/SLS configuration options.

### Logging

The provided logging settings are designed to meet the needs of most production environments. However, you can customize the configuration to suit specific requirements.

See the [_Logging_](README.md#logging) section of the _Lightstreamer Helm Chart specification_ for full details about logging configuration.

#### Primary loggers

The [`logging.loggers`](README.md#loggingloggers) section defines the primary loggers used by the Lightstreamer Broker:

- [`lightstreamerLogger`](README.md#loggingloggerslightstreamerlogger): Logs major activities of the Lightstreamer Broker.
- [`lightstreamerMonitorText`](README.md#loggingloggerslightstreamermonitortext) and [`lightstreamerMonitorTAB`](README.md#loggingloggerslightstreamermonitortab): Log statistics in text and tabular formats, respectively.
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

#### Other loggers

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

#### Extra loggers

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

- [`dailyRolling`](charts/lightstreamer/values.yaml#L660): A daily rolling file appender
- [`console`](charts/lightstreamer/values.yaml#L681): A console appender

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

##### Log to persistent storage

To persist log files, you can configure the `DailyRollingFile` appender to write to a Kubernetes volume. Here's how to set it up:

1. **Define a volume**

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

2. **Configure the appender**

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

### JMX

The Lightstreamer Broker exposes a comprehensive set of monitoring metrics and management operations through JMX (Java Management Extensions). This is an optional feature that may not be included in your license.

JMX support is designed to integrate with monitoring and management tools via two protocols:
- _JMXMP_: A pure TCP-based protocol
- _RMI_: The standard Java Remote Method Invocation protocol

See the [JMX API documentation](https://lightstreamer.com/ls-jmx-sdk/latest/api/index.html) for details on available metrics and operations.

#### RMI Connector

The default configuration enables an RMI Connector listening on TCP port `8888`. You can verify this by checking the pod's exposed ports:

```sh
kubectl get pods -l app.kubernetes.io/name=lightstreamer -o jsonpath="{.items[0].spec.containers[0].ports}" --namespace <namespace> | jq
```
> [!TIP]
> Notice the usage of the [`jq`](https://jqlang.org/) tool to simplify the processing of JSON outputs.

Expected output:
```json
[
  {
    "containerPort": 8080,
    "name": "default-server",
    "protocol": "TCP"
  },
  {
    "containerPort": 8888,
    "name": "jmx-port",
    "protocol": "TCP"
  }
]
```

The following example shows how to customize the RMI Connector listening port through the [`management.jmx.rmiConnector.port`](README.md#managementjmxrmiconnectorport) setting:

```yaml
management:
  jmx:
    rmiConnector:
      port:
        value: 9999
```

See the [`management.jmx.rmiConnector`](README.md#managementjmxrmiconnector) section of the _Lightstreamer Helm Chart specification_ for full details about other configurable RMI Connector settings.

##### TLS/SSL

To enable TLS/SSL communication, turn on the optional [`management.jmx.rmiConnector.port.enableSsl`](README.md#managementjmxrmiconnectorportenablessl) flag and reference a keystore trough [`management.jmx.rmiConnector.keystoreRef`](README.md#managementjmxrmiconnectorsslconfigkeystoreref) (as already explained in the [_TLS/SSL_](#tlsssl) ):

```yaml
management:
  jmx:
    rmiConnector:
      port:
        value: 9999
        enableSsl: true        # Enables TLS/SSL communication
      keystoreRef: rmiKeystore # Reference to a keystore
```

> [!WARNING]
> Make sure to enable TLS/SSL communication in a production deployment.

See the [`management.jmx.rmiConnector.sslConfig`](README.md#managementjmxrmiconnectorsslconfig) section of the _Lightstreamer Helm Chart specification_ for additional TLS/SSL configuration options for the RMI Connector. 

##### Authentication

To restrict access to authorized users, first create the relative secrets (every one including the mandatory keys `user` and `password`). For example:

```sh
kubectl create secret generic rmi-user-1-secret --from-literal=user=<user-1> --from-literal=password='<user1-password>' --namespace <namespace>
kubectl create secret generic rmi-user-2-secret --from-literal=user=<user-2>' --from-literal=password='<user2-password>' --namespace <namespace>
```

Then, disable public access turning off the [`management.jmx.rmiConnector.enablePublicAccess`](README.md#managementjmxrmiconnectorenablepublicaccess) flag and populate the [`management.jmx.rmiConnector.credentialsSecrets`](README.md#managementjmxrmiconnectorcredentialssecrets) list with the references to the secrets.

Example:
```yaml
management:
  jmx:
    rmiConnector:
      enablePublicAccess: false # Requires authenticated RMI Connector access
      credentialsSecrets:       # List of secrets
        - rmi-user-1-secret     
        - rmi-user-2-secret
```

> [!WARNING]
> Make sure to enable authenticated access in a production deployment.

### Monitoring Dashboard

The _Monitoring Dashboard_ provides a web interface for monitoring and managing a Lightstreamer Broker instance. It includes several tabs showing basic monitoring statistics in graphical form and a JMX Tree view that enables data viewing and management operations from the browser.

Since the Dashboard enables remote management, including server shutdown, it is critical to secure access in a production environment by applying the following recommended actions:

- Require authentication for Dashboard access.
- Create users with different levels of access to the JMX Tree.
- Restrict the Dashboard to HTTPS servers only (if TLS/SSL is allowed by our license)
- Customize the dashboard URL path.

#### Authentication

To restrict access, create Kubernetes secrets for Dashboard users and configure authentication:

1. Create secrets for Dashboard users:

   ```sh
   # Create secret for the first dashboard user
   kubectl create secret generic dashboard-user1-secret \
     --from-literal=user=admin \
     --from-literal=password='secretpass' \
     --namespace <namespace>
 
   # Create secret for the second dashboard user
   kubectl create secret generic dashboard-user2-secret \
     --from-literal=user=monitor \
     --from-literal=password='monitorpass' \
     --namespace <namespace>
   ```
 
  > [!IMPORTANT]
  > Secrets must include the mandatory keys `user` and `password`.

2. Configure authentication:

   ```yaml
   management:
     dashboard:
       enablePublicAccess: false  # Disable public access
       enableJmxTree: true        # Globally enable JMX Tree view
   
       credentials:
         - secretRef: dashboard-user1-secret
           enableJmxTreeVisibility: true  # Allow JMX Tree access
         - secretRef: dashboard-user2-secret
           enableJmxTreeVisibility: false # Restrict JMX Tree access
   ```

#### Availability on specific server

To limit the Dashboard's availability to specific servers, configure the following in the Helm chart values:

```yaml
management:
  dashboard:
    enableAvailabilityOnAllServers: false  # Disable availability on all servers

    availableOnServers:
      - serverRef: httpsServer         # Reference to a socket configuration defined the servers section
        enableJmxTreeVisibility: true  # Allow JMX Tree access
```

#### Custom Dashboard URL path

To change the default Dashboard url:

```yaml
management:
  dashboard:
    ...
    urlPath: /monitoring  # Custom dashboard path
```

#### Hands-on example

The [examples/dashboard](examples/dashboard/) directory provides a complete example of Dashboard configuration that shows how to:

- Configure a dedicated HTTPS server socket for secure Dashboard access
- Set up user authentication with different permission levels
- Customize the Dashboard URL path

See the [`management.dashboard`](README.md#managementdashboard) section of the _Helm Lightstreamer Chart specification_ for full details about available Monitoring Dashboard settings.

### Adapters

The Adapters are a crucial components in the Lightstreamer architecture that connect the Lightstreamer Broker to your backend systems. Each Adapter Set consists of:

- A **Metadata Adapter**: Handles client authentication, authorization, and item validation
- One or more **Data Adapters**: Handle real-time data by fetching, transforming, and publishing updates

Lightstreamer Adapters can be implemented in two ways:
- **In-Process Adapters**: Java classes running within the Lightstreamer Broker's JVM
- **Remote Adapters**: External processes communicating with the Lightstreamer Broker through the Remote Server API

To define an Adapter Set, add a new configuration to `adapters` section with the following mandatory settings:

- [`id`](README.md#adaptersmyadaptersetid): A unique id for the adapter set
- [`metadataProvider`](README.md#adaptersmyadaptersetmetadataprovider): A Metadata Adapter configuration
- [`dataProviders`](README.md#adaptersmyadaptersetmetadataprovider): One or more Data Adapter configurationA Metadata Adapter configuration

Moreover, set the [`enabled`](README.md#adaptersmyadaptersetenabled) flag to `true` to include the adapter set in in the deployment.

Example configuration:

```yaml
adapters:
  # Define an Adapter Set configuration
  myAdapterSet:
    
    enabled: true

    id: "MY_ADAPTER_SET"

    metadataProvider:
    ...

    dataProviders:
    ...
    
```

#### In-process Adapters

You can configure in-process Metadata Adapters and Data Adapters by populating the following sections in your Helm chart values:

- [`metadataProvider.inProcessMetadataAdapter`](README.md#adaptersmyadaptersetmetadataproviderinprocessmetadataadapter)
- [`dataProviders.<dataProviderName>.inProcessDataAdapter`](README.md#adaptersmyadaptersetdataprovidersmydataproviderinprocessdataadapter)

These sections share the following key settings:

- `adapterClass`: The fully qualified name of the Java class implementing the Adapter.

- `installDir`:  The optional location in the provisioning source of top-level directory containing the `lib` and/or `classes` folders.

- `classLoader`: The type of ClassLoader to use for loading the Adapter's classes, how explained in the subsequent sections.

##### `common` ClassLoader

When the `classLoader` is set to `common`, the _Adapter Set ClassLoader_ is used. 
This ClassLoader load classes included in the `lib` and `classes` subfolders from three different sources:

1. The Adapter Set's directory:

   ```sh
   my-adapter-set/
   ├── classes # Common classes
   └── lib     # Common jar files
   ```
   
   Example configuration:
   ```yaml
   adapters:
     myAdapterSet:
       metadataProvider:
         inProcessMetadataAdapter:
           adapterClass: com.mycompany.adapters.metadata.MyMetadataAdapter
           classLoader: common 
           ...
       dataProviders:
         myDataProvider:
           inProcessDataAdapter:
             adapterClass: com.mycompany.adapters.data.MyDataAdapter
             classLoader: common
            ...
   ```

2. The specified `installDir`:

   ```sh
   my-adapter-set/
   ├── classes # Common classes
   ├── lib     # Common jar files
   └── metadata    # MetadataAdapter-specific resources
       ├── classes 
       └── lib     
   └── data        # DataAdapter-specific resources
       ├── classes 
       └── lib     
   ```

   Example configuration:
   ```yaml
   adapters:
     myAdapterSet:
       metadataProvider:
         inProcessMetadataAdapter:
           adapterClass: com.mycompany.adapters.metadata.MyMetadataAdapter
           installDir: metadata # MetadataAdapter-specific resources
           classLoader: common
           ...
       dataProviders:
         myDataProvider:
           inProcessDataAdapter:
             adapterClass: com.mycompany.adapters.metadata.MyMetadataAdapter
             installDir: data # DataAdapter-specific resources
             classLoader: common
             ...
   ```

3. The Lightstreamer Broker's `shared` folder:
   The Adapter Set ClassLoader inherits from a global ClassLoader, which includes classes and resources from the `shared` folder of the Lightstreamer Broker deployment. This allows multiple Adapter Sets to share common resources.

   ```mermaid
   flowchart BT
     A1[Adapter Set ClassLoader]-->G[Global ClassLoader] 
     A2[Adapter Set ClassLoader]-->G[Global ClassLoader] 
     A3[Adapter Set ClassLoader]-->G[Global ClassLoader]  
   ```
    
   Example shared directory structure:
   ```sh
   /lightstreamer/shared/
   ├── classes # Globally shared classes
   └── lib     # Globally shared jar files
   ```

#### `dedicated` ClassLoader

When the `classLoader` is set to `dedicated`, a dedicated ClassLoader is assigned to the Adapter. This ClassLoader includes classes from the `<installDir>/lib` and `<installDir>/classes` folders. The `installDir` setting is mandatory in this case.

```mermaid
flowchart BT
    A1[Adapter Set ClassLoader]-->G[Global ClassLoader] 
    A2[Adapter Set ClassLoader]-->G[Global ClassLoader] 
    D1[Dedicated ClassLoader]-->A1
    D2[Dedicated ClassLoader]-->A1
    D3[Dedicated ClassLoader]-->A2
```   

Example configuration:

```sh
adapters/my-adapter-set/
├── classes     # Common classes loaded by the Adapter Set ClassLoader
├── lib         # Common jar files loaded by the Adapter Set ClassLoader
└── metadata    
    ├── classes # Classes and resources loaded by the dedicated MetadataAdapter's ClassLoader
    └── lib     # Jar files loaded by the dedicated MetadataAdapter's ClassLoader
└── data        
    ├── classes # Classes and resources loaded by the dedicated DataAdapter's ClassLoader
    └── lib     # Jar files loaded by the dedicated DataAdapters's ClassLoader
```

The following example:

```yaml
adapters:
  myAdapterSet:
    metadataProvider:
      inProcessMetadataAdapter:
        adapterClass: com.mycompany.adapters.metadata.MyMetadataAdapter
        installDir: metadata 
        classLoader: dedicated
        ...
    dataProviders:
      myDataProvider:
        inProcessDataAdapter:
          adapterClass: com.mycompany.adapters.metadata.MyMetadataAdapter
          installDir: data 
          classLoader: dedicated 
          ...
```

##### `log-enabled` ClassLoader

When the `classLoader` is set to `log-enabled`, the Adapter is assigned a dedicated ClassLoader which also includes the `slf4j` library used by the Lightstreamer Broker.
This implies that the Adapter the Broker's logging configuration. 
The ClassLoader does not inherit from the Adapter Set ClassLoader, hence the Adapter cannot share classes with other Adapters.

Example configuration:
```yaml
adapters:
  myAdapterSet:
    metadataProvider:
      inProcessMetadataAdapter:
        adapterClass: com.mycompany.adapters.metadata.MyMetadataAdapter
        classLoader: log-enabled
    dataProviders:
      myDataProvider:
        inProcessDataAdapter:
          adapterClass: com.mycompany.adapters.data.MyDataAdapter
          classLoader: log-enabled
```

##### Summary of ClassLoader types

| ClassLoader Type | Description                                                                                     | Use Case                                                                 |
|------------------|-------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| `common`         | Uses the Adapter Set ClassLoader, which includes all classes in the `lib` and `classes` folders | Suitable for simple setups where all adapters share the same resources   |
| `dedicated`      | Assigns a dedicated ClassLoader to the Adapter, inheriting from the Adapter Set ClassLoader     | Useful when adapters require isolated resources or specific dependencies |
| `log-enabled`    | Includes the `slf4j` library and shares the Broker's logging configuration                     | Suitable for adapters that need to integrate with the Broker's logging   |

By carefully organizing your Adapter Set's directory structure and selecting the appropriate `classLoader` type, you can optimize resource sharing and ensure proper isolation between adapters.

##### Proxy Adapters
