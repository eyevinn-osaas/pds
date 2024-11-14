#!/bin/sh
set -o errexit
set -o pipefail

GENERATE_SECURE_SECRET_CMD="openssl rand --hex 16"
GENERATE_K256_PRIVATE_KEY_CMD="openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32"

if [ -z "${ADMIN_PASSWORD}" ]; then
  echo "WARNING: No admin password provided. Generating a random one."
  ADMIN_PASSWORD=$(eval "${GENERATE_SECURE_SECRET_CMD}")
fi

PDS_DATADIR=${PDS_DATADIR:-/data}

if [ -d "${PDS_DATADIR}" ]; then
  echo "Using existing data directory: ${PDS_DATADIR}"
else
  echo "Creating data directory: ${PDS_DATADIR}"
  mkdir -p ${PDS_DATADIR}
fi

export PDS_PORT=${PORT:-8080}
export PDS_HOSTNAME=${DNS_NAME:-${OSC_HOSTNAME}}
export PDS_ADMIN_PASSWORD=${ADMIN_PASSWORD}
export PDS_JWT_SECRET=$(eval "${GENERATE_SECURE_SECRET_CMD}")
export PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$(eval "${GENERATE_K256_PRIVATE_KEY_CMD}")
export PDS_DATA_DIRECTORY=${PDS_DATADIR}
export PDS_BLOBSTORE_DISK_LOCATION=${PDS_DATADIR}/blocks
export PDS_BLOB_UPLOAD_LIMIT=52428800
export PDS_BSKY_APP_VIEW_URL="https://api.bsky.app"
export PDS_BSKY_APP_VIEW_DID="did:web:api.bsky.app"
export PDS_REPORT_SERVICE_URL="https://mod.bsky.app"
export PDS_REPORT_SERVICE_DID="did:plc:ar7c4by46qjdydhdevvrndac"
export PDS_CRAWLERS="https://bsky.network"

echo $PDS_HOSTNAME

cd /app && node --enable-source-maps index.js
