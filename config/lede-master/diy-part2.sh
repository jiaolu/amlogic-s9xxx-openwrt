#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

echo "开始 DIY2 配置……"
echo "========================="

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    # find package/ -follow -name $pkg -not -path "package/custom/*" | xargs -rt rm -rf
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}
function drop_package(){
    find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}
function merge_feed(){
    if [ ! -d "feed/$1" ]; then
        echo >> feeds.conf.default
        echo "src-git $1 $2" >> feeds.conf.default
    fi
    ./scripts/feeds update $1
    ./scripts/feeds install -a -p $1
}
rm -rf package/custom; mkdir package/custom


# BTF: fix failed to validate module
# config/Config-kernel.in patch
curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/master/openwrt/patch/generic/0001-kernel-add-MODULE_ALLOW_BTF_MISMATCH-option.patch | patch -p1
patch -p1 < $GITHUB_WORKSPACE/PATCH/add-xdp-diag.patch
#atch -p1 < $GITHUB_WORKSPACE/PATCH/lede_add_immotalwrt_download_method.patch

# ARM64: Add CPU model name in proc cpuinfo
#wget -P target/linux/generic/pending-5.4 https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.4/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# autocore
sed -i 's/DEPENDS:=@(.*/DEPENDS:=@(TARGET_bcm27xx||TARGET_bcm53xx||TARGET_ipq40xx||TARGET_ipq806x||TARGET_ipq807x||TARGET_mvebu||TARGET_rockchip||TARGET_armvirt) \\/g' package/lean/autocore/Makefile
# Add cputemp.sh
#cp -rf $GITHUB_WORKSPACE/PATCH/new/script/cputemp.sh ./package/base-files/files/bin/cputemp.sh

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

#添加额外软件包
#git clone https://github.com/immortalwrt/luci-app-unblockneteasemusic package/luci-app-unblockneteasemusic
#git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/luci-app-jd-dailybonus
#git clone https://github.com/jerrykuku/lua-maxminddb.git package/lua-maxminddb
merge_package https://github.com/jerrykuku/lua-maxminddb lua-maxminddb
merge_package https://github.com/xiangfeidexiaohuo/extra-ipk extra-ipk/patch/wall-luci/luci-app-vssr
merge_package https://github.com/vernesong/OpenClash OpenClash/luci-app-openclash
#git clone https://github.com/project-lede/luci-app-godproxy package/luci-app-godproxy
merge_package https://github.com/ilxp/luci-app-ikoolproxy luci-app-ikoolproxy
#svn co https://github.com/openwrt/luci/trunk/modules/luci-mod-dashboard feeds/luci/modules/luci-mod-dashboard
#svn co https://github.com/openwrt/packages/trunk/net/openssh package/openssh
#svn co https://github.com/openwrt/packages/trunk/libs/libfido2 package/libfido2
#svn co https://github.com/openwrt/packages/trunk/libs/libcbor package/libcbor
merge_package https://github.com/ophub/luci-app-amlogic luci-app-amlogic
#svn co https://github.com/breakings/OpenWrt/trunk/general/luci-app-cpufreq package/luci-app-cpufreq
#svn co https://github.com/breakings/OpenWrt/trunk/general/ntfs3 package/lean/ntfs3
#svn co https://github.com/Lienol/openwrt-package/trunk/luci-app-socat package/luci-app-socat
merge_package https://github.com/openwrt/openwrt.git openwrt/package/libs/elfutils
#svn co https://github.com/breakings/OpenWrt/trunk/general/gnupg feeds/packages/utils/gnupg
#svn co https://github.com/breakings/OpenWrt/trunk/general/n2n_v2 package/lean/n2n_v2

# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/custom/luci-app-openclash/tools/po2lmo
make && sudo make install
popd
#svn co https://github.com/xiaorouji/openwrt-passwall/trunk/brook package/brook
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
cp -rf $GITHUB_WORKSPACE/general/xray-core package/xray-core
cp -rf $GITHUB_WORKSPACE/general/xray-plugin package/xray-plugin
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/ssocks
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/dns2socks
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/ipt2socks
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/microsocks 
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/pdnsd-alt
merge_package https://github.com/fw876/helloworld helloworld/shadowsocksr-libev
merge_package https://github.com/fw876/helloworld helloworld/lua-neturl
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
cp -rf $GITHUB_WORKSPACE/general/luci-app-gost package/luci-app-gost
cp -rf $GITHUB_WORKSPACE/general/gost package/gost
#svn co https://github.com/kenzok8/openwrt-packages/trunk/gost package/gost
#svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-app-gost package/luci-app-gost
#svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/gost package/gost
merge_package https://github.com/kenzok8/openwrt-packages openwrt-packages/luci-app-eqos
git clone https://github.com/tty228/luci-app-serverchan.git package/luci-app-serverchan
#svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/luci-app-ssr-plus
merge_package https://github.com/fw876/helloworld helloworld/luci-app-ssr-plus
merge_package https://github.com/xiaorouji/openwrt-passwall-packages openwrt-passwall-packages/naiveproxy
merge_package https://github.com/fw876/helloworld helloworld/redsocks2
merge_package https://github.com/rufengsuixing/luci-app-adguardhome luci-app-adguardhome
merge_package https://github.com/Lienol/openwrt-package openwrt-package/luci-app-filebrowser
merge_package https://github.com/Lienol/openwrt-package openwrt-package/luci-app-ssr-mudb-server
merge_package https://github.com/kiddin9/openwrt-packages openwrt-packages/luci-app-speederv2

#添加smartdns
#svn co https://github.com/project-openwrt/openwrt/trunk/package/ntlf9t/smartdns package/smartdns
#svn co https://github.com/project-openwrt/openwrt/trunk/package/ntlf9t/luci-app-smartdns package/luci-app-smartdns
#svn co https://github.com/openwrt/luci/trunk/applications/luci-app-smartdns package/luci-app-smartdns
merge_package https://github.com/kenzok8/openwrt-packages openwrt-packages/luci-app-smartdns

#mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
git clone -b v5-lua https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
merge_package https://github.com/sbwml/luci-app-mosdns luci-app-mosdns/mosdns

#修改bypass的makefile
#git clone https://github.com/garypang13/luci-app-bypass package/luci-app-bypass
#find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-redir/shadowsocksr-libev-alt/g' {}
#find package/*/ feeds/*/ -maxdepth 2 -path "*luci-app-bypass/Makefile" | xargs -i sed -i 's/shadowsocksr-libev-ssr-server/shadowsocksr-libev-server/g' {}
#find package/luci-app-bypass/*/ -maxdepth 8 -path "*" | xargs -i sed -i 's/smartdns-le/smartdns/g' {}

#添加ddnsto
#svn co https://github.com/linkease/ddnsto-openwrt/trunk/ddnsto package/ddnsto
#svn co https://github.com/linkease/ddnsto-openwrt/trunk/luci-app-ddnsto package/luci-app-ddnsto
git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go
#添加udp2raw
#git clone https://github.com/sensec/openwrt-udp2raw package/openwrt-udp2raw
merge_package https://github.com/sensec/openwrt-udp2raw openwrt-udp2raw
#git clone https://github.com/sensec/luci-app-udp2raw package/luci-app-udp2raw
merge_package https://github.com/sensec/luci-app-udp2raw luci-app-udp2raw
sed -i "s/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=f2f90a9a150be94d50af555b53657a2a4309f287/" package/custom/openwrt-udp2raw/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=20200920\.0/" package/custom/openwrt-udp2raw/Makefile

#themes
merge_package https://github.com/rosywrt/luci-theme-rosy luci-theme-rosy
#git clone https://github.com/rosywrt/luci-theme-purple.git package/luci-theme-purple
#git clone https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
merge_package https://github.com/Leo-Jo-My/luci-theme-opentomcat luci-theme-opentomcat
merge_package https://github.com/Leo-Jo-My/luci-theme-opentomato luci-theme-opentomato
#svn co https://github.com/sirpdboy/luci-theme-opentopd/trunk package/luci-theme-opentopd
#git clone https://github.com/kevin-morgan/luci-theme-argon-dark.git package/luci-theme-argon-dark
#svn co https://github.com/kevin-morgan/luci-theme-argon-dark/trunk package/luci-theme-argon-dark
#svn co https://github.com/openwrt/luci/trunk/themes/luci-theme-openwrt-2020 package/luci-theme-openwrt-2020
merge_package https://github.com/thinktip/luci-theme-neobird luci-theme-neobird
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon


