# In-Process Adapters configuration examples

The following examples demonstrate how to configure and deploy the Lightstreamer Helm chart with with in-process Adapter Sets.

The [`example-adapter-set`](example-adapter-set/) set folder contains a _gradle_ project for building a sample Adapter Set, with the purpose to illustrate the available provisioning and configuration options.

Here the project structure:
...


## Example 1. Embed Adapters in the Docker image

The in-process Adapters will be embedded into the Docker image, which will be then references from the Helm Chart values

To make it easy using a custom container image, a _minikube_ local cluster will be used to deploy the Helm chart.

To deploy the 

1. Build the Adapter Set and to generate the deployment files under `build/lib/example-adapter-set`
    
   ```sh
   ./gradlew deploy
   ```

   Expected layout of output directory:

   ```sh
   build/example-adapter-set/
   └── lib
       └── first-adapter-1.0.0.jar
   ```

2. Build the Docker image:

   The Dockerfile simply derives from the official Lightstreamer Image and copy the adapter deployment files to the `/lightstreamer/adapters` folder:

   ```yaml
   FROM lightstreamer
   COPY build/example-adapter-set /lightstreamer/adapters/example-adapter-set
   ```
   
   ```sh
   docker build -t example-lightstreamer-adapters .
   ```

3. Push the Docker image to minikube:

   ```sh
   minikube image load example-lightstreamer-adapters:latest
   ```
   
4. Configure the Adapter Set.

   The values.yaml 
   Override the image.repository settings with the custom Docker image

6. Install the Helm chart using the values.yaml

   ```bash
   # Install the chart using the custom values file
   helm install lightstreamer lightstreamer/lightstreamer \
     -f values.yaml \
     --namespace lightstreamer
   ```

## Example 2. Deploy Adapters to a persistent storage


## Configuration 

According to the examples show nin the [_Monitoring Dashboard_](../../DEPLOYMENT.md#monitoring-dashboard) section of the deployment documentation, the `values.yaml` file provides:

- An additional [secure server socket](values.yaml#L3) dedicated for the Dashboard
- Definition of two separated service ports:
  - [Port](values.yaml#L14) for the the default server
  - [Port](values.yaml#L19) for Dashboard access
- Dashboard management settings:
  - [Authorized users](values.yaml#L28) with different levels of access to the JMX Tree
  - [Access restriction](values.yaml#37) to the the dedicated HTTPS server only
  - [Custom monitoring path](values.yaml#40) at `/monitoring`
  
## Prerequisites

Before proceeding with this example:

1. Complete the [general deployment prerequisites](../../DEPLOYMENT.md#prerequisites) which include:
   - Setting up a Kubernetes cluster
   - Installing kubectl and configuring access to your cluster
   - Installing Helm
   - Adding and updating the Lightstreamer Helm repository

2. This example uses `lightstreamer` as the target namespace. Create the namespace and the required Kubernetes secrets for dashboard users:

```bash
# Create the namespace
kubectl create namespace lightstreamer

# Create admin user secret
kubectl create secret generic dashboard-user1-secret \
  --from-literal=user=admin \
  --from-literal=password='secretpass' \
  --namespace lightstreamer

# Create monitor user secret
kubectl create secret generic dashboard-user2-secret \
  --from-literal=user=monitor \
  --from-literal=password='monitorpass' \
  --namespace lightstreamer
```

## Installation and access

To install the Lightstreamer Broker with this dashboard configuration:

```bash
# Install the chart using the custom values file
helm install lightstreamer lightstreamer/lightstreamer \
  -f values.yaml \
  --namespace lightstreamer
```

To access the dashboard locally through port-forwarding:

```bash
# Forward the dashboard port to your local machine
kubectl port-forward svc/lightstreamer-service 8081:8081 -n lightstreamer
```

The dashboard will be available at:
- URL: `https://localhost:8081/monitoring`
- Login with either the admin or monitor user credentials created in the prerequisites