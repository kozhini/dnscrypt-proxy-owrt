include $(TOPDIR)/rules.mk

PKG_NAME:=dnscrypt-proxy
PKG_VERSION:=2.1.15
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/DNSCrypt/dnscrypt-proxy/tar.gz/$(PKG_VERSION)
PKG_HASH:=57DA91DD2A3992A1528E764BCFE9B48088C63C933C0C571A2CAC3D27AC8C7546
PKG_SOURCE_PROTO:=https
PKG_SOURCE_VERSION:=$(PKG_VERSION)

PKG_MAINTAINER:=Your Name <your@email.com>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/dnscrypt/dnscrypt-proxy
GO_PKG_BUILD_PKG:=$(GO_PKG)/dnscrypt-proxy

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/dnscrypt-proxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Flexible DNS proxy with support for encrypted DNS protocols
  URL:=https://dnscrypt.info/
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/dnscrypt-proxy/description
  A flexible DNS proxy, with support for modern encrypted DNS protocols
  such as DNSCrypt v2, DNS-over-HTTPS and Anonymized DNSCrypt.
endef

define Package/dnscrypt-proxy/conffiles
/etc/dnscrypt-proxy/dnscrypt-proxy.toml
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
endef

define Package/dnscrypt-proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/dnscrypt-proxy $(1)/usr/sbin/
	
	$(INSTALL_DIR) $(1)/etc/dnscrypt-proxy
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/dnscrypt-proxy/example-dnscrypt-proxy.toml $(1)/etc/dnscrypt-proxy/dnscrypt-proxy.toml
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dnscrypt-proxy.init $(1)/etc/init.d/dnscrypt-proxy
endef

$(eval $(call GoBinPackage,dnscrypt-proxy))
$(eval $(call BuildPackage,dnscrypt-proxy))
