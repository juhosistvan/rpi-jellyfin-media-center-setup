if [ -z "$1" ]
then
	CRED_PATH="/mnt/mediacenter/raspberrymc_creds.json"
else
	CRED_PATH="$1"
fi

export GOOGLE_APPLICATION_CREDENTIALS=$CRED_PATH

sudo chmod 777 /etc/profile
CRED_LINE="export GOOGLE_APPLICATION_CREDENTIALS=$CRED_PATH"
sudo grep -qxF "${CRED_LINE}" /etc/profile || echo $CRED_LINE >> /etc/profile
sudo chmod 644 /etc/profile

echo
echo "A restart is needed to set up credentials correctly!"
echo
read -p "Restart now? [y/n] " restart
case $restart in
	"y") 
		sudo reboot ;;
	*) 	
		;;
esac
