#!/usr/bin/env bash
#
# downloads a fresh copy of the MaxMind databases for ASN & geolocation lookups and makes an encrypted release
#

set -o errexit
set -o pipefail
set -o nounset

echo "INFO: starting MaxMind update at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
REPO_DIR="$(realpath "${SCRIPT_DIR}/..")"

ENV_FILE="$(realpath "${REPO_DIR}/.env")"
if [ -f "${ENV_FILE}" ]; then
    echo "INFO: loading ${ENV_FILE} into environment"
    export $(cat ${ENV_FILE})
fi

TAR=tar
if [[ $OSTYPE == 'darwin'* ]]; then
    echo "INFO: running on MacOS so using gtar instead of tar"
    TAR=gtar
fi

BUILD_DIR="$(realpath "${REPO_DIR}/build")"
if [ ! -d "${BUILD_DIR}" ]; then
    echo "INFO: creating build directory ${BUILD_DIR}"
    mkdir -p "${BUILD_DIR}"
else
    echo "INFO: using existing build directory ${BUILD_DIR}"
fi

TMP_ASN_FILE=$(mktemp)
echo "INFO: download MaxMind ASN database into ${TMP_ASN_FILE}"
curl --silent "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&suffix=tar.gz&license_key=${MAXMIND_LICENSE_KEY}" >"${TMP_ASN_FILE}"
${TAR} -xzf ${TMP_ASN_FILE} --directory="${BUILD_DIR}" --wildcards --strip-components 1 "*.mmdb"
rm "${TMP_ASN_FILE}"

TMP_CITY_FILE=$(mktemp)
echo "INFO: download MaxMind City database into ${TMP_CITY_FILE}"
curl --silent "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&suffix=tar.gz&license_key=${MAXMIND_LICENSE_KEY}" >"${TMP_CITY_FILE}"
${TAR} -xzf ${TMP_CITY_FILE} --directory="${BUILD_DIR}" --wildcards --strip-components 1 "*.mmdb"
rm "${TMP_CITY_FILE}"

md5sum ${BUILD_DIR}/*.mmdb | sort >${BUILD_DIR}/mmdb.md5

#LATER: curl release/download/latest/mmdb.md5
#DIFF=$(git diff --name-only "${BUILD_DIR}/mmdb.md5")
#
#if [ "${DIFF}" == "" ]; then
#    echo "INFO: no changes, exiting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
#    exit 0
#fi

if [ "${MMDB_ENCRYPTION_KEY:-BAD}" = "BAD" ]; then
    echo "INFO: no encryption keys, exiting.  (but app can still be run locally)"
    exit 1
fi

#
# generate (and save) a new IV every time
#
MMDB_ENCRYPTION_IV=$(head -c 16 /dev/urandom | xxd -l 16 -c 16 -p)
echo -n ${MMDB_ENCRYPTION_IV} > ${BUILD_DIR}/mmdb.iv

ASN_FILE="${BUILD_DIR}/GeoLite2-ASN.mmdb"
echo "INFO: starting encryption of ${ASN_FILE} (file size=$(du ${ASN_FILE} | cut -f 1))"
gzip --stdout ${ASN_FILE} | openssl enc -aes-256-ctr \
	-K ${MMDB_ENCRYPTION_KEY} \
	-iv ${MMDB_ENCRYPTION_IV} \
	-out "${ASN_FILE}.enc"
rm ${ASN_FILE}
echo "INFO: encryption complete (file size=$(du ${ASN_FILE}.enc | cut -f 1))"

CITY_FILE="${BUILD_DIR}/GeoLite2-City.mmdb"
echo "INFO: starting encryption of ${CITY_FILE} (file size=$(du ${CITY_FILE} | cut -f 1))"
gzip --stdout ${CITY_FILE} | openssl enc -aes-256-ctr \
	-K ${MMDB_ENCRYPTION_KEY} \
	-iv ${MMDB_ENCRYPTION_IV} \
	-out "${CITY_FILE}.enc"
rm ${CITY_FILE}
echo "INFO: encryption complete (file size=$(du ${CITY_FILE}.enc | cut -f 1))"

echo "INFO: complete MaxMind update at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
