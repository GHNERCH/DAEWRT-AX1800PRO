#!/bin/bash
set -e

echo "==== Clean firmware version display ===="

cat > package/base-files/files/etc/openwrt_release <<'EOF'
DISTRIB_ID='LiBwrt'
DISTRIB_RELEASE='SNAPSHOT'
DISTRIB_REVISION='r0'
DISTRIB_TARGET='qualcommax/ipq60xx'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_DESCRIPTION='LiBwrt 稳定版'
DISTRIB_TAINTS=''
EOF

cat > package/base-files/files/etc/openwrt_version <<'EOF'
r0
EOF

# 防止某些 default-settings 后面又改回来
mkdir -p package/base-files/files/etc/uci-defaults

cat > package/base-files/files/etc/uci-defaults/99-clean-version <<'EOF'
#!/bin/sh

cat > /etc/openwrt_release <<'EOR'
DISTRIB_ID='LiBwrt'
DISTRIB_RELEASE='SNAPSHOT'
DISTRIB_REVISION='r0'
DISTRIB_TARGET='qualcommax/ipq60xx'
DISTRIB_ARCH='aarch64_cortex-a53'
DISTRIB_DESCRIPTION='LiBwrt SNAPSHOT'
DISTRIB_TAINTS=''
EOR

echo 'r0' > /etc/openwrt_version

exit 0
EOF

chmod +x package/base-files/files/etc/uci-defaults/99-clean-version
