#############################################################
#
# opkg
#
#############################################################

OPKG_VERSION = 0.1.8
OPKG_SOURCE = opkg-$(OPKG_VERSION).tar.gz
OPKG_SITE = http://opkg.googlecode.com/files
OPKG_INSTALL_STAGING = NO
OPKG_INSTALL_TARGET = YES


#OPKG_CONF_OPT = 	--with-gpgme-prefix=${STAGING_DIR}/usr
OPKG_CONF_ENV = ac_cv_path_GPGME_CONFIG=${STAGING_DIR}/usr/bin/gpgme-config \
		CFLAGS=-I$(STAGING_DIR)/usr/include/ LDFLAGS=-L$(STAGING_DIR)/usr/lib/

$(eval $(call AUTOTARGETS))
