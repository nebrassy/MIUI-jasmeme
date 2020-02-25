PATCHDATE=$(sudo grep ro.build.version.security_patch= $PSYSTEM/system/build.prop | sed "s/ro.build.version.security_patch=//g"; )

cd $SOURCEROM

PATH=/home/$CURRENTUSER/bin:$PATH
su -c "/home/$CURRENTUSER/bin/repo sync --force-sync" $CURRENTUSER

su -c "sed -i \"/PLATFORM_SECURITY_PATCH :=/c\      PLATFORM_SECURITY_PATCH := $PATCHDATE\" $SOURCEROM/build/core/version_defaults.mk" $CURRENTUSER

su -c "git -C $SOURCEROM/kernel/xiaomi/sdm660 remote add nebrassy https://github.com/nebrassy/android_kernel_xiaomi_sdm660.git" $CURRENTUSER
su -c "git -C $SOURCEROM/kernel/xiaomi/sdm660 fetch nebrassy" $CURRENTUSER
su -c "git -C $SOURCEROM/kernel/xiaomi/sdm660 checkout nebrassy/MIUI-r38-n7" $CURRENTUSER

su -c "sed -i '$ i\BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive' $SOURCEROM/device/xiaomi/sdm660-common/BoardConfigCommon.mk" $CURRENTUSER


su -c 'source build/envsetup.sh; lunch aicp_wayne-userdebug; mka bootimage; mka libwifi-hal' $CURRENTUSER

cp -f out/target/product/wayne/vendor/lib64/libwifi-hal.so $OUTP/libwifi-hal64.so
cp -f out/target/product/wayne/vendor/lib/libwifi-hal.so $OUTP/libwifi-hal32.so

cp -f out/target/product/wayne/boot.img $OUTP/zip/boot.img
su -c "git -C $SOURCEROM/device/xiaomi/sdm660-common reset --hard" $CURRENTUSER
su -c "git -C $SOURCEROM/build/core reset --hard" $CURRENTUSER

cd $CURRENTDIR
