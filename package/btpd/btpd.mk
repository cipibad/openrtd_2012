#############################################################
#
# btpd
#
#############################################################
BTPD_VERSION = 0.16
BTPD_SOURCE = btpd-$(BTPD_VERSION).tar.gz
BTPD_SITE = https://github.com/downloads/btpd/btpd
BTPD_INSTALL_STAGING = NO
BTPD_INSTALL_TARGET = YES
BTPD_CONF_ENV += CFLAGS+=-I$(TARGET_DIR)/usr/include LDFLAGS+=-L$(TARGET_DIR)/usr/lib
#BTPD_CONF_ENV = CFLAGS=-I$(TARGET_DIR)/usr/include LDFLAGS="$(TARGET_LDFLAGS)"
#BTPD_CONF_OPT =
BTPD_DEPENDENCIES = openssl

$(eval $(call AUTOTARGETS))

