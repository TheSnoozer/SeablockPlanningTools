#!/usr/bin/env bash

version=$(jq --raw-output ".version" src/info.json)
mv src SeablockPlanningTools
zip -r SeablockPlanningTools_${version}.zip SeablockPlanningTools
mv SeablockPlanningTools src
