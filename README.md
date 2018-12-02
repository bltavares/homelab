# Homelab setup

## ISP-provided Router - Vivo Fibra

![Documented](https://img.shields.io/badge/Documented-No-red.svg) ![Automated](https://img.shields.io/badge/Automated-No-red.svg) ![Online](https://img.shields.io/badge/Status-Online-green.svg)

- All in one: 2.5ghz and 5ghz
- IPv6 and IPv6 Dual Stack
  - /64 prefix provided, but not delegated (couldn't find settings yet)
  - /128 per device according to route table
- Custom configuration: DHCP settings and IPv6 ULA
  - DHCP settings provide DNS server pointing to [PiHole]
  - There is a hidden `/padrao` URL which allows you to connect as `support` and have access to extra settings

### Libreelec + <span id="pihole">PiHole</span>

![Documented](https://img.shields.io/badge/Documented-No-red.svg) ![Automated](https://img.shields.io/badge/Automated-No-red.svg) ![Online](https://img.shields.io/badge/Status-Online-green.svg)

- Raspberry Pi 3
- Libreelec based
- Connect to TV to watch tv shows and movies
- 1TB USB3 External Storage
  - SMB shared
- Docker plugin installed and running:
  - PiHole
  - Syncthing
  - Transmission Web
  - ZeroTier

### Bramble (PiCluster)

![Documented](https://img.shields.io/badge/Documented-No-red.svg) ![Automated](https://img.shields.io/badge/Automated-No-red.svg) ![Status](https://img.shields.io/badge/Status-Offline-yellow.svg)
  
- Raspberry Pi 3 + ClusterHat 1.3v + 4 Raspberry Pi W zero (5 Nodes)
- ARMv7 + ARMv6
- Plans:
  - Run Hypriot OS with custom scripts to setup ClusterHat shared networking
  - One single ethernet port to share connection between all nodes
  - Consul + Nomad to run Docker containers
  - ZeroTier connection on each to take advantage of NPD emulation
  - GlusterFS to share volume data beween containers
  - Will be automated (as far as possible)

- Questions
  - When will Habitat ARM support land?
  - Balena instead of Docker?
  - OpenWRT router managing zerotier to avoid setup cost on every node?

### Pi 1

![Documented](https://img.shields.io/badge/Documented-No-red.svg) ![Automated](https://img.shields.io/badge/Automated-No-red.svg) ![Status](https://img.shields.io/badge/Status-Offline-yellow.svg)

- Raspberry Pi 1 Model B (2011)
- ARMv5
- Plans:
  - Most likely an extra node
  - Want to automate docker build images across different ARMs (Could be useful)

- Questions:
  - Buildkit for ARM?

### VM server

![Documented](https://img.shields.io/badge/Documented-No-red.svg) ![Automated](https://img.shields.io/badge/Automated-No-red.svg) ![Status](https://img.shields.io/badge/Status-Offline-yellow.svg)

- Old laptop which don't poweroff (something broken on the motherboard)
- No reliable, but still turns on
- Proxmox 5.2
- Docker installed (disregrading wiki recomendation to no do so)
- Opportunity to experiment with VMs and other OSes
- Initial setup:
  - pixieboot running as Docker container to ofer PXE boot for VMs on the network
- Plans:
  - Expose it over ZeroTier to have access to it remotely
  - VMs?
  - Buildkit to automate Docker builds across platforms?

## Google Cloud

### Algo VPN

![Documented](https://img.shields.io/badge/Documented-Partially-yellow.svg) ![Automated](https://img.shields.io/badge/Automated-Partially-yellow.svg) ![Status](https://img.shields.io/badge/Status-Online-green.svg)

- US based VPN to filter out connections
  - WireGuard and IKEv2
- Plans:
  - ZeroTier connections
  - HTTP Egress and Ingress for the containers running on Homelab
  - Maybe Docker + Nomad node?

## Mobile setup

- Zerotier on all mobile devices
- Wireguard on Android
- IKEv2 on Windows

### GL.iNet Slate

- Wireguard setup
- Zerotier Layer 2 bridge configured

### GL.iNet AR300M

- Needs: Wireguard setup
- Needs: Zerotier Layer 2 bridge configured

## Plans

### Cluster

- Run:
  - Bouncer
  - Bitlbee
  - ?

### Backup

- They need to happen
  - Parkeep?
  - Borg + online block storage?
  - NAS Raid?

### Docker Automation

- Want: Automated ARMv5, ARMv7, arm64 (needs host), x86 and amd64 images
- Run register + clair

### Network

- Better Router @ Home
  - Configure VLANs
  - Route ZeroTier to avoid manually configuring each node
  - Most likely OpenWRT or Unifi (we can dream)
