# S3 Bucket Mount On Filesytem

This guide will help you set up and mount an S3 bucket onto your filesystem using third-party software (rclone, s3fs, etc)

## Prerequisites

Ensure you have already installed third-party software:

- Install [`rclone`](https://rclone.org/install/)
- Install [`s3fs`](https://github.com/s3fs-fuse/s3fs-fuse)

## Using 3rd software to mount your S3 bucket onto filesystem

### Step 1:

Config information before using 3rd software to mount. See [rclone.config.example](rclone/rclone.config.example), [s3fs-passwd.example](rclone/s3fs-passwd.example), etc.

### Step 2:

You need to set some configs in script `.sh` to ensure correct bucket information:

- rclone:

```bash
bucket=<YOUR_BUCKET>
url=<ENDPOINT_URL>
mount_point=<MOUNT_POINT>
config_file=/etc/rclone.conf
log_file=/var/log/rclone-mount.log
log_level=DEBUG
provider=<YOUR_PROVIDER> # vstorage, s3, etc.
```

- s3fs:

```bash
bucket=<YOUR_BUCKET>
url=<ENDPOINT_URL>
mount_point=<MOUNT_POINT>
config_file=/etc/rclone.conf
log_file=/var/log/s3fs-mount.log
log_level=debug
region=HCM03
```

### Step 3:

Setup systemd mode to ensure that the process was managed by systemd, and easy to manage your service. To do that:

Example for `rclone-mount`:

```bash
sudo cp rclone/rclone-mount.service /lib/systemd/system/rclone-mount.service
sudo systemctl daemon-reload
sudo systemctl enable rclone-mount --now
```

### Step 4:

Recheck your service with `systemctl status rclone-mount`, and check information in log file.

## Troubleshooting

- Ensure your AWS credentials are correct.
- Check for any network issues.
- Verify that the bucket name is correct.

## References

- [rclone Documentation](https://rclone.org/docs/)
- [s3fs Documentation](https://github.com/s3fs-fuse/s3fs-fuse)
