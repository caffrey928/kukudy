#!/bin/bash

if ! [[ $# -eq 1 ]] ; then
    echo -e "
    Usage
    sudo bash sleepConnectedUserCountry.sh CONFIG_ID ..."

    exit 1
fi

CONFIG_ID=$1

GUID_URL="https://nordvpn.com/wp-admin/admin-ajax.php?action=get_user_info_data"

for R in $(seq 11)
do
    RES=$(curl -s "${GUID_URL}")
    if [[ ${RES} == *'"status":true'* ]]; then
        exit 0
    fi
    sleep "$R"
done

python3 ../utils/writeErrorCountry.py "${CONFIG_ID}"
exit 1
