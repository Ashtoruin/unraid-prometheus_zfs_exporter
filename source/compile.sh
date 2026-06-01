DATA_DIR="/tmp"
RELEASE_DIR="$(git rev-parse --show-toplevel)/packages"

cd $DATA_DIR

# Get and extract latest release
latest=$(curl -s https://api.github.com/repos/pdf/zfs_exporter/releases/latest | jq '.assets[] | select(.name | test(".*linux-amd64.*"))')
url=$(echo $latest | jq '.browser_download_url' -r)
tarball=$(echo $latest | jq '.name' -r)
dir=${tarball/%$".tar.gz"}
wget -O $tarball $url
tar -xzf $tarball

# Build release
RELEASE="prometheus_zfs_exporter-$(date +'%Y.%m.%d')"

# Insert ZFS exporter
mkdir -p "$RELEASE/usr/bin"
cp $dir/zfs_exporter $RELEASE/usr/bin/prometheus_zfs_exporter

# compress release
tar -czf $RELEASE_DIR/$RELEASE.tgz -C $RELEASE .
md5sum $RELEASE_DIR/$RELEASE.tgz | awk '{print $1}' > $RELEASE_DIR/$RELEASE.tgz.md5
