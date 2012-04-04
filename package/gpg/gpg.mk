#############################################################
#
# gpg
#
#############################################################

GPG_DEPENDENCIES = libgcrypt libksba gnupth
GPG_VERSION = 2.0.19
GPG_SOURCE = gnupg-$(GPG_VERSION).tar.bz2
GPG_SITE = http://ftp.gnupg.org/gcrypt/gnupg/

GPG_CONF_OPT =  --with-gpg-error-prefix=${STAGING_DIR}/usr \
		--with-libassuan-prefix=${STAGING_DIR}/usr \
		--with-libgcrypt-prefix=${STAGING_DIR}/usr \
		--with-ksba-prefix=${STAGING_DIR}/usr \
		--with-pth-prefix=${STAGING_DIR}/usr 
GPG_CONF_ENV += CFLAGS=-I$(STAGING_DIR)/usr/include/ LDFLAGS=-L$(STAGING_DIR)/usr/lib/
GPG_INSTALL_STAGING = YES
GPG_INSTALL_TARGET = NO



$(eval $(call AUTOTARGETS))
