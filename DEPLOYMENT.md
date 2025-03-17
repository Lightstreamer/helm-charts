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
    helm repo add lightstreamer https://lightstreamer.github.io/helm-charts
    ```

2. **Update your Helm repositories:**
    ```sh
    helm repo update
    ```

3. **Install the Lightstreamer Helm Chart:**
    ```sh
    helm install lightstreamer-app lightstreamer/lightstreamer --namespace lightstreamer --create-namespace
    ```

This will deploy the Lightstreamer Broker to your Kubernetes cluster with the default configuration.

For more detailed configuration options, refer to the [Lightstreamer Helm Chart documentation](https://github.com/Lightstreamer/helm-charts/tree/main/charts/lightstreamer).

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

For more details about chart customization, refer to the [official Helm documentation](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing).

In the subsequent section, we will guide through the...

### Configure a New Server Socket Configuration

To configure a new server socket, add a new entry to the [`servers`](README.md#servers) section, along with the mandatory settings (namely, [`name`](README.md#serversdefaultservername) and [`port`](README.md#serversdefaultserverport)). In addition, remember to enable the configuration through the [`enabled`](README.md#serversdefaultserverenabled) flag to include the new server socket in the deployment.

```yaml
servers:
  myServerConfiguration:
    enabled: true
    name: "My Lightstreamer server"
    port: 8080
```

> [!IMPORTANT]
> As the `defaultServer` server socket configuration is enabled by default, you must explicitly disable it if you don't want to include it in the deployment:
> ```yaml
> servers:
>   defaultServer:
>     enabled: false    
>   ...
> ```

### Multiple-Servers

Lightstreamer Broker allows the management of multiple server sockets. Therefore you can specify as server socket configurations as you want by adding the the relative entries:

```yaml
# Multiple server socket configurations
servers:

  # Server socket listening on port 8081
  http-Server1:
    enabled: true
    name: "HTTP Server 1"
    port: 8081

  # Server socket listening on port 8082
  http-Server2:
    enabled: true
    name: "HTTP Server 2"
    port: 8082   

  # Server socket listening on port 8083
  http_Server3:
    enabled: true
    name: "HTTP Server 3"
    port: 8083
```

### Config TLS/SSL

To configure TLS/SSL settings for a server socket configuration:

- Set the [`enableHttps`](README.md#serversdefaultserverenablehttps) to `true`
- Configure a keystore:
  
  1. Create a secret containing the keystore:

     ```sh
     kubectl create secret generic <keystore-secret-name> --from-file=server.keystore=<path/to/keystore> --namespace <namespace>
     ```

  2. Create a secret containing the keystore password:

     ```sh
     kubectl create secret generic <keystore-password-secret-name> --from-literal=password=<keystore-password> --namespace <namespace>
     ```

  3. Define a new keystore in the [`keystores`](README.md#keystores) section:

     ```yaml
     keystores:
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
- If required, configure a truststore by repeating similar actions of the previous section

- Configure the [`sslConfig`](README.md#serversdefaultserversslconfig) section:
  
  ```yaml
  servers:
    mtyHttpServer:
      ...
      sslConfig:
        # The reference to the keystore definition
        keystoreRef: serverKeyStore

        # If required, the reference to the truststore definition
        truststoreRef: <>

        # Other settings
        ...
  ```

The 
Here a simple example:

```yaml
servers:
  myHttpServer:
    enabled: true
    name: "Lightstreamer HTTPS server"
    enableHttps: true # Mandatory to enable the sslConfig block

  sslConfig:

    keystoreRef: 
```

### Logging

### Dashboard

### JMX

### Health Check

## Configure Licensing
  



