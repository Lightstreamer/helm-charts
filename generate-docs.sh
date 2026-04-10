#!/bin/bash
# Regenerate charts/lightstreamer/README.md from the README.md.gotmpl template
# and the values.yaml comments using helm-docs (https://github.com/norwoodj/helm-docs).
# Run this script from the repository root after modifying values.yaml or the template.
docker run --rm --volume "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:latest