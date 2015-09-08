#!/bin/bash

# Check size of all .iso files in dir tree

checkISOScript=/home/johan/verifyISOSize/verifyISOSize/verifyISOSize.py

# Root directory
isoRoot="/home/johan/softwarevault"

# output file
fileOut="checkisos.log"

rm $fileOut

# Select all files with extension .iso

while IFS= read -d $'\0' -r file ; do
    isoName="$file"

    echo $isoName >> $fileOut
    # Run check
    python $checkISOScript $isoName >> $fileOut
    echo "*************" >> $fileOut
        
done < <(find $isoRoot -name '*.iso' -type f -print0)


