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

Next, initialize the pacman keyring in your new system & install the first set of packages
(install `intel-ucode` if you have an Intel CPU and/or `amd-ucode` if you have an AMD CPU):
```sh
$ pacstrap -K /mnt base linux{,-firmware,-headers} amd-ucode networkmanager sudo git fish byobu man-db man-pages vim which
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

Come up with a hostname and set it:
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

Install the `Hyprland` wayland compositor (can also be done with `pacman` instead of `yay`):
```sh
$ yay -S hyprland
```

Install the most crucial things that you will need in a graphical environment, such as a terminal emulator.
My preferred terminal emulator is `terminator`, but if you want to run `Hyprland` with the default config,
you _may_ need to use a different one, such as `kitty`. You may install both:

```sh
$ yay -Syu kitty  # The default config supports `kitty` (and some other emulators?)
$ yay -Syu terminator  # My config only supports `terminator`
```

## Restore your configurations

If you have any previous configurations for your software (such as your `Hyprland` config),
restore them now. If you don't, you can either skip this step (and only configure things
later, when you need something), or use someone else's configs as a starting point.

To set up my configuration, perform the following steps:
```sh
$ git clone https://github.com/kolayne/how-to-Arch.git hta
< some output >
$
$ # Install my configs
$ mkdir -p ~/.config
$ cp -r hta/_.config/* ~/.config/
$ # Enable my bash config
$ # (this OVERWRITES whatever you had in .bashrc at the moment)
$ echo "source ~/.config/bash/rc" > ~/.bashrc
$
$ # Install `pdeath_hup` (required for my Hyprland config)
$ mkdir -p ~/.local/bin/
$ gcc hta/pdeath_hup.c -o ~/.local/bin/pdeath_hup
```

**KEEP IN MIND** that my `Hyprland` config contains autostart commands that will be silently skipped
if you don't have the corresponding software installed (we will install it in the following step).


If you want, you may enter your graphical environment now. For that, as your user, run `Hyprland`.
You should be able to start graphical interface without rebooting.

Once in the graphical environment, press `Super+Q` (default `Hyprland` config) or `Super+Enter`
(my `Hyprland` config) to launch a terminal emulator.

Configure the rest to your liking by editing `~/.config/hypr/hyprland.conf`!

## Install more packages that you will need

Install other packages and apps that you will use.

-   System functionality packages
    - `bluez` for bluetooth support
    - `noto-fonts{,-extra,-cjk,-emoji}` for extended font support
    - `otf-font-awesome` for some more emoji fonts, required by `waybar`
    - `ntfs-3g` for the NTFS filesystem support
    - `xdg-user-dirs` for nice "well known" home directories support
    - `pipewire{,-alsa,-audio,-jack,-pulse}` - the `pipewire` media server for audio support, <br>
      `pwvucontrol` - GUI for volume control
    - `wl-clip-persist` to preserve clipboard content after an app is closed
    - `hypridle` for idle session management in Hyprland <br>
      (configuration required, see the next section)
    - `gvfs` for your file manager to support the `trash:///` location (and some other virtual
      filesystems)
    - `playerctl` - cli for media control (play/pause, next/prev, etc) <br>
      (keyboard integration can be configured, see the next section)
    - `linux-a11y-sound-theme` - a sound theme. Provides the success sound for the `alert` command
      in my fish config
    - `adapta-gtk-theme` - a gtk theme <br>
      (configuration required, see the next section)
    - `xremap-hypr-bin` - a keyboard remapping tool
    - `xdg-desktop-portal-hyprland` - to support screen sharing/recording under Hyprland

-   Command-line tools
    - `openssh` for the `ssh` and `ssh-agent` commands, as well as the `sshd` daemon
    - `bluez-utils` for command-line bluetooth control, such as with `bluetoothctl`
    - `lsd` - `ls` on steroids
    - `c-lolcat` for the `lolcat` command (aliased to `cat` in my bash/fish configs)
    - `light` to control backlight <br>
      (configuration suggested, see the next section)
    - `htop` - console system monitor
    - `gdb` - console debugger
    - `vim` - console text editor
    - `helix` - console text editor <br>
      `bash-language-server`, `clang`, `gopls`, `rust-analyzer` - language servers for
      Bash, C/C++, Go, and Rust, respectively.
    - `ffmpeg` - video editing utility
    - `rclone` - tool to mount remote clouds (such as Google Drive) into your system
    - `trash-cli` for the `trash` command (move files/directories to trash)
    - `autotrash` for purging old files from trash <br>
      (configuration required, see the next section)
    - `moreutils` many useful tools
    - `tldr` - like `man` but `tldr`
    - `curl` - network requests utility
    - `wget` - network file retrieval utility
    - `inetutils` - networking tools, including `telnet`
    - `dog` - the DNS lookup tool
    - `zip`, `unzip`, `rar` - tools for working with archives
    - `rustup` - the Rust toolchain installer <br>
      (configuration required, see the next section)
    - `jq` - a command-line json manipulation tool (required by my `Hyprland` config)
    - `asciinema` - a terminal record-and-share utility
    - `strace` - system calls debugging tool

-   Graphical apps
    - `rofi` app launcher
    - `waybar` status bar
    - `hyprlock` screen lock app <br>
      (configuration required, see the next section)
    - `hyprsunset` blue-light filter (akin to `redshift`)
    - `terminator` terminal emulator, <br>
      `foot` - another (simpler) terminal emulator
    - `pcmanfm` file manager
    - `gnome-system-monitor` system monitor / task manager
    - `gnome-calculator` calculator
    - `flameshot` to make screenshots <br>
      `grim` to make screenshots in automated scenarios
    - `xed` text editor
    - `eog` (a user-friendly) image viewer
    - `gpicview` (a performant) image viewer (better suit for huge photos)
    - `mpv` media player <br>
      `mpv-mpris` for MPRIS (playerctl) support in mpv <br>
      `yt-dlp` to support opening YouTube links in mpv  <br>
      (if you are using my config, it just works; otherwise, these extensions
      for `mpv` need to be configured)
    - `firefox chromium google-chrome` web browsers
    - `thunderbird` - Mozilla Thunderbird mail client
    - `obs-studio` screen recording and streaming software
    - `wps-office-bin` office software, <br>
      `onlyoffice-bin` office software
    - `telegram-desktop` client for the Telegram messenger
    - `vk-messenger-bin` client for the VK messenger
    - `timeshift` system backup and restore utility <br>
      (configuration required, see the next section)
    - `baobab` disk space usage analysis utility

-   Drivers
    - `nvidia` for nvidia drivers <br>
      `nvidia-prime` for the `prime-run` utility to launch apps with access to the GPU
    - `xpadneo-dkms` for Xbox controller vibration support

-   Daemons
    - `docker` - Docker daemon <br>
      `docker-buildx` - Docker BuildX plugin <br>
      (configuration required, see the next section)

To install all of the above, run:
```sh
$ yay -Syu --needed \
      bluez noto-fonts{,-extra,-cjk,-emoji} otf-font-awesome ntfs-3g xdg-user-dirs \
      pipewire{,-alsa,-audio,-jack,-pulse} pwvucontrol wl-clip-persist hypridle gvfs playerctl linux-a11y-sound-theme \
      adapta-gtk-theme xremap-hypr-bin xdg-desktop-portal-hyprland \
        \
      openssh bluez-utils lsd c-lolcat light htop gdb vim helix bash-language-server clang gopls rust-analyzer ffmpeg rclone \
      trash-cli autotrash moreutils tldr curl wget inetutils dog zip unzip rar rustup jq asciinema strace \
        \
      rofi waybar hyprlock hyprsunset terminator foot pcmanfm gnome-{system-monitor,calculator} flameshot grim xed eog gpicview \
      mpv{,-mpris} yt-dlp firefox chromium google-chrome thunderbird obs-studio wps-office-bin onlyoffice-bin telegram-desktop \
      vk-messenger-bin timeshift baobab \
        \
      nvidia{,-prime} xpadneo-dkms \
        \
      docker{,-buildx}
< study PKGBUILDs to make sure they are not mallicious; proceed with the installation >
```

## Configure your system

### Background helpers

Out of daemons that you installed above, some (e.g., clipboard manager) need to be
running in the background. Out of such daemons, `pipewire` and `dunst` will be launched automatically
(on startup or on demand); for the rest of them to start automatically additional set up is needed.

If you are using my `Hyprland` config, all the relevant applications are already there and will be started on
log in and terminated on log out (graphical applications will know when the graphical session
is over, so they can terminate; the rest, such as `wl-clip-persist`, are sent a SIGHUP signal on `Hyprland`
termination because they are started through `pdeath_hup`).

If you are using a different setup, you need to configure your system to launch whatever you want to be
autostarted.

### Docker

To make interaction with `docker` more comfortable, run:
```sh
$ sudo systemctl enable --now docker.socket  # Start the docker daemon on demand
$ sudo usermod -aG docker $USER  # Allow running `docker` commands without `sudo`
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

### rustup

To install the rust toolchain, run:
```sh
$ rustup toolchain install stable
```

### Backlight control - `light`

Add all users that need to run `light` to the `video` group:
```sh
$ sudo usermod -aG video $USER
```

To also support brightness control keys on your keyboard, make sure that your compositor
config uses the `light` utility for backlight control (`XF86MonBrightnessUp`, `XF86MonBrightnessDown`).
It is already configured if you are using my `Hyprland` config.

### Automatic trash clean up - `autotrash`

To automatically clean files older than 30 days, run:
```sh
$ autotrash -d 30 --install
< some output >
```

### topgrade

Run `topgrade` to get the initial `~/.config/topgrade.toml` configuration file.
Next, edit it to contain the following:
```
# ...
[misc]
# ...
pre_sudo = true
# ...
disable = ["containers"]
```

With these changes, topgrade will run `sudo -v` before performing the update and will
skip updating docker containers.

### Default apps

Set default applications for file formats:
```sh
xdg-mime default gpicview.desktop image/jpeg
xdg-mime default gpicview.desktop image/png
xdg-mime default pcmanfm.desktop inode/directory
```

### Window buttons layout

To show appmenu on the left, hide the minimize button, and show maximize and close
buttons on the right, run:

```sh
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:maximize,close'
```

### Screenshotting - `flameshot`

Run `flameshot`, open its settings from the tray, and configure it as follows:

Tab General:

- Turn off "Automatically unload from memory when it is not needed" (flameshot must remain running for the
  copied image to remain in the clipboard)
- Turn on "Show tray icon"
- Turn off "Show abort notifications" (they are noisy and inconvenient when retrying a screenshot)
- Turn off "Save image after copy"
- Turn off "Show welcome message on launch"

Tab Shortcuts:

- Set "Copy selection to clipboard" action to Enter

### `hyprlock` screen lock

Hyprlock requires a configuration file to work. If you are using my configs from above,
you already have it configured. Edit it to your liking at `~/.config/hypr/hyprlock.conf`

### `hypridle` idleness management

Hypridle requires a configuration file to work. If you are using my configs from above,
you already have it configured. Edit it to your liking at `~/.config/hypr/hypridle.conf`

### User dirs

Setup "well known" user direcotries and change the "Documents" directory from the default
`$HOME/Documents` to `$HOME/Docs` (as it's easier to type on the terminal):
```sh
$ xdg-user-dirs-update --set DOCUMENTS "$HOME/Docs"
```

### Gtk theme

To prevent some apps (e.g., `gnome-calculator`) from overriding the theme configured in
`.config/gtk-*`, install the patched version of `libadwaita`:
```sh
$ yay -S libadwaita-without-adwaita-git --asdeps
< confirm that due to a conflict `libadwaita` or `libadwaita-1.so` needs to be removed >
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
Create file `~/.thunderbird/<profile-name>.default-release/chrome/userChrome.css`.
In it, put the contents of
[_.thunderbird/profile-name/chrome/userChrome.css](_.thunderbird/profile-name/chrome/userChrome.css)
from this repository.

## Configure suspension and hibernation

(note: I am no longer using suspend-then-hibernate, since it has been pretty buggy
over many systemd releases in a row)

Edit `/etc/systemd/sleep.conf` such that it has the following entries:
```
[Sleep]
AllowSuspend=yes
AllowHibernation=yes
AllowSuspendThenHibernate=no
#...
```

Edit `/etc/systemd/logind.conf` such that it contains the following entries:
```
[Login]
#...
HandlePowerKey=suspend
#...
HandleSuspendKey=suspend
#...
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
#...
IdleAction=ignore
#...
```

Edit `/etc/mkinitcpio.conf` by adding the `resume` option to the `HOOKS=(...)` array, such that
`resume` is after `udev`, to allow resume from hibernation. For example:
```
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems resume fsck)
```
And rebuild the cpio image:
```sh
$ sudo mkinitcpio -P
```

On a modern system (systemd >= 255, mkinitcpio >= 38, UEFI system) this should be sufficient:
systemd will utilize the `HibernateLocation` EFI variable to keep the location of the hibernated
image.

Otherwise (if you end up with system hibernating but then booting normally rather than resuming), refer to
[ArchWiki:Hibernation](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation)

## Non-packaged utils

There are a few more utils that I use, which are not properly packaged (yet?). To install them,
follow the README instructions.

-   Install [docker-on-top](https://github.com/kolayne/docker-on-top)

-   Clone [Rimokon](https://github.com/kolayne/Rimokon) to `~/Docs/Rimokon` and configure it.
    With my `Hyprland` config it will be started on log in automatically
