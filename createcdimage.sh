#!/bin/sh

## Create disk image from CD/DVD-ROM using ddrescue
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

if [ "$#" -ne 2 ] ; then
  echo "Usage: createimage deviceName baseName" >&2
  echo "" >&2
  echo "    baseName: for cdrom use -auto to generate baseName from disc label" >&2
  echo "" >&2
  exit 1
fi

# User input
deviceName="$1"
baseNameUser="$2"

# General settings
sectorSize="2048"
suffix="iso"

# Unmount disk (probably not really needed, but just making sure)
umount $deviceName

# From disk extract label name and disk size (in bytes)
labelSizeString=$(lsblk $deviceName -n -i -b -o LABEL,SIZE)
label="$(echo $labelSizeString | cut -d ' ' -f 1)"
diskSize="$(echo $labelSizeString | cut -d ' ' -f 2)"

# Basename: user-defined value or automatic from disk label
if [ $baseNameUser = "-auto" ] ; then
    baseName=$label
    # Exit if label is empty string
    if [ -v "$label" ] ; then
        echo "Error: empty disk label, cannot use -auto!" >&2
        exit 1
    fi
else
    baseName=$baseNameUser
fi

# Create disk image
ddrescue -d -n -b $sectorSize $deviceName $baseName.$suffix $baseName.log

# Compute MD5 checksum on image, store to file
md5sum $baseName.$suffix > $baseName.$suffix."md5"

# Size of image
imageSize="$(du -b $baseName.$suffix | cut -f 1)"

# Check image size against disk size
if [ $imageSize = $diskSize ] ; then
    passedSizeCheck=true
else
    passedSizeCheck=false
    echo "Error: image size does not equal size of source medium!" >&2
fi

# Result of size check to file
echo "passedSizeCheck="$passedSizeCheck > $baseName.sizecheck.txt

