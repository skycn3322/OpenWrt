#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件
# 自行拉取插件之前请SSH连接进入固件配置里面确认过没有你要的插件再单独拉取你需要的插件
# 不要一下就拉取别人一个插件包N多插件的，多了没用，增加编译错误，自己需要的才好
# 修改IP项的EOF于EOF之间请不要插入其他扩展代码，可以删除或注释里面原本的代码




cat >$NETIP <<-EOF
uci set network.lan.ipaddr='192.168.2.2'                                    # IPv4 地址(openwrt后台地址)
uci set network.lan.netmask='255.255.255.0'                                 # IPv4 子网掩码
uci set network.lan.gateway='192.168.2.1'                                   # IPv4 网关
uci set network.lan.broadcast='192.168.2.255'                               # IPv4 广播
uci set network.lan.dns='223.5.5.5'                                         # DNS(多个DNS要用空格分开)
uci set network.lan.delegate='0'                                            # 去掉LAN口使用内置的 IPv6 管理
uci commit network                                                          # 不要删除跟注释,除非上面全部删除或注释掉了
#uci set dhcp.lan.ignore='1'                                                # 关闭DHCP功能
#uci commit dhcp                                                            # 跟‘关闭DHCP功能’联动,同时启用或者删除跟注释
uci set system.@system[0].hostname='OpenWrt'                             # 修改主机名称为Phicomm-N1
EOF


sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile           # 选择argon为默认主题

sed -i "s/OpenWrt /jellyfin Compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" $ZZZ          # 增加个性名字${Author}默认为你的github账号

sed -i '/CYXluq4wUazHjmCDBCqXF/d' $ZZZ                                                            # 设置密码为空

#sed -i 's/PATCHVER:=5.4/PATCHVER:=5.10/g' target/linux/armvirt/Makefile                          # 默认内核5.4，修改内核为5.10


# 设置打包固件的机型，内核组合（请看说明）
cat >$GITHUB_WORKSPACE/amlogic_openwrt <<-EOF
amlogic_model=s905x3_s905x2_s905x_s905d_s922x_s912
amlogic_kernel=5.12.12_5.4.127
rootfs_size=1024
EOF
# 修复NTFS格式优盘不自动挂载
packages=" \
brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio kmod-brcmfmac wpad \
kmod-fs-ext4 kmod-fs-vfat kmod-fs-exfat dosfstools e2fsprogs ntfs-3g \
kmod-usb2 kmod-usb3 kmod-usb-storage kmod-usb-storage-extras kmod-usb-storage-uas \
kmod-usb-net kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152 \
blkid lsblk parted fdisk cfdisk losetup resize2fs tune2fs pv unzip \
lscpu htop iperf3 curl lm-sensors python3 luci-app-amlogic
"
sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' \
    target/linux/armvirt/Makefile
for x in $packages; do
    sed -i "/DEFAULT_PACKAGES/ s/$/ $x/" target/linux/armvirt/Makefile
done

# luci-app-cpufreq修改一些代码适配amlogic
sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
# luci-app-adguardhome
rm -rf ./feeds/luci/applications/luci-app-adguardhome
git clone https://github.com/skycn3322/luci-app-adguardhome.git package/adguardhome
git clone --depth=1 -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
git clone https://github.com/brvphoenix/luci-app-wrtbwmon.git package/luci-app-wrtbwmon
# 为 armvirt 添加 autocore 支持
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile
# 增加防火墙规则
echo "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> package/network/config/firewall/files/firewall.user
# 删除默认插件
rm -rf ./feeds/luci/applications/luci-app-upnp
rm -rf ./feeds/luci/applications/luci-app-wol
rm -rf ././package/lean/vlmcsd
rm -rf ./package/lean/luci-app-vlmcsd
rm -rf ./package/lean/vsftpd-alt
rm -rf ./package/lean/luci-app-vsftpd
rm -rf ./package/lean/luci-app-dockerman        # 删除大雕docker
rm -rf ./package/lean/luci-lib-docker           # 删除大雕docker

# 修改插件名字
sed -i 's/"aMule设置"/"电驴下载"/g' `grep "aMule设置" -rl ./`
sed -i 's/"网络存储"/"存储"/g' `grep "网络存储" -rl ./`
sed -i 's/"Turbo ACC 网络加速"/"网络加速"/g' `grep "Turbo ACC 网络加速" -rl ./`
sed -i 's/"实时流量监测"/"流量"/g' `grep "实时流量监测" -rl ./`
sed -i 's/"KMS 服务器"/"KMS激活"/g' `grep "KMS 服务器" -rl ./`
sed -i 's/"TTYD 终端"/"shell终端"/g' `grep "TTYD 终端" -rl ./`
sed -i 's/"USB 打印服务器"/"网络打印"/g' `grep "USB 打印服务器" -rl ./`
sed -i 's/"Web 管理"/"Web管理"/g' `grep "Web 管理" -rl ./`
sed -i 's/"管理权"/"改密码"/g' `grep "管理权" -rl ./`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./`
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./`
