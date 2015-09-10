#!/bin/sh

## Create disk image from CD/DVD-ROM using ddrescue
## or readom
##
## Store image file, log and md5 checksum
##
## Johan van der Knijff, September 2015
##
##
## Execute script as root (sudo)!

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
tries="4"

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

# Construct command line
# cdReadCommand="ddrescue -d -n -b $sectorSize $deviceName $baseName.$suffix $baseName.log"
cdReadCommand="readom retries=$tries dev=$deviceName f=$baseName.$suffix"

# Run command line
$cdReadCommand

# Exit code
readExitCode="$?"

if [ $readExitCode = 0 ] ; then
    exitOK=true
else
    exitOK=false
    echo "Error: readom exited with error!" >&2
fi

# Compute MD5 checksum on image, store to file
checksum=$(md5sum $baseName.$suffix)
echo $checksum > $baseName.$suffix."md5"

# Size of image
imageSize="$(du -b $baseName.$suffix | cut -f 1)"

# Check image size against disk size
if [ $imageSize = $diskSize ] ; then
    passedSizeCheck=true
else
    passedSizeCheck=false
    echo "Error: image size does not equal size of source medium!" >&2
fi

# Write log file (JSON format)

logFile="$baseName".json

echo "{" > $logFile
echo \""fileName"\": \"$baseName.$suffix\", >> $logFile
echo \""readCommand"\": \"$cdReadCommand\", >> $logFile
echo \""readExitCode"\": $readExitCode, >> $logFile
echo \""diskSize"\": $diskSize, >> $logFile
echo \""imageSize"\": $imageSize, >> $logFile
echo \""passedSizeCheck"\": $passedSizeCheck, >> $logFile
echo \""messageDigestAlgorithm"\": \""MD5"\", >> $logFile
echo \""messageDigest"\": \"$(echo $checksum | cut -d ' ' -f 1)\" >> $logFile
echo "}" >> $logFile


