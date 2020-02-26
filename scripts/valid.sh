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
