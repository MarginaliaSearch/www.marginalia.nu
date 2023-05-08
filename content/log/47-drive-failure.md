+++
title = "Drive Failure"
date = 2022-02-19
section = "blog"
aliases = ["/log/47-drive-failure.gmi"]
draft = false
categories = []
tags = ["server"]
+++


Not what I had intended to do this Saturday, but a hard drive failed on the server this morning, or at least so it seemed. MariaDB server went down, dmesg was full of error messages for the nvme drive it's running off. That's a pretty important drive. 

The drive itself may actually be okay, the working hypothesis is either the drive itself or the bus overheated and reset. After a reboot the system seems fine.

That particular drive, an Optane NVMe stick, has worked impressively well for quite a while. It cost an arm and a leg and has some fairly impressive performance, so I would be sad if it failed.

Fortunately there doesn't appear to to be actual data loss. fsck is fine, mysqlcheck is fine. Even if there was data loss, there is a good system of weekly backups of critical data on a different hard drive that should prevent serous data loss from individual drives failing. 

Even if there turns out to be some sort of quiet creeping corruption that only unravels after festering for weeks, the worst that will happen is that the server resets back to the state of last week and that's really that.

In the mean time, the system is up and running again. We'll have to see if this was a one-off event or if one or more components requires replacement.

I've been putting off an upgrade of this system. The motherboard I'm using also doesn't appear to be entirely stable which is more than a bit uncomfortable. The chassis is too small and runs hot, and I have a few SSDs that are getting pretty worn. Time is fast approaching when I have to upgrade this system. 

I'm very happy I have generous Patreons to soften the blow. Hardware is not cheap.

## dmesg

If anyone is curious what the error looked like, I'm appending it below.

```
[17160266.929320] nvme nvme0: controller is down; will reset: CSTS=0xffffffff, PCI_STATUS=0xffff
[17160266.985525] print_req_error: I/O error, dev nvme0n1, sector 195060096
[17160267.013350] nvme nvme0: Removing after probe failure status: -19
[17160267.041306] print_req_error: I/O error, dev nvme0n1, sector 153936816
[17160267.041466] EXT4-fs warning (device nvme0n1p1): ext4_end_bio:323: I/O error 10 writing to inode 15 (offset 0 size 0 starting block 19242118)
```


