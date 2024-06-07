# How to Arch

My **Arch Linux desktop installation** cheat sheet.

This tutorial is based on the official [Arch Linux installation guide](https://wiki.archlinux.org/title/installation_guide)
and [General recommendations](https://wiki.archlinux.org/title/General_recommendations).

Follow the steps below to end up with a usable desktop edition of Arch Linux similar to the one I am running on my laptop.
Don't follow them blindly, though: this tutorial aggressively targets my personal preferences, which may not match yours
(such as having four different web browsers installed at the same time).

## Make a liveUSB and boot it

Download an .iso file from https://archlinux.org/download/ and flush it to a flash drive in your favourite way, e.g.,
with `dd`:
```sh
sudo dd if=<path_to_image.iso> of=</dev/sdX_of_your_flash_drive> status=progress conv=notrunc,fsync bs=4M oflags=direct
```
(note the `/dev/sdX` rather than `/dev/sdXY`).

Next, boot the flash drive.

## Connect to wifi

```
$ iwctl
[iwd]# device lsit
< find your device here, e.g., "wlan0" >
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
< find your Wi-Fi network here >
[iwd]# station wlan0 connect <wifi_ssid>
< enter password here >
[iwd]# quit
$
```

## Partition the disk

### Create partitions with `parted`

<details>
  <summary>TODO</summary>

  Rewrite this section and suggest using `fdisk` instead of `parted`

</details>

First, run `parted` on your disk (e.g., `parted /dev/nvme0n1`), and
create the deisred partition layout.

Useful commands of `parted`:
-   `help` to see the list of commands
-   `help <command>` to see more information about a particular command
-   `unit s` to change the default unit to disk sectors, `unit GiB` for GiB, etc
-   `mkpart` to interactively create a partition

My layout during the last installation (in order):
-   EFI partition created by Windows 11 (during the installation it's better to
    intervene and make it 200MB+. Alternatively, after the installation it is
    possible to resize the C: partition and give some space to the EFI partition)
-   A few Windows partitions with C: of size 107GiB
-   An ext4 `/` partition of size 149GiB
-   An ext4 `/home` partition of size 220GiB

### Create filesystems

Next, create filesystems on the partitions you just created:
```sh
mkfs.ext4 /dev/nvme0n1p5
mkfs.ext4 /dev/nvme0n1p6
```

## Mount filesystems

Mount all filesystems you will need in your system (including the ones you
created; including the EFI partition):
```sh
$ mount /dev/nvme0n1p5 /mnt
$ mount --mkdir /dev/nvme0n1p6 /mnt/home
$ mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

## Install essential packages

First, optionally, make sure that you are satisifed with the automatically generated mirror list
and the pacman configuration (for instance, I like to set `ParallelDownloads = 4` in the config):
```sh
$ vim /etc/pacman.d/mirrorlist
< view and change the mirror list >
$ vim /etc/pacman.conf
< view and change the configuration >
```

Next, initialize the pacman keyring in your new system & install the first set of packages:
```sh
$ pacstrap -K /mnt base linux linux-firmware intel-ucode sudo git fish byobu man-db man-pages vim networkmanager
```

Keep in mind that your changes to `/etc/pacman.conf` in the live mode aren't automatically
transferred in your new system's `/etc/pacman.conf`, so you'll need to update it manually.

## Create swapfile

Create a swap file called `/swapfile`. If you want hibernation to be supported, the swap file shall
be at least your RAM sizde.

```sh
$ fallocate -l 16G /mnt/swapfile
$ chmod 600 /mnt/swapfile
$ mkswap /mnt/swapfile
$ swapon /mnt/swapfile  # Helpful for later /etc/fstab generation
```

## Generate `/etc/fstab`

Generate the fstab file using UUID for partition identifiers (if the swap file is currently on,
it will be added to the fstab as well).

```sh
$ genfstab -U /mnt > /mnt/etc/fstab
```

## Miscellaneous system configuration

Chroot into your system:
```sh
$ arch-chroot /mnt
```

### Time & timezone

Set your appropriate timeone (by replacing `Europe/Moscow`)

```sh
$ ln --symbolic /usr/share/zoneinfo/Europe/Moscow /etc/localtime
$ hwclock --systohc
```

### Localization

1.  Edit `/etc/locale.gen` and uncomment locales that you need, e.g., `en_US *`, `en_GB *`, `ru_RU *`.
2.  Run `locale-gen`
3.  Edit `/etc/locale.conf` and set locale variables (one per line), e.g., `LANG=en_US.UTF-8`, `LC_TIME=en_GB.UTF-8`.

### Hostname

Set your hostname:
```sh
echo YOUR_HOSTNAME > /etc/hostname
```

### Set the root password

```sh
$ passwd
```

## Bootloader

While still inside the chroot, install the `systemd-boot` bootloader. It is a part of already installed
`systemd` package, so, you will just need to configure it.

```sh
$ bootctl install
< some output >
$ vim /boot/loader/entries/arch.conf
< edit the file according to https://wiki.archlinux.org/title/systemd-boot#Configuration >
$
```
