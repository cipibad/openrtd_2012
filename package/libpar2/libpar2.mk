
#############################################################
#
# libpar2
#
#############################################################

LIBPAR2_VERSION = 0.2
LIBPAR2_SOURCE = libpar2-$(LIBPAR2_VERSION).tar.gz
LIBPAR2_SITE = http://downloads.sourceforge.net/project/parchive/libpar2/$(LIBPAR2_VERSION)

LIBPAR2_INSTALL_TARGET = YES
LIBPAR2_INSTALL_STAGING = YES
LIBPAR2_DEPENDENCIES = libsigc
LIBPAR2_CONF_ENV = LDFLAGS+="-L$(STAGING_DIR)/usr/lib"

$(eval $(call AUTOTARGETS))
