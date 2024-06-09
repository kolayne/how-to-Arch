# How to Arch

My **Arch Linux desktop installation** cheat sheet.

This tutorial is based on the official [Arch Linux installation guide](https://wiki.archlinux.org/title/installation_guide)
and [General recommendations](https://wiki.archlinux.org/title/General_recommendations).

Follow the steps below to end up with a usable desktop edition of Arch Linux similar to the one I am running on my laptop.
Don't follow them blindly, though: this tutorial aggressively targets my personal preferences, which may not match yours
(such as having four different web browsers installed at the same time).

# Part 1, live mode

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
$ pacstrap -K /mnt base linux{,-firmware,-headers} intel-ucode networkmanager sudo git fish byobu man-db man-pages vim which
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
< set root password >
```

## Bootloader

While still inside the chroot, install the `systemd-boot` bootloader. It is a part of already installed
`systemd` package, so, you will just need to configure it.

```sh
$ bootctl install
< some output >
$ vim /boot/loader/entries/arch.conf
< edit the file according to https://wiki.archlinux.org/title/systemd-boot#Configuration >
```

# Part 2, in your system!

Now that you've followed the steps above and installed a bootloader, you should be able to boot into
your new system by exiting the chroot (`exit`) and running `reboot`. 

Once the system boots, log in as `root` with your root password you set earlier. The installation
continues from there.

## Set up a network

Enable `NetworkManager.service` and connect to a network
```sh
$ systemctl enable --now NetworkManager.service
< some output >
$ nmcli dev wifi list
< wifi networks list >
$ nmcli dev wifi connect <SSID> password <password>
< indication of success >
```

## Set up pacman mirrors

```sh
$ pacman -Syu reflector
< proceed with the installation >
$ reflector --sort score --country ru --protocol https,ftp,rsync --fastest 10 > /tmp/reflector-gen
< warnings that some mirrors are inaccessible >
$ mv /tmp/reflector-gen /etc/pacman.d/mirrrorlist
```

## Create a regular user

Run the following code, replacing `$NUSER` with your username
```sh
$ useradd --shell $(which fish) $NUSER  # Creates a new user with `fish` as the default shell
$ mkdir /home/$NUSER
$ chown $NUSER:$NUSER /home/$NUSER
$ passwd $NUSER
< set password for your user >
$ VISUAL=vim visudo
< edit the sudoers file: uncomment the line that starts with `%sudo` >
$ groupadd sudo
$ usermod -aG sudo $NUSER
```

Now you can `exit` the shell and log in as your new user (it is required for further steps).

Though, if you're too lazy to type your username and password, you can as well run
`exec sudo -u $NUSER -i`

## Install an AUR helper

First, edit `/etc/makepkg.conf`: find the line that declares the `OPTIONS=(...)` array and,
if it contains `debug`, replace it with `!debug`.

Next, to install `yay`, do:
```sh
$ sudo pacman -Syu base-devel
< enter your password and proceed with the installation >
$ cd /tmp
$ git clone https://aur.archlinux.org/yay.git
< some output >
$ cd yay
$ makepkg -s -i
< proceed with the installation >
```

## Set up a graphical environment

Install the `i3` window manager and the `emptty` display manager:
```sh
$ yay -Syu i3 emptty
< study the PKGBUILD to make sure it's not mallicious (and always do this in the future when installing AUR packages) >
< select all packages from the i3 group >
< select the noto-fonts provider for the fonts >
$ sudo systemctl enable emptty
< indication of success >
```

Install most crucial things that you will need in a graphical environment, such as `dmenu` to start applications
and the `terminator` terminal emulator.
```sh
$ yay -Syu dmenu terminator
< proceed with installation >
```

Note: you may need to rebot before you will be able to start graphical interface.

## Restore your configurations

If you have any previous configurations for your software (especially, Xorg- or `i3`-related),
you can restore them now. If you don't, you can either skip this step (and only configure things
later, when you need something), or use someone else's configs as a starting point.

To set up my configuration:
```sh
$ git clone https://github.com/kolayne/some_scripts_and_configs.git ssac
< some output >
$ sudo cp ssac/40-libinput.conf /etc/X11/xorg.conf.d/  # Configures keyboard layout and touchpad
$ cp -r ssac/dotconfig__bash/ ~/.config/bash
$ echo "source ~/.config/bash/rc" > ~/.bashrc
$ cp -r ssac/dotconfig__fish/ ~/.config/fish
$ mkdir -p ~/.config/i3
$ cp ssac/i3_config ~/.config/i3/config
$ rm -rf ssac
```

**KEEP IN MIND** that my `i3` config contains a lot of autostart commands, which will be silently ignored
if you don't have the corresponding software installed (we will install it in a further step).

Now you can `reboot` and log in to a graphical environment. Press
`Alt+Enter` (default i3 config) or `Super+Enter` (my i3 config) to launch a terminal emulator;
press `Alt+d` (default i3 config) or `Alt+F2` (my i3 config) to lanuch another application.

Configure the rest to your liking by editing `~/.config/i3/config`!

## Install more packages that you will need

Install other packages and apps that you will use. My suggestion:

-   System functionality packages
    - `noto-fonts{,-extra,-cjk,-emoji}` for extended font support
    - `ntfs-3g` for the NTFS filesystem support
    - `pulseaudio` for sound support, <br>
      `pulseaudio-bluetooth` for bluetooth devices support, <br>
      `pavucontrol` - GUI for pulseaudio settings, <br>
      `paprefs` for some advanced pulseaudio settings <br>
      (pulseaudio may require a reboot to start working)
    - `picom` (a [compositor](https://wiki.archlinux.org/title/Xorg#Composite))
      for windows transparency support and vertical synchronization (vsync)
    - `clipster` (a [clipboard manager](https://wiki.archlinux.org/title/Clipboard#Managers)) for better
      clipboard support (clipboard content preservation after an app is closed)
    - `ruby-fusuma` for touchpad gestures support, <br>
      `xdotool` for keyboard/mouse input emulation (will be useful with fusuma) <br>
      (configuration required, see next section)
    - `playerctl` - cli for media control (play/pause, next/prev, etc) <br>
      (keyboard integration can be configured, see next section)
    - `feh` for wallpapers support

-   Command-line tools
    - `openssh` for the `ssh` and `ssh-agent` commands, as well as the `sshd` daemon
    - `c-lolcat` for the `lolcat` command (aliased to `cat` in my bash/fish configs)
    - `light` to control backlight <br>
      (keyboard integration can be configured, see next section)
    - `htop` - console system monitor
    - `helix` - console text editor
    - `ffmpeg` - video editing utility
    - `rclone` - tool to mount remote clouds (such as Google Drive) into your system
    - `trash-cli` for the `trash` command (move files/directories to trash)
    - `autotrash` for purging old files from trash <br>
      (configuration required, see next section)

-   Graphical apps
    - `dmenu` app launcher
    - `polybar` configurable status panel <br>
      (configuration required, see next section)
    - `cbatticon` low-battery notification sender
    - `redshift` screen color temperature adjusting tool (for night light)
    - `xss-lock` screen saver (screen lock launcher) <br>
      `i3lock-color` screen lock app
    - `terminator` terminal emulator
    - `pcmanfm` file manager
    - `gnome-system-monitor` system monitor / task manager
    - `gnome-calculator` calculator
    - `gedit` text editor
    - `eog` image viewer
    - `mpv` media player <br>
      `mpv-mpris` to enable MPRIS support for mpv <br>
      (configuration suggested, see next section)
    - `firefox chromium google-chrome epiphany` web browsers
    - `thunderbird` - Mozilla Thunderbird mail client <br>
      `birdtray` - additional tool to hide Thunderbird's window without closing it
    - `obs-studio` screen recording and streaming software
    - `wps-office` office software
    - `telegram-desktop` messenger
    - `jetbrains-toolbox` JetBrains IDEs installation manager (not integrated with pacman)
    - `timeshift` system backup and restore utility <br>
      (configuration required, see next section)

-   Drivers
    - `nvidia` for nvidia drivers <br>
      `nvidia-prime` for the `prime-run` utility to launch apps with access to the GPU
    - `xpadneo-dkms` for Xbox controller vibration support

-   Daemons
    - `docker` - Docker daemon <br>
      `docker-buildx` - Docker BuildX plugin

To install all of the above, run:
```sh
$ yay -Syu noto-fonts{,-extra,-cjk,-emoji} ntfs-3g pulseaudio{,-bluetooth} pavucontrol paprefs \
      picom clipster ruby-fusuma xdotool playerctl feh \
        \
      openssh c-lolcat light htop helix ffmpeg rclone trash-cli autotrash \
        \
      dmenu polybar cbatticon redshift xss-lock i3lock-color terminator pcmanfm \
      gnome-{system-monitor,calculator} gedit eog mpv{,-mpris} firefox chromium google-chrome epiphany \
      thunderbird birdtray obs-studio wps-office telegram-desktop jetbrains-toolbox timeshift \
        \
      nvidia{,-prime} xpadneo-dkms \
        \
      docker{,-buildx} \
    --needed
< study PKGBUILDs to make sure they are not mallicious; proceed with the installation >
< confirm that `i3lock` needs to be uninstalled for `i3lock-color` to be installed >
```

Note: some of the above apps need to run in the background, so they should be started at some point.
If you're using my `i3` config (and have `pdeath_hup` installed, see next section), all the required
apps will be started on log in. Otherwise you need to configure your system to start them.

## Configure your system

Todo...
