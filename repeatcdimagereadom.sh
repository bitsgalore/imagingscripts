#!/bin/bash

## Test script that repeatedly images same CD for user-specified number of times
## This version uses readom

if [ "$#" -ne 1 ] ; then
  echo "Usage: repeatcdimage deviceName" >&2
  echo "" >&2
  exit 1
fi

# User input
deviceName="$1"
numberOfRuns=$2

# General settings
sectorSize="2048"
suffix="iso"

# Log file
logFile="repeatcdimage.log"

# write header line
echo "baseName","diskSize","imageSize","md5Sum","readomExitCode" > $logFile

for i in {1..3}; 
do
    echo $i
    # Unmount disk (probably not really needed, but just making sure)
    umount $deviceName

    # From disk extract label name and disk size (in bytes)
    labelSizeString=$(lsblk $deviceName -n -i -b -o LABEL,SIZE)
    label="$(echo $labelSizeString | cut -d ' ' -f 1)"
    diskSize="$(echo $labelSizeString | cut -d ' ' -f 2)"

    baseName="$label"_"$i"
    # Exit if label is empty string
    if [ -v "$label" ] ; then
        echo "Error: empty disk label, cannot use -auto!" >&2
        exit 1
    fi
    echo $baseName

    # Create disk image
    readom dev=$deviceName f=$baseName.$suffix
   
    readomExitCode="$(echo $?)"

    # Compute MD5 checksum on image
    checksum="$(md5sum $baseName.$suffix | cut -d ' ' -f 1)"

    # Size of image
    imageSize="$(du -b $baseName.$suffix | cut -f 1)"
    
    # Results to log file
    echo $baseName,$diskSize,$imageSize,$checksum,$readomExitCode >> $logFile
done



