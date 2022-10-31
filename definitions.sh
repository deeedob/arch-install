#!/bin/bash
#############
# PRE-SETUP #
#############
setup_variables() {

	echo "\x1b[1;36m"
	# this is ASCII art
	base64 -d <<<"H4sIAAAAAAAAA1NQAIF4/Xh9GA1hIdgwGZioggI2eQiNUIsQ5VLAFEdWgdsGhAw2/TA+F8wpEC6y
YmSH4jMeFaM6nlKnIzyAxem4/IU95NE9iWotuseBxgMAqF41l90BAAA=" | gunzip
	echo "\x1b[0m"
	echo
	echo "Choose the device you want to install Arch Linux on:"
	echo "\x1b[1;31mThe chosen device will be completely erased and all its data will be lost"
	echo "\x1b[33m"
	# show the drives in yellow
	lsblk
	echo "\x1b[0m"
	echo
	PS3="Choose the root drive: "

	select drive in "$(lsblk | sed '/\(^├\|^└\|^NAME\)/d' | cut -d " " -f 1)"; do
		if [ "$drive" ]; then
			export ROOT_DEVICE="$drive"
			break
		fi
	done

	PS3="Do you want an encrypted drive? "
	select ENCRYPT_DRIVE in "Yes" "No"; do
		if [ "$ENCRYPT_DRIVE" ]; then
			break
		fi
	done

	#specify root size
	SZR_=$(lsblk | grep "$ROOT_DEVICE" | head -n1 | awk '{print $4}' | sed 's|[GiB]||g')
	echo "Select the root size"
	echo "Available ${SZR_} G"
	read "ROOT_SIZE?ROOT size {G,GiB}: "
	SZU_=$(echo "$ROOT_SIZE" | sed 's|[GiB]||g')
	HOME_SIZE=$((SZR_ - SZU_))
	echo "Available Disk Space: ${HOME_SIZE}G"

	PS3="Do you want a SWAP partition? "
	select PART_SWAP in "Yes" "No"; do
		if [ "$PART_SWAP" = "Yes" ]; then
			MEMTOTAL_=$(numfmt --field=2 --from-unit=1024 --to=iec-i --suffix B </proc/meminfo | sed 's/ kB//' | sed 's|[GiB]||g' | head -n4 | grep "MemTotal" | awk '{printf("%.0f\n",$2)}')
			echo
			echo "\x1b[33m"
			# show the tip in yellow

			echo "Your Device MemTotal is: ${MEMTOTAL_}G"
			if [ "$MEMTOTAL_" -le 2 ]; then
				echo "Recommended Swap Space: $((2 * MEMTOTAL_))G"
				echo "Recommended Swap Space with hibernation: $((3 * MEMTOTAL_))G"
			fi
			if [ "$MEMTOTAL_" -gt 2 ] && [ "$MEMTOTAL_" -le 8 ]; then
				echo "Recommended Swap Space: $((MEMTOTAL_))G"
				echo "Recommended Swap Space with hibernation: $((2 * MEMTOTAL_))G"
			fi
			if [ "$MEMTOTAL_" -gt 8 ] && [ "$MEMTOTAL_" -le 64 ]; then
				echo "Recommended Swap Space: 4G - $((0.5 * MEMTOTAL_))G"
				echo "Recommended Swap Space with hibernation: $((1.5 * MEMTOTAL_))G"
			fi
			if [ "$MEMTOTAL_" -gt 64 ]; then
				echo "Recommended Swap Space: min of 4G"
				echo "Recommended Swap Space with hibernation: not recommended!"
			fi
			echo "\x1b[0m"
			echo
			read "SWAP_SIZE?SWAP size {G,GiB}: "
			SWAP_SIZE_=$(echo "$SWAP_SIZE" | sed 's|[GiB]||g')
			HOME_SIZE=$((HOME_SIZE - SWAP_SIZE_))
			echo "remaining space on /dev/${ROOT_DEVICE}: ${HOME_SIZE}G"
			break
		else
			break
		fi
	done

	read "USR?Enter your username: "
	while
		echo "\x1b[33m"
		read -s "PASSWD?Enter your password: "
		echo ""
		read -s "CONF_PASSWD?Re-enter your password: "
		echo "\x1b[31m"
		[ "$PASSWD" != "$CONF_PASSWD" ]
	do echo "Passwords don't match"; done

	echo "\x1b[32mPasswords match\x1b[0m"
	echo ""

	read "HOSTNAME?Enter this machine's hostname: "

	PS3="Do you want to install dotfiles?: "
	select DOTFILES in "Yes" "No"; do
		if [ "$DOTFILES" ]; then
			break
		fi
	done

	# detect wifi card
	if [ "$(lspci -d ::280)" ]; then
		WIFI=y
	fi

	# this: "<<-" ignores indentation, but only for tab characters
	ROOT_DEVICE="/dev/${ROOT_DEVICE}"
	cat <<-EOL >vars.sh
		export ROOT_DEVICE=$ROOT_DEVICE
		export ENCRYPT_DRIVE=$ENCRYPT_DRIVE
		export ROOT_SIZE=$ROOT_SIZE
		export SWAP_SIZE=$SWAP_SIZE
		export HOME_SIZE=$HOME_SIZE
		export PART_SWAP=$PART_SWAP
		export USR=$USR
		export PASSWD=$PASSWD
		export HOSTNAME=$HOSTNAME
		export WIFI=$WIFI
		export DOTFILES=$DOTFILES
	EOL

	print_summary
}

