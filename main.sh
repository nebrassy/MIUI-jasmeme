
SVENDOR=/mnt/vendora2
SSYSTEM=/mnt/systema2
PVENDOR=/mnt/vendorport
PSYSTEM=/mnt/systemport
CURRENTUSER=$4
SOURCEROM=$3
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
FILES=$CURRENTDIR/files
PORTZIP=$1
STOCKTAR=$2
OUTP=$CURRENTDIR/out
TOOLS=$CURRENTDIR/tools

rm -rf $OUTP
mkdir $OUTP
chown $CURRENTUSER:$CURRENTUSER $OUTP
cp -Raf $CURRENTDIR/zip $OUTP/

unzip -d $OUTP $PORTZIP system.transfer.list vendor.transfer.list system.new.dat.br vendor.new.dat.br
tar --wildcards -xf $STOCKTAR */images/vendor.img */images/system.img
mv jasmine_global_images*/images/vendor.img $OUTP/vendor.img
mv jasmine_global_images*/images/system.img $OUTP/system.img
rm -rf jasmine_global_images*
 
 
simg2img $OUTP/system.img $OUTP/systema2.img
simg2img $OUTP/vendor.img $OUTP/vendora2.img

brotli -j -v -d $OUTP/system.new.dat.br -o $OUTP/system.new.dat
brotli -j -v -d $OUTP/vendor.new.dat.br -o $OUTP/vendor.new.dat
$TOOLS/sdat2img/sdat2img.py $OUTP/system.transfer.list $OUTP/system.new.dat $OUTP/systemport.img
$TOOLS/sdat2img/sdat2img.py $OUTP/vendor.transfer.list $OUTP/vendor.new.dat $OUTP/vendorport.img
rm $OUTP/system.new.dat.br $OUTP/vendor.new.dat.br $OUTP/vendor.img $OUTP/system.img $OUTP/system.new.dat $OUTP/vendor.new.dat $OUTP/system.transfer.list $OUTP/vendor.transfer.list


unalias cp
mkdir $PSYSTEM
mkdir $PVENDOR
mkdir $SVENDOR
mkdir $SSYSTEM
mount -o rw,noatime $OUTP/systemport.img $PSYSTEM
mount -o rw,noatime $OUTP/vendorport.img $PVENDOR
mount -o rw,noatime $OUTP/systema2.img $SSYSTEM
mount -o rw,noatime $OUTP/vendora2.img $SVENDOR


#BUILD BOOT IMAGE
PATCHDATE=$(sudo grep ro.build.version.security_patch= $PSYSTEM/system/build.prop | sed "s/ro.build.version.security_patch=//g"; )
if [[ -z $PATCHDATE ]]
then
echo "failed to find security patch date, aborting" && exit
fi
su -c "$CURRENTDIR/buildbootimage.sh $PATCHDATE $SOURCEROM $OUTP $CURRENTDIR" $CURRENTUSER

rm -rf $PSYSTEM/cache
cp -af $SSYSTEM/cache $PSYSTEM/

mkdir $PSYSTEM/system/addon.d
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/addon.d
chmod 755 $PSYSTEM/system/addon.d

cp -f $FILES/bootctl $PSYSTEM/system/bin/
chmod 755 $PSYSTEM/system/bin/bootctl
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/bin/bootctl

cp -af $SSYSTEM/system/lib/vndk-29/android.hardware.boot@1.0.so $PSYSTEM/system/lib/vndk-29/android.hardware.boot@1.0.so
cp -af $SSYSTEM/system/lib64/vndk-29/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/vndk-29/android.hardware.boot@1.0.so
cp -af $SSYSTEM/system/lib64/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/android.hardware.boot@1.0.so

cp -af $SVENDOR/etc/MIUI_DualCamera_watermark.png $PVENDOR/etc/MIUI_DualCamera_watermark.png

rm -rf $PSYSTEM/system/priv-app/Updater

mv $PSYSTEM/system/etc/device_features/lavender.xml $PSYSTEM/system/etc/device_features/jasmine_sprout.xml
mv $PVENDOR/etc/device_features/lavender.xml $PVENDOR/etc/device_features/jasmine_sprout.xml


