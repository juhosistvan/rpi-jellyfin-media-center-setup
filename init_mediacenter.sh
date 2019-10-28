#!/bin/bash

MEDIACENTER_ROOT="/mnt/mediacenter"

echo
echo "    //////////////////////////////////////////////////////"
echo "    // SteweMetal's Jellyfin Media Center Config Script //"
echo "    //////////////////////////////////////////////////////"
echo
echo 
echo "Let's set up the Media Center file system!"
echo 
echo "Would you like to install one of the following file system drivers?"
echo
echo "[1] exFAT"
echo "[2] NTFS"
echo "[3] Both"
echo
read -p "Pick an option! " fs_driver_option
case $fs_driver_option in
	1) 
		sudo apt-get install exfat-fuse ;;
	2) 	
		sudo apt-get install ntfs-3g ;;
	3) 
		sudo apt-get install exfat-fuse
		sudo apt-get install ntfs-3g ;;
	*)
		echo "Skipping file system driver installation!"
esac
echo
echo "Here are the attached drives:"
echo
sudo lsblk -o UUID,NAME,LABEL,SIZE,FSTYPE,MODEL,MOUNTPOINT
echo
echo "Choose a drive to mount as the media center storage!"
echo "    (I will umnmount and remount the drive!)"
echo 
read -p "Paste a drive UUID here from above: " uuid
echo
if [ -z "$uuid" ]
then
	echo "UUID was empty, skipping mounting step!"
else
	echo "Unmounting drive..."
	sudo umount UUID=$uuid
	echo
	echo "Drive was unmounted successfully!"
	echo
	echo "Mounting drive to ${MEDIACENTER_ROOT}..."
	echo
	sudo mkdir $MEDIACENTER_ROOT
	sudo chmod 775 $MEDIACENTER_ROOT
	sudo mount UUID=$uuid /mnt/mediacenter
	echo "Drive was mounted to ${MEDIACENTER_ROOT}!"
	echo
	echo "Setting up auto-mount on boot..."
	echo
	sudo chmod 644 /etc/fstab
	sudo cp /etc/fstab /etc/fstab.backup
	sudo chmod 777 /etc/fstab
	DEVICE="UUID=$uuid"
	TYPE=$(sudo blkid | grep 2A147679147647B9 | sed -n "s/^.*TYPE=\"\(.*\)\"\s.*$/\1/p")
	FSTAB_NEW_ENTRY="${DEVICE} ${MEDIACENTER_ROOT} ${TYPE} defaults 0 0"
	sudo grep -qxF "${FSTAB_NEW_ENTRY}" /etc/fstab || echo $FSTAB_NEW_ENTRY >> /etc/fstab
	sudo chmod 644 /etc/fstab
	echo "Auto-mount setup was successful!"
	
fi
echo
echo "Do you want me to create media library folders?"
read -p "List library names separated by semicolons: " lib_names
echo
if [ -z "$lib_names" ]
then
	echo "No library names were specified, skipping library creation!"
else
	IFS=";" read -ra LIBS <<< "$lib_names"
	for i in "${LIBS[@]}"; do
		sudo mkdir "${MEDIACENTER_ROOT}/${i}"
	done
fi
echo
echo "Allright! It's time to install Jellyfin!"
echo
echo "Install Jellyfin?"
echo
echo "[1] Install"
echo "[2] Skip"
echo
read -p "Pick an option! " jellyfin_install_option
echo
case $jellyfin_install_option in
	1) 
		echo "Installing apt-transport-https..."
		echo
		sudo apt install apt-transport-https
		echo
		echo "Importing the GPG signing key (signed by the Jellyfin Team)..."
		echo
		sudo wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | sudo apt-key add -
		echo
		echo "Adding a necessary repository configuration..."
		echo
		sudo echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian $( lsb_release -c -s ) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
		echo
		echo "Updating APT repositories..."
		echo
		sudo apt update
		echo
		echo "Installing Jellyfin..."
		sudo apt install jellyfin
		echo
		echo "Jellyfin was installed successfully!";;
	*) 
		echo "Skipping Jellyfin installation!";;
esac
echo
echo "Jellyfin setup was successful! Congrats!"
echo
echo "A few handy commands to manage the Jellyfin service:"
echo "sudo service jellyfin status"
echo "sudo systemctl restart jellyfin"
echo "sudo /etc/init.d/jellyfin stop"
echo
echo "Start configuring your Jellyfin by visiting http://localhost/:8096 !"
echo
echo "Have fun!"
echo
echo "For further information, visit https://jellyfin.readthedocs.io/en/latest/ !"
echo
