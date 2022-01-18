RG_NAME ?= rg-pacifico
LOCATION ?= eastus2
DEPLOYMENT_NAME ?= webapp
PWD = $(shell pwd)

create-rg:
	@az group create -n ${RG_NAME} -l ${LOCATION}
plan:
	@az deployment group what-if -f webapps.bicep -g ${RG_NAME} -n ${DEPLOYMENT_NAME} \
		--parameters  container='shared' storage_name='${STORAGE_ACCOUNT_NAME}'  deployment_name='${DEPLOYMENT_NAME}' \
			client_secret='${AZURE_CLIENT_SECRET}' client_id='${AZURE_CLIENT_ID}' resource_id='${RESOURCE_ID}'
apply:
	@az deployment group create  -f webapps.bicep -g ${RG_NAME} -n ${DEPLOYMENT_NAME} \
		--parameters  container='shared' storage_name='${STORAGE_ACCOUNT_NAME}'  deployment_name='${DEPLOYMENT_NAME}' \
			client_secret='${AZURE_CLIENT_SECRET}' client_id='${AZURE_CLIENT_ID}' resource_id='${RESOURCE_ID}'
destroy:
	@az group delete -n ${RG_NAME} -y --verbose
