#!/bin/bash
# Executes the steps to configure an org after the source has been installed

sfdx force:user:permset:assign -n PE_Example_Access
sfdx force:apex:execute -f scripts/setupaccess.apex
sfdx force:data:tree:import --plan data/demo-Account-Contact-plan.json