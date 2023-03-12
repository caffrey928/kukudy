#!/bin/bash

if ! [[ $# -ge 3 && $2 =~ ^[0-9]+$ ]] ; then
    echo -e "
SYNOPSIS
    sudo bash userCountryByList.sh TARGET_DIR CHANNEL_COUNT LIST...

DESCRIPTION
    userCountryByList.sh connects with the server whose id is in LIST, collects at least
    CHANNEL_COUNT channels and stores the data inside the kukudy/TARGET_DIR/
    directory.
"
    exit 1
fi

cd "$(dirname "$0")/.." || exit 1

TARGET_DIR=$1
CHANNEL_COUNT=$2
LIST=$3
COUNTRY="${LIST}"

mkdir -p "${TARGET_DIR}" || exit 1
cd "${TARGET_DIR}" || exit 1

while read -r line
do
    CONFIG_FILE="$line".nordvpn.com.udp.ovpn
    [[ -f ../nordvpn/ovpn_udp/"$CONFIG_FILE" ]] || continue

    echo -e "Connecting to $line ..."
    openvpn --config         "../nordvpn/ovpn_udp/${CONFIG_FILE}" \
            --auth-user-pass "../nordvpn/auth.txt"                \
            --writepid       "../nordvpn/pid.txt"                 \
            --log-append     "../nordvpn/log.txt"                 \
            --daemon
    bash ../scripts/sleepConnectedUserCountry.sh "${line}"|| continue

    node ../updateStreams.js "${CHANNEL_COUNT}"
    echo -e "Finish updateStreams.js"
    node ../getUserCountry.js "${line}"
    echo -e "Finish getUserCountry.js"

    echo -e "Disconnecting from $line ...\n"
    kill "$(cat ../nordvpn/pid.txt)"
    bash ../scripts/sleepUntilDisconnected.sh

    sleep 25s
done < "${LIST}"
