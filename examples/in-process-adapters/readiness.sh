#!/bin/sh
echo "Checking readiness of Lightstreamer server..."
jq -e '(. == {}) or any(.[]; .metadataAdapter=="enabled" and all(.dataAdapters[]; .=="enabled"))' || {
    echo "Readiness check failed"
    exit 1
}
