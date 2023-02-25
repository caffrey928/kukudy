#!/bin/bash

if ! [[ $# -ge 3 && $2 =~ ^[0-9]+$ ]] ; then
    echo "bookvpn.sh: invalid input \"$*\"

SYNOPSIS
    sudo bash bookvpn.sh DIRECTORY CHANNEL_COUNT CONFIG_ID...

DESCRIPTION
    bookvpn.sh connects to the VPN server(s) with CONFIG_ID(s) consecutively,
    collects at least CHANNEL_COUNT channels and stores the data inside the
    DIRECTORY under the kukudy/ directory." >&2
    exit 1
fi

cd "$(dirname "$0")/.." || exit 1

DIRECTORY=$1
CHANNEL_COUNT=$2
shift
shift
CONFIG_IDS=( "$@" )

mkdir -p "${DIRECTORY}" || exit 1
cd "${DIRECTORY}" || exit 1

{
for CONFIG_ID in "${CONFIG_IDS[@]}" ; do
    CONFIG_FILE="$CONFIG_ID".nordvpn.com.udp.ovpn
    [[ -f ../nordvpn/ovpn_udp/"$CONFIG_FILE" ]] || continue

    echo -en "$(date -u +"%FT%TZ")\t${CONFIG_FILE} connecting\n"
    openvpn --config         "../nordvpn/ovpn_udp/${CONFIG_FILE}" \
            --auth-user-pass "../nordvpn/auth.txt"                \
            --writepid       "../nordvpn/pid.txt"                 \
            --log-append     "../nordvpn/log.txt"                 \
            --daemon
    bash ../scripts/sleepUntilConnected.sh || continue
    echo -en "$(date -u +"%FT%TZ")\t${CONFIG_FILE} connected\n"

    echo -en "$(date -u +"%FT%TZ")\tuS starting\n"
    node ../updateStreams.js "${CHANNEL_COUNT}"
    echo -en "$(date -u +"%FT%TZ")\tuS ended\n"

    echo -en "$(date -u +"%FT%TZ")\tuI starting\n"
    node ../updateInfo.js
    echo -en "$(date -u +"%FT%TZ")\tuI ended\n"

    kill "$(cat ../nordvpn/pid.txt)"
    bash ../scripts/sleepUntilDisconnected.sh
    echo -en "$(date -u +"%FT%TZ")\t${CONFIG_FILE} disconnected\n"
done
} >> log.out 2>> log.err
