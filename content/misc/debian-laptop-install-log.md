+++
title = "Installing Debian Bullseye on HP Spectre x360 (dual boot)"
date = 2023-05-08
section = "misc"
aliases = ["/debian-laptop-install-log.gmi"]
draft = false
categories = []
+++


The computer in question is a model 15-df0002no bought in 2020.

This is an install log of sorts, mostly for myself but others may have use of it as well. 

Disclaimer: This is not a beginner's guide. I've used Linux for over 20 years and can solve most issues that installing a linux distribution throws my way. 

If you don't know your way around BIOS, disk partitioning, linux driver loading, or grub; then misguided attempts at follow these notes as instructions may well brick your laptop, and I probably won't be able to help you unfuck it. 

## Preparation

* Disabled bitlocker in Windows 10.

* Disabled secure boot in BIOS. If you haven't disabled bitlocker, it will prompt you for a decrypt key.

* Reduced windows 10 partition from within windows since the installer didn't seem to have tools for that. I want to dual boot, and this seems to have worked smoothly.



The default netinst image doesn't ship firmware that is compatible with the wifi (there is only wifi). Use the nonfree image to get iwlwifi  
* [http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/](http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/)

I had a problem where the installer refused to authenticate on wifi, overall detection seems a bit spotty even with the nonfree image. I eventually got it working. I changed to the terminal and modprobed iwlwifi as it was detecting network device. I'm not sure if that fixed it, but it worked after. This problem seems limited to the installer as far as I can tell. Beyond installing, it's been rock solid.

Touchpad didn't work in the graphical installer, but worked after the system was installed.

Install went smoothly beyond that.

# Results

* The touch pad and touch screen works well, better than Windows, at least the way I use it. Less frustrating accidental cursor movements with the typing detection!

* Audio works out of the box.

* Webcam works out of the box.

* Graphics were a bit weird initially, had a few system freezes, but installing nvidia drivers seems to have fixed it.

* Suspend to RAM seems to work.

* Suspend to Disk doesn't seem to work.

* Setting global scale to 200-250% in KDE 5 and upping a few fonts seems to fix virtually all HiDPI-issues, except for SDDM and the console framebuffer. You may also want to resize the start bar size, but that is personal preference.

* SDDM DPI problems fix:

 Put in /etc/sddm.conf.d/kde_settings.conf 
```
[X11]
ServerArguments=-dpi 240
EnableHiDPI=true
```

I haven't tested the SD card reader or the fingerprint reader. 

## Problems that could be problems for others but aren't for me

* The DPI of the console is absurdly tiny

I haven't really attempted to fix this, for all I know it could be easily remedied.

# Conclusions

Overall it works beyond my wildest expectations. I expected jank, mis-scaled fonts, a barely working touchpad, graphics that didn't work. I got none of that. I got a well-performing Linux laptop. 

It works better with Debian Bullseye than it ever did with Windows 10. Well worth it.

## Update several months later

Yes, it's still amazing.

## 2023 Update

I needed to update the BIOS of this machine with Linux installed. Hoo boy. 

I got it working, but this was pretty nerve-racking. 

Steps were something like this:

* Create a BIOS install USB stick on a machine with windows
* Copy the BIOS install files from the USB sticks' EFI folder to the laptop's EFI folder
* Press F9 on boot-up and instruct it to boot from EFI-file.
* Select the correct BIOS upgrade .efi. Dunno which one I selected but it worked. Selecting starts the install immediately without any are-you-sures. 