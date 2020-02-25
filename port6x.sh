 # Requires: android tools, img tools, abootimg, cpio, sdat2img, brotli
 
SVENDOR=/mnt/vendora2
SSYSTEM=/mnt/systema2
PVENDOR=/mnt/vendor6x
PSYSTEM=/mnt/system6x
CURRENTUSER=nebras30
SOURCEROM=/home/$CURRENTUSER/aicp9
SD2IMG=/home/$CURRENTUSER/dev/sdat2img.py
SCRIPTDIR=$(readlink -f "$0")
CURRENTDIR=$(dirname "$SCRIPTDIR")
FILES=$CURRENTDIR/files
PORTZIP=/home/$CURRENTUSER/dev/xiaomi.eu*
STOCKZIP=/home/$CURRENTUSER/dev/jasmine*
OUTP=$CURRENTDIR/out

mkdir $OUTP
cp -Raf $CURRENTDIR/zip $OUTP/

unzip $PORTZIP boot.img system.transfer.list vendor.transfer.list system.new.dat.br vendor.new.dat.br
tar --wildcards -xf $STOCKZIP */images/vendor.img */images/system.img
mv jasmine_global_images*/images/vendor.img vendor.img
mv jasmine_global_images*/images/system.img system.img
rm -rf jasmine_global_images*
 
 
mv boot.img 6xboot.img
simg2img system.img systema2.img
simg2img vendor.img vendora2.img
#brotli --verbose --decompress --input system.new.dat.br --output system.new.dat
brotli -j -v -d system.new.dat.br
#brotli --verbose --decompress --input vendor.new.dat.br --output vendor.new.dat
brotli -j -v -d vendor.new.dat.br
$SD2IMG system.transfer.list system.new.dat system6x.img
$SD2IMG vendor.transfer.list vendor.new.dat vendor6x.img
rm system.new.dat.br vendor.new.dat.br vendor.img system.img system.new.dat vendor.new.dat system.transfer.list vendor.transfer.list



unalias cp
mkdir $PSYSTEM
mkdir $PVENDOR
mkdir $SVENDOR
mkdir $SSYSTEM
mount -o rw,noatime system6x.img $PSYSTEM
mount -o rw,noatime vendor6x.img $PVENDOR
mount -o rw,noatime systema2.img $SSYSTEM
mount -o rw,noatime vendora2.img $SVENDOR

cd $PSYSTEM
mkdir $PSYSTEM/system
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system
chmod 755 $PSYSTEM/system
ls | grep -v system | xargs mv -t system
cd $CURRENTDIR


