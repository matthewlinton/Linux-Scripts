#!/bin/sh
# A simple script to automate the build process

BASEKERNEL="0.0"				# e.g 2.6
KERNELVERSION="$BASEKERNEL.0"			# e.g. gentoo-r1
EMERGEAUTO=""					# Autoload Modules
EMERGEOTHER=""					# Manual Load Modules
MOUNTBOOT="n"					# Mount /boot?
NICENESS=19

if [ $BASEKERNEL == "0.0" ] || [ $KERNELVERSION == "0.0.0" ]; then
   echo "Kernel variables not set." 1>&2
   echo "You need to set BASEKERNEL and KERNALVERSION" 1>&2
   exit 1
fi

make clean
make menuconfig

# Remove old modules
find /lib/modules/$KERNELVERSION/ -type f -iname '*.o' \
     -or -iname '*.ko' -exec rm {} \;

make && make modules_install

# Install 3rd party modules to be loaded at startup
if [ ! "$EMERGEAUTO" = "" ]; then
   emerge $EMERGEAUTO
fi

# autoload modules
find /lib/modules/$KERNELVERSION/ -type f -iname '*.o' \
     -or -iname '*.ko' -exec basename {} .ko > \
     /etc/modules.autoload.d/kernel-$BASEKERNEL \;

# Install 3rd party modules that will not be loaded at boot
if [ ! "$EMERGEOTHER" = "" ]; then
  emerge $EMERGEOTHER
fi

# Mount /boot if needed
if [ "$MOUNTBOOT" = "y" ] || [ "$MOUNTBOOT" = "Y" ]; then
   mount /boot/
   sleep 2
fi

# copy kernel files
cp /usr/src/linux/arch/i386/boot/bzImage \
   /boot/kernel-$KERNELVERSION
cp /usr/src/linux/.config /boot/config-$KERNELVERSION
cp /usr/src/linux/System.map /boot/System.map-$KERNELVERSION

# Unmount boot
if [ "$MOUNTBOOT" = "y" ] || [ "$MOUNTBOOT" = "Y" ]; then
   sleep 2
   umount /boot/
fi

echo DONE
