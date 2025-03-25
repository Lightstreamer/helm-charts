#!/bin/bash

# Set error handling
set -e

# Build the Gradle project to generate the build/deploy folder
echo "Building Gradle project..."
./gradlew clean deploy
if [ $? -ne 0 ]; then
    echo "Error building Gradle project"
    exit 1
fi

# Define variables
IMAGE_NAME="example-lightstreamer-adapters"
TAG="latest"

# Print build information
echo "Building Docker image: ${IMAGE_NAME}:${TAG}"

# Build the Docker image
docker build -t "${IMAGE_NAME}:${TAG}" .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built ${IMAGE_NAME}:${TAG}"
else
    echo "Error building Docker image"
    exit 1
fi

# Push the image to minikube
echo "Pushing image to minikube..."
minikube image load "${IMAGE_NAME}:${TAG}"
if [ $? -eq 0 ]; then
    echo "Successfully pushed ${IMAGE_NAME}:${TAG} to minikube"
else
    echo "Error pushing image to minikube"
    exit 1
fi