---
title: 'Turning off RGB automatically on Linux'
date: 2026-09-18
norss: true
---

Many computers light up like christmas trees with RGB LEDs,
they stick these things on everything and 
on Linux it may not be obvious how to turn this visual nuisance off.

## How to turn this visual nuisance off:

1. Install `openrgb` with apt-get or pacman or whatever.

2. Verify that `openrgb -m off` turns off the lights.

3. Create a file `/etc/systemd/system/openrgb-off.service`
containing

```systemd
[Unit]
Description=Leave the x-mas tree aesthetics in CP2077 please
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/openrgb -m off
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

4. Enable the .service

```shell
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now openrgb-off.service
```

System should now disable LEDs on startup.

