#!/bin/bash

export NOMAD_ADDR="http://[$(ip addr show zt5u44ufvb | grep fc | awk '{print $2}' | cut -d/ -f1)]:4646"
