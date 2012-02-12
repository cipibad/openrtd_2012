#############################################################
#
# nzbget
#
#############################################################

NZBGET_VERSION = 0.7.0
NZBGET_SOURCE = nzbget-$(NZBGET_VERSION).tar.gz
NZBGET_SITE = http://sourceforge.net/projects/nzbget/files

NZBGET_INSTALL_TARGET = YES
NZBGET_INSTALL_STAGING = NO
NZBGET_DEPENDENCIES = libxml2 libsigc #libpar2
NZBGET_CONF_ENV  = LDFLAGS+="-L$(STAGING_DIR)/usr/lib"
#NZBGET_CONF_ENV += CPPFLAGS+="-I$(TARGET_DIR)/usr/include"
#--disable-parcheck
NZBGET_CONF_OPT =  --with-libcurses_includes=$(STAGING_DIR)/usr/include --with-libpar2_includes=$(STAGING_DIR)/usr/include --with-openssl_includes=$(STAGING_DIR)/usr/include --with-tlslib=OpenSSL --with-openssl_libraries="$(STAGING_DIR)/usr/lib -lssl -lcrypto"

#--oldincludedir=$(TARGET_DIR)/usr/include
#--with-libpar2-includes=$(TARGET_DIR)/usr/include --with-libpar2-libraries="-L$(TARGET_DIR)/usr/lib -lpar2"
$(eval $(call AUTOTARGETS))

