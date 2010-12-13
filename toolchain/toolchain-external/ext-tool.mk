
#
# This file implements the support for external toolchains, i.e
# toolchains that have not been produced by Buildroot itself and that
# Buildroot can download from the Web or that are already available on
# the system on which Buildroot runs. So far, we have tested this
# with:
#
#  * Toolchains generated by Crosstool-NG
#  * Toolchains generated by Buildroot
#  * ARM, MIPS and PowerPC toolchains made available by
#    Codesourcery. For the MIPS toolchain, the -muclibc variant isn't
#    supported yet, only the default glibc-based variant is.
#
# The basic principle is the following
#
#  1. a. For toolchains downloaded from the Web, Buildroot already
#  knows their configuration, so it just downloads them and extract
#  them in $(TOOLCHAIN_EXTERNAL_DIR).
#
#  1. b. For pre-installed toolchains, perform some checks on the
#  conformity between the toolchain configuration described in the
#  Buildroot menuconfig system, and the real configuration of the
#  external toolchain. This is for example important to make sure that
#  the Buildroot configuration system knows whether the toolchain
#  supports RPC, IPv6, locales, large files, etc. Unfortunately, these
#  things cannot be detected automatically, since the value of these
#  options (such as BR2_INET_RPC) are needed at configuration time
#  because these options are used as dependencies for other
#  options. And at configuration time, we are not able to retrieve the
#  external toolchain configuration.
#
#  2. Copy the libraries needed at runtime to the target directory,
#  $(TARGET_DIR). Obviously, things such as the C library, the dynamic
#  loader and a few other utility libraries are needed if dynamic
#  applications are to be executed on the target system.
#
#  3. Copy the libraries and headers to the staging directory. This
#  will allow all further calls to gcc to be made using --sysroot
#  $(STAGING_DIR), which greatly simplifies the compilation of the
#  packages when using external toolchains. So in the end, only the
#  cross-compiler binaries remains external, all libraries and headers
#  are imported into the Buildroot tree.

uclibc: dependencies $(STAMP_DIR)/ext-toolchain-installed

LIB_EXTERNAL_LIBS=ld*.so libc.so libcrypt.so libdl.so libgcc_s.so libm.so libnsl.so libresolv.so librt.so libutil.so
ifeq ($(BR2_TOOLCHAIN_EXTERNAL_GLIBC),y)
LIB_EXTERNAL_LIBS+=libnss_files.so libnss_dns.so
endif

ifeq ($(BR2_INSTALL_LIBSTDCPP),y)
USR_LIB_EXTERNAL_LIBS+=libstdc++.so
endif

ifneq ($(BR2_PTHREADS_NONE),y)
LIB_EXTERNAL_LIBS+=libpthread.so
ifeq ($(BR2_PACKAGE_GDB_SERVER),y)
LIB_EXTERNAL_LIBS+=libthread_db.so
endif # gdbserver
endif # ! no threads

# Details about sysroot directory selection.
#
# To find the sysroot directory:
#
#  * We first try the -print-sysroot option, available in gcc 4.4.x
#    and in some Codesourcery toolchains.
#
#  * If this option is not available, we fallback to the value of
#    --with-sysroot as visible in CROSS-gcc -v.
#
# When doing those tests, we don't pass any option to gcc that could
# select a multilib variant (such as -march) as we want the "main"
# sysroot, which contains all variants of the C library in the case of
# multilib toolchains. We use the TARGET_CC_NO_SYSROOT variable, which
# is the path of the cross-compiler, without the
# --sysroot=$(STAGING_DIR), since what we want to find is the location
# of the original toolchain sysroot. This "main" sysroot directory is
# stored in SYSROOT_DIR.
#
# Then, multilib toolchains are a little bit more complicated, since
# they in fact have multiple sysroots, one for each variant supported
# by the toolchain. So we need to find the particular sysroot we're
# interested in.
#
# To do so, we ask the compiler where its sysroot is by passing all
# flags (including -march and al.), except the --sysroot flag since we
# want to the compiler to tell us where its original sysroot
# is. ARCH_SUBDIR will contain the subdirectory, in the main
# SYSROOT_DIR, that corresponds to the selected architecture
# variant. ARCH_SYSROOT_DIR will contain the full path to this
# location.
#
# One might wonder why we don't just bother with ARCH_SYSROOT_DIR. The
# fact is that in multilib toolchains, the header files are often only
# present in the main sysroot, and only the libraries are available in
# each variant-specific sysroot directory.

