#############################################################
#
# gpgme
#
#############################################################

GPGME_DEPENDENCIES = libgpg-error libassuan gpg
GPGME_VERSION = 1.3.1
GPGME_SOURCE = gpgme-$(GPGME_VERSION).tar.bz2
GPGME_SITE = ftp://ftp.gnupg.org/gcrypt/gpgme/

GPGME_CONF_OPT = 	--with-gpg-error-prefix=${STAGING_DIR}/usr \
			--with-libassuan-prefix=${STAGING_DIR}/usr \
			\
			--with-gpg=${STAGING_DIR}/usr \
			--with-gpgsm=${STAGING_DIR}/usr \
			--with-gpgconf=${STAGING_DIR}/usr \
			--with-g13=${STAGING_DIR}/usr

GPGME_CONF_ENV += CFLAGS=-I$(STAGING_DIR)/usr/include/ LDFLAGS=-L$(STAGING_DIR)/usr/lib/
GPGME_INSTALL_STAGING = YES
GPGME_INSTALL_TARGET = NO

$(eval $(call AUTOTARGETS))
