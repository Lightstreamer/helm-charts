#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# build.sh
#
# Builds the example Adapter Set, packages it into a Docker image, and
# makes the image available to the target cluster.
#
# Usage:
#   ./build.sh kubernetes   - build locally and optionally push to a registry
#   ./build.sh openshift    - build server-side via OpenShift binary build
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

APP_NAME="lightstreamer-example-adapter-set"
TAG="1.0.0"

usage() {
  echo "Usage: $0 <kubernetes|openshift>"
  echo
  echo "  kubernetes   Build locally and optionally push to \$REGISTRY"
  echo "  openshift    Build server-side via OpenShift binary BuildConfig"
  exit 1
}

[[ $# -ne 1 ]] && usage
TARGET="$1"

# ---------------------------------------------------------------------------
# Build the Adapter Set with Gradle
# ---------------------------------------------------------------------------
echo "==> Building Adapter Set with Gradle ..."
./gradlew build

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
# Print the Helm values override
# ---------------------------------------------------------------------------
echo
echo "==> Image ready: ${IMAGE_REF}"
echo
echo "    Update your Helm values file with:"
echo
echo "    image:"
echo "      repository: ${IMAGE_REF%:*}"
echo "      tag: \"${TAG}\""
echo
echo "==> Done."
