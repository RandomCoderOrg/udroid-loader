#!/usr/bin/env bash

die()   { echo -e "?? Error ${*}" ;if $ENABLE_EXIT; then exit 1 ;fi ;:; }
warn()  { echo -e "!! ${*}";:;}
shout() { echo -e "=> ${*}";:;}
msg()   { echo -e "${*}";:;}

######## Get terminal Height and Width
export HEIGHT
export WIDTH

HEIGHT_FULL=$(stty size | cut -d ' ' -f 1)
WIDTH_FULL=$(stty size | cut -d ' ' -f 2)

# for better box size use (-16)
HEIGHT=$((HEIGHT_FULL - 16))
WIDTH=$((WIDTH_FULL - 16))

#########################
# depends_on() : check for binarie with ( command )
# if fail call die()
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
#########################
# dpkg_depends_on() : check for binarie with ( dpkg )
# * used when target package is a bundle
# if fail call die()
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

#########################
# menu: using whiptail to generate a menu need to solve a thing
# i.e dynamic menu so that devoloper dont need to modify function
# after every update in udroid
# 1) take all variales from $3 - n
# 2) add sr.no & variable with a loop like ("number" "name")
# 3) call whiptail with the above generated menu
# whiptail --title <title> --menu <title> <screen [height, weight, list height]> < variable with ("number name")>
#########################
# generate_menu() : generate a menu with whiptail
# * 1) take main title in first argument
# * 2) take sub title in second argument
# * 3) take list of choices in third argument 
# * 4) set numbers to given choices & assign values to buffer variable
# * 5) call menu with main title,sub title,buffer variable
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
            whiptail \
            --title "${title}" \
            --menu "${menu_title}" \
            $HEIGHT $WIDTH ${x} \
            ${buffer} 3>&1 1>&2 2>&3
        )
    fi

}
#########################
# generate_de_menu() : generate a menu with whiptail
# * 1) take main title in first argument
# * 2) take sub title in second argument
# * 3) take list of choices in third argument 
# * 4) set numbers to given choices & assign values to buffer variable
# * 5) call menu with main title,sub title,buffer variable

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
            whiptail \
            --title "${title}" \
            --menu "${menu_title}" \
            $HEIGHT $WIDTH ${x} \
            ${buffer} 3>&1 1>&2 2>&3
        )
    fi

}