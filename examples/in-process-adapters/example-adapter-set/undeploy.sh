#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# undeploy.sh
#
# Removes the example-adapter-set image and related resources from the
# target cluster.
#
# Usage:
#   ./undeploy.sh kubernetes  - remove local Docker image
#   ./undeploy.sh openshift   - remove BuildConfig and ImageStream
#
# Environment variables:
#   REGISTRY   (optional) Same value used during deploy. When set, removes
#              the registry-prefixed image tag.
# ---------------------------------------------------------------------------

APP_NAME="lightstreamer-example-adapter-set"
TAG="1.0.0"

usage() {
  echo "Usage: $0 <kubernetes|openshift>"
  exit 1
}

[[ $# -ne 1 ]] && usage
TARGET="$1"

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
