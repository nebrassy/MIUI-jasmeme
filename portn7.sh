# Requires: android tools, img tools, abootimg, cpio, sdat2img, brotli attr

SVENDOR=/mnt/vendora2
SSYSTEM=/mnt/systema2
PVENDOR=/mnt/vendorn7
PSYSTEM=/mnt/systemn7
SOURCEROM=/home/nebras30/aicp10
CURRENTUSER=nebras30
SD2IMG=/home/$CURRENTUSER/dev/sdat2img.py
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
FILES=$CURRENTDIR/files
PORTZIP=/home/$CURRENTUSER/dev/xiaomi.eu*
STOCKZIP=/home/$CURRENTUSER/dev/jasmine*
OUTP=$CURRENTDIR/out

mkdir $OUTP
cp -Raf $CURRENTDIR/zip $OUTP/

unzip $PORTZIP system.transfer.list vendor.transfer.list system.new.dat.br vendor.new.dat.br
tar --wildcards -xf $STOCKZIP */images/vendor.img */images/system.img
mv jasmine_global_images*/images/vendor.img vendor.img
mv jasmine_global_images*/images/system.img system.img
rm -rf jasmine_global_images*
 
 
simg2img system.img systema2.img
simg2img vendor.img vendora2.img

#brotli --verbose --decompress --input system.new.dat.br --output system.new.dat
brotli -j -v -d system.new.dat.br
#brotli --verbose --decompress --input vendor.new.dat.br --output vendor.new.dat
brotli -j -v -d vendor.new.dat.br
$SD2IMG system.transfer.list system.new.dat systemn7.img
$SD2IMG vendor.transfer.list vendor.new.dat vendorn7.img
rm system.new.dat.br vendor.new.dat.br vendor.img system.img system.new.dat vendor.new.dat system.transfer.list vendor.transfer.list



unalias cp
mkdir $PSYSTEM
mkdir $PVENDOR
mkdir $SVENDOR
mkdir $SSYSTEM
mount -o rw,noatime systemn7.img $PSYSTEM
mount -o rw,noatime vendorn7.img $PVENDOR
mount -o rw,noatime systema2.img $SSYSTEM
mount -o rw,noatime vendora2.img $SVENDOR


#BUILD BOOT IMAGE
source $CURRENTDIR/buildbootimage.sh

rm -rf $PSYSTEM/cache
cp -Rafv $SSYSTEM/cache $PSYSTEM/



cp -Rafv $FILES/bootctl $PSYSTEM/system/bin/
chmod 755 $PSYSTEM/system/bin/bootctl
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/bin/bootctl

cp -Raf $SSYSTEM/system/lib/vndk-29/android.hardware.boot@1.0.so $PSYSTEM/system/lib/vndk-29/android.hardware.boot@1.0.so
cp -Raf $SSYSTEM/system/lib64/vndk-29/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/vndk-29/android.hardware.boot@1.0.so
cp -Raf $SSYSTEM/system/lib64/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/android.hardware.boot@1.0.so

cp -Raf $SVENDOR/etc/MIUI_DualCamera_watermark.png $PVENDOR/etc/MIUI_DualCamera_watermark.png

rm -rf $PSYSTEM/system/priv-app/Updater

mv $PSYSTEM/system/etc/device_features/lavender.xml $PSYSTEM/system/etc/device_features/jasmine_sprout.xml
mv $PVENDOR/etc/device_features/lavender.xml $PVENDOR/etc/device_features/jasmine_sprout.xml


sed -i "/persist.camera.HAL3.enabled=/c\persist.camera.HAL3.enabled=1
/persist.vendor.camera.HAL3.enabled=/c\persist.vendor.camera.HAL3.enabled=1
/ro.product.model=/c\ro.product.model=Mi A2
/ro.build.id=/c\ro.build.id=MIUI 11 by Nebrassy
/persist.vendor.camera.exif.model=/c\persist.vendor.camera.exif.model=Mi A2
/ro.product.name=/c\ro.product.name=jasmine
/ro.product.device=/c\ro.product.device=jasmine_sprout
/ro.build.product=/c\ro.build.product=jasmine
/ro.product.system.device=/c\ro.product.system.device=jasmine_sprout
/ro.product.system.model=/c\ro.product.system.model=Mi A2
/ro.product.system.name=/c\ro.product.system.name=jasmine
/ro.miui.notch=/c\ro.miui.notch=0
/persist.vendor.camera.model=/c\persist.vendor.camera.model=Mi A2" $PSYSTEM/system/build.prop


