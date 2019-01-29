# Media Center Setup

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

TODO: Write more of the setup