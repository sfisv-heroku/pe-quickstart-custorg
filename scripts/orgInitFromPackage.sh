#!/bin/bash
# Creates a mew scratch org, installs the package, and opens it

DURATION=14

if [ "$#" -eq 1 ]; then
  DURATION=$1
fi

sfdx force:org:create -a pe-example -s -f config/project-scratch-def.json -d $DURATION --json
sfdx force:package:install --package 04t0b000001qKFZ
sfdx force:data:tree:import --plan data/demo-Account-Contact-plan.json
sfdx force:user:password:generate
sfdx force:org:open -p /lightning/setup/ConnectedApplication/home
echo "Org is set up.  Remember to set policy on Connected App"