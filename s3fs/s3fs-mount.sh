#!/bin/bash

set -e

bucket=<YOUR_BUCKET>
url=<ENDPOINT_URL>
mount_point=<MOUNT_POINT>
config_file=/etc/rclone.conf
log_file=/var/log/s3fs-mount.log
log_level=debug
region=HCM03

function ensure_passwd_file {
        if [ ! -f "$passwd_file" ];then
                echo "[INFO] Creating $passwd_file"
                echo "$access_key:$secret_key" > $passwd_file
                chmod 600 $passwd_file
        fi
}

function create_mount_point {

        if [ ! -d "$mount_point" ];then

           echo "[INFO] Creating $mount_point directory"
           mkdir -p $mount_point

        fi
}

function mount_bucket {

        echo "[INFO] Mounting $bucket at $mount_point"

        if [ ! -f "$config_file" ];then
                touch $log_file
        fi

        s3fs $bucket $mount_point -o passwd_file=$passwd_file -o url=$url -o endpoint=$region -o umask=0002 -o allow_other -o use_path_request_style -o dbglevel=$log_level 
}

function umount_bucket {

        echo "[INFO] Umount bucket $bucket at $mount_point"
        fusermount -uz $mount_point

}

function add_fstab_entry {
    
            fstab_entry="$bucket $mount_point fuse.s3fs passwd_file=$passwd_file,url=$url,endpoint=$region,umask=0002,allow_other,use_path_request_style,dbglevel=$log_level 0 0"
    
            if ! grep -qs "$fstab_entry" /etc/fstab; then
                    echo "[INFO] Adding fstab entry"
                    echo "$fstab_entry" | sudo tee -a /etc/fstab
                    mount -a
            else
                    echo "[INFO] fstab entry already exists"
            fi

}

case "$1" in
    mount)
        create_mount_point
        ensure_passwd_file
        mount_bucket
        add_fstab_entry
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