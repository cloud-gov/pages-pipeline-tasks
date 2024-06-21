#!/bin/bash

set -e

# install ytt
ytt_checksum=357ec754446b1eda29dd529e088f617e85809726c686598ab03cfc1c79f43b56
binary_type=linux-amd64
dst_dir=/usr/local/bin

echo "Installing ytt..."
wget -nv -O- https://github.com/carvel-dev/ytt/releases/download/v0.49.0/ytt-${binary_type} > /tmp/ytt
echo "${ytt_checksum}  /tmp/ytt" | shasum -c -
mv /tmp/ytt ${dst_dir}/ytt
chmod +x ${dst_dir}/ytt
echo "Installed ${dst_dir}/ytt v0.49.0"

# hydrate our pipelines with ytt overlays
# https://carvel.dev/ytt/docs/v0.49.x/lang-ref-ytt-overlay

ytt -f $PIPELINE_YML -f pipeline-tasks/overlays -f pipeline-tasks/common > compiled/set-pipeline.yml

# now we can set_pipeline with that final file
