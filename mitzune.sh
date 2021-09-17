#!/bin/bash

# Source user configuration
. $HOME/.config/mitzrc

# include libraries
. $MITZUNE_LIBDIR/errhand.shi
. $MITZUNE_LIBDIR/posix-alt.shi

function main {
    while getopts ":n:R:C:cdri" options; do
	    case "$options" in
		    n) export prefixName="$OPTARG" ;;
		    R) export rootfsTarball="$OPTARG" ;;
		    C) export chrootOptions="$OPTARG" ;;
		    c) create_prefix ;;
		    d) delete_prefix ;;
		    r) run_prefix ;;
		    i) show_prefix_info ;;
		    \?) print_help
	    esac
    done
    shift $(( OPTIND - 1 ))
    clean_n_quit 0
}

function check_doas {
    # doas will be necessary for now since i don't really know how to
    # work with namespaces in Linux for chroot'ing without root rights
    if `grep "$USER" "$DOAS_CONF" &>/dev/null`; then
    	return 
    elif [ $UID == 0 ]; then
        printerr 'Warning: running as root. This isn'\''t recommended.'
    else
        oh_mist 'Fatal: It appears your user doesn'\''t have doas privileges.' 1
    fi
    
}

function create_prefix {
    newPrefix="$MITZUNE_PREFIX/$prefixName"
    mkdir "$newPrefix" && \
    echo "$rootfsTarball"
    if [ -z "$rootfsTarball" ]; then
	    printerr 'Warning: no rootfs declared, creating empty rootfs directory.'
	    mkdir -v "$newPrefix/rootfs"
    else
	    copy2prefix "$rootfsTarball" "$newPrefix"
    fi
    if [ -z "$chrootOptions" ]; then
	    printerr 'Warning: no chroot options informed, creating an empty file.'
	    > "$newPrefix/$prefixName.rc"
    else
	    write_prefix_config "$chrootOptions" "$prefixName" "$newPrefix"
    fi
    # Unfortunately we can't trust lines() when the file is empty
    installedPrefixes="$(sed '/#/d' "$MITZUNE_PREFIX/prefixes" | wc -l | awk '{print $1}')"
    printf '%s %s %s %s %s\n' "$(( installedPrefixes + 1 ))" "$prefixName" "$newPrefix" "$rootfsTarball" "$(date +%Y-%m-%d)" >> "$MITZUNE_PREFIX/prefixes"
    printf 'Success: %s prefix created.' "$prefixName"
}

function delete_prefix {
    # Remove the prefix itself
    rm -rvI $MITZUNE_PREFIX/$prefixName || \
	    oh_mist "Fatal: Couldn'\''t remove $prefixName directory ($MITZUNE_PREFIX/$prefixName)." 6
    # Create a safe temporary file
    TMPFILE="$(mktemp)" || oh_mist 'Fatal: Couldn'\''t create temporary file.' 10
    # Remove the prefix mention at our "database"
    sed "/$prefixName/d" "$MITZUNE_PREFIX/prefixes" > "$TMPFILE" && \
	    cat "$TMPFILE" > "$MITZUNE_PREFIX/prefixes"
    printf 'Success: %s prefix removed.' "$prefixName"
}

function copy2prefix {
    rootfsTarball=$1
    newPrefix=$2
    # Get rootfs extension using built-in regex
    		     # |cut absolute path| 
    rootfsTarballExt="${rootfsTarball##*/}"
    		     # 	      |cut extension|
    rootfsTarballExt="${rootfsTarballExt##*.}"
    case $rootfsTarballExt in
	    gz|tgz) function c { gzip "$@"; } && export isTarball=t;;
	    xz|txz) function c { xz "$@"; } && export isTarball=t;;
	    tar) function  c { cat "$@"; } && export isTarball=t;;
	    *) export isTarball=f;; # Will just try to copy files as it
    esac    		   	    # is a directory
    mkdir -v $newPrefix/rootfs && \
    if [ $isTarball == 't' ]; then
	    c -cd $rootfsTarball | tar -xvf - -C $newPrefix/rootfs
    elif [ $isTarball == 'f' ]; then
	    cp -rv $rootfsTarball/* $newPrefix/rootfs
    fi
}

function write_prefix_config {
	chrootOptions="$1"
	prefixName=$2
	newPrefix=$3
	printf '%s' "$chrootOptions" > "$newPrefix/$prefixName.rc"
}

function run_prefix {
    check_doas
}

main "$@"
