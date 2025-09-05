# How to Arch

My **Arch Linux desktop installation** cheat sheet.

This tutorial is based on the official [Arch Linux installation guide](https://wiki.archlinux.org/title/installation_guide)
and other ArchWiki pages.

Follow the steps below to end up with a usable desktop edition of Arch Linux similar to the one I am running on my laptop.
Don't follow them blindly, though: this tutorial aggressively targets my personal preferences, which may not match yours
(such as having three different web browsers installed at the same time).

# Part 1, live mode

## Make a liveUSB and boot it

Download an .iso file from https://archlinux.org/download/ and flash it to a flash drive in your favourite way, e.g.,
with `dd`:
```sh
sudo dd if=<path_to_image.iso> of=</dev/sdX_of_your_flash_drive> status=progress conv=notrunc,fsync bs=16M oflag=direct
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

> **WARNING**: tools such as `parted` or `fdisk` only change metadata in the partition
> table, but do not alter the partitions themselves! It is fine if you will immediately
> (re)format any partitions that you modify. However, if you need to shrink
> an existing partition, the procedure is more complex than just resizing it in `parted`.
> Please, look it up yourself or use built-in Windows tools or GParted.

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
and the pacman configuration (e.g., uncomment `Color`):
```sh
$ vim /etc/pacman.d/mirrorlist
< view and change the mirror list. Alternatively, you can run `reflector` to configure mirrors, see the command a few sections below >
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

1.  Edit `/etc/locale.gen` and uncomment locales that you need, e.g., `en_US*`, `en_GB*`, `ru_RU*`, `ko_KR*`.
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

## Set up pacman

### Edit /etc/pacman.conf:

Uncomment line `Color`.

Enable the `multilib` repository by uncommenting lines
```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

### Set up mirrors

```sh
$ pacman -Syu reflector
< proceed with the installation >
$ reflector --sort score --country ru --protocol https,ftp,rsync --fastest 10 --save /etc/pacman.d/mirrorlist
< warnings that some mirrors are inaccessible >
```

## Disable `faillock`

[pam_faillock](https://www.man7.org/linux/man-pages/man8/pam_faillock.8.html) is a pam module that
records failed login attempts and locks users after several authenticatino failures in a row
(by default), except for the `root` user (by default). The simplest way to disable it is to set
the unlocking timeout to 1 second: edit `/etc/security/faillock.conf` and set `unlock_time = 1`.

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

Create `~/.config/emptty` and make it executable (`chmod +x`). This file will be sourced by `emptty`
before launching your window manager. Paste the following content:
```sh
#!/bin/sh
Selection=true  # `emptty` will offer the window manager selection

# Perform your setup here
export PATH=$HOME/.local/bin:$PATH
export LC_TIME=en_GB.UTF-8
numlockx on  # Turns numlock on (requires the `numlockx` package)

exec dbus-launch "$@"  # Launch the selected window manager
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
$ # Configures keyboard layout and touchpad behavior
$ sudo cp ssac/40-libinput.conf /etc/X11/xorg.conf.d/
$
$ # Various configs
$ mkdir -p ~/.config
$ cp -r ssac/.config/* ~/.config/
$ # An additional step to enable my bash config
$ # (this OVERWRITES whatever you had in .bashrc at the moment)
$ echo "source ~/.config/bash/rc" > ~/.bashrc
$
$ # Install `pdeath_hup`
$ mkdir -p ~/.local/bin/
$ gcc ssac/pdeath_hup.c -o ~/.local/bin/pdeath_hup
$
$ # Vim config
$ cp ssac/.vimrc ~/
$
$ # Gdb config
$ cp ssac/.gdbinit ~/
$
$ # TODO: replace polybar with i3bar
$
$ # That's it :)
$ rm -rf ssac
```

**KEEP IN MIND** that my `i3` config contains a lot of autostart commands that will be silently ignored
if you don't have the corresponding software installed (we will install it in a further step).

Now you can `reboot` and log in to a graphical environment. Press
`Alt+Enter` (default i3 config) or `Super+Enter` (my i3 config) to launch a terminal emulator;
press `Alt+d` (default i3 config) or `Alt+F2` (my i3 config) to lanuch another application.

Configure the rest to your liking by editing `~/.config/i3/config`!

## Install more packages that you will need

Install other packages and apps that you will use. My suggestion:

-   System functionality packages
    - `bluez` for bluetooth support
    - `noto-fonts{,-extra,-cjk,-emoji}` for extended font support
    - `ntfs-3g` for the NTFS filesystem support
    - `xdg-user-dirs` for nice "well known" home directories support
    - `pipewire{,-alsa,-audio,-jack,-pulse}` - the `pipewire` media server for audio support, <br>
      `pwvucontrol` - GUI for volume control
    - `picom` (a [compositor](https://wiki.archlinux.org/title/Xorg#Composite))
      for windows transparency support and vertical synchronization (vsync) <br>
      (configuration required, see next section)
    - `clipster` (a [clipboard manager](https://wiki.archlinux.org/title/Clipboard#Managers)) for better
      clipboard support (clipboard content preservation after an app is closed)
    - `gvfs` for your file manager to support the `trash:///` location (and some other virtual
      filesystems)
    - `ruby-fusuma` for touchpad gestures support, <br>
      `xdotool` for keyboard/mouse input emulation (will be useful with fusuma) <br>
      (configuration required, see next section)
    - `playerctl` - cli for media control (play/pause, next/prev, etc) <br>
      (keyboard integration can be configured, see next section)
    - `feh` for wallpapers support <br>
      (configuration required, see next section)
    - `yaru-sound-theme` - a sound theme, used to play the log in sound in my i3 config
    - `adapta-gtk-theme` - a gtk theme <br>
      (configuration required, see next section)
    - `numlockx` to enable numlock automatically (must be configured in your login manager.
      Already enabled in the `emptty` config used above, executed after logging in)

-   Command-line tools
    - `openssh` for the `ssh` and `ssh-agent` commands, as well as the `sshd` daemon
    - `bluez-utils` for command-line bluetooth control, such as with `bluetoothctl`
    - `lsd` - `ls` on steroids
    - `c-lolcat` for the `lolcat` command (aliased to `cat` in my bash/fish configs)
    - `light` to control backlight <br>
      (configuration required, see next section)
    - `htop` - console system monitor
    - `helix` - console text editor
    - `ffmpeg` - video editing utility
    - `rclone` - tool to mount remote clouds (such as Google Drive) into your system
    - `trash-cli` for the `trash` command (move files/directories to trash)
    - `autotrash` for purging old files from trash <br>
      (configuration required, see next section)
    - `moreutils` many useful tools
    - `tldr` - like `man` but `tldr`
    - `inetutils` - networking tools, including `telnet`
    - `dog` - the DNS lookup tool
    - `zip`, `unzip`, `rar`, `unrar` - tools for working with archives

-   Graphical apps
    - `dmenu` app launcher
    - `polybar` configurable status panel <br>
      (configuration required, see next section)
    - `cbatticon` low-battery notification sender
    - `redshift` screen color temperature adjusting tool (for night light) <br>
      (configuration suggested, see next section)
    - `xss-lock` screen saver (screen lock launcher) <br>
      `i3lock-color` screen lock app
    - `terminator` terminal emulator, <br>
      `xterm` another (simpler) terminal emulator
    - `pcmanfm` file manager
    - `gnome-system-monitor` system monitor / task manager
    - `gnome-calculator` calculator
    - `flameshot` to make screenshots
    - `xed` text editor
    - `eog` (a user-friendly) image viewer
    - `gpicview` (a performant) image viewer (better suit for huge photos)
    - `mpv` media player <br>
      `mpv-mpris` to enable MPRIS support for mpv <br>
      `yt-dlp` to enable YouTube support for mpv <br>
      (configuration suggested, see next section)
    - `firefox chromium google-chrome` web browsers
    - `thunderbird` - Mozilla Thunderbird mail client <br>
      `birdtray` - additional tool to hide Thunderbird's window without closing it
    - `obs-studio` screen recording and streaming software
    - `wps-office` office software, <br>
      `onlyoffice-bin` office software
    - `telegram-desktop` messenger
    - `timeshift` system backup and restore utility <br>
      (configuration required, see next section)
    - `baobab` disk space usage analysis utility

-   Drivers
    - `nvidia` for nvidia drivers <br>
      `nvidia-prime` for the `prime-run` utility to launch apps with access to the GPU
    - `xpadneo-dkms` for Xbox controller vibration support

-   Daemons
    - `docker` - Docker daemon <br>
      `docker-buildx` - Docker BuildX plugin

To install all of the above, run:
```sh
$ yay -Syu --needed \
      bluez noto-fonts{,-extra,-cjk,-emoji} ntfs-3g xdg-user-dirs pipewire{,-alsa,-audio,-jack,-pulse} \
      pwvucontrol picom clipster gvfs ruby-fusuma xdotool playerctl feh yaru-sound-theme adapta-gtk-theme \
      numlockx \
        \
      openssh bluez-utils lsd c-lolcat light htop helix ffmpeg rclone trash-cli autotrash moreutils tldr \
      inetutils dog zip unzip rar unrar \
        \
      dmenu polybar cbatticon redshift xss-lock i3lock-color terminator xterm pcmanfm \
      gnome-{system-monitor,calculator} flameshot xed eog gpicview mpv{,-mpris} firefox chromium google-chrome \
      thunderbird birdtray obs-studio wps-office onlyoffice-bin telegram-desktop timeshift baobab \
        \
      nvidia{,-prime} xpadneo-dkms \
        \
      docker{,-buildx}
< study PKGBUILDs to make sure they are not mallicious; proceed with the installation >
< confirm that `i3lock` needs to be uninstalled for `i3lock-color` to be installed >
```

## Configure your system

### Background helpers

Out of daemons that you installed above, some (e.g., clipboard manager, polybar, etc) need to be
running in the background. Out of such daemons, `pipewire` and `dunst` will be launched automatically
(on startup or on demand); for the rest of them to start automatically additional set up is needed.

If you are using my `i3` config, all the relevant applications are already there and will be started on
log in and terminated on log out (xorg-dependent applications get notified when the graphical session
is over, so they can terminate; the rest, such as fusuma, are sent a SIGHUP signal on `i3` termination
because they are started through `pdeath_hup`).

If you are using a different setup, you need to configure your system to launch whatever you want to be
autostarted.

### Gtk theme

To configure GTK-3 and GTK-4 apps to use the dark version of the Adapta theme, run:
```sh
$ mkdir -p ~/.config/gtk-{3,4}.0
$ Do not run if you already created your own gtk configs: this will overwrite them!
$ echo '[Settings]' | tee ~/.config/gtk-{3,4}.0/settings.ini
$ echo 'gtk-theme-name = Adapta' | tee -a ~/.config/gtk-{3,4}.0/settings.ini
$ echo 'gtk-icon-theme=name = Adapta' | tee -a ~/.config/gtk-{3,4}.0/settings.ini
$ echo 'gtk-application-prefer-dark-theme=true' | tee -a ~/.config/gtk-{3,4}.0/settings.ini
$
```

Additionally, to prevent some apps (e.g., `gnome-calculator`) from overriding the configured theme,
install the patched version of `libadwaita`:
```sh
$ yay -S libadwaita-without-adwaita-git --asdeps
< confirm that due to a conflict `libadwaita` or `libadwaita-1.so` needs to be removed >
```

### User dirs

Setup "well known" user direcotries and change the "Documents" directory from the default
`$HOME/Documents` to `$HOME/Docs` (as it's easier to type on the terminal):
```sh
$ xdg-user-dirs-update --set DOCUMENTS "$HOME/Docs"
```

### Git

```sh
$ git config --global init.defaultBranch master
$ git config --global user.name "Your Full Name"
$ git config --global user.email "your@email"
$ git config --global alias.fpush 'push --force-with-lease'
$ git config --global alias.dd diff
$ git config --global alias.dc 'diff --cached'
$ git config --global alias.ddh 'diff HEAD^'
$ git config --global alias.dhh 'diff HEAD^ HEAD'
$ git config --global alias.rc 'rebase --continue'
```

### picom

Create or edit `~/.config/picom.conf`:
```
vsync = true;
fading = false;
```

### fusuma

Add all users that need to run `fusuma` to the `input` group:
```sh
$ sudo usermod -aG input $USER
```

Create `~/.config/fusuma/config.yml` and put the following:
```
swipe:
  3:
    down:
      command: "xdotool key ctrl+Tab"
    up:
      command: "xdotool key ctrl+Shift+Tab"

  4:
    left:
      command: "i3 focus left"
    right:
      command: "i3 focus right"

interval:
  swipe: 0.6
```

### Media keys - `i3` + `playerctl`

Add the following line to your `i3` config (it is already there if you used mine) to
support the keyboard play/pause media key, as well as play/pause buttons on bluetooth devices:
```sh
bindsym XF86AudioPlay exec --no-startup-id playerctl play-pause
```

You can find XF86* keys names and add similar lines for other `playerctl` commands: `stop`,
`next`, `previous`, etc.

### Wallpapers - `feh`

Run the following commands and paste the following files:
```sh
$ systemctl --user edit switch_wallpaper.service --full --force
[Unit]
Description=Set a random wallpaper from a directory (hardcoded in the service file), using `feh`

[Service]
Type=oneshot
ExecStart=/usr/bin/env DISPLAY=:0 /usr/bin/feh --randomize --bg-max /home/nikolay/Images/bleach_wallpapers

[Install]
WantedBy=default.target

$ systemctl --user edit switch_wallpaper.timer --full --force
[Unit]
Description=Change background after timeout (uses set_random_wallpaper.service)

[Timer]
OnUnitActiveSec=15min

[Install]
WantedBy=timers.target
```

Next, run:
```sh
$ systemctl --user start switch_wallpaper.service
$ systemctl --user enable --now switch_wallpaper.timer
< indication of success >
```

It is suggested that you only `enable` the timer, not the service, as, when `systemd --user` starts,
the system may not yet be ready for the wallpaper to be set. Instead, you can start
`switch_wallpaper.service` from i3's config (this is the behavior with my config).

### Backlight control - `light`

Add all users that need to run `light` to the `video` group:
```sh
$ sudo usermod -aG video $USER
```

To additionally support brightness control keys on your keyboard, add the following lines to your
`i3` config (they are already there if you used mine):
```
bindsym XF86MonBrightnessUp exec --no-startup-id light -A 10
bindsym XF86MonBrightnessDown exec --no-startup-id light -U 10
```

### Automatic trash clean up - `autotrash`

To automatically clean files older than 30 days, run:
```sh
$ autotrash -d 30 --install
< some output >
```

### Status panel - `polybar`

OOPS, this section is outdated. My current setup does not use polybar. TODO: fix.

Import my config from https://github.com/kolayne/some_scripts_and_configs/blob/master/polybar_config.ini
or use another sample config to start from. Put it at `~/.config/polybar/config.ini`.

### Status panel - `i3bar`

Import my config from https://github.com/kolayne/some_scripts_and_configs/blob/master/.i3status.conf
or use another sample config to start from. Put it at `~/.i3status.conf`

### Night light - `redshift`

Create `~/.config/redshift.conf` and paste the following, replacing with your dawn and dusk time
(or use other options, such as geolocation, see the manual for redshift):
```
[redshift]
dawn-time=3:00-5:00
dusk-time=19:30-21:00
```

### Media player - `mpv`

Create `~/.config/mpv/mpv.conf` and paste the following:
```
# Youtube Support
script-opts=ytdl_hook-ytdl_path=/usr/bin/yt-dlp
ytdl-format=bestvideo[height<=?720][fps<=?30][vcodec!=?vp9]+bestaudio/best

--save-position-on-quit
--script=/usr/lib/mpv-mpris/mpris.so
```

### Timeshift

To configure `timeshift`, you need to first enable `cronie` (it is automatically installed
as a dependency and needed for snapshot scheduling), and then just launch timeshift and configure
everything you want, including the snapshots schedule, if you want them.
```sh
$ sudo systemctl enable --now cronie.service
< success indication >
$ subo timeshift-gtk
```

## Thunderbird

The following customization for Thunderbird allows individual events coloring
(similar to Google Calendar) with Thunderbird categories. However, it will
ruin the interface if you have events assigned to multiple categories.

Launch Thunderbird, go to Settings -> General -> Config editor. Set the
`toolkit.legacyUserProfileCustomizations.stylesheets` property to `true`.

Close Thunderbird.
Create file `~/.thunderbird/<profile-name>.default-release/chrome/userChrome.css`
and put the [customization](https://github.com/kolayne/some_scripts_and_configs/blob/master/.thunderbird/profile-name/chrome/userChrome.css)
in the file. The directory `chrome/` may not exist.

## Configure idleness, suspension, hibernation

Edit `/etc/systemd/sleep.conf` such that it has the following entries:
```
[Sleep]
AllowSuspend=yes
AllowHibernation=yes
AllowSuspendThenHibernate=yes
#...
```

Edit `/etc/systemd/logind.conf` such that it contains the following entries:
```
[Login]
#...
HandleSuspendKey=suspend
#...
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate
HandleLidSwitchDocked=ignore
#...
IdleAction=suspend-then-hibernate
IdleActionSec=30min
#...
```

Edit `/etc/mkinitcpio.conf` by adding the `resume` option to the `HOOKS=(...)` array, such that
`resume` is after `udev`, to allow resume from hibernation. For example:
```
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems resume fsck)
```
And rebuild the cpio image:
```sh
$ mkinitcpio -P
```

On a modern system (systemd >= 255, mkinitcpio >= 38, UEFI system) this should be sufficient:
systemd will utilize the `HibernateLocation` EFI variable to keep the location of the hibernated
image.

Otherwise (if you end up with system hibernating but then booting normally rather than resuming), refer to
[ArchWiki:Hibernation](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation)

## Non-packaged utils

There are a few more utils that I use, which are not properly packaged (yet?). To install them,
follow the README instructions.

-   Install [linux-cpu-scaling-helper](https://github.com/kolayne/linux-cpu-scaling-helper)

-   Install [docker-on-top](https://github.com/kolayne/docker-on-top)

-   Clone [Rimokon](https://github.com/kolayne/Rimokon) to `~/Docs/Rimokon` and configure it
    (with my `i3` config it will be started on log in automatically)
