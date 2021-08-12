#!/bin/bash

REPOS="
lcls-twincat-general
lcls-twincat-motion
lcls-twincat-optics
lcls-twincat-physics
lcls-twincat-pmps
lcls-twincat-vacuum
lcls-twincat-vacuum-serialdrivers
"

mkdir mirror

TWINCAT_ROOT=$PWD

for repo in $REPOS; do
    repo_url="https://github.com/pcdshub/$repo"
    mirror_path="$TWINCAT_ROOT/mirror/$repo"
    version_path="$TWINCAT_ROOT/$repo"
    echo ""
    echo "* Repository: $repo"
    if [ ! -d "$mirror_path" ]; then
        echo "* Mirroring for the first time"
        git clone --mirror "$repo_url" "$mirror_path"
    else
        cd "$mirror_path" || continue
        echo "* Fetching updates"
        git fetch -v --tags
    fi

    echo "* Checkout out new tags"
    TAGS=$(cd "$mirror_path" && git tag -l 'v*')

    echo "* Total tags: $(echo $TAGS | wc -l)"
    mkdir -p "$version_path"
    pushd "$version_path" || continue
    for tag in $TAGS; do
        tag_path="$version_path/$tag"
        if [ ! -d "$tag_path" ]; then
            git clone --branch "$tag" --single-branch "$mirror_path" "$tag_path"
        fi
    done
    popd
done
