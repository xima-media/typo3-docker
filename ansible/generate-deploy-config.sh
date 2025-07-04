#!/bin/bash
# filepath: /usr/local/bin/generate-deploy-config.sh
# Generate JSON configuration for deploy.sh from environment variables

set -eo pipefail

OUTPUT_FILE=$1

# Create base JSON structure with all required fields
jq -n \
  --arg project_name "${DEPLOY_PROJECT_NAME:-}" \
  --arg branch "${DEPLOY_BRANCH:-}" \
  --arg base_branch "${DEPLOY_BASE_BRANCH:-}" \
  --arg type "${DEPLOY_TYPE:-}" \
  --arg image "${DEPLOY_IMAGE:-}" \
  --arg domain_primary "${DEPLOY_DOMAIN_PRIMARY:-}" \
  --arg app_port "${DEPLOY_APP_PORT:-}" \
  --arg docker_compose_base64 "${DEPLOY_DOCKER_COMPOSE_BASE64:-}" \
  --argjson rollback "$(echo "${DEPLOY_ROLLBACK:-true}" | tr '[:upper:]' '[:lower:]')" \
  '{
    "project_name": $project_name,
    "branch": $branch,
    "base_branch": $base_branch,
    "type": $type,
    "image": $image,
    "domain_primary": $domain_primary,
    "app_port": $app_port,
    "rollback": $rollback,
    "docker_compose": $docker_compose_base64,
    "domain_aliases": [],
    "secrets": {},
    "cronjobs": []
  }' > "${OUTPUT_FILE}.tmp"

# Process domain aliases if defined
if [[ -n "${DEPLOY_DOMAIN_ALIASES:-}" ]]; then
  # Split comma-separated list into JSON array
  jq --arg aliases "${DEPLOY_DOMAIN_ALIASES}" \
    '.domain_aliases = ($aliases | split(",") | map(select(length > 0)))' \
    "${OUTPUT_FILE}.tmp" > "${OUTPUT_FILE}.tmp2" && mv "${OUTPUT_FILE}.tmp2" "${OUTPUT_FILE}.tmp"
fi

# Process secrets if defined
if [[ -n "${DEPLOY_SECRETS:-}" ]]; then
  # Write secrets to temporary file
  echo "${DEPLOY_SECRETS}" > /tmp/secrets.tmp

  # Convert KEY=VALUE format to JSON object
  SECRETS_JSON="$(jq -n '{}')"
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
      # Split at first equals sign
      key="${line%%=*}"
      value="${line#*=}"
      # Add to JSON
      SECRETS_JSON=$(echo "${SECRETS_JSON}" | jq --arg key "$key" --arg value "$value" '. + {($key): $value}')
    fi
  done < /tmp/secrets.tmp

  # Add secrets to main config
  jq --argjson secrets "${SECRETS_JSON}" '.secrets = $secrets' "${OUTPUT_FILE}.tmp" > "${OUTPUT_FILE}.tmp2" &&
    mv "${OUTPUT_FILE}.tmp2" "${OUTPUT_FILE}.tmp"

  # Clean up
  rm -f /tmp/secrets.tmp
fi

# Process cronjobs if defined
if [[ -n "${DEPLOY_CRONJOBS:-}" ]]; then
  # Write cronjobs to temporary file
  echo "${DEPLOY_CRONJOBS}" > /tmp/cronjobs.tmp

  # Initialize empty cronjobs array
  CRONJOBS_JSON="[]"

  # Process each line in the CSV format: schedule,user,command
  while IFS=, read -r schedule user command; do
      # Create cronjob object and add to array
      CRONJOB=$(jq -n \
        --arg schedule "$schedule" \
        --arg user "$user" \
        --arg command "$command" \
        '{schedule: $schedule, user: $user, command: $command}')
      CRONJOBS_JSON=$(echo "${CRONJOBS_JSON}" | jq --argjson job "${CRONJOB}" '. + [$job]')
  done < /tmp/cronjobs.tmp

  # Add cronjobs to main config
  jq --argjson cronjobs "${CRONJOBS_JSON}" '.cronjobs = $cronjobs' "${OUTPUT_FILE}.tmp" > "${OUTPUT_FILE}.tmp2" &&
    mv "${OUTPUT_FILE}.tmp2" "${OUTPUT_FILE}.tmp"

  # Clean up
  rm -f /tmp/cronjobs.tmp
fi

# Move temporary file to final location
mv "${OUTPUT_FILE}.tmp" "${OUTPUT_FILE}"
chmod 600 "${OUTPUT_FILE}"  # Secure permissions for potential secrets

echo "JSON configuration generated at ${OUTPUT_FILE}"

exit 0