sed -i "/ro.build.characteristics=/c\ro.build.characteristics=nosdcard" $PSYSTEM/system/product/build.prop


sed -i "/ro.miui.has_cust_partition=/c\ro.miui.has_cust_partition=false" $PSYSTEM/system/etc/prop.default


sed -i "/ro.product.vendor.model=/c\ro.product.vendor.model=Mi A2
/ro.product.vendor.name=/c\ro.product.vendor.name=jasmine
/ro.product.vendor.device=/c\ro.product.vendor.device=jasmine" $PVENDOR/build.prop


sed -i "/ro.product.odm.device=/c\ro.product.odm.device=jasmine_sprout
/ro.product.odm.model=/c\ro.product.odm.model=Mi A2
/ro.product.odm.device=/c\ro.product.odm.device=jasmine_sprout
/ro.product.odm.name=/c\ro.product.odm.name=jasmine" $PVENDOR/odm/etc/build.prop


rm -rf $PVENDOR/firmware
cp -Raf $SVENDOR/firmware $PVENDOR/firmware




#VENDOR
cp -Rafv $FILES/fstab.qcom $PVENDOR/etc/
chmod 644 $PVENDOR/etc/fstab.qcom
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $PVENDOR/etc/fstab.qcom
chown -hR root:root $PVENDOR/etc/fstab.qcom


cp -Rafv $SVENDOR/bin/hw/android.hardware.boot@1.0-service $PVENDOR/bin/hw/android.hardware.boot@1.0-service
cp -Rafv $SVENDOR/etc/init/android.hardware.boot@1.0-service.rc $PVENDOR/etc/init/android.hardware.boot@1.0-service.rc
cp -Rafv $SVENDOR/lib/hw/bootctrl.sdm660.so $PVENDOR/lib/hw/bootctrl.sdm660.so
cp -Rafv $SVENDOR/lib/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib/hw/android.hardware.boot@1.0-impl.so
cp -Rafv $SVENDOR/lib64/hw/bootctrl.sdm660.so $PVENDOR/lib64/hw/bootctrl.sdm660.so
cp -Rafv $SVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so



# insert this at line 58 of $PVENDOR/etc/vintf/manifest.xml
 #   <hal format="hidl">
#        <name>android.hardware.boot</name>
#        <transport>hwbinder</transport>
#        <version>1.0</version>
#        <interface>
#            <name>IBootControl</name>
#            <instance>default</instance>
#        </interface>
#        <fqname>@1.0::IBootControl/default</fqname>
#    </hal>


sed -i "58 i \    <hal format=\"hidl\">
58 i \        <name>android.hardware.boot</name>
58 i \        <transport>hwbinder</transport>
58 i \        <version>1.0</version>
58 i \        <interface>
58 i \            <name>IBootControl</name>
58 i \            <instance>default</instance>
58 i \        </interface>
58 i \        <fqname>@1.0::IBootControl/default</fqname>
58 i \    </hal>" $PVENDOR/etc/vintf/manifest.xml

#KEYMASTER
rm -f $PVENDOR/etc/init/android.hardware.keymaster@4.0-service-qti.rc
cp -af $SVENDOR/etc/init/android.hardware.keymaster@3.0-service-qti.rc $PVENDOR/etc/init/android.hardware.keymaster@3.0-service-qti.rc

sed -i "181 s/        <version>4.0<\/version>/        <version>3.0<\/version>/g
s/4.0::IKeymasterDevice/3.0::IKeymasterDevice/g" $PVENDOR/etc/vintf/manifest.xml


rm -rf $PVENDOR/etc/sensors
cp -Raf $SVENDOR/etc/sensors $PVENDOR/etc/sensors
cp -Raf $SVENDOR/etc/camera/camera_config.xml $PVENDOR/etc/camera/camera_config.xml
cp -Raf $SVENDOR/etc/camera/csidtg_camera.xml $PVENDOR/etc/camera/csidtg_camera.xml
cp -Raf $SVENDOR/etc/camera/csidtg_chromatix.xml $PVENDOR/etc/camera/camera_chromatix.xml

cp -Raf $SVENDOR/lib/libMiWatermark.so $PVENDOR/lib/libMiWatermark.so
cp -Raf $SVENDOR/lib/libdng_sdk.so $PVENDOR/lib/libdng_sdk.so
cp -Raf $SVENDOR/lib/libvidhance_gyro.so $PVENDOR/lib/libvidhance_gyro.so
cp -Raf $SVENDOR/lib/libvidhance.so $PVENDOR/lib/


