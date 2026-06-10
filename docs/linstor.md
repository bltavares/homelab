## Node creation


```sh
linstor node create $name $ip
linstor storage-pool create lvmthin $name compute pve/data
```


## Disk creation

```sh
service=banana
size=1Gib

linstor rg spawn nomad linstor-$service 30Mib --storage backup --place-count 1
linstor r make-available $(hostname) linstor-$service --diskful
linstor vd set-size linstor-$service 0 $size

sudo mkfs.xfs /dev/drbd/by-res/linstor-$service/0 -s size=4096
```

### Force primary

Split brain at least once when internet went down.

```sh
service=banana
sudo drbdadm primary --force linstor-$service
```
