#############################################################
#
# dtach
#
#############################################################
DTACH_VERSION = 0.8
DTACH_SOURCE = dtach-$(DTACH_VERSION).tar.gz
DTACH_SITE = http://downloads.sourceforge.net/project/dtach/dtach/$(DTACH_VERSION)
DTACH_INSTALL_STAGING = NO
DTACH_INSTALL_TARGET = YES
#DTACH_CONF_ENV += CFLAGS+=-I$(TARGET_DIR)/usr/include LDFLAGS+=-L$(TARGET_DIR)/usr/lib
#DTACH_CONF_ENV = CFLAGS=-I$(TARGET_DIR)/usr/include LDFLAGS="$(TARGET_LDFLAGS)"
#DTACH_CONF_OPT =
#DTACH_DEPENDENCIES = openssl

$(eval $(call AUTOTARGETS,package,dtach))

