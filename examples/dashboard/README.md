# Lightstreamer Monitoring Dashboard configuration example

This example demonstrates how to configure the _Lightstreamer Monitoring Dashboard_ with secure access and custom settings.

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