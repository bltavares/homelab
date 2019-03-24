#!/bin/bash

kickstart.context "File Server"

kickstart.info "Setup disk mounts"

kickstart.package.install exfat-fuse
kickstart.package.install exfat-utils

mkdir -p /media/onetb
mkdir -p /media/twotb

grep -v 50B6-F043 /etc/fstab >/tmp/fstab
echo "UUID=50B6-F043 /media/onetb     auto     nofail,lazytime,x-systemd.device-timeout=1,noauto,x-systemd.automount,x-systemd.before=docker     0 2" >>/tmp/fstab
mv /tmp/fstab /etc/fstab

grep -v 5C90-2806 /etc/fstab >/tmp/fstab
echo "UUID=5C90-2806 /media/twotb     auto     nofail,lazytime,x-systemd.device-timeout=1,noauto,x-systemd.automount,x-systemd.before=docker    0 2" >>/tmp/fstab
mv /tmp/fstab /etc/fstab

# Spin down all rotational disks after a while
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="/usr/bin/hdparm -B 127 -S 12 /dev/%k"' >/etc/udev/rules.d/60-hdparm.rules

systemctl daemon-reload
kickstart.service.restart local-fs.target

kickstart.info "Expose disks - SAMBA"

kickstart.package.install samba
cat >/etc/samba/smb.conf <<<"
[global]
workgroup = WORKGROUP
netbios name = archiver
server string = archiver
log file = /var/log/samba/log.%m
max log size = 50
map to guest = bad user
socket options = TCP_NODELAY SO_RCVBUF=8192 SO_SNDBUF=8192
local master = no
dns proxy = no

[public]
path = /media
public = yes
only guest = yes
writable = yes
"

kickstart.service.restart smbd

cat >/etc/avahi/services/smb.service <<<'<?xml version="1.0" standalone="no"?>
 <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
 <service-group>
   <name replace-wildcards="yes">SAMBA on %h</name>
   <service>
     <type>_smb._tcp</type>
     <port>139</port>  
   </service>
 </service-group>'

kickstart.info "Expose disks - NFS"

: >/etc/exports
echo "/media/onetb   192.168.15.0/24(rw,all_squash,insecure,no_subtree_check) 10.147.16.0/23(rw,all_squash,insecure,no_subtree_check)" >>/etc/exports
echo "/media/twotb   192.168.15.0/24(rw,all_squash,insecure,no_subtree_check) 10.147.16.0/23(rw,all_squash,insecure,no_subtree_check)" >>/etc/exports

cat >/etc/avahi/services/nfs-onetb.service <<<'<?xml version="1.0" standalone="no"?>
 <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
 <service-group>
   <name replace-wildcards="yes">NFS twotb on %h</name>  
   <service>
     <type>_nfs._tcp</type>
     <port>2049</port>
     <txt-record>path=/media/twotb</txt-record>
   </service>
 </service-group>'

cat >/etc/avahi/services/nfs-twotb.service <<<'<?xml version="1.0" standalone="no"?>
 <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
 <service-group>
   <name replace-wildcards="yes">NFS twotb on %h</name>  
   <service>
     <type>_nfs._tcp</type>
     <port>2049</port>
     <txt-record>path=/media/twotb</txt-record>
   </service>
 </service-group>'

kickstart.package.install nfs-kernel-server
kickstart.service.restart nfs-server
