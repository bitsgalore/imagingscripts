#!/bin/bash

## Iterate over all files in directory with .img extension and compute md5 hashes

while IFS= read -d $'\0' -r file ; do
    fileName="$file"
    md5Name="$fileName"."md5"
    md5sum $fileName > $md5Name
    
done < <(find . -name '*.img' -type f -print0)


