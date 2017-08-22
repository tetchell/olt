#!/usr/bin/env bash

# Find and replace placeholders in bintray.json with real values

find_replace_in_file() {
    # $1 - path to file to edit
    # $2 - string to replace
    # $3 - string to replace each occurrence of $2 with
    
    sed -i -e "s#$2#$3#g" "$1"
}


bintray_file="./bintray.json"
echo "before-deploy.sh - editing $bintray_file" 

date=$(date +%F)
#echo "Date is $date"
find_replace_in_file $bintray_file __released__ "$date"

package=""
if [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
    package="nightly"
    version_tag="$(date +%F_%H%M)"
else
    package="integration"
    version_tag="$(date +%F)"
    if [ ! -z "$TRAVIS_COMMIT" ]; then
        short_commit=${TRAVIS_COMMIT:0:8}
        # add short commit to ci builds too to prevent collision
        version_tag=$version_tag"_"$short_commit
    else
        # This will never happen in a real build, but just in case
        echo "ERROR: \$TRAVIS_COMMIT is empty; using unix time as a fallback"
        version_tag=$version_tag"_"$(date +%s)
    fi
fi

echo "Package is $package and version tag is $version_tag"

find_replace_in_file $bintray_file __package__ "$package"
find_replace_in_file $bintray_file __version__ "$version_tag"

path_to_artifacts="build/libs/"     # TODO replace this with dev/ant_build/artifacts

find_replace_in_file $bintray_file "__path_to_artifacts__" "$path_to_artifacts"

echo "Finished updating $bintray_file"
echo "Contents:"
cat "$bintray_file"

# Update info.json with the actual updatesite zip name

info_json="./info.json"
# Determine the name of the updatesite (NOT test updatesite) 
#artifact_base_name="open-wdt-update-site*"
artifact_base_name="olt*"

# Find matching file, then just get the file name (basename) 
# since everything will be in one dir once deployed on bintray
artifact_matching="$(ls $path_to_artifacts$artifact_base_name | xargs -n 1 basename)"

echo "Updatesite zip is $artifact_matching"
if [ -z "$artifact_matching" ]; then
    echo "ERROR: No file matching $path_to_artifacts$artifact_base_name was found. The updatesite is missing!"
    exit 1
fi

find_replace_in_file $info_json __driver_location__ "$artifact_matching"
# Remove below two lines later - Couplet will be responsible for doing these replacements
find_replace_in_file $info_json __tests_passed__ "99"
find_replace_in_file $info_json __total_tests__  "100"

echo "Finished updating $info_json"
echo "Contents:"
cat $info_json
