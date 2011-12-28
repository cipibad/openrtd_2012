#############################################################
#
# Build the rtdimg root filesystem image
#
#############################################################

ifeq ($(BR2_TARGET_ROOTFS_RTDIMG_PLAYER_EBODA_HD_FOR_ALL_500_MINI),y)
#set default params
endif

ifeq ($(BR2_TARGET_ROOTFS_RTDIMG_PLAYER_CUSTOM),y)
#read other params here
endif

define ROOTFS_RTDIMG_CMD
	echo ERROR && exit 20

##	$(SCRIPT) $(ARGS) -d $(TARGET_DIR) -o $$@ (image)

$(eval $(call ROOTFS_TARGET,rtdimg))
