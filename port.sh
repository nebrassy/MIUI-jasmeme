export CURRENTUSER=$(whoami)
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
PORTZIP=$(readlink -f "$1")
STOCKTAR=$(readlink -f "$2")
SOURCEROM=$(readlink -f "$3")

git -C $CURRENTDIR submodule update --init --recursive
if [[ -z $STOCKTAR ]] || [[ -z $PORTZIP ]] || [[ -z $SOURCEROM ]]
then
echo "usage: 
port.sh [zip to be ported]  [tar of stock rom of the same android version] [android source of same version]
example:
port.sh ~/xiaomi.eu.zip ~/jasmine_global_images.tgz ~/aicp" && exit
fi
if [ $CURRENTUSER == root ]
then
echo "do not run as root" && exit
fi
sudo su -c "$CURRENTDIR/main.sh $PORTZIP $STOCKTAR $SOURCEROM $CURRENTUSER"
