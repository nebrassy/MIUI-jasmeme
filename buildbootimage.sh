PATCHDATE=$1
SOURCEROM=$2
OUTP=$3
CURRENTDIR=$4

cd $SOURCEROM

source ~/.profile
source ~/.bashrc
PATH=~/bin:$PATH

repo sync --force-sync

sed -i "/PLATFORM_SECURITY_PATCH :=/c\      PLATFORM_SECURITY_PATCH := $PATCHDATE" $SOURCEROM/build/core/version_defaults.mk

git -C $SOURCEROM/kernel/xiaomi/sdm660 remote add nebrassy https://github.com/nebrassy/android_kernel_xiaomi_sdm660.git
git -C $SOURCEROM/kernel/xiaomi/sdm660 fetch nebrassy
git -C $SOURCEROM/kernel/xiaomi/sdm660 checkout nebrassy/MIUI-r38-n7

sed -i "$ i\BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive" $SOURCEROM/device/xiaomi/sdm660-common/BoardConfigCommon.mk


source build/envsetup.sh
lunch aicp_jasmine_sprout-userdebug
mka bootimage
mka libwifi-hal

cp -f out/target/product/jasmine_sprout/vendor/lib64/libwifi-hal.so $OUTP/libwifi-hal64.so
cp -f out/target/product/jasmine_sprout/vendor/lib/libwifi-hal.so $OUTP/libwifi-hal32.so

cp -f out/target/product/jasmine_sprout/boot.img $OUTP/zip/boot.img
git -C $SOURCEROM/device/xiaomi/sdm660-common reset --hard
git -C $SOURCEROM/build/core reset --hard

cd $CURRENTDIR