cp -Rafv $FILES/camera/lib/libmmcamera* $PVENDOR/lib/
chmod 644 $PVENDOR/lib/libmmcamera*
chown -hR root:root $PVENDOR/lib/libmmcamera*
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PVENDOR/lib/libmmcamera*

cp -Rafv $FILES/camera/lib64/libmmcamera* $PVENDOR/lib64/
chmod 644 $PVENDOR/lib64/libmmcamera*
chown -hR root:root $PVENDOR/lib64/libmmcamera*
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PVENDOR/lib64/libmmcamera*

cp -Rafv $FILES/camera/lib/hw/camera.sdm660.so $PVENDOR/lib/hw/
chmod 644 $PVENDOR/lib/hw/camera.sdm660.so
chown -hR root:root $PVENDOR/lib/hw/camera.sdm660.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PVENDOR/lib/hw/camera.sdm660.so

cp -Rafv $FILES/camera/lib/camera.sdm660_shim.so $PVENDOR/lib/
chmod 644 $PVENDOR/lib/camera.sdm660_shim.so
chown root:root $PVENDOR/lib/camera.sdm660_shim.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PVENDOR/lib/camera.sdm660_shim.so


cp -Raf $SVENDOR/app/FingerprintExtensionService/FingerprintExtensionService.apk $PVENDOR/app/FingerprintExtensionService/FingerprintExtensionService.apk
cp -Raf $SVENDOR/framework/com.fingerprints.extension.jar $PVENDOR/framework/com.fingerprints.extension.jar
cp -Raf $SVENDOR/lib64/hw/fingerprint.fpc.default.so $PVENDOR/lib64/hw/fingerprint.fpc.default.so
cp -Raf $SVENDOR/lib64/hw/fingerprint.goodix.default.so $PVENDOR/lib64/hw/fingerprint.goodix.default.so
cp -Raf $SVENDOR/lib64/vendor.qti.hardware.fingerprint@1.0.so $PVENDOR/lib64/vendor.qti.hardware.fingerprint@1.0.so
cp -Raf $SVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so $PVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
cp -Raf $SVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0.so $PVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
cp -Raf $SVENDOR/lib64/com.fingerprints.extension@1.0.so $PVENDOR/lib64/com.fingerprints.extension@1.0.so
cp -Raf $SVENDOR/lib64/libgf_ca.so $PVENDOR/lib64/libgf_ca.so
cp -Raf $SVENDOR/lib64/libgf_hal.so $PVENDOR/lib64/libgf_hal.so

cp -Raf $SSYSTEM/system/usr/keylayout/uinput-fpc.kl $PSYSTEM/system/usr/keylayout/uinput-fpc.kl
cp -Raf $SSYSTEM/system/usr/idc/uinput-fpc.idc $PSYSTEM/system/usr/idc/uinput-fpc.idc
cp -Raf $SSYSTEM/system/usr/keylayout/uinput-fpc.kl $PSYSTEM/system/usr/keylayout/uinput-fpc.kl
cp -Raf $SSYSTEM/system/usr/idc/uinput-fpc.idc $PSYSTEM/system/usr/idc/uinput-fpc.idc

#GOODSEX

sed -i "477 c\        <name>vendor.goodix.hardware.fingerprint</name>" $PVENDOR/etc/vintf/manifest.xml
sed -i "479 c\        <version>1.0</version>
481 c\            <name>IGoodixBiometricsFingerprint</name>
484 c\        <fqname>@1.0::IGoodixBiometricsFingerprint/default</fqname>
485d
486d
487d
488d
489d" $PVENDOR/etc/vintf/manifest.xml


