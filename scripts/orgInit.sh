#!/bin/bash
# Creates a mew scratch org, initiates it, and opens it

DURATION=14

if [ "$#" -eq 1 ]; then
  DURATION=$1
fi

sfdx force:org:create -a pe-example -s -f config/project-scratch-def.json -d $DURATION --json
sfdx force:source:push
./scripts/postInstall.sh
sfdx force:user:password:generate
sfdx force:org:open -p /lightning/setup/ConnectedApplication/home
echo "Org is set up.  Remember to set policy on Connected App"