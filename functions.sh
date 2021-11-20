#!/usr/bin/env bash

die()   { echo -e "?? Error ${*}" ;if $ENABLE_EXIT; then exit 1 ;fi ;:; }
warn()  { echo -e "!! ${*}";:;}
shout() { echo -e "=> ${*}";:;}
msg()   { echo -e "${*}";:;}

export HEIGHT
export WIDTH
export SCREEN_SIZE

HEIGHT_FULL=$(stty size | cut -d ' ' -f 1)
WIDTH_FULL=$(stty size | cut -d ' ' -f 2)

HEIGHT=$((HEIGHT_FULL - 6))
WIDTH=$((WIDTH_FULL - 6))

depends_on() {
    local packages="$1"
    export x

    x=0
    for package in ${packages}; do
        if ! command -v "${package}" &>/dev/null; then
            warn "Missing package: ${package}"
            ((x = x + 1))
        fi
    done

    if ((x > 0)); then
        die "Found missing packages: ${packages}"
    fi
}

dpkg_depends_on() {
    local packages="$1"
    export x

    x=0
    for package in ${packages}; do
        if ! dpkg -s "${package}" &>/dev/null; then
            warn "Missing package: ${package}"
            ((x = x + 1))
        fi
    done

    if ((x > 0)); then
        die "Found missing packages: ${packages}"
    fi
}
generate_menu() {
    title=$1
    menu_title=$2
    buffer=""

    export DIS_CHOICE

    shift 2
    items="$*"
    x=0

    if [ -z "${items}" ]; then
        die "Sorry: looks like udroid is under mantainence!"
    else
        for item in $items; do
            ((x=x+1))
            buffer="${x} ${item} ${buffer}"
        done

        DIS_CHOICE=$(
            whiptail --title "${title}" --menu "${menu_title}" $HEIGHT $WIDTH ${x} ${buffer} 3>&1 1>&2 2>&3
        )
    fi

}

generate_de_menu() {
    title=$1
    menu_title=$2
    buffer=""

    export DE_CHOICE

    shift 2
    items="$*"
    x=0

    if [ -z "${items}" ]; then
        warn "looks like no installable variants found"
        shout "fallback to raw filesystem to raw filesystem"
        DE_CHOICE="raw"
    else
        for item in $items; do
            ((x=x+1))
            buffer="${x} ${item} ${buffer}"
        done

        DE_CHOICE=$(
            whiptail --title "${title}" --menu "${menu_title}" $HEIGHT $WIDTH ${x} ${buffer} 3>&1 1>&2 2>&3
        )
    fi

}