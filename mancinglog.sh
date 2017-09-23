#!/bin/bash
logpath=/var/log/nginx/access.log
ARRAY=()
getip=()
getfile=()

function getfiles {
        echo "getfiles param " ${getip[@]}
        pat=$(echo ${getip[@]}|tr " " "|")
        getfile+=($(grep -Ew $pat $logpath| cut -f 7 -d " " | sort | uniq))
        uniqf=($(printf "%s\n" "${getfile[@]}" | sort | uniq -c | sort -rnk1 | awk '{ print $2 }'))
        unset getfile
        getfile=("${uniqf[@]}")
        printf "%s\n" "${getfile[@]}" > files.txt
        echo "getfiles result " ${getfile[@]}
        getips
}



function getips {
        echo "getips param " ${getfile[@]}
        pat=$(echo ${getfile[@]}|tr " " "|")
        getip+=($(grep -Ew $pat $logpath| cut -f 1 -d " " | sort | uniq))
        uniqi=($(printf "%s\n" "${getip[@]}" | sort | uniq -c | sort -rnk1 | awk '{ print $2 }'))
        unset getip
        getip=("${uniqi[@]}")
        printf "%s\n" "${getip[@]}" > ips.txt
        echo "getips result "${getip[@]}
        getfiles
}

getfile=( `cat "files.txt"` )
getip=( `cat "ips.txt"` )
#getips $1
getfile+=($1)
getips
