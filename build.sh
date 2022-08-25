#!/usr/bin/env bash

##############################################################
# Title          : Salesforce Dataloader                     #
# Description    : Salesforce Dataloader for Debian/Ubuntu   #
#                                                            #
# Author         : Sascha Greuel <sascha.greuel@11880.com>   #
#                                                            #
# Usage          : bash ./build.sh [--stable|--nightly]      #
##############################################################

####################
# Script arguments #
####################

while [ "$#" -gt 0 ]; do
  case "$1" in
  --stable)
    EDITION="stable"
    ;;
  --nightly | --unstable)
    EDITION="nightly"
    ;;
  *) ;;
  esac
  shift
done

if [ -z "$EDITION" ]; then
  EDITION="nightly"
fi

export DEBIAN_FRONTEND=noninteractive

####################
# Helper functions #
####################

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

getClient() {
  if command -v curl &>/dev/null; then
    CLIENT="curl"
  elif command -v wget &>/dev/null; then
    CLIENT="wget"
  elif command -v http &>/dev/null; then
    CLIENT="httpie"
  else
    echo "Error: This tool requires either curl, wget or httpie to be installed." >&2
    return 1
  fi
}

httpGet() {
  if [[ -n "${GITHUB_TOKEN}" ]]; then
    AUTHORIZATION='{"Authorization": "Bearer '"$GITHUB_TOKEN"'}"}'
  fi

  case "$CLIENT" in
  curl) curl -A curl -s -H "$AUTHORIZATION" "$@" ;;
  wget) wget -qO- --header="$AUTHORIZATION" "$@" ;;
  httpie) http -b GET "$@" "$AUTHORIZATION" ;;
  esac
}

######################
# Check requirements #
######################

# Make sure, that we are on Debian or Ubuntu
if ! command_exists apt-get; then
  echo "This script cannot run on any other system than Debian or Ubuntu."
  exit 1
fi

# Make sure, that git is installed
if ! command_exists git; then
  echo "git not found. Please install it first, and try again."
  exit 1
fi

# Make sure, that Maven is installed
if ! command_exists mvn; then
  echo "Maven not found. Please install it first, and try again."
  exit 1
fi

# Make sure, that jq is installed
if ! command_exists jq; then
  echo "jq not found. Please install it first, and try again."
  exit 1
fi

########
# Main #
########

WORK_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
HASH_FILE="$WORK_DIR/release/$EDITION/latest.hash"
PREV_HASH="master@{1day}"

# Clone dataloader and get commit information
if [ "$EDITION" = "nightly" ]; then
  git clone https://github.com/forcedotcom/dataloader.git "$WORK_DIR/dataloader-src"

  cd "$WORK_DIR/dataloader-src" || exit 1

  COMMIT_HASH=$(git rev-parse HEAD | cut -b-7)

  if test -f "$HASH_FILE"; then
    PREV_HASH=$(cat $HASH_FILE)

    if [ "$PREV_HASH" = "$COMMIT_HASH" ]; then
      exit 0
    fi
  fi
else
  if [ -z "$CLIENT" ]; then
    getClient || exit 1
  fi

  COMMIT_HASH=$(httpGet "https://api.github.com/repos/forcedotcom/dataloader/tags" | jq -r '.[0].commit | .sha' | cut -b-7)

  if test -f "$HASH_FILE"; then
    PREV_HASH=$(cat $HASH_FILE)

    if [ "$PREV_HASH" = "$COMMIT_HASH" ]; then
      exit 0
    fi
  fi
  
  git clone https://github.com/forcedotcom/dataloader.git "$WORK_DIR/dataloader-src"
  
  cd "$WORK_DIR/dataloader-src" || exit 1
  
  git checkout "$COMMIT_HASH"
fi

if [ -z "$COMMIT_HASH" ]; then
  exit 0
fi

echo "$COMMIT_HASH" >"$HASH_FILE"

# Build jar
git submodule init
git submodule update

mvn clean package -DskipTests -DtargetOS=linux_x86_64

# Build deb
NOW_TS=$(date +%s)
DATALOADER_VERSION=$(grep -oPm1 '(?<=<version>)[^<]+' "$WORK_DIR/dataloader-src/pom.xml")
DEB_FILE_NAME="apex-dataloader-$DATALOADER_VERSION-$NOW_TS-$COMMIT_HASH.deb"
DEB_FILE_PATH="$WORK_DIR/release/$EDITION/$DEB_FILE_NAME"

