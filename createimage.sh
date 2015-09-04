#!/bin/sh

## Create disk image from CD/DVD-ROM or floppy using ddrescue
## Store image file, ddrescue log and md5 checksum
##
## Johan van der Knijff, September 2015
##
## NOTE: if you get this message:
##
##    ddrescue: Can't open input file: Permission denied
##
## Then try to execute the script as root (sudo).

# Check command line args

if [ "$#" -ne 3 ] ; then
  echo "Usage: createimage deviceName mediaType baseName" >&2
  echo "" >&2
  echo "    mediaType: floppy or cdrom" >&2
  echo "" >&2
  exit 1
fi

deviceName="$1"
mediaType="$2"
baseName="$3"

if [ $mediaType = "floppy" ] ; then
  sectorSize="512"
  suffix="img"
elif [ $mediaType = "cdrom" ] ; then
  sectorSize="2048"
  suffix="iso"
else
  echo "Error: mediaType must be floppy or cdrom!" >&2
  exit 1
fi

# Create disk image

ddrescue -d -n -b $sectorSize $deviceName $baseName.$suffix $baseName.log

# Compute MD5 checksum on image, store to file

md5sum $baseName.$suffix > $baseName.$suffix."md5"


