#!/bin/bash

# usage: /bin/bash ./check_typo3_requirements.sh "packages/xima_sitepackage/composer.json"

# define path of sitepackage composer.json
if [[ -n "$1" ]]; then
    SITEPACKAGE_COMPOSER_JSON="$1"
    if [ ! -f ${SITEPACKAGE_COMPOSER_JSON} ]; then
        printf "\\e[0;31mError: '${SITEPACKAGE_COMPOSER_JSON}' does not exist.\n\\e[0m"
        exit 1
    fi
else
    printf "\\e[0;31mError: Provide path to composer.json of sitepackage as first argument. Usage: \'./check_typo3_requirements.sh "packages/xima_sitepackage/composer.json\'"\n\\e[0m"
    exit 1
fi

# error handling
set -euo pipefail

PACKAGES_MISSING=()
SUBDEPENDENCIES_ALL=()

# ensure composer.json of sitepackage has require object
if [[ "$(jq -r 'has("require")' "${SITEPACKAGE_COMPOSER_JSON}")" != "true" ]]; then
    printf "\\e[0;31mError: '${SITEPACKAGE_COMPOSER_JSON}' require object is missing.\n\\e[0m"
    exit 1
fi

# extract package name of sitepackage
SITEPACKAGE_NAME=$(jq -r '.name' "${SITEPACKAGE_COMPOSER_JSON}")

# retrieve all dependencies from root composer.json excluding the sitepackage itself
REQUIRES=$(jq -r --arg SITEPACKAGE_NAME "${SITEPACKAGE_NAME}"  'del(.require[$SITEPACKAGE_NAME]) | .require | keys[]' composer.json)

# loop through all dependencies
for REQUIRE in ${REQUIRES[@]}; do
    # cat their composer.json
    if [ -f "vendor/${REQUIRE}/composer.json" ]; then
        # extract composer type
        PACKAGE_TYPE=$(jq -r '.type' "vendor/${REQUIRE}/composer.json")
        # and check if == "typo3-cms-extension"
        if [[ "${PACKAGE_TYPE}" == "typo3-cms-extension" ]]; then
            # if so, check if the package is requirement in sitepackage
            IN_SITEPACKAGE=$(jq -r --arg REQUIRE "${REQUIRE}" '.require | has($REQUIRE)' "${SITEPACKAGE_COMPOSER_JSON}")
            if [[ "${IN_SITEPACKAGE}" == 'false' ]]; then
                # if not, save to array
                PACKAGES_MISSING+=("${REQUIRE}")
            fi
        fi
    fi
done

# if array is not empty, output all missing packages + throw exit code
if [ ${#PACKAGES_MISSING[@]} -ne 0 ]; then
    PACKAGES_MISSING_SORTED=($(printf "%s\n" "${PACKAGES_MISSING[@]}" | sort -u))
    printf "\\e[0;31mError: Packages of type 'typo3-cms-extension' missing in '${SITEPACKAGE_COMPOSER_JSON}':\n\\e[0m"
    printf "\\e[0;31m %s\n\\e[0m" "${PACKAGES_MISSING_SORTED[@]}"
    exit 1
fi
