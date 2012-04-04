#############################################################
#
# libksba
#
#############################################################


LIBKSBA_VERSION = 1.2.0
LIBKSBA_SOURCE = libksba-$(LIBKSBA_VERSION).tar.bz2
LIBKSBA_SITE = ftp://ftp.gnupg.org/gcrypt/libksba/

LIBKSBA_CONF_OPT = --with-gpg-error-prefix=${STAGING_DIR}/usr
LIBKSBA_CONF_ENV += CFLAGS=-I$(STAGING_DIR)/usr/include/ LDFLAGS=-L$(STAGING_DIR)/usr/lib/
LIBKSBA_INSTALL_STAGING = YES
LIBKSBA_INSTALL_TARGET = NO

$(eval $(call AUTOTARGETS))
