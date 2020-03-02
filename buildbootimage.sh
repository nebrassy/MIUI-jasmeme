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
git -C $SOURCEROM/kernel/xiaomi/sdm660 checkout nebrassy/MIUI-r38

sed -i "$ i\BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive" $SOURCEROM/device/xiaomi/sdm660-common/BoardConfigCommon.mk

git -C $SOURCEROM/bootable/recovery remote add aicp https://github.com/AICP/bootable_recovery.git
git -C $SOURCEROM/bootable/recovery fetch aicp
git -C $SOURCEROM/bootable/recovery checkout aicp/p9.0


source build/envsetup.sh
lunch aicp_jasmine_sprout-userdebug
mka bootimage


cp -f out/target/product/jasmine_sprout/boot.img $OUTP/zip/boot.img
git -C $SOURCEROM/device/xiaomi/sdm660-common reset --hard
git -C $SOURCEROM/build/core reset --hard

cd $CURRENTDIR
