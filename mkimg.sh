#/bin/bash

LINEAGEVERSION=lineage-18.1
DATE=`date +%Y%m%d`
IMGNAME=$LINEAGEVERSION-$DATE-rpi4.img
IMGSIZE=7
OUTDIR=${ANDROID_PRODUCT_OUT:="../../../out/target/product/rpi4"}

if [ `id -u` != 0 ]; then
	echo "Must be root to run script!"
	exit
fi

SDCARD_DEV=$1

if [ -z "$SDCARD_DEV" ]; then
	if [ -f $IMGNAME ]; then
		echo "File $IMGNAME already exists!"
		rm $IMGNAME
	fi
	echo "Creating image file $IMGNAME..."
	dd if=/dev/zero of=$IMGNAME bs=1M count=$(echo "$IMGSIZE*1024" | bc)
	sync
	echo "Creating partitions..."
	(
	echo o
	echo n
	echo p
	echo 1
	echo
	echo +128M
	echo n
	echo p
	echo 2
	echo
	echo +1536M
	echo n
	echo p
	echo 3
	echo
	echo +256M
	echo n
	echo p
	echo
	echo
	echo t
	echo 1
	echo c
	echo a
	echo 1
	echo w
	) | fdisk $IMGNAME
	sync
	LOOPDEV=`kpartx -av $IMGNAME | awk 'NR==1{ sub(/p[0-9]$/, "", $3); print $3 }'`
	sync
	if [ -z "$LOOPDEV" ]; then
		echo "Unable to find loop device!"
		kpartx -d $IMGNAME
		exit
	fi
	echo "Image mounted as $LOOPDEV"
	sleep 5
	mkfs.fat -F 32 /dev/mapper/${LOOPDEV}p1 -n boot
	mkfs.ext4 /dev/mapper/${LOOPDEV}p2 -L system
	mkfs.ext4 /dev/mapper/${LOOPDEV}p3 -L vendor
	mkfs.ext4 /dev/mapper/${LOOPDEV}p4 -L userdata
	resize2fs /dev/mapper/${LOOPDEV}p4 1343228
	echo "Copying system..."
	dd if=$OUTDIR/system.img of=/dev/mapper/${LOOPDEV}p2 bs=1M
	sync
	#mount /dev/mapper/${LOOPDEV}p2 $OUTDIR/system
	#sync
	#mkdir -p $OUTDIR/system/boot
	#sync
	#umount /dev/mapper/${LOOPDEV}p2
	echo "Copying vendor..."
	dd if=$OUTDIR/vendor.img of=/dev/mapper/${LOOPDEV}p3 bs=1M
	echo "Copying boot..."
	echo "$PWD"
	mkdir -p $OUTDIR/boot
	sync
	mount /dev/mapper/${LOOPDEV}p1 $OUTDIR/boot
	sync
	mkdir -p $OUTDIR/boot/overlays
	cp boot/* $OUTDIR/boot
	cp ../../../vendor/brcm/rpi4/proprietary/boot/* $OUTDIR/boot
	cp $OUTDIR/ramdisk.img $OUTDIR/boot
	cp $OUTDIR/obj/KERNEL_OBJ/arch/arm/boot/zImage $OUTDIR/boot
	cp $OUTDIR/obj/KERNEL_OBJ/arch/arm/boot/dts/bcm2711-rpi-4-b.dtb $OUTDIR/boot
	cp $OUTDIR/obj/KERNEL_OBJ/arch/arm/boot/dts/bcm2711-rpi-400.dtb $OUTDIR/boot
	cp $OUTDIR/obj/KERNEL_OBJ/arch/arm/boot/dts/bcm2711-rpi-cm4.dtb $OUTDIR/boot
	cp $OUTDIR/obj/KERNEL_OBJ/arch/arm/boot/dts/overlays/*.dtbo $OUTDIR/boot/overlays
	cp ../../../kernel/brcm/rpi/arch/arm/boot/dts/overlays/README $OUTDIR/boot/overlays
	if [ -d ../../../vendor/konstakang ]; then
		cp ../../../vendor/konstakang/twrp/ramdisk-recovery.img $OUTDIR/boot
	fi
	sync
	umount /dev/mapper/${LOOPDEV}p1
	#rm -rf sdcard
	kpartx -d $IMGNAME
	sync
	echo "Done, created $IMGNAME!"
else
	echo "write $IMGNAME to /dev/$SDCARD_DEV !"
	dd if=$IMGNAME of=/dev/$SDCARD_DEV status=progress bs=4M
fi
#sudo dd if=lineage-18.1-20210415-rpi4.img of=/dev/sde status=progress bs=4M