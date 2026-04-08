#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# undeploy.sh
#
# Removes the example-proxy-adapter deployment and related resources from the
# target cluster.
#
# Usage:
#   ./undeploy.sh kubernetes  - remove deployment and local Docker image
#   ./undeploy.sh openshift   - remove deployment, BuildConfig, and ImageStream
#
# Environment variables:
#   REGISTRY   (optional) Same value used during build.
#              When set, the local Docker image is also removed.
# ---------------------------------------------------------------------------

APP_NAME="example-proxy-adapter"
TAG="1.0.0"
MANIFEST_TMPL="deployment.yaml.tmpl"

usage() {
  echo "Usage: $0 <kubernetes|openshift>"
  exit 1
}

[[ $# -ne 1 ]] && usage
TARGET="$1"

echo "==> Removing deployment ..."
export IMAGE_REF="placeholder"
envsubst '${IMAGE_REF}' < "${MANIFEST_TMPL}" | kubectl delete -f - --ignore-not-found=true

echo "==> Waiting for pods to terminate ..."
kubectl wait pod \
  --selector app=example-proxy-adapter \
  --for=delete \
  --timeout=60s \
  --namespace lightstreamer 2>/dev/null || true

case "${TARGET}" in

  kubernetes)
    if [[ -n "${REGISTRY:-}" ]]; then
      echo "==> Removing Docker image ${REGISTRY}/${APP_NAME}:${TAG} ..."
      docker rmi "${REGISTRY}/${APP_NAME}:${TAG}" || true
    else
      echo "==> Removing Docker image ${APP_NAME}:${TAG} ..."
      docker rmi "${APP_NAME}:${TAG}" || true
    fi
    ;;

  openshift)
    echo "==> Removing BuildConfig and ImageStream ..."
    oc delete buildconfig "${APP_NAME}" --ignore-not-found=true
    oc delete imagestream "${APP_NAME}" --ignore-not-found=true
    ;;

  *)
    usage
    ;;
esac

echo
echo "==> Done."
