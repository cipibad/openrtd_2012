#############################################################
#
# which
#
#############################################################
WHICH_VERSION:=2.19
WHICH_SOURCE:=which-$(WHICH_VERSION).tar.gz
WHICH_SITE:=http://www.xs4all.nl/~carlo17/which/
WHICH_DIR:=$(BUILD_DIR)/which-$(WHICH_VERSION)
WHICH_CAT:=$(ZCAT)
WHICH_BINARY:=which
WHICH_TARGET_BINARY:=bin/which

$(DL_DIR)/$(WHICH_SOURCE):
	$(WGET) -P $(DL_DIR) $(WHICH_SITE)/$(WHICH_SOURCE)

which-source: $(DL_DIR)/$(WHICH_SOURCE)

$(WHICH_DIR)/.unpacked: $(DL_DIR)/$(WHICH_SOURCE)
	$(WHICH_CAT) $(DL_DIR)/$(WHICH_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	$(CONFIG_UPDATE) $(WHICH_DIR)
	touch $@

$(WHICH_DIR)/.configured: $(WHICH_DIR)/.unpacked
	(cd $(WHICH_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/ \
	)
	touch $@

$(WHICH_DIR)/$(WHICH_BINARY): $(WHICH_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(WHICH_DIR)

$(TARGET_DIR)/$(WHICH_TARGET_BINARY): $(WHICH_DIR)/$(WHICH_BINARY)
	install -D $^ $@
	$(STRIPCMD) $(STRIP_STRIP_ALL) $@

which: uclibc $(TARGET_DIR)/$(WHICH_TARGET_BINARY)

which-clean:
	rm -f $(TARGET_DIR)/$(WHICH_TARGET_BINARY)
	-$(MAKE) -C $(WHICH_DIR) clean

which-dirclean:
	rm -rf $(WHICH_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(strip $(BR2_PACKAGE_WHICH)),y)
TARGETS+=which
endif
