#############################################################
#
# unrar
#
#############################################################
UNRAR_VERSION = 4.1.4
UNRAR_SOURCE = unrarsrc-$(UNRAR_VERSION).tar.gz
UNRAR_SITE = http://www.rarlab.com/rar
UNRAR_INSTALL_STAGING = NO
UNRAR_INSTALL_TARGET = YES
define UNRAR_BUILD_CMDS
	$(MAKE) -C $(@D) -f makefile.unix CXX="$(TARGET_CXX)" STRIP="$(TARGET_STRIP)"
endef

define UNRAR_INSTALL_TARGET_CMDS
	install -D $(@D)/unrar $(TARGET_DIR)/usr/bin/unrar
endef

define UNRAR_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/bin/unrar
endef

define UNRAR_CLEAN_CMDS
	$(MAKE) -C $(@D) -f makefile.unix clean
endef


$(eval $(call GENTARGETS))

