#!/bin/bash

echo Please provide the information below
read -p 'workspace-name: ' WORKSPACE
read -p 'resource-group: ' RESOURCE_GROUP
echo

export ENDPOINT_NAME=endpoint-test-concurrency-`echo $RANDOM`

# echo -e "\nname: $ENDPOINT_NAME" >> endpoint.yml
# echo -e "\nendpoint_name: $ENDPOINT_NAME" >> deployment.yml

az ml online-endpoint create \
                --name $ENDPOINT_NAME \
                --file endpoint.yml \
                --workspace-name $WORKSPACE \
                --resource-group $RESOURCE_GROUP
az ml online-deployment create \
                --endpoint-name $ENDPOINT_NAME \
                --file deployment.yml \
                --workspace-name $WORKSPACE \
                --resource-group $RESOURCE_GROUP \
                --all-traffic
# az ml online-deployment update \
#                 --file deployment.yml \
#                 --workspace-name $WORKSPACE \
#                 --resource-group $RESOURCE_GROUP
az ml online-deployment show \
                --endpoint-name $ENDPOINT_NAME \
                --name deployment-test-concurrency \
                --workspace-name $WORKSPACE \
                --resource-group $RESOURCE_GROUP

export SCORING_URI=$(az ml online-endpoint show \
                --name $ENDPOINT_NAME \
                --workspace-name $WORKSPACE \
                --resource-group $RESOURCE_GROUP \
                --query "scoring_uri" \
                --output tsv)

export SCORING_KEY=$(az ml online-endpoint get-credentials \
                --name $ENDPOINT_NAME \
                --workspace-name $WORKSPACE \
                --resource-group $RESOURCE_GROUP \
                --query "primaryKey" \
                --output tsv)

JSON_CRED="{
\"scoring_uri\":\"${SCORING_URI}\",
\"scoring_key\":\"${SCORING_KEY}\"
}"

echo $JSON_CRED > test/cred.json