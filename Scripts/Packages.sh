#!/bin/bash
set -e

#=================================================
# Packages.sh - ZN M2 精简插件源
# 修复：
# 1. 防止 luci-app-dae 误删 luci-app-daed
# 2. 改用可访问的 laipeng668/luci-app-gecoosac
# 3. 保留 DAED 面板 + DAE 核心
#=================================================

UPDATE_PACKAGE() {
    local PKG_NAME="$1"
    local PKG_REPO="$2"
    local PKG_BRANCH="$3"
    local PKG_SPECIAL="${4:-}"
    local PKG_EXTRA_NAMES="${5:-}"
    local REPO_NAME="${PKG_REPO#*/}"

    echo ""
    echo "==== Update package: ${PKG_NAME} from ${PKG_REPO} branch ${PKG_BRANCH} ===="

    rm -rf "/tmp/${REPO_NAME}" "/tmp/${PKG_NAME}"
    git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/${PKG_REPO}.git" "/tmp/${REPO_NAME}"

    if [ "$PKG_SPECIAL" = "pkg" ]; then
        find "/tmp/${REPO_NAME}" -maxdepth 4 -type d -name "$PKG_NAME" -prune -exec cp -rf {} ./ \;
        rm -rf "/tmp/${REPO_NAME}"
    elif [ "$PKG_SPECIAL" = "name" ]; then
        rm -rf "./${PKG_NAME}"
        mv -f "/tmp/${REPO_NAME}" "./${PKG_NAME}"
    else
        rm -rf "./${REPO_NAME}"
        cp -rf "/tmp/${REPO_NAME}" "./${REPO_NAME}"
        rm -rf "/tmp/${REPO_NAME}"
    fi

    if [ -n "$PKG_EXTRA_NAMES" ]; then
        echo "Extra names: $PKG_EXTRA_NAMES"
    fi
}

echo ""
echo "==== Current package dir ===="
pwd

#=================================================
# 先清理 feeds 里可能冲突的旧包
# 注意：只清理 feeds，不清理 ./ 当前 package 目录里的新包
#=================================================
echo ""
echo "==== Remove old/conflict packages from feeds only ===="

rm -rf ../feeds/luci/applications/luci-app-daed
rm -rf ../feeds/luci/applications/luci-app-dae
rm -rf ../feeds/packages/net/daed
rm -rf ../feeds/packages/net/dae

rm -rf ../feeds/luci/applications/luci-app-mosdns
rm -rf ../feeds/packages/net/mosdns
rm -rf ../feeds/packages/utils/v2dat

rm -rf ../feeds/luci/applications/luci-app-passwall*
rm -rf ../feeds/luci/applications/luci-app-bypass*
rm -rf ../feeds/luci/applications/luci-app-openclash
rm -rf ../feeds/luci/applications/luci-app-homeproxy
rm -rf ../feeds/luci/applications/luci-app-nikki
rm -rf ../feeds/luci/applications/luci-app-momo
rm -rf ../feeds/luci/applications/luci-app-dockerman

#=================================================
# 主题：Aurora
#=================================================
UPDATE_PACKAGE "luci-theme-aurora" "eamonxg/luci-theme-aurora" "master" "name"
UPDATE_PACKAGE "luci-app-aurora-config" "eamonxg/luci-app-aurora-config" "master" "name"

#=================================================
# DAED / DAE
# 重点：
# 只克隆 luci-app-daed，不再单独克隆 luci-app-dae
# 因为 luci-app-dae 会模糊匹配误删 luci-app-daed
# luci-app-daed 仓库内通常包含 daed / dae 相关包
#=================================================
UPDATE_PACKAGE "luci-app-daed" "QiuSimons/luci-app-daed" "kix" "name"

#=================================================
# Lucky
#=================================================
UPDATE_PACKAGE "luci-app-lucky" "gdy666/luci-app-lucky" "main" "name"

#=================================================
# GecoOS AC
# 使用可访问仓库：laipeng668/luci-app-gecoosac
#=================================================
UPDATE_PACKAGE "luci-app-gecoosac" "laipeng668/luci-app-gecoosac" "main" "name"

#=================================================
# 可选补充插件包
#=================================================
UPDATE_PACKAGE "viking-packages" "VIKINGYFY/packages" "main" "name"

#=================================================
# 修复 coremark Makefile
#=================================================
if [ -f "../feeds/packages/utils/coremark/Makefile" ]; then
    sed -i 's/mkdir \$(PKG_BUILD_DIR)\/\$(ARCH)/mkdir -p \$(PKG_BUILD_DIR)\/\$(ARCH)/g' ../feeds/packages/utils/coremark/Makefile
fi

#=================================================
# 显示 DAED / GecoOSAC / Lucky 是否存在
#=================================================
echo ""
echo "==== Check packages in package dir ===="
find ./ -maxdepth 5 -type d \( \
    -name "luci-app-daed" -o \
    -name "daed" -o \
    -name "dae" -o \
    -name "luci-app-lucky" -o \
    -name "lucky" -o \
    -name "luci-app-gecoosac" -o \
    -name "gecoosac" \
\) -print || true

echo ""
echo "==== Check package Makefiles ===="
find ./ -maxdepth 5 -type f -path "*/Makefile" | while read -r mf; do
    if grep -qE "Package/(luci-app-daed|daed|dae|luci-app-lucky|lucky|luci-app-gecoosac|gecoosac)" "$mf"; then
        echo "$mf"
        grep -E "Package/(luci-app-daed|daed|dae|luci-app-lucky|lucky|luci-app-gecoosac|gecoosac)" "$mf" || true
    fi
done

echo ""
echo "==== Packages.sh done ===="
