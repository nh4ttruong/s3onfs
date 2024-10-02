#!/bin/bash

set -e

bucket=<YOUR_BUCKET>
url=<ENDPOINT_URL>
mount_point=<MOUNT_POINT>
config_file=/etc/rclone.conf
log_file=/var/log/rclone-mount.log
log_level=DEBUG
provider=<YOUR_PROVIDER> # vstorage, s3, etc.

function create_mount_point {
    if [ ! -d "$mount_point" ]; then
        echo "[info] creating $mount_point directory"
        mkdir -p $mount_point
    fi
}

function mount_bucket {
    echo "[info] mounting $bucket under $mount_point"
    if [ ! -f "$config_file" ]; then
        touch $log_file
    fi
    rclone mount --config=$config_file $provider:$bucket $mount_point --log-level=$log_level --log-file=$log_file --vfs-cache-mode off --allow-non-empty --allow-other --drive-chunk-size 256M --max-read-ahead 200M --dir-cache-time 30m --daemon
}

function umount_bucket {
    echo "[info] umount bucket $bucket at $mount_point"
    fusermount -uz $mount_point
}

function add_fstab_entry {
    fstab_entry="$provider:$bucket $mount_point fuse.rclone config=$config_file,allow-other,allow-non-empty,log-level=$log_level,log-file=$log_file,vfs-cache-mode=off,daemon 0 0"
    if ! grep -qs "$fstab_entry" /etc/fstab; then
        echo "[info] adding fstab entry"
        echo "$fstab_entry" | sudo tee -a /etc/fstab
        mount -a
    else
        echo "[info] fstab entry already exists"
    fi
}

case "$1" in
    mount)
        create_mount_point
        add_fstab_entry
        mount_bucket
        ;;
    umount)
        umount_bucket
        ;;
    remount)
        umount_bucket
        mount_bucket
        ;;
    *)
        echo "Usage: $0 {mount|umount|remount}"
        exit 1
        ;;
esac