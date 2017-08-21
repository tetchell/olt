#!/usr/bin/env bash

echo "after-deploy.sh"

# If this is a nightly build, tag it on github, and update master with the state of integration
if [ "$TRAVIS_EVENT_TYPE" = "cron" ]; then
    REMOTE_NAME="origin"
    MASTER_BRANCH="master"

    tag="nightly-$(date +%F_%H%M)"
    git tag "$tag"
    git push "$REMOTE_NAME" --tags
    echo "Created tag $tag at $TRAVIS_COMMIT"
    
    echo "Merging $TRAVIS_BRANCH into $MASTER_BRANCH"

	# Since Travis does a partial checkout, we need to get the whole thing. Clone the repo into a tmp directory 
    repo_url="https://github.com/$TRAVIS_REPO_SLUG.git"
    echo "Repository is $repo_url"
	repo_temp=$(mktemp -d)
	git clone "$repo_url" "$repo_temp"

	cd "$repo_temp"

    if [ $(pwd) != "$repo_temp" ]; then
        echo "Working directory was not changed to $repo_temp, this means the clone failed."
        echo "Merging $TRAVIS_BRANCH into $MASTER_BRANCH failed."
    else
        git checkout "$MASTER_BRANCH"

        echo "Commits in $TRAVIS_BRANCH but not $MASTER_BRANCH: "
        git log $REMOTE_NAME/$MASTER_BRANCH..$REMOTE_NAME/$TRAVIS_BRANCH

        git merge --ff-only $REMOTE_NAME/$TRAVIS_BRANCH

        echo "Pushing to $repo_url/$MASTER_BRANCH"
    
        git push $REMOTE_NAME $MASTER_BRANCH
    fi
else
    echo "Skipping tagging and updating master; this is not a push build"
fi