# enable multi-channel
sed -i '/workgroup/a \\n\t## enable multi-channel' feeds/packages/net/samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' feeds/packages/net/samba4/files/smb.conf.template
# default config
sed -i 's/#aio read size = 0/aio read size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' feeds/packages/net/samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' feeds/packages/net/samba4/files/smb.conf.template
#sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' feeds/luci/applications/luci-app-samba4/htdocs/luci-static/resources/view/samba4.js
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' feeds/packages/net/samba4/files/smb.conf.template

# ffmpeg
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=5.1.4/g' feeds/packages/multimedia/ffmpeg/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=54383bb890a1cd62580e9f1eaa8081203196ed53bde9e98fb6b0004423f49063/g' feeds/packages/multimedia/ffmpeg/Makefile
# rm -rf feeds/packages/multimedia/ffmpeg
# cp -rf $GITHUB_WORKSPACE/general/ffmpeg feeds/packages/multimedia

# btrfs-progs
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=6.11/g' feeds/packages/utils/btrfs-progs/Makefile
# sed -i 's/PKG_HASH:=.*/PKG_HASH:=ff9ae91521303a90d87e1c4be230f0121f39c44ddbe52c2aeae263c6fecfa099/g' feeds/packages/utils/btrfs-progs/Makefile
# rm -rf feeds/packages/utils/btrfs-progs/patches
#sed -i '68i\	--disable-libudev \\' feeds/packages/utils/btrfs-progs/Makefile

# qBittorrent (use cmake)
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=4.4.0/g' feeds/packages/net/qBittorrent/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=da240744c6cc5953d7c4d298a02a0cf36d2c8897931819f1e6459bd5270a7c5c/g' feeds/packages/net/qBittorrent/Makefile
#sed -i '41i\		+qt5-sql \\' feeds/packages/net/qBittorrent/Makefile
#cp -rf $GITHUB_WORKSPACE/general/qBittorrent/patches feeds/packages/net/qBittorrent
rm -f feeds/packages/net/qBittorrent/Makefile
cp -f $GITHUB_WORKSPACE/general/qBittorrent/Makefile.qt6 feeds/packages/net/qBittorrent/Makefile
#sed -i 's/zh/zh_CN/g' feeds/luci/applications/luci-app-qbittorrent/root/etc/config/qbittorrent

# libtorrent-rasterbar_v2
rm -rf feeds/packages/libs/libtorrent-rasterbar/patches
cp -f $GITHUB_WORKSPACE/general/libtorrent-rasterbar/Makefile feeds/packages/libs/libtorrent-rasterbar

cp -f $GITHUB_WORKSPACE/general/containerd/Makefile feeds/packages/utils/containerd

sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=8.3.12/g' feeds/packages/lang/php8/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=f774e28633e26fc8c5197f4dae58ec9e3ff87d1b4311cbc61ab05a7ad24bd131/g' feeds/packages/lang/php8/Makefile

# python-docker
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=7.1.0/g' feeds/packages/lang/python/python-docker/Makefile
# sed -i 's/PKG_HASH:=.*/PKG_HASH:=eb82c5e3e56209074766e6885bb04b8c38a0c015d0a30036ebe7ece34c9989e9/g' feeds/packages/lang/python/python-docker/Makefile
#cp -f $GITHUB_WORKSPACE/general/python-docker/Makefile feeds/packages/lang/python/python-docker

# coremark
#sed -i 's/PKG_SOURCE_DATE:=.*/PKG_SOURCE_DATE:=2022-07-27/g' feeds/packages/utils/coremark//Makefile
#sed -i 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/utils/coremarkMakefile
#sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=eefc986ebd3452d6adde22eafaff3e5c859f29e4/g' feeds/packages/utils/coremark/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=a5964bf215786d65d08941b6f9a9a4f4e50524f5391fa3826db2994c47d5e7f3/g' feeds/packages/utils/coremark/Makefile

# kcptun
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=20210922/g' package/kcptun/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=f6a08f0fe75fa85d15f9c0c28182c69a5ad909229b4c230a8cbe38f91ba2d038/g' package/kcptun/Makefile

# parted
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=3.6/g' feeds/packages/utils/parted/Makefile
# sed -i 's/PKG_HASH:=.*/PKG_HASH:=3b43dbe33cca0f9a18601ebab56b7852b128ec1a3df3a9b30ccde5e73359e612/g' feeds/packages/utils/parted/Makefile

