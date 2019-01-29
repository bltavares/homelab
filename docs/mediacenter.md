# Media Center Setup

Given the amount of things running, a Pi3 is ideal. It **will** struggle to run it all, specially as the USB and network use a single bus.
Using torrents (which demands a lot of network) writing to the USB disk (which shares the network bus) **will** make the Pi freeze sometimes.

Just remove the power cable, and restart as necessary. 
Maybe eperiment: celeron ultratop small form PC, Rock64 or Odroid would run them better

Tested on Libreelec 8 and 9.

## Windows Setup

Windows DOES come with Zeroconf/Avahi/Bonjour/mDNS implementatio on recent versions, but I've noticed they don't quite match some avahi versions and fail to find some devices from time to time. Also, some apps would work with the mDNS hostname, while others would ignore it.

It was more reliable to use iTunes Bonjour implementation. Here is the trick:

- Search for iTunes installer (.msi version, not the app store version)
  - Go to iTunes page on apple.com
  - Select Download
  - Avoid the recomendation to use the appstore
  - Scroll a bit down
  - Select: Other versions - Windows
  - The button now should point to the installer
- Unzip the installer
- Install only the Bonjour64

## Kodi setup

- Flash Install LibreElec
  - Simplest flashing tool: Balena Etcher
- Boot the Pi

Kodi should work out of the box with the remote control of a modern TV (couple of years old).
If it doesn't work on first boot, it is very likely be caused by bad cabling. It is possible that a cable supports 1080 transmission, but fails to transmit CEC information. Good HDMI cables often come written CEC-compliant or Ethernet or something on these lines on the cable itself, on small white letters.

A good chance of working is HDAMI 1.4 cables.

On the startup, turn on Samba Sharing and SSH services.
Configure an static IP if you meant to use it as a PiHole instance as well.

It might be necessery a couple for restarts until the NTP sets the time, and Addons are updated.
Check if the wired or network is connecting on startup. It might need to toggle the autoconnect toggle.

### Addons

You might be interested in adding a Subtitle provider. There is Legendas.TV and Subscene providers, and a AutoSub service available.

Install Docker, which will be our main tool to run services on Kodi.

### Network

