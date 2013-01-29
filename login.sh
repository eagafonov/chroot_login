#!/bin/bash

ROOT=`dirname $0`/root

function do_bind() {
    DIR=$1
    P=$ROOT$DIR

    shift

    MOUNT_ARGS=$1

    c=`mount | grep "$P" | wc -l`
#     echo "I: Binding $DIR as $P"

    if [ "$c" != "0" ]; then
        echo "I: $DIR already mounted"
    else
        echo mount -o bind  $MOUNT_ARGS $DIR $P

        mount_status=$?

        if [ "$mount_status" == "0" ]; then
           echo "I: Bind $DIR -> $P"
        else
           echo "W: Failed to bind $DIR"
        fi
    fi
}

function do_bind_ro() {
    DIR=$1 
    do_bind $DIR "-o ro"
}

if [ "`id -u`" != "0" ]; then
    echo "E: Must be launched as root"
    exit 1
fi

if [ ! -d "$ROOT" ]; then
    echo "E: Root folder $ROOT not found"
    exit 1
fi

if [ "$1" == "unbind" ]; then
    echo "I: Unmounting"
    umount `mount | grep $ROOT | cut -d\  -f3`
    exit 0
fi

echo "I: Sync resolv.conf"
cp /etc/resolv.conf $ROOT/etc/resolv.conf

# echo "I: Mounting"
do_bind /proc
do_bind /dev

# do_bind_ro /home

if [ "$#" == "0" ]; then
    PS1='\[\e[1;31m\][CHROOT:\u@\h \W]\$\[\e[0m\] ' chroot $ROOT /bin/bash
else
    chroot $ROOT $@
fi