print_summary() {

	echo -e "\n--------------------"
	echo "Summary:"
	echo ""
	# set text to bold red
	echo "\x1b[1;33m"
	echo "The installer will erase all data on the \x1b[1;31m$ROOT_DEVICE\x1b[1;33m drive\x1b[0m"
	echo

	if [ "$ENCRYPT_DRIVE" = "Yes" ]; then
		echo "With \x1b[1;33mencrypted drive\x1b[0m"
	else
		echo "You \x1b[1;33mWILL NOT\x1b[0m have disk-encryption"
	fi

	echo "The root partition will be \x1b[1;33m$ROOT_SIZE big\x1b[0m"

	if [ "$PART_SWAP" = "Yes" ]; then
		echo "The swap partition will be \x1b[1;33m$SWAP_SIZE big\x1b[0m"
	else
		echo "\x1b[1;33mno swap\x1b[0m"
	fi

	echo "The home partition will be \x1b[1;33m${HOME_SIZE}G big\x1b[0m"

	echo "Your username will be \x1b[1;33m$USR\x1b[0m"

	echo "The machine's hostname will be \x1b[1;33m$HOSTNAME\x1b[0m"

	if [ "$DOTFILES" = "Yes" ]; then
		echo "You \x1b[1;33mWILL\x1b[0m install dotfiles"
	else
		echo "You \x1b[1;33mWILL NOT\x1b[0m install dotfiles"
	fi

	read "ANS?Proceed with installation? [y/N]: "

	if [ "$ANS" != "y" ]; then
		exit
	fi
}

configure_pacman() {
	sed -i 's/^#Color/Color/' /etc/pacman.conf
	sed -i 's/^#VerboseP/VerboseP/' /etc/pacman.conf
	sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
	sed -i "s/^#ParallelDownloads = 5/ParallelDownloads = 10\nILoveCandy/" /etc/pacman.conf
}

update_keyring() {
	timedatectl set-ntp true # sync clock
	hwclock --systohc
	# this is useful if installing from outdated ISO
	pacman --noconfirm --ask=127 -Sy archlinux-keyring
}

################
# PARTITIONING #
################
partition_and_mount() {

	if [ -d /sys/firmware/efi/efivars ]; then
		UEFI=y
		partition_and_mount_uefi
	else
		UEFI=n
		partition_and_mount_bios
	fi

	echo "UEFI=$UEFI" >>vars.sh
}

