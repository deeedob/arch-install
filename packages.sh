#  core system components
BASE=(
    'base'                          #  Base Arch Linux system
    'linux'                         #  Linux Kernel
    'base-devel'                    # Various development utilities
    'linux-firmware'                #  Firmware files for Linux
)

#  basic system components
BASE_APPS=(
    'cronie'                        # Run jobs periodically
    'git'                           # Version Control System, needed for the Grub theme, Dotfiles, and Paru
    'archlinux-keyring'             # Arch Linux PGP key ring
    'efibootmgr'                    # Modify UEFI systems from CLI
    'mtpfs'                         # Media Transfer Protocol support
    'networkmanager'                # Network connection manager
    'openssh'                       # Remotely control other systems
    'python'                        # Essential package for many programs
    'usbutils'                      # Various tools for USB devices
    'reflector'
    'p7zip'                         # Support for 7zip files
    'wget'                          # Utility to download files
    'zsh'                           # An alternate shell to bash
    'neovim'                        # texteditor
    'ffmpeg'                        # Audio and video magic
    'unzip'                         # Support for zip files
    'unrar'                         # Support for rar files
    'zip'                           # Support for zip files
    'exa'                           # Replacement for the ls command
)

#  user applications
APPS=(
    'gimp'                          # Image editor
    'alsa-utils'                    # Utilities for managing alsa cards
    'btop'                          # System and process manager
    'pavucontrol'                   # Pulse Audio volume control
    'flameshot'                     # Screenshot utility
    'firefox'                       # Web browser
    'neofetch'                      # Display system information, with style
    # 'xclip'                         # Copy to clipboard from CLI
)

GAMING_APPS=(
    'steam'                         # Game storefront
    'discord'                       # Communication software
    # 'mangohud'                      # HUD for monitoring system and logging
    'wine'                          # Run Windows applications on Linux
    'winetricks'                    # Script to install libraries in Wine
)

# all of these will get enabled
SERVICES=(
    'ufw'
    'mpd'
    'sshd'
    'dhcpcd'
    'cronie'
    'NetworkManager'
)

# this will get populated automatically
GPU_DRIVERS=()
