#!/bin/bash
nfs_host="192.168.15.5"
nfs_export="/meli"
nfs_user=1000

nfs-mount-path() {
  volume_name=$1
  target=${2}
  volume_path=${3:-}
  echo "type=volume,source=${volume_name},target=${target},volume-driver=local,volume-opt=type=nfs,volume-opt=device=:${nfs_export}${volume_path},\"volume-opt=o=addr=${nfs_host},rw,nfsvers=4,async\""
}

nfs-ensure-exists() {
  volume_name="nfs-ensure-exists"
  target="/storage"
  mount="$(nfs-mount-path $volume_name $target)"
  docker run \
    --rm \
    --user 0 \
    --mount "$mount" \
    alpine sh -c "mkdir -p /storage$1 && chown $nfs_user $target$1"
  docker volume rm $volume_name
}


# volume_name="nas"
# ensure-exists /nas

# mount="$(mount-path $volume_name /storage)"
# docker run \
#   --rm -i \
#   --user $nfs_user \
#   --mount "$mount" \
#   alpine sh
# docker volume rm $volume_name