rm -rf $PSYSTEM/system/etc/firmware
cp -Raf $SSYSTEM/system/etc/firmware/* $PVENDOR/firmware/


cp -Raf $OUTP/libwifi-hal64.so $PVENDOR/lib64/libwifi-hal.so
chmod 644 $PVENDOR/lib64/libwifi-hal.so
chown -hR root:root $PVENDOR/lib64/libwifi-hal.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PVENDOR/lib64/libwifi-hal.so

cp -Raf $OUTP/libwifi-hal32.so $PVENDOR/lib/libwifi-hal.so
chmod 644 $PVENDOR/lib/libwifi-hal.so
chown -hR root:root $PVENDOR/lib/libwifi-hal.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PVENDOR/lib/libwifi-hal.so

#system/etc/device_features
sed -i "/support_dual_sd_card/c\    <bool name=\"support_dual_sd_card\">true<\/bool>
/battery_capacity_typ/c\    <string name=\"battery_capacity_typ\">3010<\/string>
/support_camera_4k_quality/c\    <bool name=\"support_camera_4k_quality\">true<\/bool>
/bool name=\"is_xiaomi\">/c\    <bool name=\"is_xiaomi\">true<\/bool>
/is_hongmi/c\    <bool name=\"is_hongmi\">false<\/bool>
/is_redmi/c\    <bool name=\"is_redmi\">false<\/bool>
/is_18x9_ratio_screen/c\    <bool name=\"is_18x9_ratio_screen\">true<\/bool>" $PSYSTEM/system/etc/device_features/jasmine_sprout.xml


#vendor/etc/device_features
sed -i "/support_dual_sd_card/c\    <bool name=\"support_dual_sd_card\">true<\/bool>
/battery_capacity_typ/c\    <string name=\"battery_capacity_typ\">3010<\/string>
/support_camera_4k_quality/c\    <bool name=\"support_camera_4k_quality\">true<\/bool>
/bool name=\"is_xiaomi\">/c\    <bool name=\"is_xiaomi\">true<\/bool>
/is_hongmi/c\    <bool name=\"is_hongmi\">false<\/bool>
/is_redmi/c\    <bool name=\"is_redmi\">false<\/bool>
/is_18x9_ratio_screen/c\    <bool name=\"is_18x9_ratio_screen\">true<\/bool>" $PVENDOR/etc/device_features/jasmine_sprout.xml


#AUDIO
rm -rf $PVENDOR/etc/acdbdata
cp -Raf $SVENDOR/etc/acdbdata $PVENDOR/etc/acdbdata


#statusbar/corner
rm -rf $PVENDOR/app/NotchOverlay
cp -Raf $FILES/overlay/DevicesOverlay.apk $PVENDOR/overlay/DevicesOverlay.apk
cp -Raf $FILES/overlay/DevicesAndroidOverlay.apk $PVENDOR/overlay/DevicesAndroidOverlay.apk
chmod 644 $PVENDOR/overlay/DevicesOverlay.apk
chmod 644 $PVENDOR/overlay/DevicesAndroidOverlay.apk
chown -hR root:root $PVENDOR/overlay/DevicesOverlay.apk
chown -hR root:root $PVENDOR/overlay/DevicesAndroidOverlay.apk
setfattr -h -n security.selinux -v u:object_r:vendor_overlay_file:s0 $PVENDOR/overlay/DevicesOverlay.apk
setfattr -h -n security.selinux -v u:object_r:vendor_overlay_file:s0 $PVENDOR/overlay/DevicesAndroidOverlay.apk

#readingmode 
cp -Raf $FILES/readingmode/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml $PVENDOR/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
cp -Raf $FILES/readingmode/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml $PVENDOR/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml
chmod 644 $PVENDOR/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
chmod 644 $PVENDOR/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml
chown -hR root:root $PVENDOR/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
chown -hR root:root $PVENDOR/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $PVENDOR/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $PVENDOR/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml


#add this to line 452 at $PVENDOR/etc/init/hw/init.qcom.rc
#    exec_background u:object_r:system_file:s0 -- /system/bin/bootctl mark-boot-successful
sed -i "452 i \    exec_background u:object_r:system_file:s0 -- /system/bin/bootctl mark-boot-successful" $PVENDOR/etc/init/hw/init.qcom.rc

sed -i "124 i \

124 i \    # Wifi firmware reload path
124 i \    chown wifi wifi /sys/module/wlan/parameters/fwpath" $PVENDOR/etc/init/hw/init.target.rc

ROMVERSION=$(grep ro.system.build.version.incremental= /mnt/systemn7/system/build.prop | sed "s/ro.system.build.version.incremental=//g"; )
PORTDATE=$(date +%d/%m/%Y)
sed -i "s%DATE%$(date +%d/%m/%Y)%g
s/ROMVERSION/$ROMVERSION/g" out/zip/META-INF/com/google/android/updater-script

umount $PSYSTEM
umount $PVENDOR
umount $SSYSTEM
umount $SVENDOR
rmdir $PSYSTEM
rmdir $PVENDOR
rmdir $SSYSTEM
rmdir $SVENDOR

e2fsck -y -f systemn7.img
resize2fs systemn7.img 786432

mv vendorn7.img $OUTP/zip/vendor_new.img
mv systemn7.img $OUTP/zip/system_new.img

cd $OUTP/zip
zip -ry $OUTP/MIUI_11_jasmine_sprout_$ROMVERSION.zip *
cd $CURRENTDIR

rm systema2.img
rm vendora2.img
