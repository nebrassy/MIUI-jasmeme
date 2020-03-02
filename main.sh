
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

mkdir $OUTP
cp -Raf $CURRENTDIR/zip $OUTP/

unzip -d $OUTP $PORTZIP boot.img system.transfer.list vendor.transfer.list system.new.dat.br vendor.new.dat.br
tar --wildcards -xf $STOCKTAR */images/vendor.img */images/system.img
mv jasmine_global_images*/images/vendor.img $OUTP/vendor.img
mv jasmine_global_images*/images/system.img $OUTP/system.img
rm -rf jasmine_global_images*
 
 
mv $OUTP/boot.img $OUTP/bootport.img
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

cd $PSYSTEM
mkdir $PSYSTEM/system
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system
chmod 755 $PSYSTEM/system
ls | grep -v system | xargs mv -t system
cd $CURRENTDIR


mkdir $OUTP/tmp
cp $OUTP/bootport.img $OUTP/tmp/
cd $OUTP/tmp
abootimg -x bootport.img
mv initrd.img initrd.gz
gunzip initrd.gz
mkdir rd
cd rd
cpio -m -i < ../initrd
cd ..
cp -Raf rd/* $PSYSTEM/
cd $CURRENTDIR
rm -rf $OUTP/tmp
rm -rf $PSYSTEM/cache
cp -af $SSYSTEM/cache $PSYSTEM/

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
PATCHDATE=$(sudo grep ro.build.version.security_patch= $PSYSTEM/system/build.prop | sed "s/ro.build.version.security_patch=//g"; )
if [[ -z $PATCHDATE ]]
then
echo "failed to find security patch date, aborting" && exit
fi
su -c "$CURRENTDIR/buildbootimage.sh $PATCHDATE $SOURCEROM $OUTP $CURRENTDIR" $CURRENTUSER

mkdir $PSYSTEM/system/addon.d
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/addon.d
chmod 755 $PSYSTEM/system/addon.d

cp -f $FILES/bootctl $PSYSTEM/system/bin/
chmod 755 $PSYSTEM/system/bin/bootctl
setfattr -h -n security.selinux -v u:object_r:system_file:s0 $PSYSTEM/system/bin/bootctl

cp -af $SSYSTEM/system/lib/vndk-28/android.hardware.boot@1.0.so $PSYSTEM/system/lib/vndk-28/android.hardware.boot@1.0.so
cp -af $SSYSTEM/system/lib64/vndk-28/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/vndk-28/android.hardware.boot@1.0.so
cp -af $SSYSTEM/system/lib64/android.hardware.boot@1.0.so $PSYSTEM/system/lib64/android.hardware.boot@1.0.so

cp -af $SVENDOR/etc/MIUI_DualCamera_watermark.png $PVENDOR/etc/MIUI_DualCamera_watermark.png

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
cp -f $FILES/fstab.qcom $PVENDOR/etc/
chmod 644 $PVENDOR/etc/fstab.qcom
setfattr -h -n security.selinux -v u:object_r:vendor_configs_file:s0 $PVENDOR/etc/fstab.qcom


cp -af $SVENDOR/bin/hw/android.hardware.boot@1.0-service $PVENDOR/bin/hw/android.hardware.boot@1.0-service
cp -af $SVENDOR/etc/init/android.hardware.boot@1.0-service.rc $PVENDOR/etc/init/android.hardware.boot@1.0-service.rc
cp -af $SVENDOR/lib/hw/bootctrl.sdm660.so $PVENDOR/lib/hw/bootctrl.sdm660.so
cp -af $SVENDOR/lib/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib/hw/android.hardware.boot@1.0-impl.so
cp -af $SVENDOR/lib64/hw/bootctrl.sdm660.so $PVENDOR/lib64/hw/bootctrl.sdm660.so
cp -af $SVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so $PVENDOR/lib64/hw/android.hardware.boot@1.0-impl.so


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


ROMVERSION=$(grep ro.build.version.incremental= $PSYSTEM/system/build.prop | sed "s/ro.build.version.incremental=//g"; )
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
zip -ry $OUTP/MIUI_11_jasmine_sprout_$ROMVERSION.zip *
cd $CURRENTDIR
rm -rf $OUTP/zip
chown -hR $CURRENTUSER:$CURRENTUSER $OUTP

rm $OUTP/systema2.img
rm $OUTP/vendora2.img
rm $OUTP/bootport.img
