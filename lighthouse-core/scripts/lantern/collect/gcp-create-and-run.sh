#!/bin/bash

# This script is assumed to be run from the LH_ROOT directory.

set -euxo pipefail

CLOUDSDK_CORE_PROJECT=lighthouse-lantern-collect

gcloud --project="$CLOUDSDK_CORE_PROJECT" compute instances create url-collect-instance \
  --image-family=ubuntu-1804-lts --image-project=ubuntu-os-cloud \
  --zone=us-central1-a \
  --boot-disk-size=100GB \
  --machine-type=n1-standard-2

gcloud --project="$CLOUDSDK_CORE_PROJECT" compute scp ./lighthouse-core/scripts/lantern/collect/gcp-setup.sh url-collect-instance:/tmp/gcp-setup.sh --zone=us-central1-a
gcloud --project="$CLOUDSDK_CORE_PROJECT" compute scp ./lighthouse-core/scripts/lantern/collect/gcp-run.sh url-collect-instance:/tmp/gcp-run.sh --zone=us-central1-a
gcloud --project="$CLOUDSDK_CORE_PROJECT" compute ssh url-collect-instance --command="bash /tmp/gcp-setup.sh" --zone=us-central1-a
gcloud --project="$CLOUDSDK_CORE_PROJECT" compute ssh url-collect-instance --command="sudo -u lighthouse sh -c 'nohup /home/lighthouse/gcp-run.sh > /home/lighthouse/collect.log 2>&1 < /dev/null &'" --zone=us-central1-a

set +x

echo "Collection has started."
echo "Check-in on progress anytime by running..."
echo "  $ gcloud --project="$CLOUDSDK_CORE_PROJECT" compute ssh url-collect-instance"
echo "  $ sudo -u lighthouse tail -f /home/lighthouse/collect.log"

echo "When complete run..."
echo "  $ gcloud --project="$CLOUDSDK_CORE_PROJECT" compute scp url-collect-instance:/home/lighthouse/src/lighthouse/timings-data/ ./collect-gcp-timings-data"
echo "  $ gcloud --project="$CLOUDSDK_CORE_PROJECT" compute instances delete url-collect-instance"
