#!/bin/bash

#=================================================
# 安装和更新软件包
#=================================================

UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4
    local PKG_LIST=("$PKG_NAME" $5)
    local REPO_NAME=${PKG_REPO#*/}

    echo " "
    echo "==== Update package: $PKG_NAME from $PKG_REPO branch $PKG_BRANCH ===="

    for NAME in "${PKG_LIST[@]}"; do
        echo "Search directory: $NAME"
        local FOUND_DIRS
        FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ ./ -maxdepth 4 -type d -iname "*$NAME*" 2>/dev/null || true)

        if [ -n "$FOUND_DIRS" ]; then
            while read -r DIR; do
                [ -n "$DIR" ] && rm -rf "$DIR" && echo "Delete directory: $DIR"
            done <<< "$FOUND_DIRS"
        else
            echo "Not found directory: $NAME"
        fi
    done

    git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"

    if [[ $PKG_SPECIAL == "pkg" ]]; then
        find ./"$REPO_NAME"/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
        rm -rf ./"$REPO_NAME"/
    elif [[ $PKG_SPECIAL == "name" ]]; then
        mv -f "$REPO_NAME" "$PKG_NAME"
    fi
}

#=================================================
# 主题：Aurora
#=================================================
UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master"
UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master"

#=================================================
# DAED / DAE
# 重要：daed 面板需要 luci-app-daed + daed + dae
#=================================================
UPDATE_PACKAGE "luci-app-daed" "QiuSimons/luci-app-daed" "kix"
UPDATE_PACKAGE "luci-app-dae" "QiuSimons/luci-app-dae" "kix"

#=================================================
# Lucky
#=================================================
UPDATE_PACKAGE "lucky" "gdy666/luci-app-lucky" "main"

#=================================================
# GecoOS AC
#=================================================
UPDATE_PACKAGE "gecoosac" "lwb1978/openwrt-gecoosac" "main"

#=================================================
# 可选：VIKINGYFY packages
# 这里只用于补充 wol/timewol 之类，不强制启用
#=================================================
UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "luci-app-timewol luci-app-wolplus"

#=================================================
# 清理重复/冲突包
#=================================================
echo " "
echo "==== Remove duplicate/conflict packages ===="

rm -rf ../feeds/luci/applications/luci-app-passwall*
rm -rf ../feeds/luci/applications/luci-app-mosdns
rm -rf ../feeds/luci/applications/luci-app-dockerman
rm -rf ../feeds/luci/applications/luci-app-bypass*

# 注意：
# 不要删除 package/luci-app-daed 里的 daed / dae
# 只删除 feeds 里的旧 dae 包，避免和 QiuSimons/luci-app-daed 冲突
rm -rf ../feeds/luci/applications/luci-app-dae
rm -rf ../feeds/luci/applications/luci-app-daed
rm -rf ../feeds/packages/net/dae
rm -rf ../feeds/packages/net/daed

#=================================================
# 修复 coremark Makefile
#=================================================
if [ -f "../feeds/packages/utils/coremark/Makefile" ]; then
    sed -i 's/mkdir \$(PKG_BUILD_DIR)\/\$(ARCH)/mkdir -p \$(PKG_BUILD_DIR)\/\$(ARCH)/g' ../feeds/packages/utils/coremark/Makefile
fi

#=================================================
# 显示 DAED 包是否存在
#=================================================
echo " "
echo "==== Check DAED packages ===="
find ./ -maxdepth 4 -type d \( -name "luci-app-daed" -o -name "daed" -o -name "dae" \) -print || true
find ../feeds/packages ../feeds/luci -maxdepth 4 -type d \( -name "luci-app-daed" -o -name "daed" -o -name "dae" \) -print 2>/dev/null || true

echo "==== Packages.sh done ===="
