#!/bin/bash
# short nmap scan for web servers
nmap -sV -sT -Pn -T4 -iL domains.txt -p80,81,443,832,981,1010,1311,2083,2087,2095,2096,4712,7000-7010,7080,7443,7474,8000-8014,8040-8091,8172,8118,8123,8172,8181,8222,8243,8280,8281,8333,8443,8500,8770-8780,8834,8880,8888,8983,9000,9043,9060,9080,9090,9091,9200,9800,9981,9999,9443,12443 -oX short_web_scan_domains.xml
