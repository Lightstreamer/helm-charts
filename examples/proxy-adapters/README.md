# Proxy Adapter example

This example demonstrates how to deploy the Lightstreamer Helm chart with a **Proxy Data Adapter**, which delegates data production to a separate remote adapter process running in its own Kubernetes pod.

## Architecture

```
  ┌──────────────────────────────────┐       ┌──────────────────────────────┐
  │  Lightstreamer Pod               │       │  nodejs-helloworld Pod       │
  │                                  │       │                              │
  │  Metadata: LiteralBasedProvider  │       │  helloworld.cjs              │
  │  Data:     Proxy Adapter (:6661) │◄──────│  (lightstreamer-adapter SDK) │
  └──────────────────────────────────┘       └──────────────────────────────┘
```

Lightstreamer is configured with:
- an **in-process** Metadata Adapter (`LiteralBasedProvider`)
- a **Proxy Data Adapter** listening on port `6661` for incoming connections from the remote adapter

The NodeJS helloworld adapter connects to Lightstreamer on port `6661` and pushes real-time data, as configured by the arguments in [`helloworld-deployment.yaml.tmpl`](nodejs-adapter/helloworld-deployment.yaml.tmpl):

```yaml
args:
  - lightstreamer-adapters.lightstreamer.svc   # Lightstreamer service hostname
  - "6661"                                     # Proxy adapter port
```

## Folder structure

```
proxy-adapters/
├── README.md
├── values.yaml                  # Helm chart configuration
└── nodejs-adapter/              # NodeJS remote adapter project
    ├── helloworld.cjs
    ├── Dockerfile
    ├── helloworld-deployment.yaml.tmpl
    ├── deploy.sh
    ├── undeploy.sh
    └── index.html
```

## Prerequisites

- A running Kubernetes cluster with `kubectl` configured, or an OpenShift cluster with `oc` available
- `helm` on your PATH
- A container registry accessible by the cluster nodes (e.g. Docker Hub, a private registry, or a local registry) — required for the `kubernetes` target
- `docker` on your PATH for local image builds

## Deployment

### 1. Install the Lightstreamer Helm chart

Install the chart using the provided [`values.yaml`](values.yaml), which configures the Proxy Data Adapter:

```sh
helm install lightstreamer lightstreamer/lightstreamer \
  -f values.yaml \
  --namespace lightstreamer
```

> The namespace must exist beforehand (`kubectl create namespace lightstreamer` or `oc new-project lightstreamer` on OpenShift). Any name can be used, but it must be applied consistently — if you change it, update [`helloworld-deployment.yaml.tmpl`](nodejs-adapter/helloworld-deployment.yaml.tmpl) accordingly, as the namespace is also part of the Lightstreamer service DNS hostname.

The relevant configuration in `values.yaml`:

```yaml
adapters:
  helloWorldAdapterSet:
    enabled: true
    id: NODE_HELLOWORLD
    metadataProvider:
      inProcessMetadataAdapter:
        adapterClass: com.lightstreamer.adapters.metadata.LiteralBasedProvider
    dataProviders:
      myDataProvider:
        enabled: true
        name: HELLOWORLD
        proxyDataAdapter:
          requestReplyPort: 6661
```

### 2. Build and deploy the NodeJS remote adapter

Once Lightstreamer is running and the Proxy Data Adapter is ready to accept connections, deploy the NodeJS helloworld adapter using the [`deploy.sh`](nodejs-adapter/deploy.sh) script inside the [`nodejs-adapter/`](nodejs-adapter/) folder.

Optionally edit [`nodejs-adapter/helloworld.cjs`](nodejs-adapter/helloworld.cjs) beforehand to customise the adapter logic.

```sh
cd nodejs-adapter/
```

- **Any Kubernetes distribution** — build and push the image to a registry accessible by your cluster nodes, then apply the manifest:
  ```sh
  REGISTRY=myregistry.example.com/myorg ./deploy.sh kubernetes
  ```
  Set `REGISTRY` to the prefix of your container registry. The image will be tagged and pushed as `${REGISTRY}/nodejs-helloworld:1.0.0`.

  > **Minikube shortcut**: If you are using Minikube for local development you can avoid a remote registry entirely by pointing your shell at Minikube's built-in Docker daemon before running the script. The image is then built directly inside Minikube and no push is needed:
  > ```sh
  > eval $(minikube docker-env)
  > ./deploy.sh kubernetes
  > ```
  > Run `eval $(minikube docker-env --unset)` to restore your shell's Docker environment afterwards.

- **OpenShift** — no local Docker build is needed. The script uploads the source directory and triggers a server-side build via a binary BuildConfig:
  ```sh
  ./deploy.sh openshift
  ```

The script generates the deployment manifest on the fly from [`helloworld-deployment.yaml.tmpl`](nodejs-adapter/helloworld-deployment.yaml.tmpl) with the resolved image reference and applies it to the cluster.

### 3. Verify the connection

Check the Lightstreamer pod logs to confirm the remote adapter has connected successfully:

```sh
kubectl logs -l app.kubernetes.io/name=lightstreamer -n lightstreamer
```

### 4. Access the demo

Enable port forwarding on the Lightstreamer pod:

```sh
kubectl port-forward svc/lightstreamer 8080:8080 -n lightstreamer
```

Then open [`index.html`](nodejs-adapter/index.html) in your browser and watch real-time greeting updates.

## Cleanup

To remove all deployed resources from the cluster, run from the [`nodejs-adapter/`](nodejs-adapter/) folder:

- **Any Kubernetes distribution**:
  ```sh
  REGISTRY=myregistry.example.com/myorg ./undeploy.sh kubernetes
  ```
  Deletes the NodeJS adapter deployment and removes the local Docker image (if `REGISTRY` is set).

- **OpenShift**:
  ```sh
  ./undeploy.sh openshift
  ```
  Deletes the NodeJS adapter deployment, the BuildConfig, and the ImageStream from the cluster.

To uninstall the Helm chart:

```sh
helm uninstall lightstreamer --namespace lightstreamer
```

