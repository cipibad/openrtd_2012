#############################################################
#
# phpfm
#
#############################################################
PHPFM_VERSION = 0.9.3
PHPFM_SOURCE = phpFileManager-$(PHPFM_VERSION).zip
PHPFM_SITE = http://sourceforge.net/projects/phpfm/files/phpFileManager/version\ $(PHPFM_VERSION)
PHPFM_INSTALL_STAGING = NO
PHPFM_INSTALL_TARGET = YES
PHPFM_EXTRACT_CMDS = unzip -d $(@D) $(DL_DIR)/$(PHPFM_SOURCE)

define PHPFM_BUILD_CMDS
	echo Nothing to compile
endef

define PHPFM_INSTALL_TARGET_CMDS
	install -D $(@D)/index.php $(TARGET_DIR)/usr/share/www/fm.php
endef

define PHPFM_UNINSTALL_TARGET_CMDS
	rm -f $(TARGET_DIR)/usr/share/www/fm.php
endef

define PHPFM_CLEAN_CMDS
	echo Nothing to clean
endef


$(eval $(call GENTARGETS))

