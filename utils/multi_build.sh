#!/bin/bash

echo "*************************"
echo "*     Debug Nightly     *"
echo "*************************"

echo "*      Archive          *"

./testflight_

echo "*      TestFlight Upload       *"

echo "Build Stage"
./archive.sh "Staging_release"


echo "Build Production"
./archive.sh "Production_release"
