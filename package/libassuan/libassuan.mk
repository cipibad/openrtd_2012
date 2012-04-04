#############################################################
#
# libassuan
#
#############################################################


LIBASSUAN_VERSION = 2.0.3
LIBASSUAN_SOURCE = libassuan-$(LIBASSUAN_VERSION).tar.bz2
LIBASSUAN_SITE = ftp://ftp.gnupg.org/gcrypt/libassuan/

LIBASSUAN_CONF_OPT = --with-gpg-error-prefix=${STAGING_DIR}/usr
LIBASSUAN_CONF_ENV += CFLAGS=-I$(STAGING_DIR)/usr/include/ LDFLAGS=-L$(STAGING_DIR)/usr/lib/
LIBASSUAN_INSTALL_STAGING = YES
LIBASSUAN_INSTALL_TARGET = NO

$(eval $(call AUTOTARGETS))
