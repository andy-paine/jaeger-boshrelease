#!/usr/bin/env bash

set -eu

jaeger_version=$(cat JAEGER_VERSION)
curl -sL "https://github.com/jaegertracing/jaeger/releases/download/v${jaeger_version}/jaeger-${jaeger_version}-linux-amd64.tar.gz" \
  -o jaeger.tgz

bosh add-blob jaeger.tgz jaeger-linux-amd64.tar.gz