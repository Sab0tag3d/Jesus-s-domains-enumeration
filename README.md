# Jesus's domains enumeration
Here is my cheat sheet of subdomain enumeration methods, collected on the Internet.

## Table of Contents
* [Subdomain gathering. Passive recon](#subdomain-gathering-passive-recon)  
  * [Subdomain bruteforcing](#subdomain-bruteforcing)
  * [Reverse DNS sweeping](#reverse-dns-sweeping)
  * [Subdomain name alterations](#subdomain-name-alterations)
  * [Certificate search](#certificate-search)
  * [External sources](#external-sources)
  * [Domain validation](#domain-validation)
  * [Horizontal domain correlation](#horizontal-domain-correlation)
* [Next steps. Active recon](#next-steps-active-recon)
  * [Gathering additional domains from web resources](#gathering-additional-domains-from-web-resources)
  * [Gathering additional domains from non web resources](#gathering-additional-domains-from-non-web-resources)

## Subdomain gathering. Passive recon

### Subdomain bruteforcing
The key part of any successful bruteforcing is creating good wordlist:
- Good wordlist for start: [here](https://gist.github.com/jhaddix/f64c97d0863a78454e44c2f7119c2a6a)
- Creating wordlist with google BigQuery: [commonspeak2](https://github.com/assetnote/commonspeak2-wordlists). Request [example](https://github.com/Sab0tag3d/Jesus-s-domains-enumeration/blob/master/scripts/Biq_query_example.sql)

##### Tools
- Good [Cheat Sheet](https://pentester.land/cheatsheets/2018/11/14/subdomains-enumeration-cheatsheet.html) about tools
- [Amass](https://github.com/OWASP/Amass) tool is the best choice for domains enumeration

 > Whichever tool you choose, it is important to configure it correctly. Every network area (the network from which you will start bruteforce) have the fastest DNS resolvers and here is [tool](https://code.google.com/archive/p/namebench/) to find them 
> Also you need a list of [public DNS servers](https://public-dns.info/)  
> **Warning**: it could be illegal in some countries

### Reverse DNS sweeping  
Start with main domain here: [BGP Toolkit](https://bgp.he.net/) and check every AS with [reverse-dns-sweep tool](https://github.com/jnyryan/reverse-dns-sweep)

> It could be usefull for big organizations, in common case you will find all mail servers.

### Subdomain name alterations
[Altdns](https://github.com/infosec-au/altdns) - Python tool that could generate a lot of mutation of input domains list   
> Altdns also have dns resolver but it's very slow, so it will be better to generate list with altdns and resolve it with another tool (with [massdns](https://github.com/blechschmidt/massdns))  
[Amass](https://github.com/OWASP/Amass/blob/master/doc/user_guide.md) has mutation module

### Certificate search
An SSL/TLS certificate usually contains domain names, sub-domain names and email addresses. The simplest way to collect data from certificates is to connect to crt.sh through web (could be unstable), [example](https://github.com/Sab0tag3d/Jesus-s-domains-enumeration/blob/master/scripts/crt.sh)

> It's possible to connect to postgres database ([example](https://github.com/appsecco/the-art-of-subdomain-enumeration/blob/master/crtsh_enum_psql.sh)). In some cases it could be more stable and faster

### External sources
Exists a lot of online sources with APIs that collect subdomains, and so many tools use them. [Subfinder](https://github.com/projectdiscovery/subfinder) one of the best

Interesting APIs:
- [Amass](https://github.com/OWASP/Amass/commit/8a0c0b3166eac2e33e70ed4c1e6bebdec5747fc5) can now use GitHub as a data source
- Web Archives. ([Python script](https://gist.github.com/mhmdiaa/adf6bff70142e5091792841d4b372050)) for connect

### :hourglass_flowing_sand: Collect SPF records

[assets-from-spf](https://github.com/0xbharath/assets-from-spf)

### :hourglass_flowing_sand: DNSSEC zone walking
[nsec3map](https://github.com/anonion0/nsec3map)

### :hourglass_flowing_sand: Check of a given domain for known TLD values
[dnsrecon](https://github.com/darkoperator/dnsrecon/blob/master/dnsrecon.py)

### :hourglass_flowing_sand: Brute-force most common SRV records for a given Domain
[dnsrecon](https://github.com/darkoperator/dnsrecon/blob/master/dnsrecon.py)

### Horizontal domain correlation
One of the helpful ways is to use [BGP Toolkit](https://bgp.he.net/) by this way:
1. Enter the main domain of the company.
2. Go to the "IP Info" tab and copy the company name.
3. Find **all** AS of company (also you can play with companies name).
4. Try to find new domains in http://ipv4info.com/ or use [Amass](https://github.com/OWASP/Amass/blob/master/doc/user_guide.md) with AS number.


### Domain validation
After subdomains collected it could be helpful to check it's validity. Bash [script](https://github.com/Sab0tag3d/Jesus-s-domains-enumeration/blob/master/scripts/valid.sh)  
Python tool for this: [dnsvalidator](https://github.com/vortexau/dnsvalidator)

## Next steps. Active recon

### Gathering additional domains from web resources
- Scan current domains and IPs for web resourses. Bash [script](https://github.com/Sab0tag3d/Jesus-s-domains-enumeration/blob/master/scripts/short_web_scan.sh)
- Create web urls from nmap XML file: [nmap-parse-output](https://github.com/ernw/nmap-parse-output)  
- Extract new domains from HTML: [second-order](https://github.com/mhmdiaa/second-order)
- Extract domain names from Content Security Policy(CSP) headers
- VHost discovery: [vhost-brute](https://github.com/gwen001/vhost-brute)

### Gathering additional domains from non web resources
- Zone transfers: `host -t axfr domain.name dns-server`
- Collect TXT-record for tokens and other things: [Article](https://blog.netspi.com/analyzing-dns-txt-records-to-fingerprint-service-providers/)
- extract new URLs from APK: [Diggy](https://github.com/s0md3v/Diggy/blob/master/diggy.sh)
- :hourglass_flowing_sand: BGP
- :hourglass_flowing_sand: SNMP

### :hourglass_flowing_sand: Monitoring new domains  
* [Monitorizer](https://github.com/BitTheByte/Monitorizer)  
* [Keye](https://github.com/clirimemini/Keye)
