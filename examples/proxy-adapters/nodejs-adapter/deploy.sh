#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# deploy.sh
#
# Builds the nodejs-helloworld Docker image and deploys it to a Kubernetes
# cluster or an OpenShift cluster.
#
# Usage:
#   ./deploy.sh kubernetes   - build and push to a registry, then apply the manifest
#   ./deploy.sh openshift    - build server-side via OpenShift binary build
#
# Environment variables:
#   REGISTRY   (optional) Container registry prefix for the kubernetes target.
#              When set, the image is tagged as ${REGISTRY}/${APP_NAME}:${TAG}
#              and pushed before deployment. Must be accessible by cluster nodes.
#              Example: REGISTRY=myregistry.example.com/myorg
#              When unset, the image is built locally with no push — the cluster
#              must have access to the image by other means (e.g. Minikube
#              docker-env: eval $(minikube docker-env)).
# ---------------------------------------------------------------------------

APP_NAME="nodejs-helloworld"
TAG="1.0.0"
MANIFEST_TMPL="helloworld-deployment.yaml.tmpl"

usage() {
  echo "Usage: $0 <kubernetes|openshift>"
  echo
  echo "  kubernetes   Build locally and push to \$REGISTRY (required)"
  echo "  openshift    Build server-side via OpenShift binary BuildConfig"
  exit 1
}

[[ $# -ne 1 ]] && usage
TARGET="$1"

case "${TARGET}" in

  kubernetes)
    echo "==> Target: Kubernetes"
    if [[ -n "${REGISTRY:-}" ]]; then
      IMAGE_REF="${REGISTRY}/${APP_NAME}:${TAG}"
      echo "==> Building Docker image ${IMAGE_REF} ..."
      docker build -t "${IMAGE_REF}" .
      echo "==> Pushing image to ${REGISTRY} ..."
      docker push "${IMAGE_REF}"
      echo "==> Successfully pushed ${IMAGE_REF}."
    else
      # No registry specified: build with a plain name and skip the push.
      # The image must be accessible to the cluster nodes by other means,
      # e.g. by pointing the Docker CLI at Minikube's daemon beforehand:
      #   eval $(minikube docker-env)
      IMAGE_REF="${APP_NAME}:${TAG}"
      echo "==> Building Docker image ${IMAGE_REF} (no registry push) ..."
      docker build -t "${IMAGE_REF}" .
    fi
    ;;

  openshift)
    echo "==> Target: OpenShift"
    NAMESPACE="${NAMESPACE:-$(oc project -q)}"
    REGISTRY="image-registry.openshift-image-registry.svc:5000"
    IMAGE_REF="${REGISTRY}/${NAMESPACE}/${APP_NAME}:${TAG}"

    echo "==> Namespace : ${NAMESPACE}"
    echo "==> Image     : ${IMAGE_REF}"

    if ! oc get buildconfig "${APP_NAME}" &>/dev/null; then
      echo "==> Creating BuildConfig '${APP_NAME}' ..."
      oc new-build --binary --name="${APP_NAME}"
    else
      echo "==> BuildConfig '${APP_NAME}' already exists, skipping creation."
    fi

    echo "==> Starting binary build from current directory ..."
    oc start-build "${APP_NAME}" --from-dir=. --follow

    echo "==> Tagging image as ${TAG} ..."
    oc tag "${APP_NAME}:latest" "${APP_NAME}:${TAG}"

    echo "==> ImageStream status:"
    oc get imagestream "${APP_NAME}"
    ;;

  *)
    usage
    ;;
esac

# ---------------------------------------------------------------------------
# Generate the deployment manifest on the fly and apply it
# ---------------------------------------------------------------------------
echo
echo "==> Applying manifest with image: ${IMAGE_REF} ..."
export IMAGE_REF
envsubst '${IMAGE_REF}' < "${MANIFEST_TMPL}" | kubectl apply -f -

echo
echo "==> Done."

