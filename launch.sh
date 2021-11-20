#!/usr/bin/env bash

export CONF_FILE

ROOT_DIR="$(dirname "$0")"
x=0

#shellcheck disable=SC1091
source "${ROOT_DIR}"/functions.sh

# depencies check
dpkg_depends_on "whiptail jq"

# get distribution choice
CONF_FILE="$ROOT_DIR/distro_prop.json"
distributions=$(jq ".distributions.variants[]" "${CONF_FILE}" | cut -d "\"" -f -2 | cut -d "\"" -f 2-)
x=0
for distribution in $distributions; do
    if [[ "$(jq ".distributions.${distribution}.enabled" "$CONF_FILE")" == true ]]; then
        enabled_distributions="$distribution $enabled_distributions"
        ((x=x+1))
    fi
done
if (( x > 1 )); then
    generate_menu "UBUNTU VERSION" "choose a ubuntu version(bigger is best)" "$enabled_distributions"
elif (( x == 1 )); then
    DIS_CHOICE="$enabled_distributions"
else
    die "No ubuntu versions is enabled"
fi



# get enabled variants with description
variants=""
choice=$(jq .distributions.variants[$((DIS_CHOICE-1))] "$CONF_FILE" | cut -d "\"" -f -2 | cut -d "\"" -f 2-)
variants=$(jq ".distributions.$choice.de.variants[]" "$CONF_FILE" | cut -d "\"" -f -2 | cut -d "\"" -f 2-)
x=0
for variant in $variants; do
    if [[ "$(jq ".distributions.$choice.de.${variant}.enabled" "$CONF_FILE")" == true ]]; then
        enabled_variants="$enabled_variants $variant"
        ((x=x+1))
    fi
done
if (( x > 1 )); then
    generate_de_menu "Desktop Environment" "choose Desktop environment.." $enabled_variants
elif (( x == 1 )); then
    DE_CHOICE="$enabled_variants"
else
    die "No ubuntu variants is enabled"
fi


echo $DIS_CHOICE
echo $DE_CHOICE
