#!/bin/bash
set -e

echo "==== Set custom Chinese firmware version ===="

cat > package/base-files/files/etc/openwrt_release <<'EOF'
DISTRIB_ID='阿宇定制固件'
DISTRIB_RELEASE='稳定版'
DISTRIB_REVISION='ZNM2'
DISTRIB_TARGET='qualcommax/ipq60xx'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_DESCRIPTION='阿宇定制固件 兆能M2专用版'
DISTRIB_TAINTS=''
EOF

cat > package/base-files/files/etc/openwrt_version <<'EOF'
阿宇定制固件 兆能M2专用版
EOF

mkdir -p package/base-files/files/etc/uci-defaults

cat > package/base-files/files/etc/uci-defaults/99-custom-version <<'EOF'
#!/bin/sh

cat > /etc/openwrt_release <<'EOR'
DISTRIB_ID='阿宇定制固件'
DISTRIB_RELEASE='稳定版'
DISTRIB_REVISION='ZNM2'
DISTRIB_TARGET='qualcommax/ipq60xx'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_DESCRIPTION='阿宇定制固件 兆能M2专用版'
DISTRIB_TAINTS=''
EOR

echo '阿宇定制固件 兆能M2专用版' > /etc/openwrt_version

exit 0
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-custom-version
