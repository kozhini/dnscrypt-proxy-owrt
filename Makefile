include $(TOPDIR)/rules.mk

PKG_NAME:=dnscrypt-proxy
PKG_VERSION:=2.1.15
PKG_RELEASE:=1

# Эти переменные не важны для локальной сборки, но нужны для структуры
PKG_MAINTAINER:=Your Name <your@email.com>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/dnscrypt/dnscrypt-proxy
GO_PKG_BUILD_PKG:=$(GO_PKG)/dnscrypt-proxy

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

GO_VERSION:=1.25.5
GO_PKG_LDFLAGS:=-linkmode internal -s -w

define Package/dnscrypt-proxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Flexible DNS proxy with support for encrypted DNS protocols
  URL:=https://dnscrypt.info/
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

# ПРИНУДИТЕЛЬНАЯ СБОРКА ИЗ ЛОКАЛЬНЫХ ИСХОДНИКОВ
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./dnscrypt-proxy* $(PKG_BUILD_DIR)/
	$(CP) ./go.* $(PKG_BUILD_DIR)/
	$(CP) ./vendor $(PKG_BUILD_DIR)/ || true
endef

define Build/Compile
	(cd $(PKG_BUILD_DIR); \
		GOOS=linux \
		GOARCH=$(GO_ARCH) \
		GOROOT=$(GOROOT) \
		CGO_ENABLED=0 \
		$(GO_BIN) build -v \
			-ldflags="$(GO_PKG_LDFLAGS)" \
			-o $(GO_PKG_BUILD_BIN_DIR)/dnscrypt-proxy \
			./dnscrypt-proxy \
	)
endef

define Package/dnscrypt-proxy/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/dnscrypt-proxy $(1)/usr/sbin/
	
	$(INSTALL_DIR) $(1)/etc/dnscrypt-proxy
	# Ищем конфиг в локальных исходниках
	[ -f $(PKG_BUILD_DIR)/dnscrypt-proxy/example-dnscrypt-proxy.toml ] && \
		$(INSTALL_CONF) $(PKG_BUILD_DIR)/dnscrypt-proxy/example-dnscrypt-proxy.toml $(1)/etc/dnscrypt-proxy/dnscrypt-proxy.toml || true
endef

$(eval $(call BuildPackage,dnscrypt-proxy))
