#!/bin/bash

if ! [[ $# -ge 3 && $2 =~ ^[0-9]+$ ]] ; then
    echo "bookvpnbycountry.sh: invalid input \"$*\"

SYNOPSIS
    sudo bash bookvpnbycountry.sh TARGET_DIR CHANNEL_COUNT COUNTRY...

DESCRIPTION
    bookvpnbycountry.sh connects with the server in COUNTRY, collects at least
    CHANNEL_COUNT channels and stores the data inside the kukudy/TARGET_DIR/
    directory." >&2
    exit 1
fi

cd "$(dirname "$0")/.." || exit 1

TARGET_DIR=$1
CHANNEL_COUNT=$2
shift
shift
COUNTRIES=( "$@" )

mkdir -p "${TARGET_DIR}" || exit 1
cd "${TARGET_DIR}" || exit 1

{
for COUNTRY in "${COUNTRIES[@]}" ; do
    CONFIG_FILE=$(node ../utils/getConfigIDByCountry.js "$COUNTRY").udp.ovpn;

    [[ -f ../nordvpn/ovpn_udp/${CONFIG_FILE} ]] || continue

    echo -en "$(date -u +"%FT%TZ")\t${CONFIG_FILE} of ${COUNTRY} connecting\n"
    openvpn --config         "../nordvpn/ovpn_udp/${CONFIG_FILE}" \
            --auth-user-pass "../nordvpn/auth.txt"                \
            --writepid       "../nordvpn/pid.txt"                 \
            --log-append     "../nordvpn/log.txt"                 \
            --daemon
    bash ../scripts/sleepUntilConnected.sh || continue
    echo -en "$(date -u +"%FT%TZ")\t${CONFIG_FILE} of ${COUNTRY} connected\n"

    echo -en "$(date -u +"%FT%TZ")\tuS starting\n"
    node ../updateStreams.js "${CHANNEL_COUNT}"
    echo -en "$(date -u +"%FT%TZ")\tuS ended\n"

    echo -en "$(date -u +"%FT%TZ")\tuI starting\n"
    node ../updateInfo.js
    echo -en "$(date -u +"%FT%TZ")\tuI ended\n"

    kill "$(cat ../nordvpn/pid.txt)"
    bash ../scripts/sleepUntilDisconnected.sh
    echo -en "$(date -u +"%FT%TZ")\t${CONFIG_FILE} of ${COUNTRY} disconnected\n"
done
} >> log.out 2>> log.err
