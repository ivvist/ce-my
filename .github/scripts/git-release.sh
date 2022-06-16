#!/bin/bash

# Get version from tag
s='-'
ver=$tagversion
version="${ver%$s*}"
version="${version//[[:blank:]]/}"
if [[ -z "$version" ]];then
  echo "Tag verion is not defined"
  exit 1
fi

text=""
# Get pre-release flag
prever="${ver#*$s}"
prever="${prever//[[:blank:]]/}"
pr=true
if [[ ${version} == ${prever} ]];then
   pr=false
fi

cd ./.
buildsh="build.sh"
# Check if build.sh exists
if [[ ! -f ${buildsh} ]]; then	 
  echo "File build.sh does not exist."
  exit 1
fi

# Execute build.sh
sh build.sh $tagversion

builddir=".build"
# Check if new ".build" folder exists
if [[ ! -d ${builddir} ]]; then	 
  echo "Folder .build does not exists. Something wnet wrong during building."
  exit 1
fi

branch=${branchname}
repo_full_name=$(git config --get remote.origin.url | sed 's/.*:\/\/github.com\///;s/.git$//')

echo "Create release $version for repo: $repo_full_name branch: $branch"
generate_post_data()
{
  cat <<EOF
{
  "tag_name": "${version}",
  "target_commitish": "${branch}",
  "name": "${version}",
  "body": "${text}",
  "draft": false,
  "prerelease": $pr
}
EOF
}
id=$(curl -H "Accept: application/json" \
   -H "Authorization: token ${token}" \
   -d "$(generate_post_data)" \
   https://api.github.com/repos/$repo_full_name/releases | jq -r '.id')

if [[ -z ${id} ]];then
  echo "release_id is empty"
  exit 1
fi

cd $builddir
for fname in *
do
   if [[ ${fname} != "." ]];then
     echo "File $fname is uploading..."
     url="https://uploads.github.com/repos/$repo_full_name/releases/${id}/assets?name=$(basename $fname)"
     echo "url: $url"
     curl \
      -H "Authorization: token ${token}" \
      -H "Content-Type: $(file -b --mime-type $fname)" \
      --data-binary @$fname ${url}
   fi
done

echo "All files are uploaded"
