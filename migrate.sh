#!/bin/bash

usage() {
  echo "Usage: $0 srcHost srcCreds srcProject srcRepo destHost destCreds destProject destRepo"
  echo -e "\nMigrate a git repository from one Bitbucket instance to another"
  echo -e "\nParameters:"
  echo -e "  srchost        The host and port of the source Bitbucket instance"
  echo -e "  srcCreds       The credentials to clone the source repository in the form user:password"
  echo -e "  srcProject     The source project key"
  echo -e "  srcRepo        The source repository to migrate"
  echo -e "  desthost       The host and port of the destination Bitbucket instance"
  echo -e "  destCreds      The credentials to push to the destination repository in the form user:password"
  echo -e "  destProject    The destination project key"
  echo -e "  destRepo       The destination repository name"
  exit 1
}

if [ -z "$8" ]; then
  usage
fi

srcHost="$1"
srcCreds="$2"
srcProject="$3"
srcRepo="$4"
srcPath="scm/${srcProject}/${srcRepo}.git"

destHost="$5"
destCreds="$6"
destProject="$7"
destRepo="$8"
destPath="scm/${destProject}/${destRepo}.git"

repoAlreadyExists() {

  statusCode=$(curl -u "${destCreds}" --silent --head --write-out '%{http_code}' --output /dev/null -X GET "https://${destHost}/rest/api/1.0/projects/${destProject}/repos/${destRepo}")

  if [[ "$statusCode" =~ 401 ]]; then
    echo >&2 "[ERROR]: 401 (Unauthorized)"
    exit 1
  fi

  [[ "$statusCode" =~ 200 ]] && return
}

cloneSrcRepository() {
  echo "[INFO]: Cloning source repository : https://${srcHost}/${srcPath}"
  git clone --mirror "https://${srcCreds}@${srcHost}/${srcPath}"
  cd "${srcRepo}.git" || exit
}

createDestRepo() {
  echo "[INFO]: Creating destination repository: https://${destHost}/${destPath}"
  curl -u "${destCreds}" --fail -s -o /dev/null \
    -H "Content-Type: application/json" \
    -X POST "https://${destHost}/rest/api/1.0/projects/${destProject}/repos" \
    -d "{ \"name\": \"${destRepo}\", \"scmId\": \"git\",\"forkable\": true,\"defaultBranch\": \"master\"}"
}

pushDestRepo() {
  echo "[INFO]: Push to destination repository : https://${destHost}/${destPath}"
  git push --mirror "https://${destCreds}@${destHost}/${destPath}"
}

cleanUp() {
  cd .. && rm -rf "${srcRepo}.git"
}

if repoAlreadyExists; then
  echo >&2 "[ERROR]: The repository already exists here: https://${destHost}/${destPath}"
  exit 1
fi

cloneSrcRepository
createDestRepo
pushDestRepo
cleanUp
