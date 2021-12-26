#!/bin/bash

# Source user configuration
. $HOME/.config/mitzrc

# include libraries
. $MITZUNE_LIBDIR/errhand.shi
. $MITZUNE_LIBDIR/posix-alt.shi

# Cuz I'm real
mitzune_prefix="$(realpath "$MITZUNE_PREFIX")"

function main {
    while getopts ":n:R:C:cdriEI" options; do
	    case "$options" in
		    n) export prefixName="$OPTARG" ;;
		    R) export rootfsTarball="$OPTARG" ;;
		    C) export chrootOptions="$OPTARG" ;;
		    c) create_prefix ;;
		    d) delete_prefix ;;
		    r) run_prefix ;;
		    i) show_prefix_info ;;
		    E) export_prefix ;;
		    I) import_prefix ;;
		    \?|h) print_help $OPTARG ;;
	    esac
    done
    shift $(( OPTIND - 1 ))
    clean_n_quit 0
}

function check_doas {
    # doas will be necessary for now since i don't really know how to
    # work with namespaces in Linux for chroot'ing without root rights
    if $(grep "$USER" "$DOAS_CONF" &>/dev/null); then
 	function elevate { doas "$@"; }
	export -f elevate
   	return 
    elif [ $UID == 0 ]; then
        printerr 'Warning: running as root. This isn'\''t recommended.'
    elif $(id -nG $USER | grep 'wheel'); then
	printerr 'Warning: %s can log directly as root, although using doas is better.' \
		"$USER"
	function elevate { su -c "$@"; }
	export -f elevate
    else
        oh_mist 'Fatal: It appears your user doesn'\''t have doas privileges.' 1
    fi
    
}

function create_prefix {
    newPrefix="$mitzune_prefix/$prefixName"

    mkdir "$newPrefix" && \
    if [ -z "$rootfsTarball" ]; then
	    printerr 'Warning: no rootfs declared, creating empty rootfs directory.'
	    mkdir -v "$newPrefix/rootfs"
    else
	    realpathRootfsTarball="$(realpath "$rootfsTarball")"
	    copy2prefix "$realpathRootfsTarball" "$newPrefix"
	    unset realpathRootfsTarball
    fi
    if [ -z "$chrootOptions" ]; then
	    printerr 'Warning: no chroot options informed, creating an empty file.'
	    > "$newPrefix/$prefixName.rc"
    else
	    write_prefix_config "$chrootOptions" "$prefixName" "$newPrefix"
    fi

    # This function generates chroot.mit, independently from chrootOptions
    # being NULL or not, since this file is essential to initialize the chroot
    # prefix.
    write_chroot_mitzune "$newPrefix"
    
    # Unfortunately we can't trust lines() when the file is empty
    installedPrefixes="$(sed '/#/d' "$mitzune_prefix/prefixes" | wc -l | awk '{print $1}')"

    printf '%s %s %s %s %s %s %s %s %s\n' "$(( installedPrefixes + 1 ))" \
    "$prefixName" "$newPrefix" "${prefixProfile:-NULL}" "${prefixMit:-NULL}" \
    "${rootfsTarball:-NULL}" "$OVERWRITE_CHROOT_PROFILE" \
    "${chrootProfile:-NULL}" "$(date +%Y-%m-%d)" >> "$mitzune_prefix/prefixes"

    printf 'Success: %s prefix created.' "$prefixName"
}

function delete_prefix {
    # Remove the prefix itself
    rm -rvI $mitzune_prefix/$prefixName || \
	    oh_mist "Fatal: Couldn't remove $prefixName directory ($mitzune_prefix/$prefixName)." 6

    # Create a safe temporary file
    TMPFILE="$(mktemp -t mitzune.XXXXXX)" || oh_mist 'Fatal: Couldn'\''t create temporary file.' 10

    # Remove the prefix mention at our "database"
    sed "/$prefixName/d" "$mitzune_prefix/prefixes" > "$TMPFILE" && \
	    cat "$TMPFILE" > "$mitzune_prefix/prefixes"

    printf 'Success: %s prefix removed.' "$prefixName"
}

