#!/usr/bin/env bash
set -o pipefail
mkdir -p reports

pa11y-ci -j --config "/pa11y-configs/.pa11yci" $@ > reports/gl-accessibility.json