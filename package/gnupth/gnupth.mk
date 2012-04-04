#############################################################
#
# gnupth
#
#############################################################

GNUPTH_VERSION = 2.0.7
GNUPTH_SOURCE = pth-$(GNUPTH_VERSION).tar.gz
GNUPTH_SITE = ftp://ftp.gnu.org/gnu/pth
GNUPTH_AUTORECONF = NO
GNUPTH_INSTALL_STAGING = YES
GNUPTH_INSTALL_TARGET = YES


define GNUPTH_STAGING_PTH_CONFIG_FIXUP
	$(SED) "s,^prefix=.*,prefix=\'$(STAGING_DIR)/usr\',g" $(STAGING_DIR)/usr/bin/pth-config
	$(SED) "s,^exec_prefix=.*,exec_prefix=\'$(STAGING_DIR)/usr\',g" $(STAGING_DIR)/usr/bin/pth-config
endef


GNUPTH_POST_INSTALL_STAGING_HOOKS += GNUPTH_STAGING_PTH_CONFIG_FIXUP

$(eval $(call AUTOTARGETS))