function copy2prefix {
    rootfsTarball="$1"
    newPrefix="$2"
    # Get rootfs extension using built-in regex
    		     # |cut absolute path| 
    rootfsTarballExt="${rootfsTarball##*/}"
    		     # |cut anything before the extension|
    rootfsTarballExt="${rootfsTarballExt##*.}"

    case "$rootfsTarballExt" in
	    gz|tgz) function c { gzip "$@"; } && export isTarball=t;;
	    xz|txz) function c { xz "$@"; } && export isTarball=t;;
	    tar) function  c { shift; cat "$@"; } && export isTarball=t;;
	    *) export isTarball=f;; # Will just try to copy files as it
    esac    		   	    # is a directory. It's in God's hands.

    mkdir -v $newPrefix/rootfs && \
    if [ $isTarball == 't' ]; then
	    c -cd "$rootfsTarball" | tar -xvf - -C "$newPrefix"/rootfs
    elif [ $isTarball == 'f' ]; then
	    cp -rv "$rootfsTarball/*" "$newPrefix"/rootfs
    fi
}

function write_prefix_config {
	chrootOptions="$1"
	prefixName="$2"
	newPrefix="$3"
	prefixProfile="$newPrefix/$prefixName.rc"

	printf '%s' "$chrootOptions" > "$prefixProfile" && \
	if [ $OVERWRITE_CHROOT_PROFILE == true ]; then
		chrootProfile="$newPrefix/rootfs/etc/profile"
	else
		chrootProfile="$newPrefix/rootfs/etc/profile.d/mitzune_conf.sh"
	fi

	test -e "$(dirname $chrootProfile)" \
		|| mkdir -p "$(dirname $chrootProfile)"
	cp -vf "$prefixProfile" "$chrootProfile"
	
	export prefixProfile chrootProfile
}

function write_chroot_mitzune { 
	newPrefix="$1"
	prefixMit="$newPrefix/chroot.mit"
	cat > $prefixMit <<EOF
# This file is part of Mitzune.

# Copyright (c) 2021 Luiz Antônio Rangel. All rights reserved.
# This work is licensed under the terms of the MIT license.  
# For a copy, see <https://opensource.org/licenses/MIT>.

# DO NOT call this function in this file, it will be called
# in the script.

function enter_chroot {
	chroot $newPrefix/rootfs /bin/sh
}
EOF
	export prefixMit
	
}

function run_prefix {
    prefixtobeRun="$mitzune_prefix/$prefixName" 

    check_doas

    if [ -n "$chrootOptions" ]; then
	    printerr 'Warning: rewriting your chroot profile.'
	    write_prefix_config "$chrootOptions" "$prefixName" "$prefixtobeRun"
    fi

    source "$prefixtobeRun"/chroot.mit
    decChrootFunction=$(declare -f enter_chroot)

    elevate sh -c "$decChrootFunction; enter_chroot"
}

function show_prefix_info {
	# Transforms the line containing the $prefixName information
	# in an array.
	# This is fairly faster than just using awk, since we're
	# just throwing the information at the memory instead of
	# pulling it from the disc every time.
	prefix_info=($(grep "$prefixName" "$mitzune_prefix/prefixes"))
	prefix_partition=$(df -H "${prefix_info[2]}" | awk 'FNR==2 {print $1}')
	
	# Mitzune's prefixes file is a matrix which has 9 columns
	if [ $(n $(echo ${prefix_info[*]} | tr -d 'NULL')) \< '9' ]; then
		printerr 'Warning: some information about the prefix isn'\''t avaliable'
	fi

	printf '
prefix name: %s
prefix path: %s
prefix number: %s
partition: %s
prefix configuration: %s
prefix shell profile: %s
chroot profile overwrite?: %s
creation date: %s
' "${prefix_info[1]}" $(trim_home_path "${prefix_info[2]}") "${prefix_info[0]}" \
	"$prefix_partition" $(trim_home_path "${prefix_info[4]}") \
	$(trim_home_path "${prefix_info[7]}") "${prefix_info[6]}" \
	"${prefix_info[8]}"
}

function export_prefix { 
	return 0 # TODO
}

function import_prefix { 
	return 0 # TODO
}

function print_help {
	printf '%s: illegal option "%s"
[usage]: %s -n example [options]

options:
 -n: Prefix name
 -R: rootfs tarball
 -C: chroot profile options
 -c: create new prefix
 -d: delete existent prefix
 -r: run existent prefix
 -i: show prefix information
 -E: export prefix (TODO)
 -I: import prefix (TODO (too))

The Pindorama developers wish you a merry Christmas and a happy new year.
Thanks for running Mitzune!
' $PROGNAME $1 $PROGNAME

	exit 0
}

main "$@"
