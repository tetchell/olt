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

build_tag=$TRAVIS_TAG
if [ ! -z "$TRAVIS_TAG" ]; then
    echo "Travis tag is $TRAVIS_TAG"
else
#    echo "No Travis tag"
    if [ ! -z "$TRAVIS_COMMIT" ]; then
        short_commit=${TRAVIS_COMMIT:0:8}
#        echo "Using commit $short_commit as tag" 
        build_tag="$short_commit"
    else
        # This will never happen in a real build
        echo "ERROR: TRAVIS_COMMIT is empty"
        build_tag=$(date +%s)
    fi
fi

#find_replace_in_file $bintray_file __vcs_tag__ $build_tag

package=""
version_tag=""
if [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
    package="olt-nightly"
    version_tag="nightly_"$(date +%Y%m%d)
else
    package="olt-ci"
    version_tag="ci_$build_tag"
fi

find_replace_in_file $bintray_file __package__ $package
find_replace_in_file $bintray_file __version__ $version_tag

echo "Finished updating $bintray_file"
echo "Contents:"
cat "$bintray_file"