# wolfSSL
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=5.4.0-stable/g' package/libs/wolfssl/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=dc36cc19dad197253e5c2ecaa490c7eef579ad448706e55d73d79396e814098b/g' package/libs/wolfssl/Makefile
#rm -rf package/libs/wolfssl
#cp -rf $GITHUB_WORKSPACE/general/wolfssl package/libs

# ustream-ssl
#sed -i 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' package/libs/ustream-ssl/Makefile
#sed -i 's/PKG_SOURCE_DATE:=.*/PKG_SOURCE_DATE:=2022-01-16/g' package/libs/ustream-ssl/Makefile
#sed -i 's/PKG_SOURCE_VERSION:=.*/PKG_SOURCE_VERSION:=868fd8812f477c110f9c6c5252c0bd172167b94c/g' package/libs/ustream-ssl/Makefile
#sed -i 's/PKG_MIRROR_HASH:=.*/PKG_MIRROR_HASH:=dd28d5e846b391917cf83d66176653bdfa4e8a0d5b11144b65a012fe7693ddeb/g' package/libs/ustream-ssl/Makefile

# expat
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=2.6.2/g' feeds/packages/libs/expat/Makefile
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=ee14b4c5d8908b1bec37ad937607eab183d4d9806a08adee472c3c3121d27364/g' feeds/packages/libs/expat/Makefile
cp -f $GITHUB_WORKSPACE/general/expat/Makefile feeds/packages/libs/expat

rm -rf feeds/packages/net/openssh
cp -rf $GITHUB_WORKSPACE/general/openssh feeds/packages/net

# nss
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=3.93/g' feeds/packages/libs/nss/Makefile
sed -i 's/PKG_HASH:=.*/PKG_HASH:=15f54bb72048eb105f8c0e936a04b899e74c3db9a19bbc1e00acee2af9476a8a/g' feeds/packages/libs/nss/Makefile


rm -rf feeds/packages/utils/unrar
cp -rf $GITHUB_WORKSPACE/general/unrar feeds/packages/utils

# at
#sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=3.2.2/g' feeds/packages/utils/at/Makefile
#sed -i 's|PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=release/3.2.2|g' feeds/packages/utils/at/Makefile
#sed -i 's/PKG_MIRROR_HASH:=.*/PKG_MIRROR_HASH=93f7f99c4242dbc5218907981e32f74ddb5e09c5b7922617c8d84c16920f488d/g' feeds/packages/utils/at/Makefile
rm -rf feeds/packages/utils/at
cp -rf $GITHUB_WORKSPACE/general/at feeds/packages/utils


# readd cpufreq for aarch64
sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' feeds/luci/applications/luci-app-cpufreq/Makefile
sed -i 's/services/system/g'  feeds/luci/applications/luci-app-cpufreq/luasrc/controller/cpufreq.lua

# luci-app-openvpn
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/controller/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/model/cbi/openvpn.lua
sed -i 's/services/vpn/g'  feeds/luci/applications/luci-app-openvpn/luasrc/view/openvpn/pageswitch.htm

sed -i 's/DEPENDS:=.*/DEPENDS:=@(LINUX_5_4||LINUX_5_10) +kmod-nls-utf8/g' package/lean/ntfs3-oot/Makefile



# alist
merge_package https://github.com/sbwml/luci-app-alist luci-app-alist/alist
git clone -b lua https://github.com/sbwml/luci-app-alist package/luci-app-alist
#sed -i 's/PKG_HASH:=.*/PKG_HASH:=b7d1929d9aef511b263673dba8e5b787f695e1b4fa4555fe562f8060ee0bdea4/g' package/alist/Makefile

# luajit2
merge_package https://github.com/openwrt/packages packages/lang/luajit2

# ymal
# rm -rf feeds/packages/libs/yaml
# merge_package https://github.com/openwrt/packages packages/libs/yaml

# v2raya
merge_package https://github.com/v2rayA/v2raya-openwrt v2raya-openwrt/v2raya
merge_package https://github.com/v2rayA/v2raya-openwrt v2raya-openwrt/luci-app-v2raya

# nqptp
merge_package https://github.com/openwrt/packages packages/net/nqptp

