#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/immortalwrt/immortalwrt / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.::0:99999:7:::/g' package/base-files/files/etc/shadow

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='immortalwrt'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
sed -i 's/192.168.1.1/192.168.1.3/g' package/base-files/files/bin/config_generate
#
# ------------------------------- Main source ends -------------------------------

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}

cp -rf $GITHUB_WORKSPACE/general/brook package/brook
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/chinadns-ng
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/tcping
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/trojan-go
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/trojan-plus
#svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-app-filebrowser package/luci-app-filebrowser
#svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/filebrowser package/filebrowser
#svn co https://github.com/project-openwrt/openwrt/trunk/package/lienol/luci-app-fileassistant package/luci-app-fileassistant
merge_package https://github.com/xiaorouji/openwrt-passwall openwrt-passwall/luci-app-passwall
merge_package https://github.com/xiaorouji/openwrt-passwall2 openwrt-passwall2/luci-app-passwall2
#cp -rf $GITHUB_WORKSPACE/general/luci-app-passwall package/luci-app-passwall
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/shadowsocks-rust
#svn co https://github.com/fw876/helloworld/trunk/shadowsocks-rust package/shadowsocks-rust
#svn co https://github.com/xiaorouji/openwrt-passwall-packages/trunk/xray-core package/xray-core
#svn co https://github.com/xiaorouji/openwrt-passwall-packages/trunk/xray-plugin package/xray-plugin
merge_package https://github.com/fw876/helloworld helloworld/luci-app-ssr-plus
rm -rf feeds/packages/net/naiveproxy
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/naiveproxy
merge_package https://github.com/fw876/helloworld helloworld/redsocks2
merge_package https://github.com/rufengsuixing/luci-app-adguardhome luci-app-adguardhome
merge_package https://github.com/Lienol/openwrt-package openwrt-package/luci-app-filebrowser
merge_package https://github.com/Lienol/openwrt-package openwrt-package/luci-app-ssr-mudb-server
merge_package https://github.com/kiddin9/openwrt-packages openwrt-packages/luci-app-speederv2
cp -rf $GITHUB_WORKSPACE/general/xray-core package/xray-core
cp -rf $GITHUB_WORKSPACE/general/xray-plugin package/xray-plugin
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/ssocks
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/dns2socks
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/ipt2socks
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/microsocks 
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/pdnsd-alt
#svn co https://github.com/xiaorouji/openwrt-passwall-packages/trunk/shadowsocksr-libev package/shadowsocksr-libev
#svn co https://github.com/fw876/helloworld/trunk/shadowsocksr-libev package/shadowsocksr-libev
merge_package https://github.com/fw876/helloworld helloworld/shadowsocksr-libev
#svn co https://github.com/fw876/helloworld/trunk/lua-neturl package/lua-neturl
merge_package https://github.com/fw876/helloworld helloworld/lua-neturl
#svn co https://github.com/fw876/helloworld/trunk/tcping package/tcping
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/v2ray-core
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/v2ray-plugin
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/v2ray-geodata
#svn co https://github.com/fw876/helloworld/trunk/v2ray-plugin package/v2ray-plugin
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/simple-obfs
#svn co https://github.com/xiaorouji/openwrt-passwall-packages/trunk/kcptun package/kcptun
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/trojan
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/hysteria
#svn co https://github.com/xiaorouji/openwrt-passwall-packages/trunk/dns2tcp package/dns2tcp
#merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/sing-box

merge_package https://github.com/fw876/helloworld helloworld/shadow-tls
merge_package https://github.com/fw876/helloworld helloworld/tuic-client
merge_package https://github.com/fw876/helloworld helloworld/dns2tcp

cp -rf $GITHUB_WORKSPACE/general/shadowsocks-rust package/shadowsocks-rust

rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
git clone -b v5-lua https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
merge_package https://github.com/sbwml/luci-app-mosdns luci-app-mosdns/mosdns

rm -rf feeds/packages/devel/gn

# ------------------------------- Other started -------------------------------
#
# Add luci-app-amlogic
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
#
# Apply patch
# git apply ../config/patches/{0001*,0002*}.patch --directory=feeds/luci
#
# ------------------------------- Other ends -------------------------------

./scripts/feeds update -a
./scripts/feeds install -a