partition_and_mount_uefi() {
	# disk partitioning
	wipefs --all --force "$ROOT_DEVICE"
	# cut removes comments from heredoc
	# this: "<<-" ignores indentation, but only for tab characters
	if [ "$PART_SWAP" = "Yes" ]; then
		cut -d " " -f 1 <<-EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
			g           # gpt partition scheme
			n           # new partition
			            # partition number 1 - BOOT
			            # start of sector
			+512MiB     # plus 512MB
			n           # new partition
			            # partition number 2 - SWAP
			            # start of sector
			+$SWAP_SIZE # plus 512MB
			n           # new parition
			            # partition number 2 - ROOT
			            # start of sector
			+$ROOT_SIZE # end of sector
			n           # new parition
			            # partition number 3 - HOME
			            # start of sector
			            # end of sector
			w           # write
		EOL
	else
		cut -d " " -f 1 <<-EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
			g           # gpt partition scheme
			n           # new partition
			            # partition number 1 - BOOT
			            # start of sector
			+512MiB     # plus 512MB
			n           # new parition
			            # partition number 2 - ROOT
			            # start of sector
			+$ROOT_SIZE # end of sector
			n           # new parition
			            # partition number 3 - HOME
			            # start of sector
			            # end of sector
			w           # write
		EOL
	fi

	# get partition names
	PARTITIONS=("$(for PARTITION in "$(dirname /sys/block/"$(basename "$ROOT_DEVICE")"/*/partition)"; do
		basename "$PARTITION"
	done)")

	if [ "$PART_SWAP" = "Yes" ]; then
		# partition formatting for swap
		mkfs.fat -F 32 /dev/"$PARTITIONS"[1]    # boot
		mkswap /dev/"$PARTITIONS"[2] -L SWAP    # swap
		mkfs.ext4 /dev/"$PARTITIONS"[3] -L ROOT # root

		# mount partitions
		mkdir -pv /mnt
		mount /dev/"$PARTITIONS"[3] /mnt
		mount --mkdir /dev/"$PARTITIONS"[1] /mnt/boot
		swapon /dev/"$PARTITIONS"[2]

		if [ "$ENCRYPT_DRIVE" = "Yes" ]; then
			# Encrypt the home partition
			echo "$PASSWD" | cryptsetup -q luksFormat /dev/"$PARTITIONS"[4]
			echo "$PASSWD" | cryptsetup open /dev/"$PARTITIONS"[4] "$USR"-home
			mkfs.ext4 /dev/mapper/"$USR"-home
			mount --mkdir /dev/mapper/"$USR"-home /mnt/home
		else
			mkfs.ext4 /dev/"$PARTITIONS"[4] -L HOME # home
			mount --mkdir /dev/"$PARTITIONS"[4] /mnt/home
		fi

		echo "export HOME_DEVICE=/dev/$PARTITIONS[4]" >>vars.sh
		echo "export ROOT_PART=/dev/$PARTITIONS[3]" >>vars.sh
	else
		# partition formatting
		mkfs.fat -F 32 /dev/"$PARTITIONS"[1]    # boot
		mkfs.ext4 /dev/"$PARTITIONS"[2] -L ROOT # root
		mkfs.ext4 /dev/"$PARTITIONS"[3] -L HOME # home

		# mount partitions
		mkdir -pv /mnt
		mount /dev/"$PARTITIONS"[2] /mnt
		mount --mkdir /dev/"$PARTITIONS"[1] /mnt/boot

		if [ "$ENCRYPT_DRIVE" = "Yes" ]; then
			# Encrypt the home partition
			echo "$PASSWD" | cryptsetup -q luksFormat /dev/"$PARTITIONS"[3]
			echo "$PASSWD" | cryptsetup open /dev/"$PARTITIONS"[3] "$USR"-home
			mkfs.ext4 /dev/mapper/"$USR"-home
			mount --mkdir /dev/mapper/"$USR"-home /mnt/home
		else
			mkfs.ext4 /dev/"$PARTITIONS"[3] -L HOME # home
			mount --mkdir /dev/"$PARTITIONS"[3] /mnt/home
		fi

		echo "export HOME_DEVICE=/dev/$PARTITIONS[3]" >>vars.sh
		echo "export ROOT_PART=/dev/$PARTITIONS[2]" >>vars.sh
	fi

	# get mirrors
	reflector >/etc/pacman.d/mirrorlist
}

partition_and_mount_bios() {
	# disk partitioning
	wipefs --all --force "$ROOT_DEVICE"
	# cut removes comments from heredoc
	# this: "<<-" ignores indentation, but only for tab characters
	cut -d " " -f 1 <<-EOL | fdisk --wipe always --wipe-partitions always $ROOT_DEVICE
		n           # new partition
		            # primary partition
		            # partition number 1
		            # start of sector
		            # end of sector
		w           # write
	EOL

	# get partition names
	PARTITIONS=("$(for PARTITION in "$(dirname /sys/block/"$(basename "$ROOT_DEVICE")"/*/partition)"; do
		basename "$PARTITION"
	done)")

	# partition formatting
	mkfs.ext4 /dev/"$PARTITIONS"[1] -L ROOT # root/boot

	# mount partitions
	mkdir -pv /mnt
	mount /dev/"$PARTITIONS"[1] /mnt

	# get mirrors
	reflector >/etc/pacman.d/mirrorlist
}

