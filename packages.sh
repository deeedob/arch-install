# core system components
BASE=(
    'base'                          # NEEDED: Base Arch Linux system
    'linux'                         # NEEDED: Linux Kernel
    'linux-firmware'                # NEEDED: Firmware files for Linux
)

# basic system components
BASE_APPS=(
    'archlinux-keyring'             # NEEDED: Arch Linux PGP key ring
    'base-devel'                    # NEEDED: Various development utilities, needed for Paru and all AUR packages
    'cronie'                        # OPTIONAL: Run jobs periodically
    'dialog'                        # NEEDED: Dependency for many TUI programs
    'dosfstools'                    # OPTIONAL: Utilities for DOS filesystems
    'efibootmgr'                    # OPTIONAL: Modify UEFI systems from CLI
    'git'                           # OPTIONAL: Version Control System, needed for the Grub theme, Dotfiles, and Paru
    'gnu-free-fonts'                # OPTIONAL: Additional system fonts
    'linux-headers'                 # OPTIONAL: Scripts for building kernel modules
    'man-db'                        # OPTIONAL: Manual database
    'mtools'                        # OPTIONAL: Utilities for DOS disks
    'mtpfs'                         # OPTIONAL: Media Transfer Protocol support
    'network-manager-applet'        # OPTIONAL: Applet for managing the network
    'networkmanager'                # OPTIONAL: Network connection manager
    'openssh'                       # OPTIONAL: Remotely control other systems
    'os-prober'                     # OPTIONAL: Scan for other operating systems
    'python'                        # NEEDED: Essential package for many programs
    'reflector'                     # OPTIONAL: Get download mirrors
    'usbutils'                      # OPTIONAL: Various tools for USB devices
    'wget'                          # OPTIONAL: Utility to download files
    'xdg-user-dirs'                 # OPTIONAL: Manager for user directories
    'zsh'                           # OPTIONAL: An alternate shell to bash
    'ufw'                           # OPTIONAL: firewall
    'neovim'                        # OPTIONAL: texteditor
)

# user applications
APPS=(
    'alsa-utils'                    # OPTIONAL: Utilities for managing alsa cards
    'android-tools'                 # OPTIONAL: Utilities for managing android devices
    'exa'                           # OPTIONAL: Replacement for the ls command
    'ffmpeg'                        # OPTIONAL: Audio and video magic
    'firefox'                       # OPTIONAL: Web browser
    'flameshot'                     # OPTIONAL: Screenshot utility
    'gimp'                          # OPTIONAL: Image editor
    'helvum'                        # OPTIONAL: GUI for Pipewire configuration
    'btop'                          # OPTIONAL: System and process manager
    'mlocate'                       # OPTIONAL: Quickly find files and directories
    'mpv'                           # OPTIONAL: Suckless video player
    'mtpfs'                         # OPTIONAL: File transfer for android devices
    'neofetch'                      # OPTIONAL: Display system information, with style
    'neovim'                        # OPTIONAL: Objectively better than Emacs
    'nerd-fonts-ubuntu-mono'        # OPTIONAL: Ubuntu fonts patched with icons
    'ntfs-3g'                       # OPTIONAL: Driver for NTFS file systems
    'numlockx'                      # OPTIONAL: Set numlock from CLI
    'p7zip'                         # OPTIONAL: Support for 7zip files
    'pavucontrol'                   # OPTIONAL: Pulse Audio volume control
    'pipewire'                      # OPTIONAL: Modern audio router and processor
    'pipewire-alsa'                 # OPTIONAL: Pipewire alsa configuration
    'pipewire-pulse'                # OPTIONAL: Pipewire replacement for pulseaudio
    'python-pynvim'                 # OPTIONAL: Python client for neovim
    'qbittorrent'                   # OPTIONAL: Torrent downloader
    'ripgrep'                       # OPTIONAL: GNU grep replacement
    'ttf-ubuntu-font-family'        # OPTIONAL: Ubuntu fonts
    'unrar'                         # OPTIONAL: Support for rar files
    'unzip'                         # OPTIONAL: Support for zip files
    #'wireplumber'                   # OPTIONAL: Session manager for Pipewire
    'xclip'                         # OPTIONAL: Copy to clipboard from CLI
    'zathura'                       # OPTIONAL: Document viewer
    'zathura-pdf-mupdf'             # OPTIONAL: PDF ePub and OpenXPS support for zathura
    'zenity'                        # OPTIONAL: Basic GUIs from CLI
    'zip'                           # OPTIONAL: Support for zip files
)

GAMING_APPS=(
    'discord'                       # OPTIONAL: Communication software
    'gamescope'                     # OPTIONAL: WM container for games
    'lutris'                        # OPTIONAL: Game launcher and configuration tool
    'mangohud'                      # OPTIONAL: HUD for monitoring system and logging
    'steam'                         # OPTIONAL: Game storefront
    'steam-native-runtime'          # OPTIONAL: A native runtime for Steam
    'wine'                          # OPTIONAL: Run Windows applications on Linux
    'wine-gecko'                    # OPTIONAL: Wine's replacement for Internet Explorer
    'wine-mono'                     # OPTIONAL: Wine's replacement for .Net Framework
    'winetricks'                    # OPTIONAL: Script to install libraries in Wine
)

# all of these will get enabled
SERVICES=(
    'NetworkManager'
    'cronie'
    'mpd'
    'sshd'
    'dhcpcd'
    'ufw'
)

# this will get populated automatically
GPU_DRIVERS=()