sed -i "/persist.camera.HAL3.enabled=/c\persist.camera.HAL3.enabled=1
/persist.vendor.camera.HAL3.enabled=/c\persist.vendor.camera.HAL3.enabled=1
/ro.product.model=/c\ro.product.model=Mi A2
/ro.build.id=/c\ro.build.id=MIUI 12 by Nebrassy
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
cp -f $FILES/fstab.qcom $PVENDOR/etc/
chmod 644 $PVENDOR/etc/fstab.qcom
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $PVENDOR/etc/fstab.qcom
chown -hR root:root $PVENDOR/etc/fstab.qcom


cp -af $SVENDOR/bin/hw/android.hardware.boot@1.0-service $PVENDOR/bin/hw/android.hardware.boot@1.0-service
cp -af $SVENDOR/etc/init/android.hardware.boot@1.0-service.rc $PVENDOR/etc/init/android.hardware.boot@1.0-service.rc
cp -af $SVENDOR/lib/hw/bootctrl.sdm660.so $PVENDOR/lib/hw/bootctrl.sdm660.so
cp -af $SVENDOR/lib/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib/hw/android.hardware.boot@1.0-impl.so
cp -af $SVENDOR/lib64/hw/bootctrl.sdm660.so $PVENDOR/lib64/hw/bootctrl.sdm660.so
cp -af $SVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so


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
cp -af $SVENDOR/etc/camera/camera_config.xml $PVENDOR/etc/camera/camera_config.xml
cp -af $SVENDOR/etc/camera/csidtg_camera.xml $PVENDOR/etc/camera/csidtg_camera.xml
cp -af $SVENDOR/etc/camera/csidtg_chromatix.xml $PVENDOR/etc/camera/camera_chromatix.xml

cp -af $SVENDOR/lib/libMiWatermark.so $PVENDOR/lib/libMiWatermark.so
cp -af $SVENDOR/lib/libdng_sdk.so $PVENDOR/lib/libdng_sdk.so
cp -af $SVENDOR/lib/libvidhance_gyro.so $PVENDOR/lib/libvidhance_gyro.so
cp -af $SVENDOR/lib/libvidhance.so $PVENDOR/lib/


cp -af $SVENDOR/lib/libmmcamera* $PVENDOR/lib/

cp -af $SVENDOR/lib64/libmmcamera* $PVENDOR/lib64/

cp -f $SVENDOR/lib/hw/camera.sdm660.so $PVENDOR/lib/hw/


#BOOTANIMATION
cp -f $FILES/bootanimation.zip $PSYSTEM/system/media/bootanimation.zip
chmod 644 $PSYSTEM/system/media/bootanimation.zip
chown root:root $PSYSTEM/system/media/bootanimation.zip
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/media/bootanimation.zip

cp -af $SVENDOR/app/FingerprintExtensionService/FingerprintExtensionService.apk $PVENDOR/app/FingerprintExtensionService/FingerprintExtensionService.apk
cp -af $SVENDOR/framework/com.fingerprints.extension.jar $PVENDOR/framework/com.fingerprints.extension.jar
cp -af $SVENDOR/lib64/hw/fingerprint.fpc.default.so $PVENDOR/lib64/hw/fingerprint.fpc.default.so
cp -af $SVENDOR/lib64/hw/fingerprint.goodix.default.so $PVENDOR/lib64/hw/fingerprint.goodix.default.so
cp -af $SVENDOR/lib64/vendor.qti.hardware.fingerprint@1.0.so $PVENDOR/lib64/vendor.qti.hardware.fingerprint@1.0.so
cp -af $SVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so $PVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
cp -af $SVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0.so $PVENDOR/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
cp -af $SVENDOR/lib64/com.fingerprints.extension@1.0.so $PVENDOR/lib64/com.fingerprints.extension@1.0.so
cp -af $SVENDOR/lib64/libgf_ca.so $PVENDOR/lib64/libgf_ca.so
cp -af $SVENDOR/lib64/libgf_hal.so $PVENDOR/lib64/libgf_hal.so