mkdir tmp
cp 6xboot.img tmp/
cd tmp
abootimg -x 6xboot.img
mv initrd.img initrd.gz
gunzip initrd.gz
mkdir rd
cd rd
cpio -m -i < ../initrd
cd ..
cp -Raf rd/* $PSYSTEM/
cd ..
rm -rf tmp
rm -rf $PSYSTEM/cache
cp -Rafv $SSYSTEM/cache $PSYSTEM/

chown -hR root:root $PSYSTEM/*


setfattr -h -n security.selinux -v u:object_r:cgroup:s0 $PSYSTEM/acct
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/bin
setfattr -h -n security.selinux -v u:object_r:bt_firmware_file:s0 $PSYSTEM/bt_firmware
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/bugreports
setfattr -h -n security.selinux -v u:object_r:cache_file:s0 $PSYSTEM/cache
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/charger
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/config
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/d
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/cust
setfattr -h -n security.selinux -v u:object_r:system_data_file:s0 $PSYSTEM/data
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/default.prop
setfattr -h -n security.selinux -v u:object_r:device:s0 $PSYSTEM/dev
setfattr -h -n security.selinux -v u:object_r:adsprpcd_file:s0 $PSYSTEM/dsp
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/etc
setfattr -h -n security.selinux -v u:object_r:firmware_file:s0 $PSYSTEM/firmware
setfattr -h -n security.selinux -v u:object_r:init_exec:s0 $PSYSTEM/init
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/*.rc
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/init.miui.post_boot.sh
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/lost+found
setfattr -h -n security.selinux -v u:object_r:tmpfs:s0 $PSYSTEM/mnt
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PSYSTEM/odm
setfattr -h -n security.selinux -v u:object_r:oemfs:s0 $PSYSTEM/oem
setfattr -h -n security.selinux -v u:object_r:mnt_vendor_file:s0 $PSYSTEM/persist
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/proc
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/product
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/res
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/sbin
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/sdcard
setfattr -h -n security.selinux -v u:object_r:storage_file:s0 $PSYSTEM/storage
setfattr -h -n security.selinux -v u:object_r:sysfs:s0 $PSYSTEM/sys
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PSYSTEM/vendor
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/verity_key
setfattr -h -n security.selinux -v u:object_r:vendor_app_file:s0 $PSYSTEM/odm/app
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PSYSTEM/odm/bin
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $PSYSTEM/odm/etc
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PSYSTEM/odm/firmware
setfattr -h -n security.selinux -v u:object_r:vendor_framework_file:s0 $PSYSTEM/odm/framework
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PSYSTEM/odm/lib
setfattr -h -n security.selinux -v u:object_r:vendor_file:s0 $PSYSTEM/odm/lib64
setfattr -h -n security.selinux -v u:object_r:vendor_overlay_file:s0 $PSYSTEM/odm/overlay
setfattr -h -n security.selinux -v u:object_r:vendor_app_file:s0 $PSYSTEM/odm/priv-app
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/res/images
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/res/images/charger
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/res/images/charger/*
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/sbin/*
setfattr -h -n security.selinux -v u:object_r:rootfs:s0 $PSYSTEM/init.miui.early_boot.sh

chmod 755 $PSYSTEM/acct
chmod 644 $PSYSTEM/bin
chmod 644 $PSYSTEM/bt_firmware
chmod 644 $PSYSTEM/bugreports
chmod 644 $PSYSTEM/cache
chmod 644 $PSYSTEM/charger
chmod 555 $PSYSTEM/config
chmod 644 $PSYSTEM/cust
chmod 644 $PSYSTEM/d
chmod 771 $PSYSTEM/data
chmod 600 $PSYSTEM/default.prop
chmod 755 $PSYSTEM/dev
chmod 644 $PSYSTEM/dsp
chmod 644 $PSYSTEM/etc
chmod 644 $PSYSTEM/firmware
chmod 750 $PSYSTEM/init
chmod 750 $PSYSTEM/init.environ.rc
chmod 750 $PSYSTEM/init.miui.cust.rc
chmod 750 $PSYSTEM/init.miui.early_boot.sh
chmod 750 $PSYSTEM/init.miui.post_boot.sh
chmod 750 $PSYSTEM/init.miui.google_revenue_share.rc
chmod 750 $PSYSTEM/init.miui.google_revenue_share_v2.rc
chmod 750 $PSYSTEM/init.miui.nativedebug.rc
chmod 750 $PSYSTEM/init.miui.rc
chmod 750 $PSYSTEM/init.rc
chmod 750 $PSYSTEM/init.recovery.hardware.rc
chmod 750 $PSYSTEM/init.recovery.qcom.rc
chmod 750 $PSYSTEM/init.usb.configfs.rc
chmod 750 $PSYSTEM/init.usb.rc
chmod 750 $PSYSTEM/init.zygote32.rc
chmod 750 $PSYSTEM/init.zygote64_32.rc
chmod 755 $PSYSTEM/mnt
chmod 755 $PSYSTEM/odm
chmod 644 $PSYSTEM/odm/*
chmod 755 $PSYSTEM/oem
chmod 644 $PSYSTEM/persist
chmod 755 $PSYSTEM/proc
chmod 644 $PSYSTEM/product
chmod 755 $PSYSTEM/res
chmod 755 $PSYSTEM/res/images
chmod 755 $PSYSTEM/res/images/charger
chmod 644 $PSYSTEM/res/images/charger/*
chmod -R 750 $PSYSTEM/sbin
chmod 644 $PSYSTEM/sdcard
chmod 751 $PSYSTEM/storage
chmod 755 $PSYSTEM/sys
chmod 644 $PSYSTEM/ueventd.rc
chmod 755 $PSYSTEM/vendor
chmod 644 $PSYSTEM/verity_key


#BUILD BOOT IMAGE
source $CURRENTDIR/buildbootimage.sh


#mkdir $PSYSTEM/system/addon.d
#setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/addon.d
#chmod 755 $PSYSTEM/system/addon.d

cp -Rafv $FILESbootctl $PSYSTEM/system/bin/
chmod 755 $PSYSTEM/system/bin/bootctl
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/bin/bootctl

cp -Raf $SSYSTEM/system/lib/vndk-28/android.hardware.boot@1.0.so $PSYSTEM/system/lib/vndk-28/android.hardware.boot@1.0.so
cp -Raf $SSYSTEM/system/lib64/vndk-28/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/vndk-28/android.hardware.boot@1.0.so
cp -Raf $SSYSTEM/system/lib64/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/android.hardware.boot@1.0.so

cp -Raf $SVENDOR/etc/MIUI_DualCamera_watermark.png $PVENDOR/etc/MIUI_DualCamera_watermark.png

rm -rf $PSYSTEM/system/priv-app/Updater

mv $PSYSTEM/system/etc/device_features/wayne.xml $PSYSTEM/system/etc/device_features/jasmine_sprout.xml

sed -i "/persist.camera.HAL3.enabled=/c\persist.camera.HAL3.enabled=1
/persist.vendor.camera.HAL3.enabled=/c\persist.vendor.camera.HAL3.enabled=1
/ro.product.model=/c\ro.product.model=Mi A2
/ro.build.id=/c\ro.build.id=MIUI 11 by Nebrassy
/persist.vendor.camera.exif.model=/c\persist.vendor.camera.exif.model=Mi A2
/ro.product.name=/c\ro.product.name=jasmine
/ro.product.device=/c\ro.product.device=jasmine_sprout
/ro.build.product=/c\ro.build.product=jasmine" $PSYSTEM/system/build.prop


sed -i "/ro.miui.has_cust_partition=/c\ro.miui.has_cust_partition=false" $PSYSTEM/system/etc/prop.default

sed -i "/ro.product.vendor.model=/c\ro.product.vendor.model=Mi A2
/ro.product.vendor.name=/c\ro.product.vendor.name=jasmine
/ro.product.vendor.device=/c\ro.product.vendor.device=jasmine" $PVENDOR/build.prop


#VENDOR
cp -Rafv $FILESfstab.qcom $PVENDOR/etc/
chmod 644 $PVENDOR/etc/fstab.qcom
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $PVENDOR/etc/fstab.qcom


cp -Rafv $SVENDOR/bin/hw/android.hardware.boot@1.0-service $PVENDOR/bin/hw/android.hardware.boot@1.0-service
cp -Rafv $SVENDOR/etc/init/android.hardware.boot@1.0-service.rc $PVENDOR/etc/init/android.hardware.boot@1.0-service.rc
cp -Rafv $SVENDOR/lib/hw/bootctrl.sdm660.so $PVENDOR/lib/hw/bootctrl.sdm660.so
cp -Rafv $SVENDOR/lib/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib/hw/android.hardware.boot@1.0-impl.so
cp -Rafv $SVENDOR/lib64/hw/bootctrl.sdm660.so $PVENDOR/lib64/hw/bootctrl.sdm660.so
cp -Rafv $SVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so


sed -i "42 i \    <hal format=\"hidl\">
42 i \        <name>android.hardware.boot</name>
42 i \        <transport>hwbinder</transport>
42 i \        <version>1.0</version>
42 i \        <interface>
42 i \            <name>IBootControl</name>
42 i \            <instance>default</instance>
42 i \        </interface>
42 i \        <fqname>@1.0::IBootControl/default</fqname>
42 i \    </hal>" $PVENDOR/etc/vintf/manifest.xml

sed -i "280 i \    exec_background u:object_r:system_file:s0 -- /system/bin/bootctl mark-boot-successful" $PVENDOR/etc/init/hw/init.qcom.rc


ROMVERSION=$(grep ro.system.build.version.incremental= /mnt/systemn7/system/build.prop | sed "s/ro.system.build.version.incremental=//g"; )
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


mv vendor6x.img $OUTP/zip/vendor_new.img
mv system6x.img $OUTP/zip/system_new.img

cd $OUTP/zip
zip -ry $OUTP/MIUI_11_jasmine_sprout_$ROMVERSION.zip *
cd $CURRENTDIR

rm systema2.img
rm vendora2.img
rm 6xboot.img
