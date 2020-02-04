# Jesus's domains enumeration
Here is my cheat sheet of subdomain enumeration methods, collected on the Internet.

## Table of Contents
* [Subdomain gathering. Passive recon](#subdomain-gathering-passive-recon)  
	* [Subdomain bruteforcing](#subdomain-bruteforcing)
	* [Reverse DNS sweeping](#reverse-dns-sweeping)
  * [Subdomain name alterations](#subdomain-name-alterations)
  * [Certificate search](#certificate-search)
  * [APIs](#apis)
  * [Domain validation](#domain-validation)
  * [Horizontal domain correlation](#horizontal-domain-correlation)
* [Next steps. Active recon](#next-steps-active-recon)
  * [Gathering additional domains from web resources](#gathering-additional-domains-from-web-resources)
  * [Gathering additional domains from non web resources](#gathering-additional-domains-from-non-web-resources)

## Subdomain gathering. Passive recon

### Subdomain bruteforcing
The key part of any successful bruteforcing is creating good wordlist:
- Good wordlist for start: [here](https://gist.github.com/jhaddix/f64c97d0863a78454e44c2f7119c2a6a)
- Creating wordlist with google BigQuery: [assetnote/commonspeak2](https://github.com/assetnote/commonspeak2-wordlists)
	<details>
	<summary>Example of request for BigQuery</summary>

	```sql
	SELECT DISTINCT s, COUNT(s) c
	FROM (
	  SELECT SPLIT(REGEXP_REPLACE(REGEXP_REPLACE(url, r'https?:\/\/([-a-zA-Z0-9@:%._\+~#=]{0,256}\.)([-a-zA-Z0-9@:%._\+~#=]{1,256}){1}\.([a-zA-Z]{1,6})', '\\1'), r'https?:\/\/.*', ''), '.') subd
	  FROM (
	    SELECT DISTINCT url
	    FROM `bigquery-public-data.github_repos.contents` 
	    CROSS JOIN UNNEST(REGEXP_EXTRACT_ALL(LOWER(content), r'https?:\/\/[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z]{1,6}')) AS url
	)
	)
	CROSS JOIN UNNEST(subd) as s
	WHERE s != '' and s not like '%@%'
	GROUP BY s
	ORDER BY c DESC
	```

	</details>

##### Tools
- Good cheat sheet about tools: [Subdomains Enumeration Cheat Sheet · Pentester Land](https://pentester.land/cheatsheets/2018/11/14/subdomains-enumeration-cheatsheet.html)

- Amass tool is the best: [link](https://github.com/OWASP/Amass)

 > Whichever tool you choose, it is important to configure it correctly. Every network area (place where you will start bruteforce) have fastest DNS resolvers and here is tool to collect few: [namebench](https://code.google.com/archive/p/namebench/).  
> Also you need a list of public dns recolvers: [Public DNS Server List](https://public-dns.info/)  
> **Warning**: it could be illegal in some countries

### Reverse DNS sweeping  
Start with main domain here: [Hurricane Electric BGP Toolkit](https://bgp.he.net/) and check every AS with this [tool](https://github.com/jnyryan/reverse-dns-sweep).

> It could be usefull for big organizations, in common case you will find all mail servers.

### Subdomain name alterations
[Altdns](https://github.com/infosec-au/altdns) - Python tool that could generate a lot of mutation of input domains list. 

[Amass](https://github.com/OWASP/Amass/blob/master/doc/user_guide.md) have mutation module

>Altdns also have dns resolver but it's very slow, so it will be better to generate list with altdns and resolve it with another tool (with [massdns](https://github.com/blechschmidt/massdns))

### Certificate search
An SSL/TLS certificate usually contains domain names, sub-domain names and email addresses. The simplest way to collect data from certificates is to connect to crt.sh through web (could be unstable):
```bash
sudo apt-get install jq
curl --silent 'https://crt.sh/?q=%.'mail.ru'&output=json' | jq '.[] | .name_value' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u > domains_crt_sh.txt
```
> It's possible to connect to postgres database([examples](https://github.com/appsecco/the-art-of-subdomain-enumeration/blob/master/crtsh_enum_psql.sh)). Im some cases it could be more stable and faster.

### APIs
Exists a lot of online sources with APIs that collect subdomains, and so many tools use them. [Subfinder](https://github.com/projectdiscovery/subfinder) one of the best.

Interesting APIs:
- [Amass can now use GitHub as a data source](https://github.com/OWASP/Amass/commit/8a0c0b3166eac2e33e70ed4c1e6bebdec5747fc5)
- Web Archives ([python ex.](https://gist.github.com/mhmdiaa/adf6bff70142e5091792841d4b372050))

### :hourglass_flowing_sand: Collect SPF records

[GitHub - 0xbharath/assets-from-spf: A Python script to parse net blocks & domain names from SPF record](https://github.com/0xbharath/assets-from-spf)

### :hourglass_flowing_sand: DNSSEC zone walking
[GitHub - anonion0/nsec3map: a tool to enumerate the resource records of a DNS zone using its DNSSEC NSEC or NSEC3 chain](https://github.com/anonion0/nsec3map)

### :hourglass_flowing_sand: Check of a given domain for known TLD values
[dnsrecon/dnsrecon.py at master · darkoperator/dnsrecon · GitHub](https://github.com/darkoperator/dnsrecon/blob/master/dnsrecon.py)

### :hourglass_flowing_sand: Brute-force most common SRV records for a given Domain
[dnsrecon/dnsrecon.py at master · darkoperator/dnsrecon · GitHub](https://github.com/darkoperator/dnsrecon/blob/master/dnsrecon.py)

### Horizontal domain correlation
One of the helpful ways is to use [Hurricane Electric BGP Toolkit](https://bgp.he.net/) by this way:
1. Enter the main domain of the company.
2. Go to the "IP Info" tab and copy the company name.
3. Find **all** AS of company (also you can play with companies name).
4. Try to find new domains in http://ipv4info.com/ or use [amass](https://github.com/OWASP/Amass/blob/master/doc/user_guide.md) with AS number.


### Domain validation
After subdomains collected it could be helpful to check it's validity. 
<details>
<summary>Simple bash script for that</summary>

```bash

#!/bin/bash
#Finding valid domain (that have valid A record). After that domains without A record will be rechecked$
input_domain_list=input_domains.txt
validated_domains_list=domains_valid.txt
sort --ignore-case -u -o $input_domain_list $input_domain_list

tput setaf 4; echo "domains validation (DNS requests)"
for line in $(cat $input_domain_list)
    do
        if [[ $(dig $line +short +time=5 +tries=1 @8.8.8.8 | wc -c) -eq 0 ]]
        then
            echo $line >> $workdir/unvalidated_domains.txt
        else
            echo $line >> $validated_domains_list
        fi
    done

```
</details>

Python tool for this: [GitHub - vortexau/dnsvalidator: Maintains a list of IPv4 DNS servers by verifying them against baseline servers, and ensuring accurate responses.](https://github.com/vortexau/dnsvalidator)

## Next steps. Active recon

### Gathering additional domains from web resources
- Scan current domains and IPs for web resourses
```bash
#short nmap scan for web servers
nmap -sV -sT -Pn -T4 -iL domains.txt -p80,81,443,832,981,1010,1311,2083,2087,2095,2096,4712,7000-7010,7080,7443,7474,8000-8014,8040-8091,8172,8118,8123,8172,8181,8222,8243,8280,8281,8333,8443,8500,8770-8780,8834,8880,8888,8983,9000,9043,9060,9080,9090,9091,9200,9800,9981,9999,9443,12443 -oX short_web_scan_domains.xml
```
- Create web urls from nmap XML file  
[GitHub - ernw/nmap-parse-output: Converts/manipulates/extracts data from a Nmap scan output.](https://github.com/ernw/nmap-parse-output)  
```bash
./nmap-parse-output short_scan_ipv4.xml http-ports | sed 's/:80$//' | sed 's/:443$//' | sed 's/$/\//' | sort -u  >> $nmap_dir/domains_urls.txt
```
- Extract new domains from HTML  
[GitHub - mhmdiaa/second-order: Second-order subdomain takeover scanner](https://github.com/mhmdiaa/second-order)
- Extract domain names from Content Security Policy(CSP) headers
- VHost discovery  
[GitHub - gwen001/vhost-brute: A PHP tool to brute force vhost configured on a server.](https://github.com/gwen001/vhost-brute)

### Gathering additional domains from non web resources
```bash
#short interesting port scan
nmap -sV -sT -Pn -T4 -iL domains.txt -p53,U:53 -oX $nmap_dir/short_scan_ipv4.xml
```
- Zone transfers
```bash
host -t axfr domain.name dns-server
```
- collect TXT-record for tokens and other things
[Analyzing DNS TXT Records to Fingerprint Online Service Providers](https://blog.netspi.com/analyzing-dns-txt-records-to-fingerprint-service-providers/)

- :hourglass_flowing_sand: BGP
- :hourglass_flowing_sand: SNMP

### :hourglass_flowing_sand: Monitoring new domains  
* [BitTheByte/Monitorizer: The ultimate subdomain monitorization framework](https://github.com/BitTheByte/Monitorizer)  
* [clirimemini/Keye: Keye is a reconnaissance tool that was written in Python with SQLite3 integrated. After adding a single URL, or a list of URLs, it will make a request to these URLs and try to detect changes based on their response's body length.](https://github.com/clirimemini/Keye)
