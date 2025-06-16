#!/usr/bin/env bash

# Prometheus Pushgateway Exporter for Pa11y Accessibility Reports

set -euo pipefail

# Configuration
ACCESSIBILITY_REPORT="${ACCESSIBILITY_REPORT:-./reports/gl-accessibility.json}"
PROM_PUSH_URL="${PROM_PUSH_URL}"
PROM_AUTH="${PROM_AUTH}"
PROM_LABEL_PROJECT="${PROM_LABEL_PROJECT:-$CI_PROJECT_NAME}"
PROM_LABEL_TEAM="${PROM_LABEL_TEAM}"
PROM_LABEL_COMMIT="${PROM_LABEL_COMMIT:-$CI_COMMIT_SHORT_SHA}"
PROM_LABEL_BRANCH="${PROM_LABEL_BRANCH:-$CI_COMMIT_REF_NAME}"
PROM_LABEL_INSTANCE="${PROM_LABEL_INSTANCE:-$CI_SERVER_HOST}"

# Ensure accessibility report exists
if [[ ! -f "${ACCESSIBILITY_REPORT}" ]]; then
    echo "Error: Accessibility report not found at ${ACCESSIBILITY_REPORT}"
    exit 1
fi

# Ensure required variables are set
if [[ -z "${PROM_PUSH_URL}" ]]; then
    echo "Error: PROM_PUSH_URL must be set."
    exit 1
fi
if [[ -z "${PROM_AUTH}" ]]; then
    echo "Error: PROM_AUTH must be set."
    exit 1
fi
if [[ -z "${PROM_LABEL_TEAM}" ]]; then
    echo "Error: PROM_LABEL_TEAM must be set."
    exit 1
fi

# Create a temporary file for metrics
METRICS_FILE=$(mktemp)
trap 'rm -f "${METRICS_FILE}"' EXIT

# Extract metrics from JSON and format them for Pushgateway
TOTAL=$(jq -r '.total // 0' "${ACCESSIBILITY_REPORT}")
PASSES=$(jq -r '.passes // 0' "${ACCESSIBILITY_REPORT}")
ERRORS=$(jq -r '.errors // 0' "${ACCESSIBILITY_REPORT}")

# Add summary metrics in Prometheus text format
cat << EOF > "${METRICS_FILE}"
# HELP pa11y_total Total number of pages tested
# TYPE pa11y_total gauge
pa11y_total{project="${PROM_LABEL_PROJECT}",team="${PROM_LABEL_TEAM}",commit="${PROM_LABEL_COMMIT}",branch="${PROM_LABEL_BRANCH}",instance="${PROM_LABEL_INSTANCE}"} ${TOTAL}
# HELP pa11y_passes Total number of passed tests
# TYPE pa11y_passes gauge
pa11y_passes{project="${PROM_LABEL_PROJECT}",team="${PROM_LABEL_TEAM}",commit="${PROM_LABEL_COMMIT}",branch="${PROM_LABEL_BRANCH}",instance="${PROM_LABEL_INSTANCE}"} ${PASSES}
# HELP pa11y_errors Total number of errors
# TYPE pa11y_errors gauge
pa11y_errors{project="${PROM_LABEL_PROJECT}",team="${PROM_LABEL_TEAM}",commit="${PROM_LABEL_COMMIT}",branch="${PROM_LABEL_BRANCH}",instance="${PROM_LABEL_INSTANCE}"} ${ERRORS}
# HELP pa11y_issue Accessibility issues found
# TYPE pa11y_issue gauge
EOF

# Process issues for each URL
jq -c '.results | to_entries[]' "${ACCESSIBILITY_REPORT}" | while read -r url_entry; do
    URL=$(echo "${url_entry}" | jq -r '.key')
    # Escape quotes and backslashes in URL
    URL_ESCAPED=$(echo "${URL}" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

    echo "${url_entry}" | jq -c '.value[]' | while read -r issue; do
        CODE=$(echo "${issue}" | jq -r '.code // "unknown"')
        TYPE=$(echo "${issue}" | jq -r '.type // "unknown"')
        MESSAGE=$(echo "${issue}" | jq -r '.message // "No message provided"')
        SELECTOR=$(echo "${issue}" | jq -r '.selector // "No selector"')
        TYPECODE=$(echo "${issue}" | jq -r '.typeCode // "0"')

        # Escape quotes and backslashes in values
        CODE_ESCAPED=$(echo "${CODE}" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        MESSAGE_ESCAPED=$(echo "${MESSAGE}" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        SELECTOR_ESCAPED=$(echo "${SELECTOR}" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

        # Truncate very long values to avoid Prometheus limits (max 1024 bytes)
        if [ ${#MESSAGE_ESCAPED} -gt 900 ]; then
            MESSAGE_ESCAPED="${MESSAGE_ESCAPED:0:900}..."
        fi
        if [ ${#SELECTOR_ESCAPED} -gt 900 ]; then
            SELECTOR_ESCAPED="${SELECTOR_ESCAPED:0:900}..."
        fi

        if [[ "${CODE}" != "unknown" && "${TYPE}" != "unknown" &&
              "${MESSAGE}" != "No message provided" && "${SELECTOR}" != "No selector" ]]; then
            VALUE="1"
        else
            VALUE="0"
        fi

        # Add this issue to the metrics file
        echo "pa11y_issue{project=\"${PROM_LABEL_PROJECT}\",team=\"${PROM_LABEL_TEAM}\",commit=\"${PROM_LABEL_COMMIT}\",branch=\"${PROM_LABEL_BRANCH}\",instance=\"${PROM_LABEL_INSTANCE}\",url=\"${URL_ESCAPED}\",type=\"${TYPE}\",code=\"${CODE_ESCAPED}\",message=\"${MESSAGE_ESCAPED}\",selector=\"${SELECTOR_ESCAPED}\",typecode=\"${TYPECODE}\"} ${VALUE}" >> "$METRICS_FILE"
    done
done

# Prepare the job name and grouping parameters for Pushgateway
JOB_NAME="pa11y"
GROUPING="job/${JOB_NAME}/project/${PROM_LABEL_PROJECT}/team/${PROM_LABEL_TEAM}"

# Push metrics to Pushgateway
echo "Pushing metrics to Pushgateway at ${PROM_PUSH_URL}/metrics/${GROUPING}"
curl -s -X POST \
    -u "${PROM_AUTH}" \
    -H "Content-Type: text/plain" \
    --data-binary @"${METRICS_FILE}" \
    "${PROM_PUSH_URL}/metrics/${GROUPING}"

if [ $? -eq 0 ]; then
    echo "Successfully pushed metrics to Pushgateway"
else
    echo "Failed to push metrics to Pushgateway"
    exit 1
fi
