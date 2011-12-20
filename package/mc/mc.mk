#############################################################
#
# mc
#
#############################################################
MC_VERSION = 4.6.1
MC_SOURCE = mc-$(MC_VERSION).tar.gz
MC_SITE = http://ftp.gnu.org/gnu/mc
MC_INSTALL_STAGING = NO
MC_INSTALL_TARGET = YES
MC_CONF_ENV += LDFLAGS+=-L$(TARGET_DIR)/usr/lib

MC_DEPENDENCIES = ncurses


$(eval $(call AUTOTARGETS,package,mc))

