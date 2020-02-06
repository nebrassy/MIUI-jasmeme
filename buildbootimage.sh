PATCHDATE=$(sudo grep ro.build.version.security_patch= /mnt/systemn7/system/build.prop | sed "s/ro.build.version.security_patch=//g"; )

cd $SOURCEROM

PATH=/home/$CURRENTUSER/bin:$PATH
su -c "/home/$CURRENTUSER/bin/repo sync --force-sync" $CURRENTUSER

sudo -u $CURRENTUSER sed -i "/PLATFORM_SECURITY_PATCH :=/c\      PLATFORM_SECURITY_PATCH := $PATCHDATE" /home/nebras30/aicp10/build/core/version_defaults.mk

sudo -u $CURRENTUSER git -C $SOURCEROM/kernel/xiaomi/sdm660 remote add nebrassy https://github.com/nebrassy/android_kernel_xiaomi_sdm660.git
sudo -u $CURRENTUSER git -C $SOURCEROM/kernel/xiaomi/sdm660 fetch nebrassy
sudo -u $CURRENTUSER git -C $SOURCEROM/kernel/xiaomi/sdm660 checkout nebrassy/MIUI-r38-n7

sudo -u $CURRENTUSER sed -i "$ i\BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive" $SOURCEROM/device/xiaomi/sdm660-common/BoardConfigCommon.mk


su -c 'source build/envsetup.sh; lunch aicp_jasmine_sprout-userdebug; mka bootimage; mka libwifi-hal' $CURRENTUSER

cp -f out/target/product/jasmine_sprout/vendor/lib64/libwifi-hal.so $OUTP/libwifi-hal64.so
cp -f out/target/product/jasmine_sprout/vendor/lib/libwifi-hal.so $OUTP/libwifi-hal32.so

cp -f out/target/product/jasmine_sprout/boot.img $OUTP/zip/boot.img
git -C $SOURCEROM/device/xiaomi/sdm660-common reset --hard
git -C $SOURCEROM/build/core reset --hard

cd $CURRENTDIR