TARGET_CC_NO_SYSROOT=$(filter-out --sysroot=%,$(TARGET_CC_NOCCACHE))

ifeq ($(BR2_TOOLCHAIN_EXTERNAL_DOWNLOAD),y)
TOOLCHAIN_EXTERNAL_DEPENDENCIES = $(TOOLCHAIN_EXTERNAL_DIR)/.extracted
else
TOOLCHAIN_EXTERNAL_DEPENDENCIES = $(STAMP_DIR)/ext-toolchain-checked
endif

ifeq ($(BR2_TOOLCHAIN_EXTERNAL_CODESOURCERY_ARM2009Q1),y)
TOOLCHAIN_EXTERNAL_SITE=http://www.codesourcery.com/sgpp/lite/arm/portal/package5383/public/arm-none-linux-gnueabi/
TOOLCHAIN_EXTERNAL_SOURCE=arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
else ifeq ($(BR2_TOOLCHAIN_EXTERNAL_CODESOURCERY_ARM2010Q1),y)
TOOLCHAIN_EXTERNAL_SITE=http://www.codesourcery.com/sgpp/lite/arm/portal/package6488/public/arm-none-linux-gnueabi/
TOOLCHAIN_EXTERNAL_SOURCE=arm-2010q1-202-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
else ifeq ($(BR2_TOOLCHAIN_EXTERNAL_CODESOURCERY_ARM201009),y)
TOOLCHAIN_EXTERNAL_SITE=http://www.codesourcery.com/sgpp/lite/arm/portal/package7851/public/arm-none-linux-gnueabi/
TOOLCHAIN_EXTERNAL_SOURCE=arm-2010.09-50-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
else ifeq ($(BR2_TOOLCHAIN_EXTERNAL_CODESOURCERY_MIPS44),y)
TOOLCHAIN_EXTERNAL_SITE=http://www.codesourcery.com/sgpp/lite/mips/portal/package7401/public/mips-linux-gnu/
TOOLCHAIN_EXTERNAL_SOURCE=mips-4.4-303-mips-linux-gnu-i686-pc-linux-gnu.tar.bz2
else ifeq ($(BR2_TOOLCHAIN_EXTERNAL_CODESOURCERY_POWERPC201009),y)
TOOLCHAIN_EXTERNAL_SITE=http://www.codesourcery.com/sgpp/lite/power/portal/package7703/public/powerpc-linux-gnu/
TOOLCHAIN_EXTERNAL_SOURCE=freescale-2010.09-55-powerpc-linux-gnu-i686-pc-linux-gnu.tar.bz2
else ifeq ($(BR2_TOOLCHAIN_EXTERNAL_CODESOURCERY_SH201009),y)
TOOLCHAIN_EXTERNAL_SITE=http://www.codesourcery.com/sgpp/lite/superh/portal/package7783/public/sh-linux-gnu/
TOOLCHAIN_EXTERNAL_SOURCE=renesas-2010.09-45-sh-linux-gnu-i686-pc-linux-gnu.tar.bz2
else
# A value must be set (even if unused), otherwise the
# $(DL_DIR)/$(TOOLCHAIN_EXTERNAL_SOURCE) rule would override the main
# $(DL_DIR) rule
TOOLCHAIN_EXTERNAL_SOURCE=none
endif

# Download and extraction of a toolchain
$(DL_DIR)/$(TOOLCHAIN_EXTERNAL_SOURCE):
	$(call DOWNLOAD,$(TOOLCHAIN_EXTERNAL_SITE),$(TOOLCHAIN_EXTERNAL_SOURCE))