install_base() {
	pacstrap /mnt "${BASE[@]}"
	reflector >/mnt/etc/pacman.d/mirrorlist
	genfstab -U /mnt | tac | sed '/\/home/I,+2 d' | tac >/mnt/etc/fstab
}

###########
# NETWORK #
###########
setup_network() {
	# timezone
	ln -sfv /usr/share/zoneinfo/Europe/Berlin /etc/localtime

	configure_locale

	echo "$HOSTNAME" >/etc/hostname

	# this: "<<-" ignores indentation, but only for tab characters
	cat >>/etc/hosts <<-EOL
		127.0.0.1   localhost
		::1         localhost
		127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
	EOL

	echo -e "${PASSWD}\n${PASSWD}\n" | passwd
}

configure_locale() {
	sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
	sed -i 's/^#de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen

	locale-gen

	echo "KEYMAP=de" >/etc/vconsole.conf
	echo "LANG=en_US.UTF-8" >/etc/locale.conf
}

########
# BASE #
########
prepare_system() {
	# install basic system components
	if [ "$WIFI" = "y" ]; then
		BASE_APPS+=('wpa_supplicant' 'wireless_tools')
	fi

	# download database
	pacman --needed --noconfirm -Sy
	pacman --noconfirm --ask=127 --needed -S "${BASE_APPS[@]}"
	# update pacman keys
	pacman-key --init
	pacman-key --populate

	install_cpu_ucode

	# install bootloader
	if [ "$UEFI" == y ]; then
		pacman --needed --noconfirm -S refind
		refind-install
		rm -f /boot/refind_linux.conf
		RUUID_=$(blkid "$ROOT_PART" | grep -Pwo 'UUID="\K[^"]*')
		echo "\"Boot with standard options\" \"root=UUID=${RUUID_} rw quiet splash button.lid_init_state=open acpi_backlight=vendor\"" >/boot/refind_linux.conf
	elif [ "$UEFI" == n ]; then
		pacman --needed --noconfirm -S grub
		grub-install --target=i386-pc "$ROOT_DEVICE"
		# configure grub
		echo -e '\nGRUB_DISABLE_OS_PROBER=false\n' >>/etc/default/grub
		grub-mkconfig -o /boot/grub/grub.cfg
	fi

}

install_cpu_ucode() {
	CPU=$(lscpu | awk '/Vendor ID:/ {print $3}')

	if [ "$CPU" == AuthenticAMD ]; then
		pacman --needed --noconfirm -S amd-ucode
	elif [ "$CPU" == GenuineIntel ]; then
		pacman --needed --noconfirm -S intel-ucode
	fi
}

#########
# USERS #
#########
setup_users() {
	useradd -mG wheel,video,audio,optical,storage,games,kvm -s /bin/zsh "$USR"
	echo -e "${PASSWD}\n${PASSWD}\n" | passwd "$USR"

	export USR_HOME=$(getent passwd "$USR" | cut -d\: -f6)

	# let wheel group use sudo
	echo '%wheel ALL=(ALL:ALL) ALL' >/etc/sudoers.d/wheel_sudo
	# add insults to injury
	echo 'Defaults insults' >/etc/sudoers.d/insults
	if [ "$ENCRYPT_DRIVE" = "Yes" ]; then
		setup_crypt
	fi

}

###############
# SETUP CRYPT #
###############
setup_crypt() {
	sed -i '/auth[ \t]*include[ \t]*system-auth/a auth       optional   pam_exec.so expose_authtok /etc/pam_cryptsetup.sh' /etc/pam.d/system-login
	# this: "<<-" ignores indentation, but only for tab characters
	# unlocking at login
	cat <<-EOL >/etc/pam_cryptsetup.sh
		#!/bin/sh

		CRYPT_USER="${USR}"
		PARTITION="${HOME_DEVICE}"
		NAME="home-\${CRYPT_USER}"
		if [ "\$PAM_USER" = "\$CRYPT_USER" ] && [ ! -e "/dev/mapper/\$NAME" ]; then
		    /usr/bin/cryptsetup open "\$PARTITION" "\$NAME"
		fi
	EOL
	chmod +x /etc/pam_cryptsetup.sh
	# Mounting and unmounting automatically
	export USERID=$(id --user "$USR")
	cat <<-EOL >/etc/systemd/system/home.mount
		[Unit]
		Requires=user@${USERID}.service
		Before=user@${USERID}.service
		[Mount]
		Where=/home
		What=/dev/mapper/home-${USR}
		Options=defaults,relatime

		[Install]
		RequiredBy=user@${USERID}.service
	EOL
	# Locking after unmounting
  PART=$(systemd-escape -p "$HOME_DEVICE")
	cat <<-EOL >/etc/systemd/system/cryptsetup-${USR}.service
		[Unit]
		DefaultDependencies=no
		BindsTo=dev-${PART}.device
		After=dev-${PART}.device
		BindsTo=dev-mapper-home\x2d${USR}.device
		Requires=home.mount
		Before=home.mount
		Conflicts=umount.target
		Before=umount.target

		[Service]
		Type=oneshot
		RemainAfterExit=yes
		TimeoutSec=0
		ExecStop=/usr/bin/cryptsetup close home-${USR}

		[Install]
		RequiredBy=dev-mapper-home\x2d${USR}.device
	EOL
	systemctl enable home.mount
	systemctl enable cryptsetup-"$USR".service
}

