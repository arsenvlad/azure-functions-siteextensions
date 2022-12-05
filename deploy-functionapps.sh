#!/bin/bash

location="westeurope"
rg="avdtrepro400-${location}"

az group create --location "${location}" --name "${rg}"

# Change 1..1 to 1..N to control how many function apps to create in the loop
for i in {1..1}
do
    suffix="${i}"

    az deployment group create \
    --resource-group "${rg}" \
    --name "d${suffix}" \
    --template-file functionapp.bicep \
    --parameters name="${rg}-${suffix}" \
    
    echo "Started deploying ${rg}${suffix}"
done