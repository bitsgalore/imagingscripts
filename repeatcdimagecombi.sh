#!/bin/bash

## Test script that repeatedly images same CD for user-specified number of times
## Tests repeated using ddrescue and readom

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

# Log files
logDdrescue="repeatddrescue.log"
logReadom="repeatreadom.log"

# write header line
echo "baseName","diskSize","imageSize","md5Sum","ddrescueExitCode" > $logDdrescue
echo "baseName","diskSize","imageSize","md5Sum","readomExitCode" > $logReadom

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
    
    baseNameRescue="$baseName""_rescue"
    baseNameReadom="$baseName""_readom"
    
    ## DDRESCUE BLOCK
    
    # Create disk image with ddrescue
    ddrescue -d -n -b $sectorSize $deviceName $baseNameRescue.$suffix $baseNameRescue.log
   
    ddrescueExitCode="$(echo $?)"

    # Compute MD5 checksum on image
    checksumRescue="$(md5sum $baseNameRescue.$suffix | cut -d ' ' -f 1)"

    # Size of image
    imageSizeRescue="$(du -b $baseNameRescue.$suffix | cut -f 1)"
    
    # Results to log file
    echo $baseNamebaseNameRescue,$diskSize,$imageSizeRescue,$checksumRescue,$ddrescueExitCode >> $logDdrescue

    ## READOM BLOCK
        
    umount $deviceName
    
    # Create disk image with readom
    readom dev=$deviceName f=$baseNameReadom.$suffix
   
    readomExitCode="$(echo $?)"
  
    # Compute MD5 checksum on image
    checksumReadom="$(md5sum $baseNameReadom.$suffix | cut -d ' ' -f 1)"

    # Size of image
    imageSizeReadom="$(du -b $baseNameReadom.$suffix | cut -f 1)"
    
    # Results to log file
    echo $baseNamebaseNameReadom,$diskSize,$imageSizeReadom,$checksumReadom,$ReadomExitCode >> $logReadom

done

