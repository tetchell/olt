#!/usr/bin/env bash

# Find and replace placeholders in bintray.json with real values

bintray_file="./bintray.json"
echo "before-deploy.sh - editing $bintray_file" 

date=$(date +"%F")
echo "Date is $date"
sed -i -e "s/__released__/$date/g" $bintray_file

build_tag=$TRAVIS_TAG
if [ ! -z "$TRAVIS_TAG" ]; then
    echo "Travis tag is $TRAVIS_TAG"
else
    echo "No Travis tag"
    if [ ! -z "$TRAVIS_COMMIT" ]; then
        short_commit=${TRAVIS_COMMIT:0:8}
        echo "Using commit $short_commit" 
        build_tag="$short_commit"
    else
        echo "ERROR: TRAVIS_COMMIT is empty"
    fi
fi

sed -i -e "s/__vcs_tag__/$build_tag/g" $bintray_file
upload_type=""
if [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
    upload_type="release"
else
    upload_type="personal"
fi

sed -i -e "s/__upload_type__/$upload_type/g" $bintray_file

echo "Finished updating $bintray_file"
echo "Contents:"
cat "$bintray_file"
