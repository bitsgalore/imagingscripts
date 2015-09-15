#!/bin/sh

## Create disk image from floppy using ddrescue
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
  echo "Usage: createfloppyimage deviceName baseName" >&2
  echo "" >&2
  echo "" >&2
  exit 1
fi

deviceName="$1"
baseName="$2"
suffix="img"
sectorSize="512"

# Construct command line
floppyReadCommand="ddrescue -d -n -b $sectorSize $deviceName $baseName.$suffix $baseName.log"

# Run command line
$floppyReadCommand

# Exit code
readExitCode="$?"

if [ $readExitCode = 0 ] ; then
    exitOK=true
else
    exitOK=false
    echo "Error: ddrescue exited with error!" >&2
fi

# Compute MD5 checksum on image, store to file
checksum=$(md5sum $baseName.$suffix)
echo $checksum > $baseName.$suffix."md5"

# From floppy extract size (in bytes)
diskSize=$(lsblk $deviceName -n -i -b -o SIZE)

# Size of image
imageSize="$(du -b $baseName.$suffix | cut -f 1)"

# Check image size against disk size
if [ $imageSize = $diskSize ] ; then
    passedSizeCheck=true
else
    passedSizeCheck=false
    echo "Error: image size does not equal size of source medium!" >&2
fi

# Verify integrity of DOS filesystem with dosfsck
#integrityCheckCommand="echo 'n' | dosfsck -t -r $baseName.$suffix > $baseName.fsc"
# echo $integrityCheckCommand
$integrityCheckCommand

# Exit code
# NOTE: even if errors were found, exit code is zero!
#integrityCheckExitCode="$?"

#if [ $integrityCheckExitCode = 0 ] ; then
#    exitOK=true
#else
#    exitOK=false
#    echo "Error: integrity check exited with error!" >&2
#fi

# Write log file (JSON format)

logFile="$baseName".json

echo "{" > $logFile
echo \""fileName"\": \"$baseName.$suffix\", >> $logFile
echo \""readCommand"\": \"$floppyReadCommand\", >> $logFile
echo \""readExitCode"\": $readExitCode, >> $logFile
echo \""ddrescueLog"\": \"$baseName.log\", >> $logFile
#echo \""integrityCheckCommand"\": \"$integrityCheckCommand\", >> $logFile
#echo \""integrityCheckExitCode"\": $integrityCheckExitCode, >> $logFile
#echo \""integrityCheckResult"\": \"$baseName.fsc\", >> $logFile
echo \""diskSize"\": $diskSize, >> $logFile
echo \""imageSize"\": $imageSize, >> $logFile
echo \""passedSizeCheck"\": $passedSizeCheck, >> $logFile
echo \""messageDigestAlgorithm"\": \""MD5"\", >> $logFile
echo \""messageDigest"\": \"$(echo $checksum | cut -d ' ' -f 1)\" >> $logFile
echo "}" >> $logFile