cp -af $SSYSTEM/system/usr/keylayout/uinput-fpc.kl $PSYSTEM/system/usr/keylayout/uinput-fpc.kl
cp -af $SSYSTEM/system/usr/idc/uinput-fpc.idc $PSYSTEM/system/usr/idc/uinput-fpc.idc
cp -af $SSYSTEM/system/usr/keylayout/uinput-fpc.kl $PSYSTEM/system/usr/keylayout/uinput-fpc.kl
cp -af $SSYSTEM/system/usr/idc/uinput-fpc.idc $PSYSTEM/system/usr/idc/uinput-fpc.idc

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


cp -f $OUTP/libwifi-hal64.so $PVENDOR/lib64/libwifi-hal.so
chmod 644 $PVENDOR/lib64/libwifi-hal.so
chown -hR root:root $PVENDOR/lib64/libwifi-hal.so
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PVENDOR/lib64/libwifi-hal.so

cp -f $OUTP/libwifi-hal32.so $PVENDOR/lib/libwifi-hal.so
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
cp -f $FILES/overlay/DevicesOverlay.apk $PVENDOR/overlay/DevicesOverlay.apk
cp -f $FILES/overlay/DevicesAndroidOverlay.apk $PVENDOR/overlay/DevicesAndroidOverlay.apk
chmod 644 $PVENDOR/overlay/DevicesOverlay.apk
chmod 644 $PVENDOR/overlay/DevicesAndroidOverlay.apk
chown -hR root:root $PVENDOR/overlay/DevicesOverlay.apk
chown -hR root:root $PVENDOR/overlay/DevicesAndroidOverlay.apk
setfattr -h -n security.selinux -v u:object_r:vendor_overlay_file:s0 $PVENDOR/overlay/DevicesOverlay.apk
setfattr -h -n security.selinux -v u:object_r:vendor_overlay_file:s0 $PVENDOR/overlay/DevicesAndroidOverlay.apk

#readingmode 
cp -f $FILES/readingmode/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml $PVENDOR/etc/qdcm_calib_data_jdi_nt36672_fhd_video_mode_dsi_panel.xml
cp -f $FILES/readingmode/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml $PVENDOR/etc/qdcm_calib_data_tianma_nt36672_fhd_video_mode_dsi_panel.xml
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
124 i \    chown wifi wifi /sys/module/wlan/parameters/fwpath
124 i \

124 i \    # DT2W node
124 i \    chmod 0660 /sys/touchpanel/double_tap
124 i \    chown system system /sys/touchpanel/double_tap" $PVENDOR/etc/init/hw/init.target.rc

ROMVERSION=$(grep ro.system.build.version.incremental= $PSYSTEM/system/build.prop | sed "s/ro.system.build.version.incremental=//g"; )
sed -i "s%DATE%$(date +%d/%m/%Y)%g
s/ROMVERSION/$ROMVERSION/g" $OUTP/zip/META-INF/com/google/android/updater-script

umount $PSYSTEM
umount $PVENDOR
umount $SSYSTEM
umount $SVENDOR
rmdir $PSYSTEM
rmdir $PVENDOR
rmdir $SSYSTEM
rmdir $SVENDOR

e2fsck -y -f $OUTP/systemport.img
resize2fs $OUTP/systemport.img 786432


img2simg $OUTP/systemport.img $OUTP/sparsesystem.img
rm $OUTP/systemport.img
$TOOLS/img2sdat/img2sdat.py -v 4 -o $OUTP/zip -p system $OUTP/sparsesystem.img
rm $OUTP/sparsesystem.img
img2simg $OUTP/vendorport.img $OUTP/sparsevendor.img
rm $OUTP/vendorport.img
$TOOLS/img2sdat/img2sdat.py -v 4 -o $OUTP/zip -p vendor $OUTP/sparsevendor.img
rm $OUTP/sparsevendor.img
brotli -j -v -q 6 $OUTP/zip/system.new.dat
brotli -j -v -q 6 $OUTP/zip/vendor.new.dat

cd $OUTP/zip
zip -ry $OUTP/10_MIUI_12_jasmine_sprout_$ROMVERSION.zip *
cd $CURRENTDIR
rm -rf $OUTP/zip
chown -hR $CURRENTUSER:$CURRENTUSER $OUTP

rm $OUTP/systema2.img
rm $OUTP/vendora2.img