#################
# CUSTOMIZATION #
#################
install_applications() {
	ins='paru --needed --useask --ask=127 --noconfirm -S'

	# let regular user run comands without password
	echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/wheel_sudo

	# paru is needed for some AUR packages
	install_paru

	# install the chosen DE and GPU drivers
	#sudo su ${USR} -s /bin/zsh -lc "$ins ${DE[*]}"

	detect_drivers
	if [ "$GPU_DRIVERS" ]; then
		sudo su "$USR" -s /bin/zsh -lc "$ins ${GPU_DRIVERS[*]}"
	fi

	# install user applications
	#sudo su ${USR} -s /bin/zsh -lc "$ins ${APPS[*]}"
	su - "$USR" -c "paru --noconfirm -S plymouth-git plymouth-theme-lone-git"

	if [ "$DOTFILES" == "Yes" ]; then
		install_dotfiles
	fi

	# remove unprotected root privileges
	echo '%wheel ALL=(ALL:ALL) ALL' >/etc/sudoers.d/wheel_sudo
}

install_paru() {
	OG_DIR=$PWD
	cd /home/"$USR"

	# clone the repo
	sudo -u "$USR" git clone https://aur.archlinux.org/paru-bin.git paru
	cd paru

	# make the package
	sudo -u "$USR" makepkg -si --noconfirm

	# clean up
	cd ..
	rm -rf paru
	cd "$OG_DIR"
}

detect_drivers() {
	GPU=$(lspci | grep VGA | cut -d " " -f 5-)

	if [[ "$GPU" == *"NVIDIA"* ]]; then
		GPU_DRIVERS+=('nvidia' 'nvidia-utils' 'lib32-nvidia-utils')
	elif [[ "$GPU" == *"AMD"* ]]; then
		GPU_DRIVERS+=('mesa' 'lib32-mesa' 'mesa-vdpau' 'lib32-mesa-vdpau'
			'xf86-video-amdgpu' 'vulkan-radeon' 'lib32-vulkan-radeon'
			'libva-mesa-driver' 'lib32-libva-mesa-driver')
	elif [[ "$GPU" == *"Intel"* ]]; then
		GPU_DRIVERS+=('mesa' 'lib32-mesa' 'vulkan-intel')
	fi
}

install_dotfiles() {
	# this creates the default profiles for firefox
	# it's needed to have a directory to drop some configs
	sudo su "$USR" -s /bin/zsh -lc "timeout 1s firefox --headless"

	git clone --recursive https://github.com/deeedob/ddob-dotfiles "$USR_HOME"/.dotfiles
	chmod +x "$USR_HOME"/.dotfiles/install
	chown -R "$USR:$USR" "$USR_HOME"
	cd "$USR_HOME"/.dotfiles
	sudo -u "$USR" "$USR_HOME"/.dotfiles/install
}

############
# SERVICES #
############
enable_services() {
	for service in "${SERVICES[@]}"; do
		systemctl enable "$service"
	done
}

#################
# CUSTOMIZATION #
#################

customization() {
	plymouth-set-default-theme -R lone
	git clone https://github.com/deeedob/arch-install.git
	mv arch-install/refind/themes /boot/EFI/refind/
	rm -rf arch-install
	echo "include themes/refind-black/theme.conf" >>/boot/EFI/refind/refind.conf
	sed -i 's/EFI\/refind\/icons/EFI\/refind\/themes\/refind-black\/icons/g' /boot/EFI/refind/refind.conf
}
