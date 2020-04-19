ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

SUBPROJECTS  += gawk
DOWNLOAD     += https://ftp.gnu.org/gnu/gawk/gawk-$(GAWK_VERSION).tar.xz{,.sig}
GAWK_VERSION := 5.1.0
DEB_GAWK_V   ?= $(GAWK_VERSION)

gawk-setup: setup
	$(call PGP_VERIFY,gawk-$(GAWK_VERSION).tar.xz)
	$(call EXTRACT_TAR,gawk-$(GAWK_VERSION).tar.xz,gawk-$(GAWK_VERSION),gawk)

ifneq ($(wildcard $(BUILD_WORK)/gawk/.build_complete),)
gawk:
	@echo "Using previously built gawk."
else
gawk: gawk-setup
	cd $(BUILD_WORK)/gawk && ./configure \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr
	+$(MAKE) -C $(BUILD_WORK)/gawk install \
		DESTDIR=$(BUILD_STAGE)/gawk
	rm -f $(BUILD_STAGE)/gawk/usr/bin/gawk-*
	touch $(BUILD_WORK)/gawk/.build_complete
endif

gawk-package: gawk-stage
	# gawk.mk Package Structure
	rm -rf $(BUILD_DIST)/gawk
	
	# gawk.mk Prep gawk
	cp -a $(BUILD_STAGE)/gawk $(BUILD_DIST)
	
	# gawk.mk Sign
	$(call SIGN,gawk,general.xml)
	
	# gawk.mk Make .debs
	$(call PACK,gawk,DEB_GAWK_V)
	
	# gawk.mk Build cleanup
	rm -rf $(BUILD_DIST)/gawk

.PHONY: gawk gawk-package
