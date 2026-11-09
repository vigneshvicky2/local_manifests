#!/bin/bash
# PenguinOS (Android 17) for POCO X7 Pro (rodin) - runs on a crave.io build node.
# Usage (from your crave clone dir):
#   crave run --no-patch -- "curl -fsSL https://raw.githubusercontent.com/vigneshvicky2/local_manifests/penguin/crave-build.sh | bash"

# 1. ROM manifest + our local manifest
rm -rf .repo/local_manifests
repo init -u https://github.com/Project-PenguinOS/manifest -b celerity --git-lfs --depth=1 || exit 1
git clone --depth 1 -b penguin https://github.com/vigneshvicky2/local_manifests .repo/local_manifests || exit 1

# 2. Sync (crave's resync handles conflicts left by the base project)
/opt/crave/resync.sh || exit 1

# 3. Device source patches (git am needs an identity)
git config --global user.name  "${GIT_NAME:-rodin-builder}"
git config --global user.email "${GIT_EMAIL:-rodin-builder@users.noreply.github.com}"
bash device/xiaomi/rodin/apply_source_patches.sh 2>&1 | tee patches.log
echo ">>> Check patches.log: lines with 'Failed' mean that patch must be fixed by hand."

# 4. Build  (-l = vanilla/no GMS; drop it for a GMS build)
export BUILD_USERNAME=vignesh BUILD_HOSTNAME=crave
./rom-build.sh rodin ${ROM_FLAGS:--l} 2>&1 | tee build.log
exit ${PIPESTATUS[0]}
