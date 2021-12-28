RG_NAME ?= "pacifico-poc2"
LOCATION ?= "eastus"
DEPLOYMENT_NAME ?= "webapp"
PWD = $(shell pwd)
create-rg:
	@az group create -n ${RG_NAME} -l ${LOCATION}
plan: create-rg
	@az deployment group what-if -f webapps.bicep -g ${RG_NAME} -n ${DEPLOYMENT_NAME}
apply:
	@az deployment group create -f webapps.bicep -g ${RG_NAME} -n ${DEPLOYMENT_NAME}
destroy:
	@az group delete -n ${RG_NAME} -y --verbose