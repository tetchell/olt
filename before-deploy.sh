#!/usr/bin/env bash

# Find and replace placeholders in bintray.json with real values

find_replace_in_file() {
    # $1 - path to file to edit
    # $2 - string to replace
    # $3 - string to replace each occurrence of $2 with
    
    sed -i -e "s/$2/$3/g" $1
}


bintray_file="./bintray.json"
echo "before-deploy.sh - editing $bintray_file" 

date=$(date +%F)
#echo "Date is $date"
find_replace_in_file $bintray_file __released__ $date

short_commit=${TRAVIS_COMMIT:0:8}

package=""
version_tag="$(date +%F_%H%M)"
if [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
    package="olt-nightly"
else
    package="olt-ci"
    # add short commit to ci builds too to prevent collision
    version_tag=$version_tag_$short_commit
fi

find_replace_in_file $bintray_file __package__ $package
find_replace_in_file $bintray_file __version__ $version_tag

echo "Finished updating $bintray_file"
echo "Contents:"
cat "$bintray_file"
