#!/bin/sh

# -------------------------------------------------------------
# This file releases a new version of the application.
# -------------------------------------------------------------

# Authenticate with the Elastic Container Repository
$(aws ecr get-login --no-include-email --region us-west-2)

# Create a unique ID to use as the tag for this release
RELEASE_UUID=$(uuidgen)

# Determine the url for the ECR repository and the target cluster name
cd ./infrustructure
ECR_REPOSITORY_URL=$(terraform output ecr_repository_url)
ECS_CLUSTER_NAME=$(terraform output ecs_cluster_name)
cd ../
echo "The ECR id for this release is ${ECR_REPOSITORY_URL}:${RELEASE_UUID}"

# Build the node-server container in production mode to trim unnecesary dependencies
docker build -t node-server ./app --build-arg NODE_ENV=production --no-cache

# Tag the node-server build with the UUID above and push to the Elastic Container Registry
docker tag node-server:latest "${ECR_REPOSITORY_URL}:${RELEASE_UUID}"
docker push "${ECR_REPOSITORY_URL}:${RELEASE_UUID}"

# Create a new ECS Task Definition which tells containers in the cluster to run the latest image
cd ./infrustructure
terraform apply -var="node_server_image_version=${RELEASE_UUID}"

# Force a deployment so containers in the cluster run the latest image
APPLY_EXIT_CODE=$?
if test $APPLY_EXIT_CODE -eq 0
then
	aws ecs update-service --service node-server --cluster "$ECS_CLUSTER_NAME" --force-new-deployment
fi
