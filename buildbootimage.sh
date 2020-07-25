PATCHDATE=$1
SOURCEROM=$2
OUTP=$3
CURRENTDIR=$4

set -e
cd $SOURCEROM

source ~/.profile
source ~/.bashrc
PATH=~/bin:$PATH

repo sync --force-sync

sed -i "/PLATFORM_SECURITY_PATCH :=/c\      PLATFORM_SECURITY_PATCH := $PATCHDATE" $SOURCEROM/build/core/version_defaults.mk


git -C $SOURCEROM/kernel/xiaomi/sdm660 remote add nebrassy https://github.com/nebrassy/android_kernel_xiaomi_sdm660.git || true
git -C $SOURCEROM/kernel/xiaomi/sdm660 fetch nebrassy
git -C $SOURCEROM/kernel/xiaomi/sdm660 checkout nebrassy/MIUI-common

sed -i "$ i\BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive" $SOURCEROM/device/xiaomi/sdm660-common/BoardConfigCommon.mk
sed -i "s/TARGET_KERNEL_CONFIG := jasmine-perf_defconfig/TARGET_KERNEL_CONFIG := wayne_defconfig/g" $SOURCEROM/device/xiaomi/jasmine_sprout/BoardConfig.mk

git -C $SOURCEROM/bootable/recovery remote add aicp https://github.com/AICP/bootable_recovery.git
git -C $SOURCEROM/bootable/recovery fetch aicp
git -C $SOURCEROM/bootable/recovery checkout aicp/p9.0


source build/envsetup.sh
lunch aicp_jasmine_sprout-userdebug
mka bootimage


cp -f out/target/product/jasmine_sprout/boot.img $OUTP/zip/boot.img
git -C $SOURCEROM/device/xiaomi/sdm660-common reset --hard
git -C $SOURCEROM/device/xiaomi/jasmine_sprout reset --hard
git -C $SOURCEROM/build/core reset --hard

cd $CURRENTDIR
