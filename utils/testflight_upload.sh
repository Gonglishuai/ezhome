#!/bin/bash


# testflightapp.com tokens

# SERGEI's API TOKEN
#API_TOKEN="98e46a82733d6538b589f3e7c5a57831_ODI3OTQyMjAxMy0wMS0xNSAwNTo0NTo1Ny43MzY2NjE" 

# AVIHAY's API TOKEN
API_TOKEN="f2c9f9871f0f1edf3ca4c48eebcd4605_MTYzNzIxNDIwMTQtMDItMTEgMDY6Mzg6MzcuMTE0NDg0"

# Homestyler API TEAM TOKEN
TEAM_TOKEN="831ec0f6ba453d59c0d91bb67308176f_MTEyODUxMjAxMi0wOS0yNyAxMzoxMjozNS45NTcyODA"

OUT_IPA=$1
OUT_DSYM=$2
NOTES=$3
LIST=$4
 

/usr/bin/curl "http://testflightapp.com/api/builds.json" \
-F file=@"${OUT_IPA}" \
-F dsym=@"${OUT_DSYM}" \
-F api_token="${API_TOKEN}" \
-F team_token="${TEAM_TOKEN}" \
-F notes="${NOTES}" \
-F notify="True" \
-F distribution_lists="${LIST}"