cd ~
#sudo pacman --noconfirm --noedit -Syu trizen cpio brotli abootimg
#trizen --noconfirm --noedit -Syu simg-tools aosp-devel
sudo apt -y install cpio brotli simg2img abootimg git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip zip screen attr ccache libssl-dev imagemagick schedtool
ccache -M 50G
echo "USE_CCACHE=1" >> ~/.bashrc
echo "export USE_CCACHE=1" >> ~/.bashrc
echo "export CCACHE_EXEC=$(command -v ccache)" >> ~/.bashrc

mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
mkdir ~/aicp10
cd ~/aicp10
git config --global user.name nebrassy
git config --global user.email nebras30@gmail.com
repo init -u https://github.com/AICP/platform_manifest.git -b q10.0
repo sync