$(TOOLCHAIN_EXTERNAL_DIR)/.extracted: $(DL_DIR)/$(TOOLCHAIN_EXTERNAL_SOURCE)
	mkdir -p $(@D)
	$(INFLATE$(suffix $(TOOLCHAIN_EXTERNAL_SOURCE))) $^ | $(TAR) $(TAR_STRIP_COMPONENTS)=1 -C $(@D) $(TAR_OPTIONS) -
	touch $@

# Checks for an already installed toolchain: check the toolchain
# location, check that it supports sysroot, and then verify that it
# matches the configuration provided in Buildroot: ABI, C++ support,
# type of C library and all C library features.
$(STAMP_DIR)/ext-toolchain-checked:
	@echo "Checking external toolchain settings"
	$(Q)$(call check_cross_compiler_exists)
	$(Q)SYSROOT_DIR=`$(TARGET_CC_NO_SYSROOT) -print-sysroot 2>/dev/null` ; \
	if test -z "$${SYSROOT_DIR}" ; then \
		SYSROOT_DIR=`readlink -f $$(LANG=C $(TARGET_CC_NO_SYSROOT) -print-file-name=libc.a) |sed -r -e 's:usr/lib/libc\.a::;'` ; \
	fi ; \
	if test -z "$${SYSROOT_DIR}" ; then \
		@echo "External toolchain doesn't support --sysroot. Cannot use." ; \
		exit 1 ; \
	fi ; \
	if test x$(BR2_arm) == x"y" ; then \
		$(call check_arm_abi) ; \
	fi ; \
	if test x$(BR2_INSTALL_LIBSTDCPP) == x"y" ; then \
		$(call check_cplusplus) ; \
	fi ; \
	if test x$(BR2_TOOLCHAIN_EXTERNAL_UCLIBC) == x"y" ; then \
		$(call check_uclibc,$${SYSROOT_DIR}) ; \
	else \
		$(call check_glibc,$${SYSROOT_DIR}) ; \
	fi

# Integration of the toolchain into Buildroot: find the main sysroot
# and the variant-specific sysroot, then copy the needed libraries to
# the $(TARGET_DIR) and copy the whole sysroot (libraries and headers)
# to $(STAGING_DIR).
$(STAMP_DIR)/ext-toolchain-installed: $(TOOLCHAIN_EXTERNAL_DEPENDENCIES)
	$(Q)SYSROOT_DIR=`$(TARGET_CC_NO_SYSROOT) -print-sysroot 2>/dev/null` ; \
	if test -z "$${SYSROOT_DIR}" ; then \
		SYSROOT_DIR=`readlink -f $$(LANG=C $(TARGET_CC_NO_SYSROOT) -print-file-name=libc.a) |sed -r -e 's:usr/lib/libc\.a::;'` ; \
	fi ; \
	if test -z "$${SYSROOT_DIR}" ; then \
		@echo "External toolchain doesn't support --sysroot. Cannot use." ; \
		exit 1 ; \
	fi ; \
	ARCH_SUBDIR=`$(TARGET_CC_NO_SYSROOT) $(TARGET_CFLAGS) -print-multi-directory` ; \
	ARCH_SYSROOT_DIR=$${SYSROOT_DIR}/$${ARCH_SUBDIR} ; \
	mkdir -p $(TARGET_DIR)/lib ; \
	echo "Copy external toolchain libraries to target..." ; \
	for libs in $(LIB_EXTERNAL_LIBS); do \
		$(call copy_toolchain_lib_root,$${ARCH_SYSROOT_DIR},$$libs,/lib); \
	done ; \
	for libs in $(USR_LIB_EXTERNAL_LIBS); do \
		$(call copy_toolchain_lib_root,$${ARCH_SYSROOT_DIR},$$libs,/usr/lib); \
	done ; \
	echo "Copy external toolchain sysroot to staging..." ; \
	$(call copy_toolchain_sysroot,$${SYSROOT_DIR},$${ARCH_SYSROOT_DIR},$${ARCH_SUBDIR}) ; \
	if [ -L $${ARCH_SYSROOT_DIR}/lib64 ] ; then \
		$(call create_lib64_symlinks) ; \
	fi ; \
	touch $@