# libnghttp3
merge_package https://github.com/openwrt/packages packages/libs/nghttp3

# ngtcp2
merge_package https://github.com/openwrt/packages packages/libs/ngtcp2


# inih
cp -rf $GITHUB_WORKSPACE/general/inih feeds/packages/libs

# xfsprogs
# rm -rf feeds/packages/utils/xfsprogs
# cp -rf $GITHUB_WORKSPACE/general/xfsprogs feeds/packages/utils

# shadowsocks-rust
cp -rf $GITHUB_WORKSPACE/general/shadowsocks-rust package/shadowsocks-rust

# 晶晨宝盒
sed -i "s|https.*/amlogic-s9xxx-openwrt|https://github.com/breakings/OpenWrt|g" package/custom/luci-app-amlogic/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|http.*/library|https://github.com/breakings/OpenWrt|g" package/custom/luci-app-amlogic/luci-app-amlogic/root/etc/config/amlogic
sed -i "s|s9xxx_lede|ARMv8|g" package/custom/luci-app-amlogic/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|.img.gz|..OPENWRT_SUFFIX|g" package/custom/luci-app-amlogic/luci-app-amlogic/root/etc/config/amlogic

# jq 
# rm -rf feeds/packages/utils/jq
# cp -rf $GITHUB_WORKSPACE/general/jq feeds/packages/utils

# sing-box
cp -rf $GITHUB_WORKSPACE/general/sing-box package/sing-box

# v2dta
sed -i '/CGO_ENABLED=0/{N;d;}' feeds/packages/utils/v2dat/Makefile

# dae
#cp -rf $GITHUB_WORKSPACE/general/dae package/dae
#cp -rf $GITHUB_WORKSPACE/general/luci-app-dae package/luci-app-dae

# dnsmasq
#rm -rf package/network/services/dnsmasq
#cp -rf $GITHUB_WORKSPACE/general/dnsmasq package/network/services

# Optimization level -Ofast
if [ "$platform" = "x86_64" ]; then
    curl -s https://raw.githubusercontent.com/sbwml/r4s_build_script/master/openwrt/patch/target-modify_for_x86_64.patch | patch -p1
fi

# x86 - disable intel_pstate
sed -i 's/noinitrd/noinitrd intel_pstate=disable/g' target/linux/x86/image/grub-efi.cfg

# bash
if [ "$platform" = "x86_64" ]; then
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
fi
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
mkdir -pv files/root
curl -so files/root/.bash_profile https://raw.githubusercontent.com/sbwml/r4s_build_script/master/openwrt/files/root/.bash_profile
curl -so files/root/.bashrc https://raw.githubusercontent.com/sbwml/r4s_build_script/master/openwrt/files/root/.bashrc

# musl patch
# cp -fv $GITHUB_WORKSPACE/PATCH/001-elf.h-add-typedefs-for-Elf-_Relr.patch toolchain/musl/patches

# rm -rf feeds/packages/lang/python
# cp -rf $GITHUB_WORKSPACE/general/python feeds/packages/lang

# rm -rf  feeds/packages/net/uugamebooster
# cp -rf $GITHUB_WORKSPACE/general/uugamebooster feeds/packages/net

rm -rf feeds/packages/utils/lrzsz
cp -rf $GITHUB_WORKSPACE/general/lrzsz feeds/packages/utils

# rm -rf feeds/packages/net/wget
# cp -rf $GITHUB_WORKSPACE/general/wget feeds/packages/net/wget

# liburcu
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=0.14.0/g' feeds/packages/libs/liburcu/Makefile
# sed -i 's/PKG_HASH:=.*/PKG_HASH:=ca43bf261d4d392cff20dfae440836603bf009fce24fdc9b2697d837a2239d4f/g' feeds/packages/libs/liburcu/Makefile
# 
# # afalg_engine
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:=1.2.1/g' feeds/packages/libs/afalg_engine/Makefile
# sed -i 's/PKG_RELEASE:=.*/PKG_RELEASE:=1/g' feeds/packages/libs/afalg_engine/Makefile
# sed -i 's/PKG_HASH:=.*/PKG_HASH:=3f0f6ee9ea7a5ea9c668ec16f8c492aa024a82dca78d0fbe30fd256f9da95d65/g' feeds/packages/libs/afalg_engine/Makefile

./scripts/feeds update -a
./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"