cp -rp "$WORK_DIR/deb-src" "$WORK_DIR/deb-tmp"
cp -rp "$WORK_DIR/dataloader-src/target/dataloader-$DATALOADER_VERSION-uber.jar" "$WORK_DIR/deb-tmp/opt/dataloader"
cp -rp "$WORK_DIR/dataloader-src/target/swtlinux_aarch64" "$WORK_DIR/deb-tmp/opt/dataloader"
cp -rp "$WORK_DIR/dataloader-src/target/swtlinux_x86_64" "$WORK_DIR/deb-tmp/opt/dataloader"

find "$WORK_DIR/deb-tmp" -type f -exec sed -i 's/@@@DATALOADER_VERSION@@@/'"$DATALOADER_VERSION"'/g' {} +
find "$WORK_DIR/deb-tmp" -type f -exec sed -i 's/@@@COMMIT_HASH@@@/'"-$COMMIT_HASH"'/g' {} +

chmod +x "$WORK_DIR/deb-tmp/opt/dataloader/*"

dpkg-deb --build --root-owner-group "$WORK_DIR/deb-tmp" "$DEB_FILE_PATH"

rm -rf "$WORK_DIR/deb-tmp"
rm -rf "$WORK_DIR/dataloader-src"

# Create info file
FILESIZE1=$(stat -c %s "$DEB_FILE_PATH")
FILESIZE2=$(echo "$FILESIZE1" | numfmt --to=iec)
NOW=$(date)
SHA256=$(sha256sum "$DEB_FILE_PATH" | cut -b-64)
SHA1=$(sha1sum "$DEB_FILE_PATH" | cut -b-40)
MD5=$(md5sum "$DEB_FILE_PATH" | cut -b-32)

cat >"$DEB_FILE_PATH.info" <<EOL
Filename: ${DEB_FILE_NAME}
Size: ${FILESIZE2} (${FILESIZE1} bytes)
Last Modified: ${NOW} (Unix time: ${NOW_TS})
SHA-256 Hash: ${SHA256}
SHA-1 Hash: ${SHA1}
MD5 Hash: ${MD5}

Diff: https://github.com/forcedotcom/dataloader/compare/${PREV_HASH}..${COMMIT_HASH}
EOL

# Update readme
if [ "$EDITION" = "nightly" ]; then
  if test -f "$WORK_DIR/README.md"; then
    REPLACEMENT1="\n\`\`\`bash\nwget https:\/\/github.com\/SoftCreatR\/dataloader-for-linux\/raw\/main\/release\/nightly\/$DEB_FILE_NAME\n\`\`\`\n"
    sed -En '1h;1!H;${g;s/(<!-- download nightly start -->)(.*)(<!-- download nightly end -->)/\1'"$REPLACEMENT1"'\3/;p;}' -i "$WORK_DIR/README.md"

    REPLACEMENT2="\n\`\`\`bash\nsudo dpkg -i $DEB_FILE_NAME\n\`\`\`\n"
    sed -En '1h;1!H;${g;s/(<!-- install nightly start -->)(.*)(<!-- install nightly end -->)/\1'"$REPLACEMENT2"'\3/;p;}' -i "$WORK_DIR/README.md"
  fi
else
  if test -f "$WORK_DIR/README.md"; then
    REPLACEMENT1="\n\`\`\`bash\nwget https:\/\/github.com\/SoftCreatR\/dataloader-for-linux\/raw\/main\/release\/stable\/$DEB_FILE_NAME\n\`\`\`\n"
    sed -En '1h;1!H;${g;s/(<!-- download stable start -->)(.*)(<!-- download stable end -->)/\1'"$REPLACEMENT1"'\3/;p;}' -i "$WORK_DIR/README.md"

    REPLACEMENT2="\n\`\`\`bash\nsudo dpkg -i $DEB_FILE_NAME\n\`\`\`\n"
    sed -En '1h;1!H;${g;s/(<!-- install stable start -->)(.*)(<!-- install stable end -->)/\1'"$REPLACEMENT2"'\3/;p;}' -i "$WORK_DIR/README.md"
  fi
fi

exit 0
