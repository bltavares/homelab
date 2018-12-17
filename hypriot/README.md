# Hypriot

- Use Hypriot 1.9 or 1.10
- Flash it with balenaEtcher
- ClusterHAT v1.3

## Build

To generate the files:

```bash
make
```

Flash Hypriot v9 (or v10 RC), then copy the filese from `build` to the boot partition.
Also change `config.txt` as the recomendations below.

### Controller

Needs `enable_uart=1` on `config.txt`

### Pi Zero

Needs `dtoverlay=dwc2` on `config.txt`

Connect from the controller with: `sudo minicom pX`

## cloud-init

Files must start with `#cloud-config` to be valid configuration.

Validate on [CoreOs](https://coreos.com/validate/)