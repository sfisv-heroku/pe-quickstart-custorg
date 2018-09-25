#! /bin/bash
# Registers a new or modified Salesforce customer org with the business org
# Uses command line parameter and env variables to populate fields in an Apex file to execute.

# Source the env file to get values for the business org credentials
. ./.env

# Check for variables from env file
if [ -z $BIZ_USERNAME ]
then
	echo "Credentials must be defined in .env file"
	exit 1
fi

# Mandatory parameter
if [ "$#" -eq 0 ] 
then
	echo "Arguments required: Client Id"
	exit 1
else
	CUST_CLIENT_ID=$1
fi

# Substitute field in customMetadata file
sed -e "s/CUST_CLIENT_ID/${CUST_CLIENT_ID}/g" \
	-e "s/BIZ_USERNAME/${BIZ_USERNAME}/g" \
	-e "s/BIZ_PASSWORD/${BIZ_PASSWORD}/g" \
	-e "s/BIZ_CLIENT_ID/${BIZ_CLIENT_ID}/g" \
	-e "s/BIZ_CLIENT_SECRET/${BIZ_CLIENT_SECRET}/g" \
	./scripts/customMetadata.template > force-app/main/default/customMetadata/ConnectionInfo.PE_Example_Business_Org.md-meta.xml