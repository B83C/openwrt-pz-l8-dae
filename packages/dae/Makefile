
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# Prebuilt-binary package: dae v2.0.0 linux-arm64 from daeuniverse releases.
# The binary is static (cgo-free) and validated to run on the qualcommax
# ipq50xx kernel (musl, aarch64).

include $(TOPDIR)/rules.mk

PKG_NAME:=dae
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-linux-arm64.tar.xz
PKG_SOURCE_URL:=https://github.com/daeuniverse/$(PKG_NAME)/releases/download/v$(PKG_VERSION)
PKG_HASH:=d258548db62870c4ec5bcfc4deff2c64f2be24c3e06dc49767d3fec541bec976

PKG_MAINTAINER:=PZ-L8 OpenWrt build
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKGARCH:=aarch64_generic
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	xzcat $(DL_DIR)/$(PKG_SOURCE) | $(TAR) -C $(PKG_BUILD_DIR) -xf -
endef

define Build/Compile
endef

define Package/dae
  SECTION:=net
  CATEGORY:=Network
  TITLE:=eBPF-based transparent proxy and traffic splitter
  URL:=https://github.com/daeuniverse/dae
  DEPENDS:=@(aarch64||x86_64) +kmod-veth
endef

define Package/dae/description
  dae means goose. It is a Linux high-performance transparent proxy
  solution based on eBPF. Requires kernel with BPF/BTF/veth support.
endef

define Package/dae/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/bin/dae $(1)/usr/bin/dae
	$(INSTALL_DIR) $(1)/etc/dae
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/etc/dae/example.dae $(1)/etc/dae/config.dae
	$(INSTALL_DIR) $(1)/usr/share/dae
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/share/dae/geoip.dat $(1)/usr/share/dae/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/usr/share/dae/geosite.dat $(1)/usr/share/dae/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dae.init $(1)/etc/init.d/dae
endef

$(eval $(call BuildPackage,dae))