To make use of Zerotier, and have a p2p VPN access to the device, it is important to ask the network manager to not manage the zt interface
(as of I'm writing).

```sh
cp /etc/connman/main.conf /storage/.config/connman_main.conf
## Edit the file to ignore zt interfaces and reboot
## https://github.com/LibreELEC/LibreELEC.tv/commit/7cee2a095cb6c9126971afc58c145aad473fe7d7
## This will not be necessary in future releases
```

If you intend to use PiHole, you need to manually setup the ip, make it static.
You may do this over ssh using `connmanctl`.

### Transmission

Edit settings to enable other devices to connect:

```sh
docker stop transmission

## Enable RPC password
## add a username
## add a plaintext password (will be hashed automatically later)
## Add RPC host list and enable:
### Eg: 127.0.0.1,192.168.0.*
```

### Sonarr/Radarr

- Add Transmission as client
- Enable rename
- :warning: Don't add series with Monitor all by default, it is very heavy to update a lot of seasons at once with a Pi
- Connect: Kodi
- Add indexers using Jackett

## File Sharing

Kodi comes with SMB service available, but [due to limitations on VLC (libdsm)](https://github.com/videolabs/libdsm/issues/110), both Desktop and Android, it is not possible to use use newer versions of SMB protocol.

This means we need to enable the CIFS/SMB 1.0 protocol on Kodi, even tho that is not that much secure.
What we do for convenience.

Head to Settings, and change the Minimum and Maxium to SMB 1.

That also means that we need to enable SMB/CIFS 1.0 protocol on Windows 10.
Since April 2018, Windows have disabled SMB1 as it is not secure. But you have still the option to enable the client and server discovery. [Better documented here](https://support.microsoft.com/pt-br/help/2696547/how-to-detect-enable-and-disable-smbv1-smbv2-and-smbv3-in-windows-and)

After enabling (there might be some restarts needed), you should be able to acess the files on the network folder.

## PiHole

PiHole is capable to run from Docker. After giving the node a static ip in the network, start it and configure the DHCP server on the router.

## Scripted setup

```sh
DOWNLOADS=/storage/<hdname>/Downloads
MOVIES=/storage/<hdname>/Series
SERIES=/storage/<hdname>/Movies
SYNCTHING=/storage/<hdname>/Syncthing
USERNAME=<username>
PASSWORD=<password>
CONFIG_FOLDER=/storage
TZ=America/Sao_Paulo

pihole() {
  #IP=
  #IPv6=
  WEBPASSWORD="$PASSWORD"

  IP_LOOKUP="$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"
  IPv6_LOOKUP="$(ip -6 route get 2001:4860:4860::8888 | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}')"
  IP="${IP:-$IP_LOOKUP}"       # use $IP, if set, otherwise IP_LOOKUP
  IPv6="${IPv6:-$IPv6_LOOKUP}" # use $IPv6, if set, otherwise IP_LOOKUP

  echo "### Make sure your IPs are correct, hard code ServerIP ENV VARs if necessary\nIP: ${IP}\nIPv6: ${IPv6}"
  docker run -d \
    --name pihole-ng \
    -p 53:53/tcp -p 53:53/udp \
    -p 67:67/udp \
    -p 80:80 \
    -p 443:443 \
    -v "${CONFIG_FOLDER}/pihole/pihole:/etc/pihole/" \
    -v "${CONFIG_FOLDER}/pihole/dnsmasq.d/:/etc/dnsmasq.d/" \
    -e ServerIP="${IP}" \
    -e ServerIPv6="${IPv6}" \
    -e IPv6=true \
    -e WEBPASSWORD \
    -e TZ \
    -e DNS1=1.0.0.1 \
    -e DNS2=8.8.8.8 \
    --restart=unless-stopped \
    --cap-add=NET_ADMIN \
    --dns=127.0.0.1 --dns=1.0.0.1 \
    pihole/pihole:latest

  echo -n "Your password for https://${IP}/admin/ is "
  docker logs pihole-ng 2>/dev/null | grep 'password'
}

syncthing() {
  docker run --name=syncthing \
    -e GUI_USERNAME="$USERNAME" \
    -e GUI_PASSWORD_PLAIN="$PASSWORD" \
    -e UID=0 -e GID=0 \
    -v "${CONFIG_FOLDER}/syncthing/:/syncthing/config" \
    -v "${SYNCTHING}/:/syncthing/data" \
    --network=host \
    --restart=unless-stopped -d \
    funkyfuture/rpi-syncthing
}

transmission() {
  docker run --name=transmission \
    -v /storage/transmission:/config \
    -v "${DOWNLOADS}/:/downloads" \
    -v "${DOWNLOADS}/watch:/watch" \
    -e PGID=0 -e PUID=0 \
    -e TZ \
    -p 9091:9091 \
    --net=host \
    --restart=unless-stopped -d \
    lsioarmhf/transmission
}

sonarr() {
  docker run \
    --name sonarr \
    -p 8989:8989 \
    -e PUID=0 -e PGID=0 \
    -e TZ \
    -v "${CONFIG_FOLDER}/sonarr:/config" \
    -v "${SERIES}/:/tv" \
    -v "${DOWNLOADS}:/downloads" \
    --net=host \
    --restart=unless-stopped -d \
    lsioarmhf/sonarr
}

jackett() {
  docker run --name=jackett \
    -v "${CONFIG_FOLDER}/jackett:/config" \
    -v "${DOWNLOADS}/:/downloads" \
    -e PGID=0 -e PUID=0 \
    -e TZ \
    -p 9117:9117 \
    --net=host \
    --restart=unless-stopped -d \
    lsioarmhf/jackett
}

radarr() {
  docker run --name=radarr \
    -v "${CONFIG_FOLDER}/radarr:/config" \
    -v "${DOWNLOADS}/:/downloads" \
    -v "${MOVIES}/:/movies" \
    -e PGID=0 -e PUID=0 \
    -e TZ \
    -p 7878:7878 \
    --net=host \
    --restart=unless-stopped -d \
    lsioarmhf/radarr
}

bazarr() {
  docker run --name=bazarr \
    -v "${CONFIG_FOLDER}/bazarr:/config" \
    -v "${MOVIES}/:/movies" \
    -v "${SERIES}/:/tv" \
    -e PGID=0 -e PUID=0 \
    -e TZ \
    -p 6767:6767 \
    --net=host \
    --restart=unless-stopped -d \
    lsioarmhf/bazarr
}

zerotier() {
  docker run --name zerotier \
    --device=/dev/net/tun \
    --net=host \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_ADMIN \
    -v "${CONFIG_FOLDER}/zerotier-one:/var/lib/zerotier-one" \
    --restart=unless-stopped -d \
    bltavares/zerotier
}

zerotier-join() {
    docker exec zerotier zerotier-cli join $1
}

## libreelec: defualt hostname
# kodi: http://libreelec.local:8080/
# transmission: http://libreelec.local:9091/
# sonarr: http://libreelec.local:8989/
# jackett: http://libreelec.local:9117/
# radarr: http://libreelec.local:7878/
# bazarr: http://libreelec.local:6767/
```