#!/bin/bash
set -x
curl  -H "X-DNSimple-Token: ${DNSimple_V1}" \
      -H 'Accept: application/json' \
      https://api.dnsimple.com/v1/domains/$1/check | jq .
