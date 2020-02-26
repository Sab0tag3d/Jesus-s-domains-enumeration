#!/bin/bash
sudo apt-get install jq curl
curl --silent 'https://crt.sh/?q=%.'domain'&output=json' | jq '.[] | .name_value' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u
