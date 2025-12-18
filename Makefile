include $(TOPDIR)/rules.mk

PKG_NAME:=dnscrypt-proxy2
PKG_VERSION:=2.1.15
PKG_RELEASE:=1

PKG_MAINTAINER:=Your Name <your@email.com>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/dnscrypt/dnscrypt-proxy
GO_PKG_BUILD_PKG:=$(GO_PKG)/dnscrypt-proxy

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

GO_PKG_LDFLAGS:=-s -w

define Package/dnscrypt-proxy2
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Flexible DNS proxy with support for encrypted DNS protocols
  URL:=https://dnscrypt.info/
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/dnscrypt-proxy2/description
  A flexible DNS proxy with support for modern encrypted DNS protocols
  including DNSCrypt v2, DNS-over-HTTPS and Anonymized DNSCrypt.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) -r ./* $(PKG_BUILD_DIR)/
	rm -f $(PKG_BUILD_DIR)/Makefile
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
		GOOS=linux \
		GOARCH=arm64 \
		GOARM= \
		CGO_ENABLED=0 \
		$(GO_BIN) build -v \
			-mod=vendor \
			-trimpath \
			-ldflags="$(GO_PKG_LDFLAGS)" \
			-o $(PKG_BUILD_DIR)/dnscrypt-proxy-bin \
			./dnscrypt-proxy
endef

define Package/dnscrypt-proxy2/conffiles
/etc/dnscrypt-proxy2/dnscrypt-proxy.toml
endef

define Package/dnscrypt-proxy2/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnscrypt-proxy-bin $(1)/usr/sbin/dnscrypt-proxy2
	
	$(INSTALL_DIR) $(1)/etc/dnscrypt-proxy2
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/example-dnscrypt-proxy.toml \
		$(1)/etc/dnscrypt-proxy2/dnscrypt-proxy.toml
endef

$(eval $(call BuildPackage,dnscrypt-proxy2))
